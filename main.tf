module "s3_bucket" {
  source = "./modules/s3_bucket"
  SNSarn = "${module.SNS.SNSarn}"
}

module "PythonLambdaStarter" {
  source   = "./modules/PythonLambdaStarter"
  deadQarn = "${module.SNS.deadQarn}"
}

module "SNS" {
  source          = "./modules/SNS"
  moveFunctionArn = "${module.PythonLambdaStarter.moveFunctionArn}"
}
