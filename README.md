# reMarkable 中文字體安裝工具 | Chinese Font Installer for reMarkable

一鍵為 reMarkable 平板安裝中文字體（繁體/簡體），支援 OS 更新後自動修復。

A one-click tool to install Chinese fonts (Traditional/Simplified) on reMarkable tablets, with auto-recovery after OS updates.

![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![reMarkable](https://img.shields.io/badge/reMarkable-Paper%20Pro%20%7C%20rM2-orange)

---

## ✨ Features

- **Drag & Drop** — 拉字體檔案（`.ttf` / `.otf`）到 App 即自動安裝
- **OS Update Proof** — 系統更新後 SSH 登入一次即自動修復
- **跨平台** — 支援 macOS 同 Windows
- **支援所有 CJK 字體** — 繁體、簡體、日文、韓文
- **Variable Font 支援** — 一個檔案包含所有粗幼（Regular、Bold、Light 等）

## 📋 前提條件 | Prerequisites

- reMarkable 2 或 Paper Pro
- USB 線連接電腦，或同一 WiFi 網絡
- SSH 密碼（在 reMarkable 上：`設定 → 關於 → 版權與授權` 底部）

## 🚀 快速開始 | Quick Start

### 方法一：用 Desktop App（推薦）

1. 從 [Releases](../../releases) 下載適合你系統嘅版本
2. 打開 App
3. 輸入 reMarkable IP 同 SSH 密碼
4. 拉字體檔案到 App
5. 撳 **Install** — 搞掂！

### 方法二：用 Command Line（懶人包）

```bash
# 1. Clone repo
git clone https://github.com/YOUR_USERNAME/remarkable-chinese-fonts.git
cd remarkable-chinese-fonts

# 2. 行安裝 script
# macOS / Linux:
chmod +x scripts/install-fonts.sh
./scripts/install-fonts.sh

# Windows (PowerShell):
.\scripts\install-fonts.ps1
```

Script 會問你：
- reMarkable IP（USB: `10.11.99.1` / WiFi: 你嘅 IP）
- SSH 密碼
- 字體檔案路徑

## 📖 懶人包（手動安裝）| Manual Guide

<details>
<summary>展開完整手動安裝步驟</summary>

### Step 1 — 搵到你嘅 SSH 密碼

在 reMarkable 上：`設定 → 關於 → 版權與授權`，碌到最底搵到 SSH 密碼。

### Step 2 — 傳字體去 reMarkable

在你電腦嘅 Terminal / PowerShell：

```bash
# macOS / Linux
scp YourFont.ttf root@10.11.99.1:/home/root/.local/share/fonts/

# Windows PowerShell
scp "C:\path\to\YourFont.ttf" root@10.11.99.1:/home/root/.local/share/fonts/
```

### Step 3 — SSH 入去設定

```bash
ssh root@10.11.99.1

# 建字體目錄（如果未有）
mkdir -p /home/root/.local/share/fonts/

# 設權限
chmod 644 /home/root/.local/share/fonts/*.ttf

# 設定 fontconfig fallback
cat > /home/root/.fonts.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Serif TC</family>
      <family>Noto Serif SC</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Serif TC</family>
      <family>Noto Serif SC</family>
    </prefer>
  </alias>
  <alias>
    <family>Noto Sans</family>
    <prefer>
      <family>Noto Serif TC</family>
      <family>Noto Serif SC</family>
    </prefer>
  </alias>
  <alias>
    <family>Noto Sans UI</family>
    <prefer>
      <family>Noto Serif TC</family>
      <family>Noto Serif SC</family>
    </prefer>
  </alias>
  <alias>
    <family>Noto Mono</family>
    <prefer>
      <family>Noto Serif TC</family>
      <family>Noto Serif SC</family>
    </prefer>
  </alias>
  <match>
    <test qual="any" name="family">
      <string>sans-serif</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Serif TC</string>
      <string>Noto Serif SC</string>
    </edit>
  </match>
  <match target="pattern">
    <edit name="family" mode="append">
      <string>Noto Serif TC</string>
      <string>Noto Serif SC</string>
    </edit>
  </match>
</fontconfig>
EOF

# 複製字體去系統目錄
mount -o remount,rw /
mkdir -p /usr/share/fonts/ttf/chinese/
cp /home/root/.local/share/fonts/*.ttf /usr/share/fonts/ttf/chinese/
chmod 644 /usr/share/fonts/ttf/chinese/*.ttf
mount -o remount,ro /

# 重建字體 cache
fc-cache -f -v

# Reboot
reboot
```

### Step 4 — 設定 OS Update 自動修復

```bash
ssh root@10.11.99.1

# 建 restore script
cat > /home/root/restore-fonts.sh << 'SCRIPT'
#!/bin/sh
FONT_SRC="/home/root/.local/share/fonts"
FONT_DST="/usr/share/fonts/ttf/chinese"

if [ -d "$FONT_SRC" ] && [ ! -d "$FONT_DST" ]; then
    mount -o remount,rw /
    mkdir -p "$FONT_DST"
    cp "$FONT_SRC"/Noto*.ttf "$FONT_DST"/
    chmod 644 "$FONT_DST"/*.ttf
    mount -o remount,ro /
fi

fc-cache -f -v

if [ ! -f "/etc/systemd/system/xochitl.service.d/fonts.conf" ]; then
    mkdir -p /etc/systemd/system/xochitl.service.d/
    cat > /etc/systemd/system/xochitl.service.d/fonts.conf << 'OVERRIDE'
[Service]
ExecStartPre=/home/root/restore-fonts.sh
OVERRIDE
    systemctl daemon-reload
fi
SCRIPT
chmod +x /home/root/restore-fonts.sh

# 設定 auto-trigger on SSH login
cat > /home/root/.profile << 'EOF'
if [ ! -d "/usr/share/fonts/ttf/chinese" ] || [ ! -f "/etc/systemd/system/xochitl.service.d/fonts.conf" ]; then
    /home/root/restore-fonts.sh
    systemctl restart xochitl
fi
EOF

# 行一次
/home/root/restore-fonts.sh
systemctl restart xochitl
```

</details>

## 🔧 OS Update 後點算？

reMarkable 嘅 `/etc` 係 volatile overlay，每次 reboot 或 OS update 都會重置。

**你嘅字體檔案同設定唔會消失**（全部喺 `/home/root/`，獨立 encrypted partition）。

**主介面書名變方塊？** 只需要：
```bash
ssh root@10.11.99.1
# .profile 會自動修復，等幾秒
# 如果未自動修復：
systemctl restart xochitl
```

**PDF/EPUB 入面嘅中文：** 通常自動 work，因為 fontconfig 會搵到 `/home/root/.local/share/fonts/` 入面嘅字體。

## 📁 reMarkable 上嘅檔案結構

```
/home/root/                          ← persist（唔會被 OS update 覆蓋）
├── .local/share/fonts/              ← 字體檔案
│   ├── NotoSerifTC-VariableFont_wght.ttf
│   └── NotoSerifSC-VariableFont_wght.ttf
├── .fonts.conf                      ← fontconfig fallback 設定
├── .profile                         ← SSH login 自動修復 trigger
└── restore-fonts.sh                 ← 修復 script

/usr/share/fonts/ttf/chinese/        ← 系統字體（OS update 會覆蓋，restore script 會修復）
/etc/systemd/system/xochitl.service.d/fonts.conf  ← xochitl override（volatile，自動重建）
```

## ⚠️ 已知限制

- **Noto Serif CJK 無 Italic** — CJK 字體普遍無斜體
- **OS update 後主介面需要 SSH 一次** — `/etc` 係 volatile，暫時冇方法完全自動化
- **reMarkable 空間有限** — 建議用 Variable Font（一個檔包曬所有 weight）

## 🙏 Credits

- [Noto Fonts by Google](https://fonts.google.com/noto) — 開源 CJK 字體
- [reMarkable Wiki](https://remarkable.guide/) — 社群指南
- 靈感來自 [chenhunghan 嘅 Gist](https://gist.github.com/chenhunghan/b9dbb6ad4095fa12c31838784c26073d)

## 📄 License

MIT License — 自由使用、修改、分發。
