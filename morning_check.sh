#!/bin/bash
# ==========================================
# 脚本名称：morning_check.sh
# 功能：每日早间巡检 + 服务异常时自动重启（故障自愈）
# 日志：/var/log/auto_fix.log
# 作者：hy111105
# 最后更新：2026-07-27
# 适用环境：CentOS 7 / Bash 4.0+
# 备注：MySQL 免密依赖 /root/.my.cnf 配置文件
# ==========================================

# ---------- 日志函数 ----------
log_auto_fix() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" >> /var/log/auto_fix.log
    echo "$msg"
}

# ---------- 1. 问候函数 ----------
greeting() {
    HOUR=$(date +%H)
    if [ $HOUR -lt 12 ]; then
        echo "🌅 早安！精神抖擞开始敲命令！"
    elif [ $HOUR -ge 12 ] && [ $HOUR -lt 18 ]; then
        echo "☀️ 下午好！继续肝脚本！"
    else
        echo "🌙 早点休息，别熬夜敲命令了！"
    fi
}

# ---------- 2. Redis 检测 + 自愈 ----------
check_redis() {
    echo "----------------------------------------"
    PID=$(pgrep -x redis-server)
    if [ -n "$PID" ]; then
        echo "✅ Redis 正在运行，进程号是：$PID"
    else
        echo "❌ Redis 没有运行，尝试自动重启..."
        log_auto_fix "Redis 未运行，开始自动重启"
        
        systemctl start redis
        sleep 2
        
        NEW_PID=$(pgrep -x redis-server)
        if [ -n "$NEW_PID" ]; then
            echo "✅ Redis 已自动恢复，进程号是：$NEW_PID"
            log_auto_fix "Redis 自愈成功 ✅（PID: $NEW_PID）"
        else
            echo "❌ Redis 重启后仍异常，请人工介入"
            log_auto_fix "Redis 自愈失败 ❌，请人工检查"
        fi
    fi
}

# ---------- 3. MySQL 检测 + 自愈（免密） ----------
check_mysql() {
    echo "----------------------------------------"
    if mysqladmin ping -s 2>/dev/null; then
        echo "✅ MySQL 正在运行（响应正常）"
    else
        echo "❌ MySQL 没有运行，尝试自动重启..."
        log_auto_fix "MySQL 未运行，开始自动重启"
        
        systemctl start mysqld
        sleep 3
        
        if mysqladmin ping -s 2>/dev/null; then
            echo "✅ MySQL 已自动恢复"
            log_auto_fix "MySQL 自愈成功 ✅"
        else
            echo "❌ MySQL 重启后仍异常，请人工介入"
            log_auto_fix "MySQL 自愈失败 ❌，请人工检查"
        fi
    fi
}

# ---------- 4. Tomcat 检测 + 自愈 ----------
check_tomcat() {
    echo "----------------------------------------"
    TOMCAT_PID=$(ps -ef | grep tomcat | grep -v grep | awk '{print $2}')
    if [ -n "$TOMCAT_PID" ]; then
        echo "✅ Tomcat 正在运行，进程号是：$TOMCAT_PID"
    else
        echo "❌ Tomcat 没有运行，尝试自动重启..."
        log_auto_fix "Tomcat 未运行，开始自动重启"
        
        /export/server/apache-tomcat-9.0.117/bin/startup.sh
        sleep 3
        
        NEW_TOMCAT_PID=$(ps -ef | grep tomcat | grep -v grep | awk '{print $2}')
        if [ -n "$NEW_TOMCAT_PID" ]; then
            echo "✅ Tomcat 已自动恢复，进程号是：$NEW_TOMCAT_PID"
            log_auto_fix "Tomcat 自愈成功 ✅（PID: $NEW_TOMCAT_PID）"
        else
            echo "❌ Tomcat 重启后仍异常，请人工介入"
            log_auto_fix "Tomcat 自愈失败 ❌，请人工检查"
        fi
    fi
}

# ---------- 5. Tomcat 日志检测 ----------
check_tomcat_log() {
    echo "----------------------------------------"
    LOG_PATH="/export/server/apache-tomcat-9.0.117/logs/catalina.out"
    if [ ! -f "$LOG_PATH" ]; then
        echo "ℹ️  Tomcat 日志文件不存在，跳过检查"
        return 1
    fi
    COUNT=$(grep -c "ERROR" "$LOG_PATH" 2>/dev/null)
    if [ "$COUNT" -eq 0 ]; then
        echo "✅ Tomcat 运行平稳，无 ERROR 日志"
    else
        echo "❌ Tomcat 发现异常，错误行数：$COUNT 行"
        echo "   （建议执行：tail -20 $LOG_PATH 查看最近错误）"
    fi
}

# ---------- 主程序 ----------
echo "========== 开始每日体检 =========="
greeting
check_redis
check_mysql
check_tomcat
check_tomcat_log
echo "========== 体检结束 =========="

