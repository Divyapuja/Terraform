variable "SourceBucket" {
  description = "Name of source s3 bucket"
  default     = "1srcdivyabucket"
}

variable "destBucket" {
  description = "Name of source s3 bucket"
  default     = "1destdivyabucket"
}

variable "versioning" {
  description = "Versioning enabled or not"
  default     = "false"
}

variable "lifecycle" {
  description = "All related parameters would be meaninful iff this is enabled in main"
  default     = "true"
}

/*useful
variable "pathToObject" {
  description = "Path of the object you want to upload in source bucket"
  default     = "C:/Users/divyapuja.vitonde/AAP/Final/Tulips.jpg"
}
*/


/*
variable "action" {
  description = "action should be in the sequence"
  type = "list"
  default     = ["s3:PutBucketAcl","s3:PutObjectAcl","s3:PutObjectVersionAcl","s3:PutBucketWebsite"]
}

variable "Sid" {
  description = "Sid should be in the sequence"
  default     = ["DenyACLChanges","DenyS3Website"]
}

variable "Effect" {
  description = "Effect should be in the sequence"
  default     = "Deny"
}


variable "Resource" {
  description = "Resource should be in the sequence"
  default     = ["arn:aws:s3:::aap-intern-projects-divya8/*","arn:aws:s3:::aap-intern-projects-divya8/*"]
}
//["arn:aws:s3:::aap-intern-projects-divya8","arn:aws:s3:::aap-intern-projects-divya8/*"]
variable "policyCount" {
  description = "Number of customized policies to add"
  default     = 2
}


variable "policyId" {
  description = "policy ID"
  default     = "AAPS3BucketPolicy"
}

variable "bigCount" {
  description = "bigCount should be in the sequence"
  default     = ["0","3","4"]
}
*/
/*
variable "Statement"{
  description = "Try"
  default = ["Sid : PutBucketAcl","Effect : PutObjectAcl","Principal : PutObjectVersionAcl"," Action:${format("%s","${var.action}")}", "Resource: arn:aws:s3:::${aws_s3_bucket.bucket.id}"]

}
output "Statement" {
  description = "statement to iterate again and again"
  value     = can not use directly to interpolate
}
*/

