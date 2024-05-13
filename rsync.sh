#!/bin/sh

# 使用rsync做数据备份

# 定义待备份的源数据目录
SOURCE_DIR="sshalias:/root/docker/data/mysql8"
# 定义备份根目录
BACKUP_DIR="/home/myname/nfsdir/backup"

# 定义增量备份目录
BACKUP_ADD_DIR="${BACKUP_DIR}/mysql8_add"
# 定义增量备份路径
BACKUP_PATH="${BACKUP_ADD_DIR}/mysql8_$(date '+%Y%m%d_%H%M')"
# 定义全量备份路径
BASE_PATH="${BACKUP_DIR}/mysql8_base"

# 创建增量备份目录
if [ ! -d ${BACKUP_ADD_DIR} ]; then
    mkdir -p ${BACKUP_ADD_DIR}
fi

if [ ! -d ${BASE_PATH} ]; then
    # 创建全量备份
    echo "${BASE_PATH} not exists. create full backup:\n"
   # rsync -av --delete "${SOURCE_DIR}/" "${BACKUP_PATH}"
    rsync -trzv --delete "${SOURCE_DIR}/" "${BASE_PATH}"
   # ln -s "${BACKUP_PATH}" "${BASE_PATH}"
    exit 0
else
    # 创建基于全量备份的增量备份
    rsync -trzv --delete --link-dest="${BASE_PATH}" "${SOURCE_DIR}/" "${BACKUP_PATH}"
fi

# rsync -av --delete --link-dest="${BASE_PATH}" "${SOURCE_DIR}/" "${BACKUP_PATH}"
# unlink "${BASE_PATH}"
# ln -s "${BACKUP_PATH}" "${BASE_PATH}"

# 删除10天前的增量备份
find "$BACKUP_ADD_DIR" -maxdepth 1 -type d -ctime +10 | xargs rm -rf
