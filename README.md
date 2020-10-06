# terraform-aws-alb-ecs-efs-rds

Terraform module for running simple container based web apps on ECS.

* Public ALB (http only)
* ECS/Fargate for running web service via a task definition
* auto-scaling based on CPU
* Support for Private Registry Authentication
* RDS Serverless for MySQL
* EFS volume attached to ECS for persistent file store
* Logging to CloudWatch

This is mostly based on https://medium.com/@bradford\_hamilton/deploying-containers-on-amazons-ecs-using-fargate-and-terraform-part-2-2e6f6a3a957f & https://github.com/bradford-hamilton/terraform-ecs-fargate

(https://blog.oxalide.io/post/aws-fargate/ looks like an earler terraform 0.11.x version of the same code base)

## Examples

### simple

[simple](examples/simple) is minimal viable usage, set the name and an empty `private_registry_access_token`.

## TODO

1. terratest validatiom
2. enable https/acm support

