#!/bin/bash

LOG_FILE="/var/log/resume-app/events.log"
STATE_FILE="/var/lib/resume-monitor/state.json"
ANSIBLE_DIR="/opt/resume-platform/ansible"

mkdir -p /var/log/resume-app
mkdir -p /var/lib/resume-monitor
touch $LOG_FILE
chmod 666 $LOG_FILE

log_event() {
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $1" >> "$LOG_FILE"
}

update_state() {
    cat <<EOF > "$STATE_FILE"
{
  "overall": "$1",
  "services": {
    "nginx": "$2",
    "application": "$3",
    "monitoring": "healthy",
    "storage": "healthy"
  },
  "updatedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    chmod 666 "$STATE_FILE"
}

update_state "healthy" "healthy" "healthy"
log_event "Monitoring agent started"

while true; do
    NGINX_STATE="healthy"
    APP_STATE="healthy"
    OVERALL="healthy"

    if [ -f "/var/lib/resume-monitor/crash_nginx.flag" ]; then
        log_event "Monitoring: Nginx crash requested via UI flag"
        log_event "Nginx DOWN"
        docker stop resume-nginx-container
        rm -f "/var/lib/resume-monitor/crash_nginx.flag"
        sleep 2
    fi

    if ! docker ps --format '{{.Names}}' | grep -q "^resume-nginx-container$"; then
        NGINX_STATE="failed"
        OVERALL="failed"
    fi

    if ! docker ps --format '{{.Names}}' | grep -q "^resume-backend-container$"; then
        APP_STATE="failed"
        OVERALL="failed"
    else
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health || echo "000")
        if [ "$HTTP_CODE" != "200" ]; then
            APP_STATE="failed"
            OVERALL="failed"
        fi
    fi

    if [ "$NGINX_STATE" == "failed" ]; then
        update_state "failed" "failed" "$APP_STATE"
        log_event "Monitoring detected Nginx failure"
        sleep 4
        
        update_state "recovering" "recovering" "$APP_STATE"
        log_event "Recovery started via Ansible"
        cd $ANSIBLE_DIR && sudo ansible-playbook playbooks/recover.yml -e target_service=nginx -c local -i localhost, > /dev/null 2>&1
        
        sleep 4
        if docker ps --format '{{.Names}}' | grep -q "^resume-nginx-container$"; then
            log_event "Ansible recovery completed"
            log_event "Nginx HEALTHY"
            NGINX_STATE="healthy"
        else
            log_event "Ansible recovery failed for Nginx"
        fi
    fi

    if [ "$APP_STATE" == "failed" ]; then
        update_state "failed" "$NGINX_STATE" "failed"
        log_event "Monitoring detected Application failure"
        sleep 4
        
        update_state "recovering" "$NGINX_STATE" "recovering"
        log_event "Recovery started via Ansible"
        cd $ANSIBLE_DIR && sudo ansible-playbook playbooks/recover.yml -e target_service=application -c local -i localhost, > /dev/null 2>&1
        
        sleep 4
        if docker ps --format '{{.Names}}' | grep -q "^resume-backend-container$"; then
            log_event "Ansible recovery completed"
            log_event "Application HEALTHY"
            APP_STATE="healthy"
        else
            log_event "Ansible recovery failed for Application"
        fi
    fi

    if [ "$NGINX_STATE" == "healthy" ] && [ "$APP_STATE" == "healthy" ]; then
        OVERALL="healthy"
    fi

    update_state "$OVERALL" "$NGINX_STATE" "$APP_STATE"
    
    sleep 10
done
