def APP_URL = ''
def ECR_FRONTEND = ''
def ECR_BACKEND = ''
def S3_BUCKET_NAME = ''
pipeline{
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        app_admin_pwd = credentials('ShopSphere_App_Admin_Password')
        Flask_Secret = credentials('Flask_Secret')
        TF_TOKEN_app_terraform_io = credentials('tfc-token')
        TF_VAR_db_pwd = credentials('aws_eks_proj_db_password')
        TF_VAR_default_region = "${params.AWS_REGION}"
        IMAGE_TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        Ingress_Name = "shopsphere-app-ingress"
    }
    parameters {
        choice(
            name: 'PIPELINE_ACTION',
            choices: ['Deploy Infrastructure and Application', 'Destroy Infrastructure and Application'],
            description: 'Select whether to deploy or destroy infrastructure and application'
        )
        string (
            name: 'AWS_REGION',
            defaultValue: 'ap-south-1',
            description: 'AWS region to deploy infrastructure and application'
        )
    }
    stages {
        stage('Pre-build Validation') {
            when {
                expression {params.PIPELINE_ACTION == 'Deploy Infrastructure and Application'}
            }
            steps{
                echo "-------------------------------------- Started Testing!... -------------------------------"
                sh """
                    set -e

                    test -d AWS_Terraform
                    test -d backend
                    test -d common
                    test -d database
                    test -d frontend
                    test -d Kubernetes_Helm
                    test -f .dockerignore
                    test -f app.py
                    test -f Dockerfile.backend
                    test -f Dockerfile.frontend
                    test -f requirements_backend.txt
                    test -f requirements_frontend.txt
                """
                echo "---------------------- Testing Completed: All Checks passed in Testing! ------------------"
            }
        }

        stage('Build Docker Images') {
            when {
                expression {params.PIPELINE_ACTION == 'Deploy Infrastructure and Application'}
            }
            steps{
                echo "------------------------- Started Building Container Images!... --------------------------"
                sh """
                    docker build -f Dockerfile.frontend -t frontend-app:${IMAGE_TAG} .
                    docker build -f Dockerfile.backend -t backend-app:${IMAGE_TAG} .
                """
                echo "-------- Image Build Successful: Container Images have been successfully Built! ----------"
            }
        }

        stage('Manual Approval') {
            steps {
                echo "-------------------------- Waiting for manual approval!... -------------------------------"
                input message: 'Approve to add/modify the Infrastructure and Application'
                echo "--------------------- Approval Completed: Successfully Approved! -------------------------"
            }
        }

        stage('Provision Infrastructure') {
            when {
                expression {params.PIPELINE_ACTION == 'Deploy Infrastructure and Application'}
            }
            steps{
                echo "-------------- Started Building the Infrastructure using Terraform!... -------------------"
                sh """
                    cd AWS_Terraform
                    terraform init -input=false
                    terraform fmt -check -recursive
                    terraform validate
                    terraform plan
                    terraform apply -auto-approve
                """
                script {
                    ECR_FRONTEND = sh(
                        script: "cd AWS_Terraform && terraform output -raw ecr_frontend_url",
                        returnStdout: true
                    ).trim()
                    ECR_BACKEND = sh(
                        script: "cd AWS_Terraform && terraform output -raw ecr_backend_url",
                        returnStdout: true
                    ).trim()
                    S3_BUCKET_NAME = sh(
                        script: 'cd AWS_Terraform && terraform output -raw s3_bucket_name',
                        returnStdout: true
                    ).trim()
                }
                echo "--------- Infrastructure Building Completed: Infrastructure is built and ready! ----------"
            }
        }

        stage('Push Images to ECR') {
            when {
                expression {params.PIPELINE_ACTION == 'Deploy Infrastructure and Application'}
            }
            steps{
                echo "----------------- Starting to push the Docker Image to ECR!... ---------------------------"
                sh """
                    cd AWS_Terraform
                    terraform init -input=false
                    ECR_REGISTRY=\$(terraform output -raw ecr_registry_url)

                    aws ecr get-login-password --region ${params.AWS_REGION} | docker login --username AWS --password-stdin \$ECR_REGISTRY

                    docker tag frontend-app:${IMAGE_TAG} ${ECR_FRONTEND}:${IMAGE_TAG}
                    docker tag backend-app:${IMAGE_TAG} ${ECR_BACKEND}:${IMAGE_TAG}

                    docker push ${ECR_FRONTEND}:${IMAGE_TAG}
                    docker push ${ECR_BACKEND}:${IMAGE_TAG}

                    docker logout \$ECR_REGISTRY
                """
                echo "-------- Docker Image push Completed: Container image has been pushed to ECR! ------------"
            }
        }

        stage('Upload Application Images to S3') {
            when {
                expression {params.PIPELINE_ACTION == 'Deploy Infrastructure and Application'}
            }
            steps{
                echo "---------------- Started to upload the product images to S3!... --------------------------"
                sh """
                    aws s3 sync ./frontend/static/product_images s3://${S3_BUCKET_NAME}/product_images/ --region ${params.AWS_REGION}
                """
                echo "------ Application Images uploaded Successfully: Product images have been uploaded to S3! -------"
            }
        }

        stage('Deploy to Kubernetes (EKS)') {
            when {
                expression {params.PIPELINE_ACTION == 'Deploy Infrastructure and Application'}
            }
            steps{
                echo "------------------ Started deploying Kubernetes resources to EKS!... ---------------------"
                sh """
                    cd AWS_Terraform
                    terraform init -input=false
                    EKS_CLUSTER_NAME=\$(terraform output -raw eks_cluster_name)
                    LBC_POLICY_ARN=\$(terraform output -raw lbc_policy_arn)
                    VPC_ID=\$(terraform output -raw vpc_id)
                    DB_CONN_STRING=\$(terraform output -raw db_conn_string)
                    cd ..

                    aws eks update-kubeconfig --region ${params.AWS_REGION} --name \$EKS_CLUSTER_NAME

                    eksctl utils associate-iam-oidc-provider \
                        --region ${params.AWS_REGION} \
                        --cluster \$EKS_CLUSTER_NAME \
                        --approve

                    eksctl create iamserviceaccount \
                        --cluster=\$EKS_CLUSTER_NAME \
                        --namespace=kube-system \
                        --name=aws-load-balancer-controller \
                        --attach-policy-arn=\$LBC_POLICY_ARN \
                        --approve \
                        --override-existing-serviceaccounts \
                        --region=${params.AWS_REGION}

                    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"

                    helm repo add eks https://aws.github.io/eks-charts
                    helm repo update
                    helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
                        -n kube-system \
                        --set clusterName=\$EKS_CLUSTER_NAME \
                        --set serviceAccount.create=false \
                        --set serviceAccount.name=aws-load-balancer-controller \
                        --set region=${params.AWS_REGION} \
                        --set vpcId=\$VPC_ID

                    kubectl rollout status deployment aws-load-balancer-controller -n kube-system

                    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

                    helm upgrade --install shopsphere ./Kubernetes_Helm/shopsphere \
                        --set services.frontend.imageName=${ECR_FRONTEND} \
                        --set services.frontend.imageVersion=${IMAGE_TAG} \
                        --set services.backend.imageName=${ECR_BACKEND} \
                        --set services.backend.imageVersion=${IMAGE_TAG} \
                        --set s3BucketName=${S3_BUCKET_NAME} \
                        --set AwsRegion=${params.AWS_REGION} \
                        --set flaskSecret=${Flask_Secret} \
                        --set adminUsername="admin" \
                        --set adminPassword=${app_admin_pwd} \
                        --set dbConnectionString="\$DB_CONN_STRING" \
                        --set ingressName=${Ingress_Name}
                """
                script {
                    sh "kubectl wait --for=jsonpath='{.status.loadBalancer.ingress[0].hostname}' ingress/${Ingress_Name} --timeout=300s"
                    APP_URL = sh(
                        script: "kubectl get ingress ${Ingress_Name} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'",
                        returnStdout: true
                    ).trim()
                    APP_URL = "http://${APP_URL}"
                }
                echo "------ Kubernetes resources deployed Successfully: K8 resources have been deployed to EKS using Helm! ------"
            }
        }

        stage('Smoke Test') {
            when {
                expression {params.PIPELINE_ACTION == 'Deploy Infrastructure and Application'}
            }
            steps{
                echo "-------------------------- Started Smoke Testing!... --------------------------------------"
                retry(8) {
                    sleep(time: 20, unit: 'SECONDS')
                    sh """
                        set -e
                        URL="${APP_URL}"
                        curl --fail --max-time 10 "\$URL/health"
                        curl -s --max-time 10 "\$URL" | grep -q "ShopSphere"
                    """
                }
                echo "---------- Smoke Testing Completed: The application is LIVE and working! ------------------"
            }
        }

        stage('Destroy Infrastructure') {
            when {
                expression {params.PIPELINE_ACTION == 'Destroy Infrastructure and Application'}
            }
            steps{
                echo "--------- Started Tear down of the complete Infrastructure and Application ----------------"
                sh """
                    cd AWS_Terraform
                    terraform init -input=false
                    EKS_CLUSTER_NAME=\$(terraform output -raw eks_cluster_name)
                    
                    aws eks update-kubeconfig --region ${params.AWS_REGION} --name \$EKS_CLUSTER_NAME || true
                    helm uninstall shopsphere || true
                    sleep 90
                    helm uninstall aws-load-balancer-controller -n kube-system || true
                    
                    aws cloudformation update-termination-protection --no-enable-termination-protection --stack-name eksctl-\$EKS_CLUSTER_NAME-addon-iamserviceaccount-kube-system-aws-load-balancer-controller --region ${params.AWS_REGION} || true
                    aws cloudformation delete-stack --stack-name eksctl-\$EKS_CLUSTER_NAME-addon-iamserviceaccount-kube-system-aws-load-balancer-controller --region ${params.AWS_REGION} || true
                    aws cloudformation wait stack-delete-complete --stack-name eksctl-\$EKS_CLUSTER_NAME-addon-iamserviceaccount-kube-system-aws-load-balancer-controller --region ${params.AWS_REGION} || true

                    terraform destroy -auto-approve
                """
                echo "------- Infrastructure Tear down Completed: The Complete Infrastructure (with all the Resources) have been Cleaned-up -------"
            }
        }
    }
    post {
        always {
            script {
                def extraContent  = ""
                if (params.PIPELINE_ACTION == 'Deploy Infrastructure and Application' && currentBuild.currentResult == 'SUCCESS') {
                    extraContent += """
                        <br/>
                        Click here to access the application: 
                        <a href="${APP_URL}">Open application</a>
                    """
                }
                emailext (
                    to: '$DEFAULT_RECIPIENTS',
                    subject: '$DEFAULT_SUBJECT',
                    attachLog: true, 
                    compressLog: true,
                    body: """
                        <b>The Pipeline was executed using the below Parameter:</b><br/>
                        RUN_TYPE: ${params.PIPELINE_ACTION}
                        <br/><br/>
                        \$DEFAULT_CONTENT
                        ${extraContent}
                    """
                )
            }
            cleanWs()
            echo "--------- Workspace cleaned!!! ---------"
        }
    }
}