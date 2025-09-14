#!/bin/bash

# ===================================================================
# EBS Data Volume Setup (if enabled)
# ===================================================================
%{ if enable_ebs_data_volume ~}
echo "$(date): Setting up EBS data volume" >> /var/log/ecs-init.log

# Wait for the EBS volume to be attached
while [ ! -e /dev/xvdf ]; do
  echo "$(date): Waiting for EBS data volume to be attached..." >> /var/log/ecs-init.log
  sleep 5
done

# Check if the volume has a filesystem
if ! blkid /dev/xvdf; then
  echo "$(date): Formatting EBS data volume with ext4" >> /var/log/ecs-init.log
  mkfs.ext4 /dev/xvdf
else
  echo "$(date): EBS data volume already has a filesystem" >> /var/log/ecs-init.log
fi

# Create mount point
mkdir -p ${ebs_data_mount_point}

# Mount the volume
echo "$(date): Mounting EBS data volume to ${ebs_data_mount_point}" >> /var/log/ecs-init.log
mount /dev/xvdf ${ebs_data_mount_point}

# Add to fstab for persistent mounting
UUID=$(blkid -s UUID -o value /dev/xvdf)
echo "UUID=$UUID ${ebs_data_mount_point} ext4 defaults,nofail 0 2" >> /etc/fstab

# Create application directories
mkdir -p ${ebs_data_mount_point}/postgres
mkdir -p ${ebs_data_mount_point}/n8n
mkdir -p ${ebs_data_mount_point}/traefik

# Set proper permissions
chown -R 999:999 ${ebs_data_mount_point}/postgres  # PostgreSQL user
chown -R node:node ${ebs_data_mount_point}/n8n      # N8N user (if exists)
chmod 755 ${ebs_data_mount_point}/traefik

echo "$(date): EBS data volume setup completed" >> /var/log/ecs-init.log
%{ endif ~}

# ===================================================================
# Custom Environment Variables (User-defined)
# ===================================================================
%{ for name, value in custom_environment_vars ~}
export ${name}="${value}"
echo 'export ${name}="${value}"' >> /etc/environment
%{ endfor ~}

# ===================================================================
# ECS Agent Configuration
# ===================================================================
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config

# Enable ECS Agent logging
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs"]' >> /etc/ecs/ecs.config

# Optional: Enable container instance draining support
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config

# ===================================================================
# SSM Agent Configuration (Security Hardening)
# ===================================================================

# Ensure SSM Agent is running and enabled
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Configure SSM agent for better security
mkdir -p /etc/amazon/ssm
cat > /etc/amazon/ssm/seelog.xml << 'EOF'
<seelog type="adaptive" mininterval="2000000" maxinterval="100000000" critmsgcount="500" minlevel="info">
    <outputs formatid="fmtinfo">
        <console formatid="fmtinfo"/>
        <rollingfile type="size" filename="/var/log/amazon/ssm/amazon-ssm-agent.log" maxsize="30000000" maxrolls="5"/>
        <filter levels="error,critical" formatid="fmterror">
            <rollingfile type="size" filename="/var/log/amazon/ssm/errors.log" maxsize="10000000" maxrolls="5"/>
        </filter>
    </outputs>
    <formats>
        <format id="fmterror" format="%Date %Time %LEVEL [%FuncShort @ %File.%Line] %Msg%n"/>
        <format id="fmtdebug" format="%Date %Time %LEVEL [%FuncShort @ %File.%Line] %Msg%n"/>
        <format id="fmtinfo" format="%Date %Time %LEVEL %Msg%n"/>
    </formats>
</seelog>
EOF

# ===================================================================
# Security Hardening - Disable SSH
# ===================================================================

# Stop and disable SSH service for security (access via SSM only)
systemctl stop sshd
systemctl disable sshd

# Remove any existing SSH keys for additional security
find /home -name "authorized_keys" -delete 2>/dev/null || true
find /root -name "authorized_keys" -delete 2>/dev/null || true

# Disable password authentication (if SSH service ever gets re-enabled)
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# ===================================================================
# Custom User Data Script (User-defined)
# ===================================================================
%{ if custom_user_data != "" ~}
# Execute custom user data script
cat > /tmp/custom_user_data.sh << 'CUSTOM_SCRIPT_EOF'
${custom_user_data}
CUSTOM_SCRIPT_EOF

chmod +x /tmp/custom_user_data.sh
echo "$(date): Executing custom user data script" >> /var/log/ecs-init.log
/tmp/custom_user_data.sh >> /var/log/ecs-init.log 2>&1
echo "$(date): Custom user data script completed" >> /var/log/ecs-init.log
%{ endif ~}

# ===================================================================
# Additional Commands (User-defined)
# ===================================================================
%{ for command in additional_commands ~}
echo "$(date): Executing additional command: ${command}" >> /var/log/ecs-init.log
${command} >> /var/log/ecs-init.log 2>&1
%{ endfor ~}

# ===================================================================
# Restart Services
# ===================================================================

# Restart ECS agent to pick up new configuration
stop ecs
start ecs

# Log successful initialization
echo "$(date): ECS instance initialized successfully with SSM-only access" >> /var/log/ecs-init.log