import os
import json
import boto3
import pyodbc

def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    image_key = event['Records'][0]['s3']['object']['key']

    db = pyodbc.connect(os.environ["DB_CONN_STRING"])
    cur = db.cursor()

    cur.execute(
        "SELECT id FROM products WHERE thumbnail_url LIKE ?",
        ("%" + image_key + "%",)
    )
    row = cur.fetchone()

    if not row:
        db.close()
        raise Exception(f"Product not found for image {image_key}. Retrying...")

    product_id = row[0]

    cur.execute("SELECT COUNT(*) FROM product_tags WHERE product_id = ?", (product_id,))
    count = cur.fetchone()[0]

    if count > 0:
        db.close()
        return

    try:
        rekognition = boto3.client("rekognition")

        result = rekognition.detect_labels(
            Image={
                "S3Object": {
                    "Bucket": bucket_name,
                    "Name": image_key
                }
            },
            MaxLabels=8,
            MinConfidence=70
        )

        if result["Labels"]:
            for label in result["Labels"]:
                cur.execute(
                    "INSERT INTO product_tags (product_id, tag_name) VALUES (?, ?)",
                    (product_id, label["Name"])
                )

            db.commit()

    except Exception as e:
        print(f"Error processing image: {e}")
        pass

    db.close()
