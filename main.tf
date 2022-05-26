provider "aws" {
access_key = "----"
secret_key = "---"
region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "firefly-elm-prod-terraform"
    key    = "firefly-elm-prod-terra-log/terraform.tfstat"
    region = "us-east-2"
  }
}


#Create the VPC
 resource "aws_vpc" "Main" {                # Creating VPC here
   cidr_block       = var.main_vpc_cidr     # Defining the CIDR block use 26.15.17.0/24 for demo
   instance_tenancy = "default"
   tags = {
     Name = "firefly-ELM-Dev"
   }  
 }
 #Create Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "IGW" {    # Creating Internet Gateway
    vpc_id =  aws_vpc.Main.id               # vpc_id will be generated after we create VPC
    tags = {
     Name = "firefly-IGW"
   }
 }
 #Create a Public Subnets.
 resource "aws_subnet" "publicsubnets" {    # Creating Public Subnets
   vpc_id =  aws_vpc.Main.id
   cidr_block = "${var.public_subnets}"        # CIDR block of public subnets
   availability_zone = "us-east-2a"
   tags = {
     Name = "firefly-ELM-public-2b"
   }
 }

 #Create a Public Subnets.
 resource "aws_subnet" "publicsubnets-2" {    # Creating Public Subnets
   vpc_id =  aws_vpc.Main.id
   cidr_block = "${var.public_subnets-1}"        # CIDR block of public subnets
   availability_zone = "us-east-2b"
   tags = {
     Name = "firefly-ELM-public-2b"
   }
 }


# Create a Private Subnet                   # Creating Private Subnets
 resource "aws_subnet" "privatesubnets" {
   vpc_id =  aws_vpc.Main.id
   cidr_block = "${var.private_subnets}"          # CIDR block of private subnets
   availability_zone = "us-east-2b"
   tags = {
     Name = "firefly-ELM-private-2b"
   }
 }

# Create a Private Subnet                   # Creating Private Subnets
 resource "aws_subnet" "privatesubnets-2" {
   vpc_id =  aws_vpc.Main.id
   cidr_block = "${var.private_subnets-1}"          # CIDR block of private subnets
   availability_zone = "us-east-2a"
   tags = {
     Name = "firefly-ELM-private-2a"
   }
 }


# Route table for Public Subnet's
 resource "aws_route_table" "PublicRT" {    # Creating RT for Public Subnet
    vpc_id =  aws_vpc.Main.id
         route {
    cidr_block = "0.0.0.0/0"               # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
     }
    tags = {
     Name = "firefly-ELM-public-route"
   }
 }
# Route table for Private Subnet's
 resource "aws_route_table" "PrivateRT" {    # Creating RT for Private Subnet
   vpc_id = aws_vpc.Main.id
   route {
   cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
   nat_gateway_id = aws_nat_gateway.NATgw.id
   
   }
   tags = {
     Name = "firefly-ELM-private-route"
   }
 }
#Route table Association with Public Subnet's
 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PublicRT.id
 }

#Route table Association with Public Subnet's
 resource "aws_route_table_association" "PublicRTassociation-2" {
    subnet_id = aws_subnet.publicsubnets-2.id
    route_table_id = aws_route_table.PublicRT.id
 }


# Route table Association with Private Subnet's
 resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.PrivateRT.id
 }

# Route table Association with Private Subnet's
 resource "aws_route_table_association" "PrivateRTassociation-2" {
    subnet_id = aws_subnet.privatesubnets-2.id
    route_table_id = aws_route_table.PrivateRT.id
 }


 resource "aws_eip" "nateIP" {
   vpc   = true
 }
# Creating the NAT Gateway using subnet_id and allocation_id
 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.publicsubnets.id
   tags = {
     Name = "firefly-NGW"
   }
 }
