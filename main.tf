provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # restrict in production
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c71c99" # example: region-specific
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  tags = {
    Name = "terraform-ec2-example"
  }
}

# Replace the `ami` with a valid AMI for your region and tighten security group rules for production (do not use 0.0.0.0/0 unless needed).
