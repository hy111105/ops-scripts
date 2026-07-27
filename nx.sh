#!/bin/bash
# ==========================================
# 脚本名称：nx.sh（宿主机版 + 帮助菜单 + 日志记录）
# 功能：智能重启服务
# 作者：hy111105
# 用法：./nx.sh <服务名>
# 支持：nginx | mysql | redis | tomcat | rabbitmq | help
# 日志：/var/log/ops_tool.log
# 最后更新：2026-07-27
# 适用环境：CentOS 7 / Bash 4.0+
# 备注：MySQL 免密依赖 /root/.my.cnf 配置文件
# ==========================================

# ---------- 日志函数 ----------
log_action() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" >> /var/log/ops_tool.log
}

# ---------- 帮助菜单 ----------
show_help() {
    cat << EOF
用法: $0 <服务名>
支持的服务:
  nginx      - 重启 Nginx
  mysql      - 重启 MySQL
  redis      - 重启 Redis
  tomcat     - 重启 Tomcat
  rabbitmq   - 重启 RabbitMQ
  help       - 显示此帮助信息

示例:
  $0 nginx
  $0 mysql
  $0 help

日志文件: /var/log/ops_tool.log
EOF
}

# ---------- 重启函数 ----------
restart_service() {
    local SERVICE="$1"
    log_action "执行 $SERVICE 重启"
    
    case $SERVICE in
        nginx)
            systemctl restart nginx
            sleep 2
            if systemctl is-active nginx >/dev/null 2>&1; then
                echo "✅ Nginx 已成功重启"
                log_action "Nginx 重启成功 ✅"
            else
                echo "❌ Nginx 重启失败，请检查"
                log_action "Nginx 重启失败 ❌"
            fi
            ;;
        mysql)
            systemctl restart mysqld
            sleep 3
            if mysqladmin ping -s 2>/dev/null; then
                echo "✅ MySQL 已成功重启"
                log_action "MySQL 重启成功 ✅"
            else
                echo "❌ MySQL 重启失败，请检查"
                log_action "MySQL 重启失败 ❌"
            fi
            ;;
        redis)
            systemctl restart redis
            sleep 2
            if pgrep -x redis-server >/dev/null; then
                echo "✅ Redis 已成功重启"
                log_action "Redis 重启成功 ✅"
            else
                echo "❌ Redis 重启失败，请检查"
                log_action "Redis 重启失败 ❌"
            fi
            ;;
        tomcat)
            /export/server/apache-tomcat-9.0.117/bin/shutdown.sh
            sleep 2
            /export/server/apache-tomcat-9.0.117/bin/startup.sh
            sleep 3
            if pgrep -f tomcat >/dev/null; then
                echo "✅ Tomcat 已成功重启"
                log_action "Tomcat 重启成功 ✅"
            else
                echo "❌ Tomcat 重启失败，请检查"
                log_action "Tomcat 重启失败 ❌"
            fi
            ;;
        rabbitmq)
            systemctl restart rabbitmq-server
            sleep 3
            if systemctl is-active rabbitmq-server >/dev/null 2>&1; then
                echo "✅ RabbitMQ 已成功重启"
                log_action "RabbitMQ 重启成功 ✅"
            else
                echo "❌ RabbitMQ 重启失败，请检查"
                log_action "RabbitMQ 重启失败 ❌"
            fi
            ;;
        help)
            show_help
            ;;
        *)
            echo "❌ 未知服务: $SERVICE"
            echo "   请执行 $0 help 查看支持的服务列表"
            log_action "未知服务: $SERVICE"
            return 1
            ;;
    esac
}

# ---------- 主程序 ----------
if [ -z "$1" ]; then
    echo "❌ 缺少参数"
    echo "   请执行 $0 help 查看用法"
    exit 1
fi

restart_service "$1"
