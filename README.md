# ops-scripts

Linux 服务自动化巡检与故障自愈脚本集合。

## 脚本列表

| 脚本 | 功能 |
| :--- | :--- |
| `morning_check.sh` | 每日巡检 + 故障自愈（自动重启并记录日志） |
| `nx.sh` | 一键重启指定服务（支持 nginx / mysql / redis / tomcat / rabbitmq） |
| `redis_backup.sh` | Redis 每日定时备份（BGSAVE + 时间戳） |

## 环境

- CentOS 7
- Bash 4.0+
- Nginx / Tomcat / MySQL / Redis / RabbitMQ

## 日志

- `/var/log/auto_fix.log` - 自愈操作记录
- `/var/log/ops_tool.log` - 服务管理操作记录
