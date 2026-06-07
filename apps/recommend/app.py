"""
校园二手平台 - AI推荐服务
Python Flask 微服务，通过 REST API 与 Spring Boot 后端通信
"""

from flask import Flask, jsonify, request

app = Flask(__name__)


@app.route("/health", methods=["GET"])
def health():
    """健康检查接口"""
    return jsonify({"status": "ok", "service": "campus-recommend"})


@app.route("/recommend", methods=["POST"])
def recommend():
    """
    商品推荐接口
    请求体: {"user_id": 1, "limit": 20}
    响应: {"product_ids": [1, 2, 3, ...]}
    """
    data = request.get_json()
    user_id = data.get("user_id")
    limit = data.get("limit", 20)

    # TODO: 实现推荐算法
    # - 冷启动: 热门商品兜底
    # - 协同过滤: UserCF + ItemCF
    # - 内容推荐: 基于商品属性
    return jsonify({
        "user_id": user_id,
        "product_ids": [],
        "method": "placeholder",
        "message": "推荐算法待实现"
    })


@app.route("/behavior", methods=["POST"])
def record_behavior():
    """
    用户行为记录接口
    请求体: {"user_id": 1, "product_id": 1, "behavior_type": "VIEW", "duration_ms": 5000}
    """
    data = request.get_json()
    # TODO: 存储行为数据用于训练推荐模型
    return jsonify({"status": "ok", "message": "行为已记录"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
