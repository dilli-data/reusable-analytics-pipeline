import boto3
import os

AWS_REGION = 'us-east-1'
S3_BUCKET = 'your-s3-bucket-name'

s3 = boto3.client('s3', region_name=AWS_REGION)

def upload_file(file_path, bucket, s3_key):
    s3.upload_file(file_path, bucket, s3_key)
    print(f"Uploaded {file_path} to s3://{bucket}/{s3_key}")

if __name__ == "__main__":
    data_dir = 'mock_data'
    for fname in os.listdir(data_dir):
        if fname.endswith('.csv'):
            file_path = os.path.join(data_dir, fname)
            s3_key = f"raw/{fname}"
            upload_file(file_path, S3_BUCKET, s3_key) 