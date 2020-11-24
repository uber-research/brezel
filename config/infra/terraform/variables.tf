variable "cluster" {
    description = "The Kubernetes Engine cluster name"
    type = string
}

variable "zone" {
    description = "The location of the cluster"
    type = string
}

variable "region" {
    description = "The location of the project"
    type = string
}

variable "project" {
    description = "The name of the project"
    type = string
}
