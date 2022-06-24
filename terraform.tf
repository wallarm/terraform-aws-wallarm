terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.10.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.1, < 4.0.0"
    }
  }
  required_version = ">= 1.0.5"
}
