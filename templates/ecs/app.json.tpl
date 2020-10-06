[
  {
    "name": "${APP_NAME}",
    "image": "${app_image}:${app_image_tag}",
    "essential": true,
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${APP_NAME}",
          "awslogs-stream-prefix": "ecs",
          "awslogs-region": "${aws_region}"
        }
    },
    "mountPoints": [
      {
        "containerPath": "/var/www/shared_data",
        "sourceVolume": "${EFS_VOLUME}"
      }
    ],
    "environment" : [
      { "name" : "DATABASE_HOSTNAME", "value" : "${DATABASE_HOSTNAME}" },
      { "name" : "DATABASE_USERNAME", "value" : "${DATABASE_USERNAME}" }
    ],
    "secrets": [
      { "name": "DATABASE_PASSWORD", "valueFrom": "${DATABASE_PASSWORD_ARN}" }
    ],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ]
  }
]
