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
    mkdir -p ${BASE_PATH}
    
    # 方法一：固定基准目录。可以一个月重建1次基准目录。
    rsync -trzv --delete "${SOURCE_DIR}/" "${BASE_PATH}"

    # 方法二：使用软链接，动态指定基准目录。
    # rsync -av --delete "${SOURCE_DIR}/" "${BACKUP_PATH}"
    # ln -s "${BACKUP_PATH}" "${BASE_PATH}"
    exit 0
else
    # 方法一：固定基准目录。创建基于全量备份的增量备份
    rsync -trzv --delete --link-dest="${BASE_PATH}" "${SOURCE_DIR}/" "${BACKUP_PATH}"

    # 方法二：使用软链接，动态指定基准目录。创建增量备份
    # rsync -av --delete --link-dest="${BASE_PATH}" "${SOURCE_DIR}/" "${BACKUP_PATH}"
    # unlink "${BASE_PATH}"
    # ln -s "${BACKUP_PATH}" "${BASE_PATH}"
fi

# 删除10天前的增量备份
find "$BACKUP_ADD_DIR" -maxdepth 1 -type d -ctime +10 | xargs rm -rf


# 增量备份目录，也是包含所有文件。实际上，它只保存变动过的文件，其他没有变动的文件，都是指向基准目录文件的硬链接。
# --link-dest 参数指定基准目录 ${BASE_PATH}。
# 源目录 ${SOURCE_DIR}/ 跟基准目录进行比较，找出变动的文件，将它们拷贝到备份保存目录 ${BACKUP_PATH}。那些没变动的文件则会生成硬链接。
# 这个命令的第一次是全量备份，后面就都是增量备份。
