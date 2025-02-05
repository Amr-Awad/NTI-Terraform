//configure s3 bucket as backend for tfstate 
/*terraform {
  backend "s3" {
    bucket = "blueteaching"
    key    = "lab1/sharedState.tfstate"
    region = "us-east-1"
    dynamodb_table = "remote-state-lock" 
  }
}*/