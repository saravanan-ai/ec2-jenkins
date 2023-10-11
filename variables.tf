variable "instance_name" {
        description = "Name of the instance to be created"
        default = "newlinuxvm"
}

variable "instance_type" {
        default = "t2.micro"
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-09d56f8956ab235b3"
}


variable "ami_key_pair_name" {
        default = "testnew"
}

variable "key_name" {
  type        = string
  description = "name of the key"
  default     = "testnewlinux"
}
