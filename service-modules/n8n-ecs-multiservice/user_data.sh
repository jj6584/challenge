#!/bin/bash

# Update system
yum update -y

# Install necessary packages
yum install -y amazon-cloudwatch-agent

# Configure ECS agent
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_IAM_ROLE=true" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config

# Create data directories
mkdir -p /data/postgres
mkdir -p /data/redis  
mkdir -p /data/n8n
mkdir -p /data/traefik

# Set permissions
chown -R 999:999 /data/postgres    # PostgreSQL UID
chown -R 999:999 /data/redis       # Redis UID
chown -R 1000:1000 /data/n8n       # N8N UID
chown -R 100:101 /data/traefik     # Traefik UID

# Mount EBS volume if it exists
if [ -b /dev/xvdf ]; then
    # Check if filesystem exists
    if ! blkid /dev/xvdf; then
        # Create filesystem
        mkfs.ext4 /dev/xvdf
    fi
    
    # Mount the volume
    mount /dev/xvdf /data
    
    # Add to fstab for persistence
    echo "/dev/xvdf /data ext4 defaults,nofail 0 2" >> /etc/fstab
    
    # Recreate directories after mount
    mkdir -p /data/postgres /data/redis /data/n8n /data/traefik
    chown -R 999:999 /data/postgres
    chown -R 999:999 /data/redis
    chown -R 1000:1000 /data/n8n
    chown -R 100:101 /data/traefik
fi

# Start ECS agent
start ecs

# Configure CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux