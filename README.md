# Terraform
Maintain a Pipeline and handle the object. Use AWS Services.
- Terraform Pipeline Task: Create a pipeline such that, when any object is put in s3 bucket it should create some notification and message. Fetch the message and transfer the object into another bucket and maintain the messages so that if moving object failed it should trigger fail message else success message.
- I used various services in this task. Created complete pipeline and lambda function is written in python 2.7 
- The 3 modules named as python lambda starter, s3_bucket and SNS, are modules segregated so that it can be reusable. The module name represents its functionality. 
- After putting an object in S3 bucket, it triggers SNS topic. SNS Topic triggers lambda function and SQS to maintain queue of messages. I fetched important message string from JSON message. This lambda function is wrapper lambda and triggers step function. Step function contains various services which does the functionality.
