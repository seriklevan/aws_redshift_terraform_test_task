provider "aws" {
  region = var.region
}

data "aws_availability_zones" "working" {}
data "aws_region" "current" {}

#################VPC##################

#Create the VPC

resource "aws_vpc" "test_vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  tags             = merge(var.tags, { Name = "${var.project_name}-${var.environment}-vpc" })
}

#Create Internet Gateway and attach it to VPC

resource "aws_internet_gateway" "test_gw" {
  vpc_id = aws_vpc.test_vpc.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-IGW" })
}

#Create a Public Subnets.

resource "aws_subnet" "test_publicsubnet_1" {
  vpc_id            = aws_vpc.test_vpc.id
  availability_zone = data.aws_availability_zones.working.names[0]
  cidr_block        = "192.168.10.0/24"
  tags              = merge(var.tags, { Name = "${var.project_name}-${var.environment}-subnet-1" })
}

resource "aws_subnet" "test_publicsubnet_2" {
  vpc_id            = aws_vpc.test_vpc.id
  availability_zone = data.aws_availability_zones.working.names[1]
  cidr_block        = "192.168.20.0/24"
  tags              = merge(var.tags, { Name = "${var.project_name}-${var.environment}-subnet-2" })
}

resource "aws_subnet" "test_publicsubnet_3" {
  vpc_id            = aws_vpc.test_vpc.id
  availability_zone = data.aws_availability_zones.working.names[2]
  cidr_block        = "192.168.30.0/24"
  tags              = merge(var.tags, { Name = "${var.project_name}-${var.environment}-subnet-3" })

}

#Route table for Public Subnet's

resource "aws_route_table" "test_rt" { # Creating RT for Public Subnet
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0" # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.test_gw.id
  }
  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-RT" })
}

#Route table Association with Public Subnets

resource "aws_route_table_association" "test_rt_association_1" {
  subnet_id      = aws_subnet.test_publicsubnet_1.id
  route_table_id = aws_route_table.test_rt.id
}

resource "aws_route_table_association" "test_rt_association_2" {
  subnet_id      = aws_subnet.test_publicsubnet_2.id
  route_table_id = aws_route_table.test_rt.id
}

resource "aws_route_table_association" "test_rt_association_3" {
  subnet_id      = aws_subnet.test_publicsubnet_3.id
  route_table_id = aws_route_table.test_rt.id
}

#Redshift Cluster and Redshift subnet group

resource "aws_redshift_cluster" "test-cluster" {
  cluster_identifier        = "tf-redshift-cluster"
  database_name             = "testdb"
  master_username           = "testuser"
  master_password           = "Ololo_-_Password"
  node_type                 = "dc1.large"
  cluster_type              = "single-node"
  iam_roles                 = [aws_iam_role.redshift_test_role.arn]
  cluster_subnet_group_name = aws_redshift_subnet_group.group1.id
  skip_final_snapshot       = true
  tags                      = merge(var.tags, { Name = "${var.project_name}-${var.environment}-cluster" })
}

resource "aws_redshift_subnet_group" "group1" {
  name       = "group1"
  subnet_ids = [aws_subnet.test_publicsubnet_1.id, aws_subnet.test_publicsubnet_2.id, aws_subnet.test_publicsubnet_3.id]
  tags       = merge(var.tags, { Name = "${var.project_name}-${var.environment}-RSG" })
}


#Role and Policy

resource "aws_iam_role_policy" "redshift_test_policy" {
  name = "redshift_test_policy"
  role = aws_iam_role.redshift_test_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "redshift_test_role" {
  name = "redshift_test_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Effect" : "Allow",
      "Principal" : { "Service" : "s3.amazonaws.com" },
      "Action" : "sts:AssumeRole"
    }
  })
}
