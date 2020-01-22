[
  {
    "name": "app",
    "image": "${account_id}.dkr.ecr.${region}.amazonaws.com/${project_name}/${server_name}:latest",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${container_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${project_name}-log-group",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${server_name}"
      }
    },
    "environment": [
      {
        "name": "PORT",
        "value": "${container_port}"
      },
      {
        "name": "COLOR",
        "value": "no color!"
      }
    ]
  },
  {
    "name": "envoy",
    "image": "${envoy_image}",
    "essential": true,
    "user": "1337",
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 15000,
        "hardLimit": 15000
      }
    ],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 9901
      },
      {
        "protocol": "tcp",
        "containerPort": 15000
      },
      {
        "protocol": "tcp",
        "containerPort": 15001
      }
    ],
    "healthCheck": {
      "retries": 3,
      "command": [
        "CMD-SHELL",
        "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
      ],
      "timeout": 2,
      "interval": 5,
      "startPeriod": 10
    },
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${project_name}-log-group",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${server_name}-envoy"
      }
    },
    "environment": [
      {
        "name": "APPMESH_VIRTUAL_NODE_NAME",
        "value": "mesh/${project_name}/virtualNode/${server_name}"
      },
      {
        "name": "ENVOY_LOG_LEVEL",
        "value": "debug"
      }
    ]
  }
]