# Contributing | 貢獻指南

感謝你有興趣幫手改進呢個工具！

## 如何貢獻

### 回報問題 | Bug Reports

1. 開一個 [Issue](../../issues)
2. 包括以下資料：
   - reMarkable 型號（rM2 / Paper Pro）
   - 軟件版本（`設定 → 關於`）
   - 你用咗咩字體
   - 錯誤訊息（如有）

### 新功能建議

歡迎提交 Pull Request！特別歡迎以下方面嘅改進：

- 支援更多字體格式
- 完全自動化（唔使 SSH login 觸發修復）
- 改善 Desktop App UI
- 新增語言翻譯

### 開發環境

```bash
# Clone
git clone https://github.com/YOUR_USERNAME/remarkable-chinese-fonts.git
cd remarkable-chinese-fonts

# Desktop App 開發
cd app
npm install
npm start
```

### 測試

如果你有 reMarkable，可以用 USB 連接測試。如果冇，可以用 SSH mock server 測試 App 嘅連接流程。

## License

MIT — 自由使用、修改、分發。
