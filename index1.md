# 🔧 HDY Auto 工具文档

<style>
/* 整体区域 */
.doc-container {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial;
  line-height: 1.6;
}

/* 代码块盒子 */
.copy-box { 
  display:flex;
  align-items:center;
  background:#f8f8f8;
  padding:12px;
  border-radius:8px;
  border:1px solid #e1e1e1;
  margin-top:8px;
}
.copy-btn {
  margin-left:10px;
  padding:6px 12px;
  border:none;
  background:#007bff;
  color:white;
  border-radius:6px;
  cursor:pointer;
  font-size:14px;
}
.copy-btn:hover {
  background:#0056b3;
}

/* 标题美化 */
h2 {
  border-bottom: 1px solid #eee;
  padding-bottom: 4px;
}
</style>

<div class="doc-container">

---

# 📚 目录

<details>
<summary><b>点击展开目录</b></summary>

- [快速开始](#快速开始)
- [.env 文件格式化](#env-文件格式化)
- [.yml 文件格式化](#yml-文件格式化)
- [脚本来源说明](#脚本来源说明)
- [常见问题](#常见问题)

</details>

---

# 🚀 快速开始

HDY Auto 提供便捷的格式化工具，用于：

- 清理 `.env` 文件  
- 美化 `.yaml / .yml` 文件  
- 自动排版、删除空行、对齐格式  

无需安装任何依赖，直接运行即可。

---

# 🧩 .env 文件格式化

将 `.env` 自动整理（对齐、移除空行、排序）。

<div class="copy-box">
  <code>bash &lt;(curl -sL install.hdyauto.qzz.io/format-envs)</code>
  <button class="copy-btn"
    onclick="navigator.clipboard.writeText('bash <(curl -sL install.hdyauto.qzz.io/format-envs)')">
    复制
  </button>
</div>

---

# 📑 .yml 文件格式化

自动格式化 YAML 文件（缩进修复、顺序优化、校验结构）。

<div class="copy-box">
  <code>bash &lt;(curl -sL install.hdyauto.qzz.io/format-yml)</code>
  <button class="copy-btn"
    onclick="navigator.clipboard.writeText('bash <(curl -sL install.hdyauto.qzz.io/format-yml)')">
    复制
  </button>
</div>

---

# 🧭 脚本来源说明

所有脚本均来自：