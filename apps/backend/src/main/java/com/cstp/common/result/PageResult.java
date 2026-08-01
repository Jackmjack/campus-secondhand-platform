package com.cstp.common.result;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Collections;
import java.util.List;
import java.util.function.Function;

/**
 * 分页响应封装。
 *
 * <p>配合分页查询使用，包装分页结果。JSON 结构示例：</p>
 * <pre>{@code
 * {
 *   "records": [ ... ],
 *   "total": 150,
 *   "page": 1,
 *   "size": 20,
 *   "pages": 8
 * }
 * }</pre>
 *
 * <h3>使用示例</h3>
 * <pre>{@code
 * // 手动构造
 * PageResult<ProductVO> page = PageResult.of(total, page, size, voList);
 *
 * // Entity → VO 转换
 * PageResult<ProductVO> voPage = entityPage.map(ProductConverter::toVO);
 *
 * // 空结果
 * return PageResult.empty();
 * }</pre>
 *
 * @param <T> 列表元素类型
 * @author jackmjack
 * @since 2026/8/1
 */
@Data
public class PageResult<T> implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 当前页数据列表 */
    private List<T> records;

    /** 总记录数 */
    private long total;

    /** 当前页码（从 1 开始） */
    private long page;

    /** 每页记录数 */
    private long size;

    /** 总页数 */
    private long pages;

    public PageResult() {
        this.records = Collections.emptyList();
    }

    public PageResult(long total, long page, long size, List<T> records) {
        this.records = records != null ? records : Collections.emptyList();
        this.total = total;
        this.page = page;
        this.size = size;
        this.pages = size > 0 ? (total + size - 1) / size : 0;
    }

    /**
     * 手动构造分页结果。
     *
     * @param total   总记录数
     * @param page    当前页码
     * @param size    每页大小
     * @param records 数据列表
     * @param <T>     记录类型
     */
    public static <T> PageResult<T> of(long total, long page, long size, List<T> records) {
        return new PageResult<>(total, page, size, records);
    }

    /**
     * 空分页结果。
     */
    public static <T> PageResult<T> empty() {
        return new PageResult<>(0, 1, 0, Collections.emptyList());
    }

    /**
     * 将分页记录从一种类型转换为另一种类型（如 Entity → VO）。
     *
     * @param converter 转换函数
     * @param <R>       目标类型
     * @return 新的 PageResult，包含转换后的数据；分页信息保持不变
     */
    public <R> PageResult<R> map(Function<? super T, R> converter) {
        List<R> converted = this.records.stream()
                .map(converter)
                .toList();
        return new PageResult<>(this.total, this.page, this.size, converted);
    }
}
