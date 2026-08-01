package com.cstp.common.result;

import com.cstp.common.enums.ResultCode;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 统一响应体封装。
 *
 * <p>所有 Controller 通过本类包装返回值，确保前端收到一致的 JSON 结构：</p>
 * <pre>{@code
 * {
 *   "code": "00000",
 *   "message": "操作成功",
 *   "data": { ... },
 *   "timestamp": 1722499200000
 * }
 * }</pre>
 *
 * <h3>使用示例</h3>
 * <pre>{@code
 * // 成功
 * return Result.success(product);
 * return Result.success("操作成功", product);
 *
 * // 失败（推荐：使用 ResultCode 枚举）
 * return Result.error(ResultCode.PRODUCT_NOT_EXIST);
 * return Result.error(ResultCode.PARAM_ERROR, "商品标题不能为空");
 *
 * // 失败（兜底：动态错误码，仅在无对应枚举时使用）
 * return Result.error("B0499", "自定义错误");
 * }</pre>
 *
 * @param <T> 响应数据的类型
 * @author jackmjack
 * @since 2026/8/1
 */
@Data
public class Result<T> implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 响应码，5 位字符串，格式 XYYZZ */
    private String code;

    /** 提示信息 */
    private String message;

    /** 响应数据 */
    private T data;

    /** 时间戳（毫秒） */
    private long timestamp;

    private Result() {
        this.timestamp = System.currentTimeMillis();
    }

    private Result(String code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
        this.timestamp = System.currentTimeMillis();
    }

    /**
     * 成功响应（无数据），适用于删除、更新等无需返回数据的场景。
     */
    public static <T> Result<T> success() {
        return new Result<>(ResultCode.SUCCESS.getCode(),
                ResultCode.SUCCESS.getMessage(), null);
    }

    /**
     * 成功响应（带数据）。
     *
     * @param data 响应数据
     */
    public static <T> Result<T> success(T data) {
        return new Result<>(ResultCode.SUCCESS.getCode(),
                ResultCode.SUCCESS.getMessage(), data);
    }

    /**
     * 成功响应（自定义消息 + 数据）。
     *
     * @param message 自定义成功消息
     * @param data    响应数据
     */
    public static <T> Result<T> success(String message, T data) {
        return new Result<>(ResultCode.SUCCESS.getCode(), message, data);
    }

    /**
     * 失败响应，使用 {@link ResultCode} 枚举中定义的 code 和 message。
     *
     * @param resultCode 错误码枚举
     */
    public static <T> Result<T> error(ResultCode resultCode) {
        return new Result<>(resultCode.getCode(), resultCode.getMessage(), null);
    }

    /**
     * 失败响应，使用枚举 code，但覆盖 message（附带运行时上下文）。
     *
     * @param resultCode 错误码枚举
     * @param message    自定义错误消息
     */
    public static <T> Result<T> error(ResultCode resultCode, String message) {
        return new Result<>(resultCode.getCode(), message, null);
    }

    /**
     * 失败响应，使用枚举 code 和 message，附加错误详情数据。
     *
     * @param resultCode 错误码枚举
     * @param data       附加数据（如校验失败的具体字段列表）
     */
    public static <T> Result<T> error(ResultCode resultCode, T data) {
        return new Result<>(resultCode.getCode(), resultCode.getMessage(), data);
    }

    /**
     * 失败响应，使用自定义 code 和 message。
     *
     * <p><b>注意：</b>优先使用 {@link #error(ResultCode)}。
     * 本方法仅在需要动态构造错误码（无对应枚举值）时使用。</p>
     *
     * @param code    自定义错误码
     * @param message 错误消息
     */
    public static <T> Result<T> error(String code, String message) {
        return new Result<>(code, message, null);
    }

    /**
     * 判断当前响应是否为成功状态。
     *
     * @return {@code true} 如果 code 等于 {@code "00000"}
     */
    public boolean isSuccess() {
        return ResultCode.SUCCESS.getCode().equals(this.code);
    }
}
