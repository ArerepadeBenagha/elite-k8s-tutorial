terraform {
 backend "s3" {
   bucket = "terraform-state-00gc"
   key    = "ec2instance-state"
   region = "us-east-1"
 }
}