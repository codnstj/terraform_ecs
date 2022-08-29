resource "aws_security_group" "lb" {
  vpc_id = aws_vpc.ecs_vpc.id
  name = "lb-sg"
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    protocol = "tcp"
    from_port = 80
    to_port = 80  
    }

  ingress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    protocol = "tcp"
    from_port = 443
    to_port = 443
  }  

  egress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  } 
}