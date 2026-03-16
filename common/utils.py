import os

# 1. AI Analysis
def analyze_sentiment(text):
    import boto3
    aws_region = os.environ['AWS_REGION']
    try:
        client = boto3.client('comprehend', region_name=aws_region)
        result = client.detect_sentiment(Text=text, LanguageCode='en')
        tag = result['Sentiment']  # POSITIVE, NEGATIVE, NEUTRAL, MIXED
        scores = result['SentimentScore']
        score = scores.get('Positive', 0.5)
        return {'score': round(score, 2), 'label': tag.capitalize()}
    except Exception as e:
        if 'Subscription' in str(e):
            return {'score': 0.5, 'label': 'No access for free account'}
        return {'score': 0.5, 'label': 'Error'}

# 2. Image Upload
def upload_product_image(file, name):
    import boto3
    try:
        s3_bucket = os.environ.get('S3_BUCKET_NAME')
        aws_region = os.environ['AWS_REGION']
        s3 = boto3.client('s3', region_name=aws_region)

        # Create Filename & Upload
        filename = f"product_{name}.jpg"
        s3_key = f"product_images/{filename}"
        file.seek(0)  # Make sure we read from start
        s3.upload_fileobj(file, s3_bucket, s3_key, ExtraArgs={'ContentType': 'image/jpeg'})

        url = f"https://{s3_bucket}.s3.{aws_region}.amazonaws.com/{s3_key}"
        return url, filename
    except Exception as e:
        print(f"Upload Error: {e}")
        return None, None

# 3. Currency Format (Indian Style: 1,00,000)
def format_indian_currency(value):
    s = str(int(value))
    if len(s) <= 3: return s
    
    # 12345 -> 12,345 | 1234567 -> 12,34,567
    last_3 = s[-3:]
    rest = s[:-3]
    
    # Add commas to the rest every 2 digits
    formatted = ""
    while len(rest) > 2:
        formatted = "," + rest[-2:] + formatted
        rest = rest[:-2]
        
    return rest + formatted + "," + last_3
