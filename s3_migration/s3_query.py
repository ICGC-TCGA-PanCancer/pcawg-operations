import boto
import logging
import os
import sys
        

def SetupLogging(filename,level=logging.INFO):
    logging.basicConfig(filename=filename,level=level)

def Credentials():
    return {"aws_access_key_id": os.environ['AWS_ACCESS_KEY'],
            "aws_secret_access_key": os.environ['AWS_SECRET_KEY']}

def GetS3TopLevel(bucket):
    key_list = bucket.list("", "/")
    for k in key_list:
        print k.name
        logging.info("FOUND: %s" % k.name)

def main():
    SetupLogging('s3_query.log')
    bucket_name = sys.argv[1]
    creds = Credentials()
    try:
        logging.info("Connecting to S3 ... ")
        conn = boto.connect_s3(creds['aws_access_key_id'], creds['aws_secret_access_key'])
        logging.info("Connecting to Bucket: %s ... " % (bucket_name))
        bucket = conn.get_bucket(bucket_name)
        logging.info("Getting list of keys ... ")
        GetS3TopLevel(bucket)
        conn.close()
    except Exception as e:
        sys.stderr.write(str(e)+"\n\n")
        sys.stderr.write("Error interfacing with S3.\n")
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print "Usage:\n s3upload.py bucketname\n"
        sys.exit(1)
    main()
