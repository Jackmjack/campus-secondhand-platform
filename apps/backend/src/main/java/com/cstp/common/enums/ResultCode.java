package com.cstp.common.enums;

import lombok.Getter;

import java.util.HashMap;
import java.util.Map;

/**
 * 统一响应码枚举，遵循《阿里巴巴 Java 开发手册》错误码规范。
 *
 * <h3>错误码结构（5 位字符串）</h3>
 * <pre>
 *   X YY ZZ
 *   │ ││ └── 三级错误码：具体错误明细
 *   │ └┘──── 二级错误码：宏观错误类别
 *   └─────── 一级错误码：错误来源
 *           0 = 成功
 *           A = 用户端错误
 *           B = 系统端错误（含业务自定义）
 *           C = 调用第三方服务错误
 * </pre>
 *
 * <h3>区间分配</h3>
 * <ul>
 *   <li>A 类：A0001(一级) → A01xx 注册 A02xx 登录 A03xx 权限 A04xx 参数 A06xx 资源 A07xx 上传 A09xx 隐私</li>
 *   <li>B 类系统：B0001(一级) → B01xx 超时 B02xx 容灾 B03xx 资源</li>
 *   <li>B 类业务：B04xx 商品 B05xx 订单 B06xx 支付 B07xx 评价 B08xx 收藏 B09xx 消息 B10xx 学校</li>
 *   <li>C 类：C0001(一级) → C01xx 中间件 C02xx 超时 C03xx 数据库 C05xx 通知</li>
 * </ul>
 *
 * @author jackmjack
 * @since 2026/8/1
 */
@Getter
public enum ResultCode {

    /** 操作成功 */
    SUCCESS("00000", "操作成功"),

    /** 用户端错误（一级宏观错误码） */
    USER_ERROR("A0001", "用户端错误"),

    /** 用户注册错误 */
    REGISTER_ERROR("A0100", "用户注册错误"),
    /** 用户未同意隐私协议 */
    USER_AGREEMENT_NOT_SIGNED("A0101", "用户未同意隐私协议"),
    /** 用户名已存在 */
    USERNAME_EXISTS("A0111", "用户名已存在"),
    /** 用户名包含敏感词 */
    USERNAME_SENSITIVE("A0112", "用户名包含敏感词"),
    /** 密码强度不够 */
    PASSWORD_WEAK("A0122", "密码强度不够"),
    /** 手机号格式校验失败 */
    PHONE_FORMAT_ERROR("A0151", "手机号格式校验失败"),
    /** 邮箱格式校验失败 */
    EMAIL_FORMAT_ERROR("A0153", "邮箱格式校验失败"),

    /** 用户登录异常 */
    LOGIN_ERROR("A0200", "用户登录异常"),
    /** 用户账户不存在 */
    ACCOUNT_NOT_EXIST("A0201", "用户账户不存在"),
    /** 用户账户被冻结 */
    ACCOUNT_FROZEN("A0202", "用户账户被冻结"),
    /** 用户密码错误 */
    PASSWORD_ERROR("A0210", "用户密码错误"),
    /** 用户输入密码错误次数超限 */
    PASSWORD_RETRY_EXCEED("A0211", "用户输入密码错误次数超限"),
    /** 用户登录已过期 */
    LOGIN_EXPIRED("A0230", "用户登录已过期"),
    /** 用户验证码错误 */
    VERIFY_CODE_ERROR("A0240", "用户验证码错误"),

    /** 访问权限异常 */
    ACCESS_ERROR("A0300", "访问权限异常"),
    /** 访问未授权 */
    UNAUTHORIZED("A0301", "访问未授权"),
    /** 用户授权申请被拒绝 */
    PERMISSION_DENIED("A0303", "用户授权申请被拒绝"),
    /** 无权限使用该接口 */
    API_NO_PERMISSION("A0312", "无权限使用该接口"),
    /** 黑名单用户 */
    BLACKLIST_USER("A0321", "黑名单用户"),
    /** IP地址受限 */
    IP_FORBIDDEN("A0324", "IP地址受限"),

    /** 用户请求参数错误 */
    PARAM_ERROR("A0400", "用户请求参数错误"),
    /** 请求必填参数为空 */
    PARAM_MISSING("A0410", "请求必填参数为空"),
    /** 商品ID为空 */
    PRODUCT_ID_EMPTY("A0411", "商品ID为空"),
    /** 商品标题为空 */
    PRODUCT_TITLE_EMPTY("A0412", "商品标题为空"),
    /** 商品价格为空 */
    PRODUCT_PRICE_EMPTY("A0413", "商品价格为空"),
    /** 商品描述为空 */
    PRODUCT_DESC_EMPTY("A0414", "商品描述为空"),
    /** 商品分类为空 */
    PRODUCT_CATEGORY_EMPTY("A0415", "商品分类为空"),
    /** 订单号为空 */
    ORDER_ID_EMPTY("A0416", "订单号为空"),
    /** 订单金额为空 */
    ORDER_AMOUNT_EMPTY("A0417", "订单金额为空"),
    /** 收货地址为空 */
    ADDRESS_EMPTY("A0418", "收货地址为空"),
    /** 参数格式不匹配 */
    PARAM_FORMAT_ERROR("A0421", "参数格式不匹配"),
    /** 价格超出允许范围 */
    PRICE_OUT_OF_RANGE("A0424", "价格超出允许范围"),
    /** 数量超出允许范围 */
    QUANTITY_OUT_OF_RANGE("A0425", "数量超出允许范围"),
    /** 用户输入内容非法 */
    CONTENT_ILLEGAL("A0430", "用户输入内容非法"),
    /** 包含违禁敏感词 */
    SENSITIVE_WORD("A0431", "包含违禁敏感词"),
    /** 图片包含违禁信息 */
    IMAGE_ILLEGAL("A0432", "图片包含违禁信息"),

    /** 用户操作异常 */
    OPERATION_ERROR("A0440", "用户操作异常"),
    /** 用户支付超时 */
    PAYMENT_TIMEOUT("A0441", "用户支付超时"),
    /** 确认订单超时 */
    ORDER_CONFIRM_TIMEOUT("A0442", "确认订单超时"),
    /** 订单已关闭 */
    ORDER_CLOSED("A0443", "订单已关闭"),

    /** 用户资源异常 */
    USER_RESOURCE_ERROR("A0600", "用户资源异常"),
    /** 账户余额不足 */
    BALANCE_INSUFFICIENT("A0601", "账户余额不足"),
    /** 今日操作次数已达上限 */
    DAILY_QUOTA_EXCEEDED("A0605", "今日操作次数已达上限"),

    /** 用户上传文件异常 */
    UPLOAD_ERROR("A0700", "用户上传文件异常"),
    /** 文件类型不匹配 */
    FILE_TYPE_NOT_MATCH("A0701", "文件类型不匹配"),
    /** 文件过大 */
    FILE_TOO_LARGE("A0702", "文件过大"),
    /** 图片过大 */
    IMAGE_TOO_LARGE("A0703", "图片过大"),

    /** 用户隐私未授权 */
    PRIVACY_ERROR("A0900", "用户隐私未授权"),
    /** 摄像头未授权 */
    CAMERA_NOT_AUTHORIZED("A0902", "摄像头未授权"),
    /** 位置信息未授权 */
    LOCATION_NOT_AUTHORIZED("A0906", "位置信息未授权"),

    /** 系统执行出错（一级宏观错误码） */
    SYSTEM_ERROR("B0001", "系统执行出错"),

    /** 系统执行超时 */
    SYSTEM_TIMEOUT("B0100", "系统执行超时"),
    /** 订单处理超时 */
    ORDER_PROCESS_TIMEOUT("B0101", "订单处理超时"),

    /** 系统容灾功能被触发 */
    SYSTEM_FALLBACK("B0200", "系统容灾功能被触发"),
    /** 系统限流 */
    SYSTEM_LIMIT("B0210", "系统限流"),
    /** 系统功能降级 */
    SYSTEM_DEGRADE("B0220", "系统功能降级"),

    /** 系统资源异常 */
    RESOURCE_ERROR("B0300", "系统资源异常"),
    /** 数据库连接池耗尽 */
    DB_CONNECTION_EXHAUSTED("B0314", "数据库连接池耗尽"),
    /** 系统线程池耗尽 */
    THREAD_POOL_EXHAUSTED("B0315", "系统线程池耗尽"),
    /** 系统读取数据库失败 */
    DB_READ_FAIL("B0321", "系统读取数据库失败"),

    /** 商品不存在 */
    PRODUCT_NOT_EXIST("B0401", "商品不存在"),
    /** 商品已下架 */
    PRODUCT_OFF_SHELF("B0402", "商品已下架"),
    /** 商品已售出 */
    PRODUCT_SOLD_OUT("B0403", "商品已售出"),
    /** 商品库存不足 */
    PRODUCT_QUANTITY_INSUFFICIENT("B0404", "商品库存不足"),
    /** 商品审核不通过 */
    PRODUCT_AUDIT_FAIL("B0405", "商品审核不通过"),
    /** 无权限操作该商品 */
    PRODUCT_NO_PERMISSION("B0406", "无权限操作该商品"),

    /** 订单不存在 */
    ORDER_NOT_EXIST("B0501", "订单不存在"),
    /** 订单状态异常，不允许操作 */
    ORDER_STATUS_ERROR("B0502", "订单状态异常，不允许操作"),
    /** 订单当前不可取消 */
    ORDER_CANNOT_CANCEL("B0503", "订单当前不可取消"),
    /** 订单当前不可确认收货 */
    ORDER_CANNOT_CONFIRM("B0504", "订单当前不可确认收货"),
    /** 订单已支付，请勿重复支付 */
    ORDER_ALREADY_PAID("B0505", "订单已支付，请勿重复支付"),
    /** 该订单不属于当前用户 */
    ORDER_NOT_BELONG_USER("B0506", "该订单不属于当前用户"),

    /** 支付失败 */
    PAYMENT_ERROR("B0601", "支付失败"),
    /** 退款失败 */
    PAYMENT_REFUND_ERROR("B0602", "退款失败"),
    /** 支付渠道异常 */
    PAYMENT_CHANNEL_ERROR("B0603", "支付渠道异常"),

    /** 评价不存在 */
    EVALUATION_NOT_EXIST("B0701", "评价不存在"),
    /** 已评价，不可重复评价 */
    EVALUATION_ALREADY_EXISTS("B0702", "已评价，不可重复评价"),
    /** 无权限操作该评价 */
    EVALUATION_NO_PERMISSION("B0703", "无权限操作该评价"),

    /** 已收藏该商品 */
    FAVORITE_ALREADY_EXISTS("B0801", "已收藏该商品"),
    /** 未收藏该商品 */
    FAVORITE_NOT_EXIST("B0802", "未收藏该商品"),

    /** 消息发送失败 */
    MESSAGE_SEND_FAIL("B0901", "消息发送失败"),
    /** 消息不存在 */
    MESSAGE_NOT_EXIST("B0902", "消息不存在"),

    /** 当前学校暂未开通服务 */
    SCHOOL_NOT_SUPPORTED("B1001", "当前学校暂未开通服务"),
    /** 校区不在服务范围内 */
    CAMPUS_OUT_OF_SERVICE("B1002", "校区不在服务范围内"),

    /** 调用第三方服务出错（一级宏观错误码） */
    THIRD_PARTY_ERROR("C0001", "调用第三方服务出错"),

    /** RPC服务出错 */
    RPC_ERROR("C0110", "RPC服务出错"),
    /** RPC服务未找到 */
    SERVICE_NOT_FOUND("C0111", "RPC服务未找到"),
    /** 接口不存在 */
    INTERFACE_NOT_FOUND("C0113", "接口不存在"),

    /** 缓存服务出错 */
    CACHE_ERROR("C0130", "缓存服务出错"),
    /** key长度超过限制 */
    CACHE_KEY_TOO_LONG("C0131", "key长度超过限制"),
    /** 存储容量已满 */
    CACHE_FULL("C0133", "存储容量已满"),

    /** 第三方系统执行超时 */
    THIRD_PARTY_TIMEOUT("C0200", "第三方系统执行超时"),
    /** RPC执行超时 */
    RPC_TIMEOUT("C0210", "RPC执行超时"),
    /** 数据库服务超时 */
    DB_TIMEOUT("C0250", "数据库服务超时"),

    /** 数据库服务出错 */
    DB_ERROR("C0300", "数据库服务出错"),
    /** 表不存在 */
    TABLE_NOT_EXIST("C0311", "表不存在"),
    /** 列不存在 */
    COLUMN_NOT_EXIST("C0312", "列不存在"),
    /** 数据库死锁 */
    DB_DEADLOCK("C0331", "数据库死锁"),
    /** 主键冲突 */
    PRIMARY_KEY_CONFLICT("C0341", "主键冲突"),

    /** 通知服务出错 */
    NOTIFY_ERROR("C0500", "通知服务出错"),
    /** 短信提醒服务失败 */
    SMS_SEND_FAIL("C0501", "短信提醒服务失败"),
    /** 邮件提醒服务失败 */
    EMAIL_SEND_FAIL("C0503", "邮件提醒服务失败");

    /** 错误码（5 位字符串，格式 XYYZZ） */
    private final String code;

    /** 用户提示信息 */
    private final String message;

    ResultCode(String code, String message) {
        this.code = code;
        this.message = message;
    }

    /** code → 枚举 映射缓存，用于 O(1) 查找 */
    private static final Map<String, ResultCode> CODE_MAP = new HashMap<>();

    static {
        for (ResultCode rc : values()) {
            if (CODE_MAP.put(rc.code, rc) != null) {
                throw new IllegalStateException("ResultCode 存在重复的错误码: " + rc.code);
            }
        }
    }

    /**
     * 根据错误码字符串查找对应的枚举值。
     *
     * @param code 5 位错误码
     * @return 对应的枚举值，未找到返回 {@code null}
     */
    public static ResultCode getByCode(String code) {
        return CODE_MAP.get(code);
    }

    /**
     * 判断是否为成功码。
     *
     * @return {@code true} 如果当前枚举为 {@link #SUCCESS}
     */
    public boolean isSuccess() {
        return this == SUCCESS;
    }
}
