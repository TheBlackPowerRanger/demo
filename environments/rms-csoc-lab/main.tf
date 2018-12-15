provider "aws" {
  region = "${var.region}"
}

module "environment-state" {
  source      = "../../modules/state"
  environment = "${var.environment}"
}

terraform {
  backend "s3" {
    bucket  = "rms-csoc-lab"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

module "vpc" {
  source                 = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.5"
  vpc_name               = "rms-csoc-lab"
  custom_azs             = ["us-east-1a"]
  cidr_range             = "10.0.0.0/8"
  public_cidr_ranges     = ["10.1.0.0/16"]
  public_subnets_per_az  = 1
  private_cidr_ranges    = ["10.2.0.0/16", "10.3.0.0/16", "10.4.0.0/16"]
  private_subnets_per_az = 3
}n

module "rms_main" {
  source                  = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rms//?ref=v0.1.3"
  name                    = "RMS"
  subnets                 = "${module.vpc.private_subnets}"
  alert_logic_customer_id = "123456789"
}

data "aws_subnet" "selected" {
  id = "${element(module.vpc.private_subnets, 0)}"
}

data "aws_vpc" "selected" {
  id = "${data.aws_subnet.selected.vpc_id}"
}

resource "aws_instance" "bastion" {
  ami                  = "ami-cfe4b2b0"
  instance_type        = "t2.small"
  iam_instance_profile = "SSMforEC2"
  subnet_id            = "${element(module.vpc.public_subnets, 0)}"

  tags {
    Name = "csoc-test-host-amazonlinux"
  }
}

resource "aws_instance" "ubuntu-1604" {
  ami                  = "ami-759bc50a"
  instance_type        = "t2.small"
  iam_instance_profile = "SSMforEC2"

  tags {
    Name = "csoc-test-host-ubuntu1604"
  }
}

resource "aws_instance" "rhel-7" {
  ami                  = "ami-6871a115"
  instance_type        = "t2.small"
  iam_instance_profile = "SSMforEC2"

  tags {
    Name = "csoc-test-host-rhel-7"
  }

  user_data = <<EOF
#!/bin/bash
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
EOF
}

resource "aws_instance" "rhel-6" {
  ami                  = "ami-6d176b12"
  instance_type        = "t2.small"
  iam_instance_profile = "SSMforEC2"

  tags {
    Name = "csoc-test-host-rhel-6"
  }

  user_data = <<EOF
#!/bin/bash
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
EOF
}

resource "aws_instance" "centos-7" {
  ami                  = "ami-9887c6e7"
  instance_type        = "t2.small"
  iam_instance_profile = "SSMforEC2"

  tags {
    Name = "csoc-test-host-centos7"
  }

  user_data = <<EOF
#!/bin/bash
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
EOF
}

resource "aws_instance" "centos-6" {
  ami                  = "ami-e3fdd999"
  instance_type        = "t2.small"
  iam_instance_profile = "SSMforEC2"

  tags {
    Name = "csoc-test-host-centos-6"
  }

  user_data = <<EOF
#!/bin/bash
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
EOF
}

/*resource "aws_instance" "windows-2016" {
  ami                  = "ami-0327667c"
  instance_type        = "t2.small"
  iam_instance_profile = "SSMforEC2"

  tags {
    Name = "csoc-test-host-windows-2016"
  }
}

resource "aws_instance" "windows-2012R2" {
  ami                  = "ami-b8f3b5c7"
  instance_type        = "t2.small"
  iam_instance_profile = "SSMforEC2"

  tags {
    Name = "csoc-test-host-windows-2012R2"
  }
}*/
