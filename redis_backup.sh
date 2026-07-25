#!/bin/bash
# ==========================================
# 脚本名称：redis_backup.sh
# 功能：自动备份 Redis RDB 文件
# 用法：./redis_backup.sh
# ==========================================

BACKUP_DIR="/root/redis_backup"
RDB_DIR="/var/lib/redis"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 触发 BGSAVE（生产推荐）
redis-cli BGSAVE

# 等待 2 秒让备份完成
sleep 2

# 拷贝 dump.rdb 到备份目录
cp "$RDB_DIR/dump.rdb" "$BACKUP_DIR/dump.rdb_$TIMESTAMP"

# 检查是否成功
if [ $? -eq 0 ]; then
    echo "✅ Redis 备份成功：$BACKUP_DIR/dump.rdb_$TIMESTAMP"
else
    echo "❌ Redis 备份失败，请检查"
fi
