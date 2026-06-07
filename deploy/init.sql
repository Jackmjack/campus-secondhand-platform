-- ============================================
-- 校园智能二手流转平台 - 数据库初始化脚本
-- 数据库: MySQL 8.0
-- 字符集: utf8mb4
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `campus_trade`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `campus_trade`;

-- 确保客户端连接使用 utf8mb4，防止中文乱码
SET NAMES utf8mb4;

-- ============================================
-- 一、用户相关表
-- ============================================

-- 1. 用户表
CREATE TABLE `user` (
    `id`            BIGINT        NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `student_id`    VARCHAR(20)   NOT NULL COMMENT '学号/工号',
    `username`      VARCHAR(50)   NOT NULL COMMENT '用户名（学号/工号，用于登录）',
    `password_hash` VARCHAR(255)  NOT NULL COMMENT '密码哈希（BCrypt加密）',
    `nickname`      VARCHAR(50)   DEFAULT NULL COMMENT '昵称（默认使用真实姓名）',
    `real_name`     VARCHAR(50)   DEFAULT NULL COMMENT '真实姓名（注册时填写）',
    `avatar_url`    VARCHAR(255)  DEFAULT NULL COMMENT '头像URL',
    `phone`         VARCHAR(20)   DEFAULT NULL COMMENT '手机号（加密存储）',
    `email`         VARCHAR(100)  DEFAULT NULL COMMENT '邮箱',
    `department`    VARCHAR(100)  DEFAULT NULL COMMENT '院系',
    `major`         VARCHAR(100)  DEFAULT NULL COMMENT '专业',
    `grade`         VARCHAR(20)   DEFAULT NULL COMMENT '年级（如2024级）',
    `role`          VARCHAR(20)   NOT NULL DEFAULT 'USER' COMMENT '角色: USER/ADMIN',
    `status`        TINYINT(1)    NOT NULL DEFAULT 1 COMMENT '状态: 1正常 0禁用',
    `last_login_at` DATETIME      DEFAULT NULL COMMENT '最后登录时间',
    `created_at`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted`    TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0未删除 1已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_student_id` (`student_id`),
    UNIQUE KEY `uk_user_username` (`username`),
    KEY `idx_user_department` (`department`),
    KEY `idx_user_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 2. 用户信用表
CREATE TABLE `user_credit` (
    `id`               BIGINT       NOT NULL AUTO_INCREMENT COMMENT '信用记录ID',
    `user_id`          BIGINT       NOT NULL COMMENT '用户ID',
    `score`            DECIMAL(3,1) NOT NULL DEFAULT 5.0 COMMENT '信用分（1.0-5.0）',
    `total_reviews`    INT          NOT NULL DEFAULT 0 COMMENT '收到的评价总数',
    `good_reviews`     INT          NOT NULL DEFAULT 0 COMMENT '好评数（4-5星）',
    `completed_orders` INT          NOT NULL DEFAULT 0 COMMENT '完成交易数',
    `cancelled_orders` INT          NOT NULL DEFAULT 0 COMMENT '取消交易数',
    `version`          INT          NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    `updated_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_credit_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信用表';

-- 3. 校园网IP段表（用于注册时IP校验）
CREATE TABLE `campus_ip_range` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'IP段ID',
    `ip_start`    VARCHAR(45)  NOT NULL COMMENT '起始IP地址',
    `ip_end`      VARCHAR(45)  NOT NULL COMMENT '结束IP地址',
    `cidr`        VARCHAR(45)  DEFAULT NULL COMMENT 'CIDR表示法（如 10.0.0.0/8）',
    `description` VARCHAR(200) DEFAULT NULL COMMENT '描述（如"教学区有线网络"）',
    `is_active`   TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '是否启用: 1启用 0禁用',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_ip_range_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园网IP段表（用于注册时IP校验）';

-- ============================================
-- 二、商品相关表
-- ============================================

-- 4. 商品分类表
CREATE TABLE `category` (
    `id`         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `name`       VARCHAR(50) NOT NULL COMMENT '分类名称',
    `parent_id`  BIGINT      DEFAULT NULL COMMENT '父分类ID（NULL为一级分类）',
    `icon`       VARCHAR(100) DEFAULT NULL COMMENT '图标标识',
    `sort_order` INT         NOT NULL DEFAULT 0 COMMENT '排序权重（越小越前）',
    `status`     TINYINT(1)  NOT NULL DEFAULT 1 COMMENT '状态: 1启用 0禁用',
    `created_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` TINYINT(1)  NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_category_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- 5. 商品表
CREATE TABLE `product` (
    `id`               BIGINT         NOT NULL AUTO_INCREMENT COMMENT '商品ID',
    `seller_id`        BIGINT         NOT NULL COMMENT '卖家用户ID',
    `category_id`      BIGINT         NOT NULL COMMENT '分类ID',
    `title`            VARCHAR(100)   NOT NULL COMMENT '商品标题',
    `description`      TEXT           NOT NULL COMMENT '商品描述',
    `price`            DECIMAL(10,2)  NOT NULL COMMENT '售价（元）',
    `original_price`   DECIMAL(10,2)  DEFAULT NULL COMMENT '原价（元）',
    `condition_level`  TINYINT        NOT NULL COMMENT '成色: 1全新 2几乎全新 3轻微使用 4正常使用',
    `purchase_date`    DATE           DEFAULT NULL COMMENT '购买时间',
    `usage_duration`   INT            DEFAULT NULL COMMENT '使用时长（月）',
    `status`           VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE' COMMENT '状态: ACTIVE在售 SOLD已售 RESERVED已预定 DRAFT草稿 OFFLINE已下架',
    `view_count`       INT            NOT NULL DEFAULT 0 COMMENT '浏览次数',
    `favorite_count`   INT            NOT NULL DEFAULT 0 COMMENT '收藏次数',
    `meet_location`    VARCHAR(200)   DEFAULT NULL COMMENT '期望面交地点',
    `version`          INT            NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`       TINYINT(1)     NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_product_seller_id` (`seller_id`),
    KEY `idx_product_category_id` (`category_id`),
    KEY `idx_product_status` (`status`),
    KEY `idx_product_price` (`price`),
    KEY `idx_product_created_at` (`created_at`),
    FULLTEXT KEY `ft_product_title_desc` (`title`, `description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 6. 商品图片表
CREATE TABLE `product_image` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '图片ID',
    `product_id`  BIGINT       NOT NULL COMMENT '商品ID',
    `url`         VARCHAR(255) NOT NULL COMMENT '图片URL',
    `sort_order`  INT          NOT NULL DEFAULT 0 COMMENT '排序（越小越前，第一张为首图）',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `is_deleted`  TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_product_image_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品图片表';

-- ============================================
-- 三、交易相关表
-- ============================================

-- 7. 交易订单表
CREATE TABLE `trade_order` (
    `id`                 BIGINT        NOT NULL AUTO_INCREMENT COMMENT '订单ID',
    `product_id`         BIGINT        NOT NULL COMMENT '商品ID',
    `buyer_id`           BIGINT        NOT NULL COMMENT '买家用户ID',
    `seller_id`          BIGINT        NOT NULL COMMENT '卖家用户ID',
    `final_price`        DECIMAL(10,2) NOT NULL COMMENT '最终成交价（元）',
    `status`             VARCHAR(20)   NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待确认 CONFIRMED待面交 MEETING面交中 RATING待评价 COMPLETED已完成 CANCELLED已取消',
    `meet_location`      VARCHAR(200)  DEFAULT NULL COMMENT '约定面交地点',
    `meet_time`          DATETIME      DEFAULT NULL COMMENT '约定面交时间',
    `buyer_confirm_at`   DATETIME      DEFAULT NULL COMMENT '买家确认完成时间',
    `seller_confirm_at`  DATETIME      DEFAULT NULL COMMENT '卖家确认完成时间',
    `cancel_reason`      VARCHAR(500)  DEFAULT NULL COMMENT '取消原因',
    `cancelled_by`       BIGINT        DEFAULT NULL COMMENT '取消操作人用户ID',
    `version`            INT           NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`         TINYINT(1)    NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_order_product_id` (`product_id`),
    KEY `idx_order_buyer_id` (`buyer_id`),
    KEY `idx_order_seller_id` (`seller_id`),
    KEY `idx_order_status` (`status`),
    KEY `idx_order_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='交易订单表';

-- 8. 协商记录表
CREATE TABLE `negotiation` (
    `id`            BIGINT         NOT NULL AUTO_INCREMENT COMMENT '协商ID',
    `order_id`      BIGINT         NOT NULL COMMENT '订单ID',
    `from_user_id`  BIGINT         NOT NULL COMMENT '发起协商的用户ID',
    `to_user_id`    BIGINT         NOT NULL COMMENT '接收协商的用户ID',
    `price`         DECIMAL(10,2)  NOT NULL COMMENT '提议价格',
    `message`       VARCHAR(500)   DEFAULT NULL COMMENT '协商留言',
    `status`        VARCHAR(20)    NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待回应 ACCEPTED接受 REJECTED拒绝',
    `created_at`    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_negotiation_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='协商记录表';

-- 9. 评价表
CREATE TABLE `review` (
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '评价ID',
    `order_id`       BIGINT       NOT NULL COMMENT '订单ID',
    `reviewer_id`    BIGINT       NOT NULL COMMENT '评价者用户ID',
    `target_user_id` BIGINT       NOT NULL COMMENT '被评价者用户ID',
    `rating`         TINYINT      NOT NULL COMMENT '评分: 1-5星',
    `content`        VARCHAR(500) DEFAULT NULL COMMENT '评价内容',
    `tags`           VARCHAR(200) DEFAULT NULL COMMENT '评价标签（逗号分隔，如：响应快,商品质量好）',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `is_deleted`     TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_review_order_reviewer` (`order_id`, `reviewer_id`),
    KEY `idx_review_target_user_id` (`target_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';

-- 10. 收藏表
CREATE TABLE `favorite` (
    `id`          BIGINT     NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
    `user_id`     BIGINT     NOT NULL COMMENT '用户ID',
    `product_id`  BIGINT     NOT NULL COMMENT '商品ID',
    `created_at`  DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `is_deleted`  TINYINT(1) NOT NULL DEFAULT 0 COMMENT '取消收藏即为逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_favorite_user_product` (`user_id`, `product_id`),
    KEY `idx_favorite_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- ============================================
-- 四、AI推荐相关表
-- ============================================

-- 11. 用户行为埋点表（AI推荐训练数据，基于 ShardingSphere-JDBC 水平分表）
-- 分表说明：物理上拆分为 user_behavior_0 ~ user_behavior_3，ShardingKey=user_id，路由算法 user_id % 4
CREATE TABLE `user_behavior` (
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '行为ID',
    `user_id`        BIGINT       NOT NULL COMMENT '用户ID',
    `product_id`     BIGINT       NOT NULL COMMENT '商品ID',
    `behavior_type`  VARCHAR(20)  NOT NULL COMMENT '行为类型: VIEW浏览 FAVORITE收藏 PURCHASE购买 CLICK点击',
    `duration_ms`    INT          DEFAULT NULL COMMENT '浏览时长（毫秒），仅VIEW类型有值',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_behavior_user_id` (`user_id`),
    KEY `idx_behavior_product_id` (`product_id`),
    KEY `idx_behavior_type` (`behavior_type`),
    KEY `idx_behavior_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户行为埋点表（AI推荐训练数据）';

-- ============================================
-- 五、以物换物相关表
-- ============================================

-- 12. 以物换物商品表
CREATE TABLE `barter_product` (
    `id`               BIGINT         NOT NULL AUTO_INCREMENT COMMENT '换物商品ID',
    `user_id`          BIGINT         NOT NULL COMMENT '发布者用户ID',
    `title`            VARCHAR(100)   NOT NULL COMMENT '物品标题',
    `description`      TEXT           NOT NULL COMMENT '物品描述',
    `condition_level`  TINYINT        NOT NULL COMMENT '成色: 1全新 2几乎全新 3轻微使用 4正常使用',
    `want_description` VARCHAR(500)   NOT NULL COMMENT '期望换取的物品描述',
    `want_category_id` BIGINT         DEFAULT NULL COMMENT '期望换取的分类ID',
    `status`           VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE' COMMENT '状态: ACTIVE在换 TRADING交换中 TRADED已换出 OFFLINE已下架',
    `view_count`       INT            NOT NULL DEFAULT 0,
    `created_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`       TINYINT(1)     NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_barter_product_user_id` (`user_id`),
    KEY `idx_barter_product_status` (`status`),
    FULLTEXT KEY `ft_barter_title_desc` (`title`, `description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='以物换物商品表';

-- 13. 以物换物订单表
CREATE TABLE `barter_order` (
    `id`                 BIGINT        NOT NULL AUTO_INCREMENT COMMENT '换物订单ID',
    `barter_product_id`  BIGINT        NOT NULL COMMENT '换物商品ID',
    `from_user_id`       BIGINT        NOT NULL COMMENT '发起换物方用户ID',
    `to_user_id`         BIGINT        NOT NULL COMMENT '换物商品发布者用户ID',
    `offer_description`  VARCHAR(500)  NOT NULL COMMENT '发起方提供的物品描述',
    `status`             VARCHAR(20)   NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待确认 ACCEPTED已接受 REJECTED已拒绝 NEGOTIATING协商中 COMPLETED已完成 CANCELLED已取消',
    `meet_location`      VARCHAR(200)  DEFAULT NULL COMMENT '面交地点',
    `meet_time`          DATETIME      DEFAULT NULL COMMENT '面交时间',
    `from_confirm_at`    DATETIME      DEFAULT NULL,
    `to_confirm_at`      DATETIME      DEFAULT NULL,
    `cancel_reason`      VARCHAR(500)  DEFAULT NULL,
    `created_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`         TINYINT(1)    NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_barter_order_from` (`from_user_id`),
    KEY `idx_barter_order_to` (`to_user_id`),
    KEY `idx_barter_order_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='以物换物订单表';

-- ============================================
-- 六、租赁相关表
-- ============================================

-- 14. 租赁商品表
CREATE TABLE `rental_product` (
    `id`               BIGINT         NOT NULL AUTO_INCREMENT COMMENT '租赁商品ID',
    `owner_id`         BIGINT         NOT NULL COMMENT '出租方用户ID',
    `category_id`      BIGINT         NOT NULL COMMENT '租赁分类ID（服装租赁/课本租赁）',
    `title`            VARCHAR(100)   NOT NULL COMMENT '商品标题',
    `description`      TEXT           NOT NULL COMMENT '商品描述（含尺码/ISBN等关键信息）',
    `price_per_day`    DECIMAL(10,2)  NOT NULL COMMENT '日租金（元）',
    `deposit`          DECIMAL(10,2)  NOT NULL COMMENT '押金（元）',
    `condition_level`  TINYINT        NOT NULL COMMENT '成色',
    `available_from`   DATE           DEFAULT NULL COMMENT '可租开始日期',
    `available_to`     DATE           DEFAULT NULL COMMENT '可租结束日期',
    `status`           VARCHAR(20)    NOT NULL DEFAULT 'AVAILABLE' COMMENT 'AVAILABLE可租 RENTED已租出 OFFLINE已下架',
    `view_count`       INT            NOT NULL DEFAULT 0,
    `rent_count`       INT            NOT NULL DEFAULT 0 COMMENT '累计出租次数',
    `version`          INT            NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`       TINYINT(1)     NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_rental_product_owner` (`owner_id`),
    KEY `idx_rental_product_category` (`category_id`),
    KEY `idx_rental_product_status` (`status`),
    KEY `idx_rental_product_price` (`price_per_day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租赁商品表';

-- 15. 租赁订单表
CREATE TABLE `rental_order` (
    `id`               BIGINT         NOT NULL AUTO_INCREMENT COMMENT '租赁订单ID',
    `rental_product_id` BIGINT        NOT NULL COMMENT '租赁商品ID',
    `renter_id`        BIGINT         NOT NULL COMMENT '租客用户ID',
    `owner_id`         BIGINT         NOT NULL COMMENT '出租方用户ID',
    `rent_days`        INT            NOT NULL COMMENT '租用天数',
    `total_price`      DECIMAL(10,2)  NOT NULL COMMENT '总租金（日租金×天数）',
    `deposit`          DECIMAL(10,2)  NOT NULL COMMENT '押金金额',
    `rent_start_date`  DATE           DEFAULT NULL COMMENT '租期开始日期',
    `rent_end_date`    DATE           DEFAULT NULL COMMENT '租期结束日期',
    `status`           VARCHAR(20)    NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待确认 CONFIRMED待交付 RENTING租赁中 RETURNING待归还 COMPLETED已完成 CANCELLED已取消 OVERDUE逾期',
    `owner_deliver_at` DATETIME       DEFAULT NULL COMMENT '出租方确认交付时间',
    `renter_return_at` DATETIME       DEFAULT NULL COMMENT '租客确认归还时间',
    `owner_confirm_at` DATETIME       DEFAULT NULL COMMENT '出租方确认归还时间',
    `damage_note`      VARCHAR(500)   DEFAULT NULL COMMENT '损坏说明（如有）',
    `cancel_reason`    VARCHAR(500)   DEFAULT NULL,
    `created_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`       TINYINT(1)     NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_rental_order_renter` (`renter_id`),
    KEY `idx_rental_order_owner` (`owner_id`),
    KEY `idx_rental_order_status` (`status`),
    KEY `idx_rental_order_dates` (`rent_start_date`, `rent_end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租赁订单表';

-- ============================================
-- 七、清仓打折相关表
-- ============================================

-- 16. 清仓活动表
CREATE TABLE `clearance_event` (
    `id`             BIGINT        NOT NULL AUTO_INCREMENT COMMENT '清仓活动ID',
    `user_id`        BIGINT        NOT NULL COMMENT '发起用户ID',
    `title`          VARCHAR(100)  NOT NULL COMMENT '活动标题（如"毕业清仓大甩卖"）',
    `description`    VARCHAR(500)  DEFAULT NULL COMMENT '活动描述',
    `discount_type`  VARCHAR(20)   NOT NULL COMMENT '折扣类型: UNIFORM统一折扣 CUSTOM自定义折扣',
    `discount_rate`  DECIMAL(3,2)  DEFAULT NULL COMMENT '统一折扣率（如0.8=8折），UNIFORM类型时使用',
    `start_time`     DATETIME      NOT NULL COMMENT '活动开始时间',
    `end_time`       DATETIME      NOT NULL COMMENT '活动结束时间',
    `status`         VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE进行中 ENDED已结束 CANCELLED已取消',
    `view_count`     INT           NOT NULL DEFAULT 0,
    `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`     TINYINT(1)    NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_clearance_user_id` (`user_id`),
    KEY `idx_clearance_time` (`start_time`, `end_time`),
    KEY `idx_clearance_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='清仓活动表';

-- 17. 清仓活动商品关联表
CREATE TABLE `clearance_product` (
    `id`               BIGINT         NOT NULL AUTO_INCREMENT COMMENT '关联ID',
    `clearance_id`     BIGINT         NOT NULL COMMENT '清仓活动ID',
    `product_id`       BIGINT         NOT NULL COMMENT '商品ID',
    `original_price`   DECIMAL(10,2)  NOT NULL COMMENT '商品原售价（快照）',
    `clearance_price`  DECIMAL(10,2)  NOT NULL COMMENT '清仓价',
    `custom_discount`  DECIMAL(3,2)   DEFAULT NULL COMMENT '自定义折扣（CUSTOM类型时使用）',
    `created_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_clearance_product` (`clearance_id`, `product_id`),
    KEY `idx_cp_clearance_id` (`clearance_id`),
    KEY `idx_cp_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='清仓活动商品关联表';

-- ============================================
-- 八、论坛相关表
-- ============================================

-- 18. 论坛板块表
CREATE TABLE `forum_board` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '板块ID',
    `name`        VARCHAR(50)  NOT NULL COMMENT '板块名称',
    `description` VARCHAR(200) DEFAULT NULL COMMENT '板块描述',
    `icon`        VARCHAR(50)  DEFAULT NULL COMMENT '板块图标',
    `sort_order`  INT          NOT NULL DEFAULT 0 COMMENT '排序权重',
    `post_count`  INT          NOT NULL DEFAULT 0 COMMENT '帖子总数（冗余计数）',
    `status`      TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1启用 0禁用',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_board_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='论坛板块表';

-- 19. 论坛帖子表
CREATE TABLE `forum_post` (
    `id`              BIGINT       NOT NULL AUTO_INCREMENT COMMENT '帖子ID',
    `board_id`        BIGINT       NOT NULL COMMENT '所属板块ID',
    `user_id`         BIGINT       NOT NULL COMMENT '发帖用户ID',
    `title`           VARCHAR(100) NOT NULL COMMENT '帖子标题',
    `content`         TEXT         NOT NULL COMMENT '帖子正文（支持Markdown）',
    `view_count`      INT          NOT NULL DEFAULT 0 COMMENT '浏览次数',
    `comment_count`   INT          NOT NULL DEFAULT 0 COMMENT '评论数（冗余计数）',
    `like_count`      INT          NOT NULL DEFAULT 0 COMMENT '点赞数（冗余计数）',
    `is_pinned`       TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '是否置顶',
    `status`          VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE正常 HIDDEN被屏蔽 DELETED已删除',
    `last_comment_at` DATETIME     DEFAULT NULL COMMENT '最新评论时间',
    `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`      TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_forum_post_board_id` (`board_id`),
    KEY `idx_forum_post_user_id` (`user_id`),
    KEY `idx_forum_post_created_at` (`created_at`),
    KEY `idx_forum_post_last_comment` (`last_comment_at`),
    KEY `idx_forum_post_status` (`status`),
    FULLTEXT KEY `ft_forum_post_title_content` (`title`, `content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='论坛帖子表';

-- 20. 论坛评论表
CREATE TABLE `forum_comment` (
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '评论ID',
    `post_id`        BIGINT       NOT NULL COMMENT '所属帖子ID',
    `user_id`        BIGINT       NOT NULL COMMENT '评论用户ID',
    `parent_id`      BIGINT       DEFAULT NULL COMMENT '父评论ID（NULL为一级评论，有值为楼中楼回复）',
    `reply_to_uid`   BIGINT       DEFAULT NULL COMMENT '回复的目标用户ID',
    `content`        VARCHAR(1000) NOT NULL COMMENT '评论内容',
    `like_count`     INT          NOT NULL DEFAULT 0,
    `status`         VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE正常 HIDDEN被屏蔽',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `is_deleted`     TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_forum_comment_post_id` (`post_id`),
    KEY `idx_forum_comment_user_id` (`user_id`),
    KEY `idx_forum_comment_parent` (`parent_id`),
    KEY `idx_forum_comment_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='论坛评论表';

-- 21. 论坛点赞表
CREATE TABLE `forum_like` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '点赞ID',
    `user_id`     BIGINT      NOT NULL COMMENT '用户ID',
    `target_type` VARCHAR(20) NOT NULL COMMENT '点赞目标类型: POST帖子 COMMENT评论',
    `target_id`   BIGINT      NOT NULL COMMENT '目标ID',
    `created_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_like_user_target` (`user_id`, `target_type`, `target_id`),
    KEY `idx_forum_like_target` (`target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='论坛点赞表';

-- ============================================
-- 九、拼卡共享相关表
-- ============================================

-- 22. 拼卡共享表
CREATE TABLE `card_share` (
    `id`             BIGINT         NOT NULL AUTO_INCREMENT COMMENT '拼卡ID',
    `user_id`        BIGINT         NOT NULL COMMENT '发起用户ID',
    `card_type`      VARCHAR(50)    NOT NULL COMMENT '卡类型: GYM健身卡 COURSE网课会员 VIDEO视频会员 LIBRARY储物柜 OTHER其他',
    `title`          VARCHAR(100)   NOT NULL COMMENT '拼卡标题',
    `description`    VARCHAR(500)   DEFAULT NULL COMMENT '补充描述',
    `total_cost`     DECIMAL(10,2)  NOT NULL COMMENT '总费用（元）',
    `max_members`    INT            NOT NULL COMMENT '最大拼卡人数（含发起人）',
    `cost_per_person` DECIMAL(10,2) NOT NULL COMMENT '人均分摊费用',
    `current_members` INT           NOT NULL DEFAULT 1 COMMENT '当前参与人数',
    `status`         VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE拼卡中 FULL已满员 COMPLETED已完成 CANCELLED已取消',
    `version`        INT            NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at`     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`     TINYINT(1)     NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_card_share_user_id` (`user_id`),
    KEY `idx_card_share_type` (`card_type`),
    KEY `idx_card_share_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼卡共享表';

-- 23. 拼卡参与记录表
CREATE TABLE `card_share_participant` (
    `id`            BIGINT      NOT NULL AUTO_INCREMENT COMMENT '参与记录ID',
    `card_share_id` BIGINT      NOT NULL COMMENT '拼卡ID',
    `user_id`       BIGINT      NOT NULL COMMENT '参与用户ID',
    `status`        VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待确认 ACCEPTED已确认 REJECTED已拒绝',
    `created_at`    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_csp_card_user` (`card_share_id`, `user_id`),
    KEY `idx_csp_card_share_id` (`card_share_id`),
    KEY `idx_csp_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼卡参与记录表';

-- ============================================
-- 十、兼职相关表
-- ============================================

-- 24. 兼职岗位表
CREATE TABLE `job_listing` (
    `id`             BIGINT         NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
    `publisher_id`   BIGINT         NOT NULL COMMENT '发布者用户ID',
    `title`          VARCHAR(100)   NOT NULL COMMENT '岗位标题',
    `description`    TEXT           NOT NULL COMMENT '岗位描述（工作内容、要求等）',
    `category`       VARCHAR(30)    NOT NULL COMMENT '分类: CAMPUS校内勤工俭学 TUTOR家教辅导 SKILL技能外包 TEMP临时工 OTHER其他',
    `salary`         VARCHAR(100)   NOT NULL COMMENT '薪资描述（如"50元/小时"或"2000元/月"）',
    `work_location`  VARCHAR(200)   DEFAULT NULL COMMENT '工作地点',
    `work_time`      VARCHAR(200)   DEFAULT NULL COMMENT '工作时间描述',
    `contact_info`   VARCHAR(200)   NOT NULL COMMENT '联系方式（脱敏展示）',
    `expire_date`    DATE           DEFAULT NULL COMMENT '截止日期',
    `status`         VARCHAR(20)    NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待审核 ACTIVE招募中 FILLED已招满 EXPIRED已过期 CANCELLED已取消 REJECTED审核不通过',
    `review_reason`  VARCHAR(500)   DEFAULT NULL COMMENT '审核意见',
    `reviewed_by`    BIGINT         DEFAULT NULL COMMENT '审核人ID',
    `reviewed_at`    DATETIME       DEFAULT NULL COMMENT '审核时间',
    `view_count`     INT            NOT NULL DEFAULT 0,
    `apply_count`    INT            NOT NULL DEFAULT 0,
    `created_at`     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`     TINYINT(1)     NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_job_publisher_id` (`publisher_id`),
    KEY `idx_job_category` (`category`),
    KEY `idx_job_status` (`status`),
    KEY `idx_job_expire_date` (`expire_date`),
    FULLTEXT KEY `ft_job_title_desc` (`title`, `description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='兼职岗位表';

-- 25. 兼职申请表
CREATE TABLE `job_application` (
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '申请ID',
    `job_id`         BIGINT       NOT NULL COMMENT '岗位ID',
    `applicant_id`   BIGINT       NOT NULL COMMENT '申请人用户ID',
    `message`        VARCHAR(300) DEFAULT NULL COMMENT '申请留言/自我介绍',
    `status`         VARCHAR(20)  NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待查看 ACCEPTED已录用 REJECTED未录用',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_application_job_user` (`job_id`, `applicant_id`),
    KEY `idx_application_job_id` (`job_id`),
    KEY `idx_application_applicant` (`applicant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='兼职申请表';

-- ============================================
-- 十一、第二阶段扩展表
-- ============================================

-- 26. 小法庭案件表（第二阶段）
CREATE TABLE `court_case` (
    `id`                BIGINT        NOT NULL AUTO_INCREMENT COMMENT '案件ID',
    `order_id`          BIGINT        NOT NULL COMMENT '关联订单ID',
    `plaintiff_id`      BIGINT        NOT NULL COMMENT '原告（发起仲裁方）用户ID',
    `defendant_id`      BIGINT        NOT NULL COMMENT '被告用户ID',
    `plaintiff_statement` TEXT         NOT NULL COMMENT '原告诉求与描述',
    `defendant_statement` TEXT         DEFAULT NULL COMMENT '被告答辩',
    `evidence_images`   VARCHAR(1000) DEFAULT NULL COMMENT '证据图片URL列表（JSON数组或逗号分隔）',
    `status`            VARCHAR(20)   NOT NULL DEFAULT 'FILING' COMMENT 'FILING审理中 DEFENDING等待答辩 VOTING投票中 VERDICT已裁决 DISMISSED驳回',
    `verdict`           VARCHAR(20)   DEFAULT NULL COMMENT '裁决结果: PLAINTIFF_WIN原告胜 DEFENDANT_WIN被告胜 TIE平局',
    `plaintiff_votes`   INT           NOT NULL DEFAULT 0 COMMENT '支持原告票数',
    `defendant_votes`   INT           NOT NULL DEFAULT 0 COMMENT '支持被告票数',
    `juror_count`       INT           NOT NULL DEFAULT 20 COMMENT '陪审员总人数',
    `verdict_reason`    VARCHAR(500)  DEFAULT NULL COMMENT '裁决理由摘要',
    `created_at`        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_court_case_order` (`order_id`),
    KEY `idx_court_case_plaintiff` (`plaintiff_id`),
    KEY `idx_court_case_defendant` (`defendant_id`),
    KEY `idx_court_case_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='小法庭案件表（第二阶段）';

-- 27. 小法庭投票表（第二阶段）
CREATE TABLE `court_vote` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '投票ID',
    `case_id`     BIGINT      NOT NULL COMMENT '案件ID',
    `juror_id`    BIGINT      NOT NULL COMMENT '陪审员用户ID',
    `vote_for`    VARCHAR(20) NOT NULL COMMENT '投票对象: PLAINTIFF原告 DEFENDANT被告',
    `comment`     VARCHAR(300) DEFAULT NULL COMMENT '投票理由',
    `created_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_vote_case_juror` (`case_id`, `juror_id`),
    KEY `idx_court_vote_case` (`case_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='小法庭投票表（第二阶段）';

-- 28. 拼团活动表（第二阶段）
CREATE TABLE `group_buy` (
    `id`              BIGINT         NOT NULL AUTO_INCREMENT COMMENT '拼团ID',
    `product_id`      BIGINT         NOT NULL COMMENT '商品ID',
    `initiator_id`    BIGINT         NOT NULL COMMENT '发起人/卖家用户ID',
    `min_members`     INT            NOT NULL COMMENT '成团最少人数',
    `group_price`     DECIMAL(10,2)  NOT NULL COMMENT '拼团价',
    `original_price`  DECIMAL(10,2)  NOT NULL COMMENT '原价（快照）',
    `current_members` INT            NOT NULL DEFAULT 0 COMMENT '当前参团人数',
    `deadline`        DATETIME       NOT NULL COMMENT '成团截止时间',
    `status`          VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE拼团中 SUCCESS已成团 FAILED拼团失败 CANCELLED已取消',
    `created_at`      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted`      TINYINT(1)     NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_group_buy_product` (`product_id`),
    KEY `idx_group_buy_status` (`status`),
    KEY `idx_group_buy_deadline` (`deadline`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼团活动表（第二阶段）';

-- 29. 拼团参与记录表（第二阶段）
CREATE TABLE `group_buy_participant` (
    `id`           BIGINT      NOT NULL AUTO_INCREMENT COMMENT '参与记录ID',
    `group_buy_id` BIGINT      NOT NULL COMMENT '拼团ID',
    `user_id`      BIGINT      NOT NULL COMMENT '参团用户ID',
    `order_id`     BIGINT      DEFAULT NULL COMMENT '成团后生成的订单ID',
    `created_at`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_gbp_group_user` (`group_buy_id`, `user_id`),
    KEY `idx_gbp_group_buy_id` (`group_buy_id`),
    KEY `idx_gbp_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼团参与记录表（第二阶段）';

-- ============================================
-- 十二、预置数据
-- ============================================

-- 商品分类数据
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
('教材教辅', NULL, 1),
('电子产品', NULL, 2),
('生活用品', NULL, 3),
('服饰鞋包', NULL, 4),
('运动户外', NULL, 5),
('其他', NULL, 99);

INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
('公共课教材', 1, 1),
('专业课教材', 1, 2),
('考研资料', 1, 3),
('考证资料', 1, 4),
('手机平板', 2, 1),
('电脑配件', 2, 2),
('耳机音箱', 2, 3),
('数码相机', 2, 4),
('收纳整理', 3, 1),
('日用百货', 3, 2),
('床品家纺', 3, 3),
('台灯风扇', 3, 4),
('男装', 4, 1),
('女装', 4, 2),
('鞋靴', 4, 3),
('箱包', 4, 4),
('健身器材', 5, 1),
('球类运动', 5, 2),
('户外装备', 5, 3),
('自行车', 5, 4),
('乐器', 6, 1),
('手办', 6, 2),
('手工制品', 6, 3);

-- 租赁和换物分类（用变量动态获取自增ID，避免硬编码parent_id）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES ('租赁专区', NULL, 7);
SET @rental_parent_id = LAST_INSERT_ID();
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
('正装租赁', @rental_parent_id, 1),
('礼服租赁', @rental_parent_id, 2),
('演出服租赁', @rental_parent_id, 3),
('课本租赁', @rental_parent_id, 4),
('参考书租赁', @rental_parent_id, 5);

INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES ('以物换物', NULL, 8);
SET @barter_parent_id = LAST_INSERT_ID();
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
('服饰换物', @barter_parent_id, 1),
('电子换物', @barter_parent_id, 2),
('书籍换物', @barter_parent_id, 3),
('生活换物', @barter_parent_id, 4),
('其他换物', @barter_parent_id, 5);

-- 论坛板块初始化数据
INSERT INTO `forum_board` (`name`, `description`, `icon`, `sort_order`) VALUES
('好物推荐', '分享你买到的好物，推荐给同学们', 'star', 1),
('二手经验', '二手交易心得、砍价技巧、防骗指南', 'book', 2),
('学习交流', '课程讨论、考试资料分享、学术求助', 'study', 3),
('生活互助', '校园生活问题求助、搬家、代取快递等', 'help', 4),
('闲置交换', '免费赠送或交换闲置物品', 'swap', 5),
('平台公告', '平台更新公告、使用指南、规则说明', 'announce', 6);
