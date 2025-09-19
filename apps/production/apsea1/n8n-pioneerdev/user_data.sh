#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config

# Install AWS CLI and CloudWatch agent
yum update -y
yum install -y aws-cli

# Configure CloudWatch agent for ECS monitoring
echo '{
  "metrics": {
    "namespace": "AWS/ECS/ContainerInsights",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Mount EBS volume if it exists
if [ -b /dev/xvdf ]; then
    # Check if the volume is already formatted
    if ! file -s /dev/xvdf | grep -q filesystem; then
        # Format the volume
        mkfs -t ext4 /dev/xvdf
    fi
    
    # Create mount point and mount
    mkdir -p /data
    mount /dev/xvdf /data
    
    # Add to fstab for persistence
    echo '/dev/xvdf /data ext4 defaults,nofail 0 2' >> /etc/fstab
    
    # Create directories for N8N data
    mkdir -p /data/n8n
    chown 1000:1000 /data/n8n
    chmod 755 /data/n8n
else
    # Create local directories if no EBS volume
    mkdir -p /data/n8n
    chown 1000:1000 /data/n8n
    chmod 755 /data/n8n
fi

# Start the ECS agent
start ecs