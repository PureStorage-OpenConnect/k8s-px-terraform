resource "aws_security_group" "purestorage_worker_group_mgmt_one" {
  name_prefix = "purestorage_worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
  
  tags = {
    Name = "purestorage_worker_group_mgmt_one"
  }
}

resource "aws_security_group" "purestorage_worker_group_mgmt_two" {
  name_prefix = "purestorage_worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }

  tags = {
    Name = "purestorage_worker_group_mgmt_two"
  }
}

resource "aws_security_group" "purestorage_all_worker_mgmt" {
  name_prefix = "purestorage_all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = {
    Name = "purestorage_all_worker_mgmt"
  }
}

