drop database if exists `metis_storage_3.0`;

CREATE DATABASE `metis_storage_3.0` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `metis_storage_3.0`;

-- 组织计算资源的使用率是动态的，当有任务正在计算时才有意义。
DROP TABLE IF EXISTS org_info;
CREATE TABLE org_info (
	identity_id VARCHAR(200) NOT NULL COMMENT '身份认证标识的id',
	identity_type VARCHAR(100) NOT NULL COMMENT '身份认证标识的类型 (ca 或者 did)',
    org_name VARCHAR(100) COMMENT '组织身份名称',
    node_id VARCHAR(200) NOT NULL COMMENT '组织节点ID',
    image_url varchar(256) COMMENT '组织机构图像url',
    profile  varchar(256) COMMENT '组织机构简介',
    status int NOT NULL DEFAULT 1 COMMENT '状态,1:Normal;2:NonNormal',
--     accumulative_core INT DEFAULT 0 COMMENT '组织算力累积的core数量',
--     accumulative_memory BIGINT DEFAULT 0 COMMENT '组织算力累积的内存数量, 字节',
--     accumulative_bandwidth BIGINT DEFAULT 0 COMMENT '组织算力累积的带宽数量, bps',
--     accumulative_power_task_count INT DEFAULT 0 COMMENT '组织作为算力提供方参与的任务累积数量',
--     accumulative_data_task_count INT DEFAULT 0 COMMENT '组织作为数据提供方参与的任务累积数量',
    accumulative_data_file_count INT DEFAULT 0 COMMENT '组织的文件累积数量',
    update_at DATETIME NOT NULL comment '(状态)修改时间',
    PRIMARY KEY (identity_id)
) comment '组织信息';


DROP TABLE IF EXISTS power_server;
CREATE TABLE power_server (
    id VARCHAR(200) NOT NULL comment '计算服务主机ID,hash',
    identity_id VARCHAR(200) NOT NULL COMMENT '组织身份ID',
    memory BIGINT  NOT NULL DEFAULT 0 COMMENT '计算服务内存, 字节',
    core INT NOT NULL DEFAULT 0 COMMENT '计算服务core',
    bandwidth BIGINT  NOT NULL DEFAULT 0 COMMENT '计算服务带宽, bps',
    used_memory BIGINT DEFAULT 0 COMMENT '使用的内存, 字节',
    used_core INT DEFAULT 0 COMMENT '使用的core',
    used_bandwidth BIGINT DEFAULT 0 COMMENT '使用的带宽, bps',
    published BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否发布，true/false',
    published_at DATETIME(3) NOT NULL comment '发布时间，精确到毫秒',
    status int COMMENT '算力的状态 (0: 未知; 1: 还未发布的算力; 2: 已发布的算力; 3: 已撤销的算力)',
    update_at DATETIME NOT NULL comment '(状态)修改时间',
    PRIMARY KEY (id)
) comment '计算服务信息';


DROP TABLE IF EXISTS data_file;
CREATE TABLE data_file (
    meta_data_id VARCHAR(200) NOT NULL comment '元数据ID,hash',
    origin_id VARCHAR(200) NOT NULL comment '数据文件ID,hash',
    identity_id VARCHAR(200) NOT NULL COMMENT '组织身份ID',
    file_name VARCHAR(100) NOT NULL COMMENT '文件名称',
    file_path VARCHAR(100) NOT NULL COMMENT '文件存储路径',
    file_type int NOT NULL COMMENT '文件后缀/类型, 0:未知; 1:csv',
    resource_name VARCHAR(100) NOT NULL COMMENT '资源名称',
    industry VARCHAR(100)  COMMENT '行业名称',
    size BIGINT NOT NULL DEFAULT 0 COMMENT '文件大小(字节)',
    `rows` INT NOT NULL DEFAULT 0  COMMENT '数据行数(不算title)',
    columns INT NOT NULL DEFAULT 0  COMMENT '数据列数',
    published BOOLEAN NOT NULL DEFAULT false comment '是否公开发布的，true/false',
    published_at DATETIME(3) NOT NULL comment '发布时间，精确到毫秒',
    has_title BOOLEAN NOT NULL DEFAULT false comment '是否带标题',
    remarks VARCHAR(100) COMMENT '数据描述',
    status int COMMENT '元数据的状态 (0: 未知; 1: 还未发布的新表; 2: 已发布的表; 3: 已撤销的表)',
    update_at DATETIME NOT NULL comment '(状态)修改时间',
    dfs_data_status int COMMENT '元数据在分布式存储环境中的状态 (0: DataStatus_Unknown ; DataStatus_Normal = 1; DataStatus_Deleted = 2)',
    dfs_data_id  VARCHAR(200) COMMENT '元数据在分布式存储环境中的ID',
	PRIMARY KEY (meta_data_id)
) comment '数据文件信息';

DROP TABLE IF EXISTS  meta_data_auth;
CREATE TABLE meta_data_auth(
    meta_data_auth_id VARCHAR(200) NOT NULL COMMENT '申请数据授权的ID',
    user_identity_id VARCHAR(200) NOT NULL COMMENT '申请用户所属组织身份ID',
    user_id           VARCHAR(200) NOT NULL COMMENT '申请数据授权的用户ID',
    user_type         INT          NOT NULL COMMENT '用户类型 (0: 未定义; 1: 以太坊地址; 2: Alaya地址; 3: PlatON地址',
    meta_data_id      VARCHAR(200) NOT NULL comment '元数据ID,hash',
    dfs_data_status   INT COMMENT '元数据在分布式存储环境中的状态 (0: DataStatus_Unknown ; DataStatus_Normal = 1; DataStatus_Deleted = 2)',
    dfs_data_id       VARCHAR(200) COMMENT '元数据在分布式存储环境中的ID',
    auth_type         INT DEFAULT 0 NOT NULL COMMENT '申请收集授权类型：(0: 未定义; 1: 按照时间段来使用; 2: 按照次数来使用)',
    start_at          DATETIME COMMENT '授权开始时间(auth_type=1时)',
    end_at            DATETIME COMMENT '授权结束时间(auth_type=1时)',
    times             INT DEFAULT 0 COMMENT '授权次数(auth_type=2时)',
    expired           BOOLEAN DEFAULT FALSE COMMENT '是否已过期 (当 usage_type 为 1 时才需要的字段)',
    used_times        INT DEFAULT 0 COMMENT '已经使用的次数 (当 usage_type 为 2 时才需要的字段)',
    apply_at          DATETIME(3) NOT NULL COMMENT '授权申请时间，精确到毫秒',
    audit_option      INT DEFAULT 0 COMMENT '审核结果，0：等待审核中；1：审核通过；2：审核拒绝',
    audit_desc        VARCHAR(256) DEFAULT '' COMMENT '审核意见 (允许""字符)',
    audit_at          DATETIME(3) COMMENT '授权审核时间，精确到毫秒',
    auth_sign         VARCHAR(1024) COMMENT '授权签名hex',
    auth_status       INT DEFAULT 0 COMMENT '数据授权信息的状态 (0: 未知; 1: 还未发布的数据授权; 2: 已发布的数据授权; 3: 已撤销的数据授权 <失效前主动撤回的>; 4: 已经失效的数据授权 <过期or达到使用上限的>)',
    update_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  COMMENT '修改时间',
    PRIMARY KEY (meta_data_auth_id),
    INDEX (`update_at`)
) comment '元数据文件授权信息';

DROP TABLE IF EXISTS meta_data_column;
CREATE TABLE meta_data_column (
    meta_data_id VARCHAR(200) NOT NULL comment '元数据ID,hash',
    column_idx int NOT NULL COMMENT '字段索引序号',
    column_name VARCHAR(100) NOT NULL COMMENT '字段名称',
    column_type VARCHAR(100) NOT NULL COMMENT '字段类型',
    column_size int NOT NULL DEFAULT 0 COMMENT '字段大小',
    remarks VARCHAR(100) COMMENT '字段描述',
    published BOOLEAN NOT NULL DEFAULT TRUE comment '是否公开的, true/false',
    PRIMARY KEY(meta_data_id, column_idx)
) comment '数据文件元数据信息';

DROP TABLE IF EXISTS task;
CREATE TABLE task (
    id VARCHAR(200) NOT NULL comment '任务ID,hash',
    task_name VARCHAR(100) NOT NULL COMMENT '任务名称',
    user_id           VARCHAR(200) NOT NULL COMMENT '发起任务的用户的信息 (task是属于用户的)',
    user_type         INT          NOT NULL COMMENT '用户类型 (0: 未定义; 1: 以太坊地址; 2: Alaya地址; 3: PlatON地址',
    required_memory BIGINT NOT NULL DEFAULT 0 COMMENT '需要的内存, 字节',
    required_core INT NOT NULL DEFAULT 0 COMMENT '需要的core',
    required_bandwidth BIGINT NOT NULL DEFAULT 0 COMMENT '需要的带宽, bps',
    required_duration BIGINT NOT NULL DEFAULT 0 COMMENT '需要的时间, milli seconds',
    owner_identity_id VARCHAR(200) NOT NULL COMMENT '任务创建者组织身份ID',
    owner_party_id VARCHAR(200) NOT NULL COMMENT '任务参与方在本次任务中的唯一识别ID',
    create_at DATETIME(3) NOT NULL COMMENT '任务创建时间，精确到毫秒',
    start_at DATETIME(3) COMMENT '任务开始执行时间，精确到毫秒',
    end_at DATETIME(3) COMMENT '任务结束时间，精确到毫秒',
    used_memory BIGINT NOT NULL DEFAULT 0 COMMENT '使用的内存, 字节',
    used_core INT NOT NULL DEFAULT 0 COMMENT '使用的core',
    used_bandwidth BIGINT NOT NULL DEFAULT 0 COMMENT '使用的带宽, bps',
    used_file_size BIGINT  DEFAULT 0 COMMENT '使用的所有数据大小，字节',
    status int COMMENT '任务状态, 0:未知;1:等待中;2:计算中,3:失败;4:成功',
    status_desc VARCHAR(255) COMMENT '任务状态说明',
    remarks VARCHAR(255) COMMENT '任务描述',
    task_sign VARCHAR(1024) COMMENT '任务签名',
    update_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  COMMENT '修改时间',
    PRIMARY KEY (ID),
    INDEX (end_at)
) comment '任务';

DROP TABLE IF EXISTS task_algo_provider;
CREATE TABLE task_algo_provider (
    task_id VARCHAR(200) NOT NULL comment '任务ID,hash',
    identity_id VARCHAR(200) NOT NULL COMMENT '算法提供者组织身份ID',
    party_id VARCHAR(200) NOT NULL COMMENT '任务参与方在本次任务中的唯一识别ID',
    PRIMARY KEY (task_ID)
) comment '任务算法提供者';

DROP TABLE IF EXISTS task_meta_data;
CREATE TABLE task_meta_data (
    task_id VARCHAR(200) NOT NULL comment '任务ID,hash',
    meta_data_id VARCHAR(200) NOT NULL COMMENT '参与任务的元数据ID',
    identity_id VARCHAR(200) NOT NULL COMMENT '(冗余)参与任务的元数据的所属组织的identity_id',
    party_id VARCHAR(200) NOT NULL COMMENT '任务参与方在本次任务中的唯一识别ID',
    key_column_idx INT COMMENT '元数据在此次任务中的主键列下标索引序号',
    PRIMARY KEY (task_ID, meta_data_ID)
) comment '任务metadata';

DROP TABLE IF EXISTS task_meta_data_column;
CREATE TABLE task_meta_data_column (
    task_id VARCHAR(200) NOT NULL comment '任务ID,hash',
    meta_data_id VARCHAR(200) NOT NULL COMMENT '参与任务的元数据ID',
    selected_column_idx int NOT NULL COMMENT '元数据在此次任务中的参与计算的字段索引序号',
    PRIMARY KEY (task_ID, meta_data_ID, selected_column_idx)
) comment '任务metadata明细';


DROP TABLE IF EXISTS task_power_provider;
CREATE TABLE task_power_provider(
    task_id VARCHAR(200) NOT NULL comment '任务ID,hash',
    identity_id VARCHAR(200) NOT NULL COMMENT '算力提供者组织身份ID',
    party_id VARCHAR(200) NOT NULL COMMENT '任务参与方在本次任务中的唯一识别ID',
    used_memory BIGINT DEFAULT 0 COMMENT '任务使用的内存, 字节',
    used_core INT DEFAULT 0 COMMENT '任务使用的core',
    used_bandwidth BIGINT DEFAULT 0 COMMENT '任务使用的带宽, bps',
    PRIMARY KEY (task_ID, identity_id)
) comment '任务算力提供者';


DROP TABLE IF EXISTS task_result_consumer;
CREATE TABLE task_result_consumer (
    task_id VARCHAR(200) NOT NULL comment '任务ID,hash',
    consumer_identity_id VARCHAR(200) NOT NULL COMMENT '结果消费者组织身份ID',
    consumer_party_id VARCHAR(200) NOT NULL COMMENT '任务参与方在本次任务中的唯一识别ID',
    producer_identity_id VARCHAR(200) COMMENT '结果产生者的组织身份ID',
    producer_party_id VARCHAR(200)  COMMENT '任务参与方在本次任务中的唯一识别ID',
    PRIMARY KEY (task_ID, consumer_identity_id)
) comment '任务结果接收者';


DROP TABLE IF EXISTS task_event;
CREATE TABLE task_event (
    ID BIGINT auto_increment NOT NULL comment 'ID',
    task_id VARCHAR(200) NOT NULL comment '任务ID,hash',
    event_type VARCHAR(20) NOT NULL COMMENT '事件类型',
    identity_id VARCHAR(200) NOT NULL COMMENT '产生事件的组织身份ID',
    party_id VARCHAR(200) NOT NULL COMMENT '产生事件的partyId (单个组织可以担任任务的多个party, 区分是哪一方产生的event)',
    event_at DATETIME(3) NOT NULL COMMENT '产生事件的时间，精确到毫秒',
    event_content VARCHAR(1024) NOT NULL COMMENT '事件内容',
    PRIMARY KEY (ID)
) comment '任务事件';



-- 创建首页统计 view
create or replace view v_global_stats as
select allOrg.total_org_count, powerOrg.power_org_count, srcFile.data_file_size, usedFile.used_data_file_size,
    task.task_count, (partner.partner_count + task.task_count) as partner_count, power.total_core, power.total_memory, power.total_bandwidth
from
--  总组织数
(
    select count(*) as total_org_count
    from org_info where status= 1
) allOrg,

-- 算力参与方数
(
    select count(oi.identity_id) as power_org_count
    from org_info oi
    where EXISTS (select 1 from power_server ps where oi.identity_id = ps.identity_id)
    and status = 1

) powerOrg,

-- 上传数据量
(
    select IFNULL(sum(size),0) as data_file_size
    from data_file where status=2
) srcFile,

-- 交易数据量
(
    select ifnull(sum(df.size),0) as used_data_file_size
    from task_meta_data tmd
    left join data_file df on tmd.meta_data_id = df.meta_data_id
) usedFile,

-- 完成任务数
(
    select count(*) as task_count
    from task
) task,

-- 参与任务总人次：发起人（一个任务一个发起人，所以发起人次数就是taskCount），算力提供者，数据提供者，或者结果消费者，算法提供者
(
	select ifnull(dataPartner.dataPartnerCount,0) + ifnull(powerPartner.powerPartnerCount,0) + ifnull(algoPartner.algoPartnerCount,0)  + ifnull(resultConsumerPartner.resultConsumerPartnerCount,0) as partner_count
	from
	(
		select count(*) as dataPartnerCount
		from task_meta_data
	) dataPartner,
	(
		select count(*) as powerPartnerCount
		from task_power_provider
	) powerPartner,
    (
        select count(*) as algoPartnerCount
        from task_algo_provider
    ) algoPartner,
    (
        select count(*) as resultConsumerPartnerCount
        from task_result_consumer
    ) resultConsumerPartner

) as partner,

-- 总算力
(
    select ifnull(sum(p.core),0) as total_core, ifnull(sum(p.memory),0) as total_memory, ifnull(sum(p.bandwidth),0) as total_bandwidth
	from power_server p
) as power;

-- 组织参与任务数统计 view （统计组织在任务中的角色是：发起人， 算法提供方，算力提供者，数据提供者，结果消费者）
create or replace view v_org_daily_task_stats as
select tmp.identity_id, count(tmp.task_id) as task_count, date(t.create_at) as task_date
from
    (

    select oi.identity_id, t.id as task_id
    from org_info oi, task t
    WHERE oi.identity_id = t.owner_identity_id

    union

    select oi.identity_id, tap.task_id as task_id
    from org_info oi, task_algo_provider tap
    WHERE oi.identity_id = tap.identity_id

    union

    select oi.identity_id, tpp.task_id
    from  org_info oi, task_power_provider tpp
    WHERE oi.identity_id = tpp.identity_id

    union

    select oi.identity_id, tmd.task_id
    from org_info oi, task_meta_data tmd
    WHERE oi.identity_id = tmd.identity_id

    union

    select oi.identity_id, trc.task_id
    from org_info oi, task_result_consumer trc
    WHERE oi.identity_id = trc.consumer_identity_id

    ) tmp, task t
where tmp.task_id = t.id
group by tmp.identity_id, task_date;


-- 创建元数据月统计视图
CREATE OR REPLACE VIEW v_data_file_stats_monthly as
SELECT a.stats_time, a.month_size, SUM(b.month_size) AS accu_size
FROM (
         SELECT DATE_FORMAT(df.published_at, '%Y-%m')  as stats_time, sum(df.size) as month_size
         FROM data_file df
         WHERE df.status=2
         GROUP BY DATE_FORMAT(df.published_at, '%Y-%m')
         ORDER BY DATE_FORMAT(df.published_at, '%Y-%m')
     ) a
         JOIN (
    SELECT DATE_FORMAT(df.published_at, '%Y-%m')  as stats_time, sum(df.size) as month_size
    FROM data_file df
    WHERE df.status=2
    GROUP BY DATE_FORMAT(df.published_at, '%Y-%m')
    ORDER BY DATE_FORMAT(df.published_at, '%Y-%m')
) b
              ON a.stats_time >= b.stats_time
GROUP BY a.stats_time
ORDER BY a.stats_time;

-- 创建元数据日统计视图
CREATE OR REPLACE VIEW v_data_file_stats_daily as
SELECT a.stats_time, a.day_size, SUM(b.day_size) AS accu_size
FROM (
         SELECT DATE(df.published_at) as stats_time, sum(df.size) as day_size
    FROM data_file df
WHERE df.status=2
GROUP BY DATE(df.published_at)
ORDER BY DATE(df.published_at)
    ) a
    JOIN (
SELECT DATE(df.published_at) as stats_time, sum(df.size) as day_size
FROM data_file df
WHERE df.status=2
GROUP BY DATE(df.published_at)
ORDER BY DATE(df.published_at)
    ) b
ON a.stats_time >= b.stats_time
GROUP BY a.stats_time
ORDER BY a.stats_time;

-- 创建算力月统计视图
CREATE OR REPLACE VIEW v_power_stats_monthly as
SELECT a.stats_time, a.month_core, a.month_memory, a.month_bandwidth, SUM(b.month_core) AS accu_core, SUM(b.month_memory) AS accu_memory, SUM(b.month_bandwidth) AS accu_bandwidth
FROM (
    SELECT DATE_FORMAT(ps.published_at, '%Y-%m')  as stats_time, sum(ps.core) as month_core, sum(ps.memory) as month_memory, sum(ps.bandwidth) as month_bandwidth
    FROM power_server ps
    WHERE ps.status=2 or ps.status=3
    GROUP BY DATE_FORMAT(ps.published_at, '%Y-%m')
    ORDER BY DATE_FORMAT(ps.published_at, '%Y-%m')
) a
JOIN (
    SELECT DATE_FORMAT(ps.published_at, '%Y-%m')  as stats_time, sum(ps.core) as month_core, sum(ps.memory) as month_memory, sum(ps.bandwidth) as month_bandwidth
    FROM power_server ps
    WHERE ps.status=2 or ps.status=3
    GROUP BY DATE_FORMAT(ps.published_at, '%Y-%m')
    ORDER BY DATE_FORMAT(ps.published_at, '%Y-%m')
) b
ON a.stats_time >= b.stats_time
GROUP BY a.stats_time
ORDER BY a.stats_time;


-- 创建算力日统计视图
CREATE OR REPLACE VIEW v_power_stats_daily as
SELECT a.stats_time, a.day_core, a.day_memory, a.day_bandwidth, SUM(b.day_core) AS accu_core, SUM(b.day_memory) AS accu_memory, SUM(b.day_bandwidth) AS accu_bandwidth
FROM (
    SELECT DATE(ps.published_at)  as stats_time, sum(ps.core) as day_core, sum(ps.memory) as day_memory, sum(ps.bandwidth) as day_bandwidth
    FROM power_server ps
    WHERE ps.status=2 or ps.status=3
    GROUP BY DATE(ps.published_at)
    ORDER BY DATE(ps.published_at)
) a
JOIN (
    SELECT DATE(ps.published_at)  as stats_time, sum(ps.core) as day_core, sum(ps.memory) as day_memory, sum(ps.bandwidth) as day_bandwidth
    FROM power_server ps
    WHERE ps.status=2 or ps.status=3
    GROUP BY DATE(ps.published_at)
    ORDER BY DATE(ps.published_at)
) b
ON a.stats_time >= b.stats_time
GROUP BY a.stats_time
ORDER BY a.stats_time;