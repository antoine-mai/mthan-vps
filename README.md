# 🚀 MTHAN VPS Platform

Welcome to the **MTHAN VPS** – an ultra-modern, lightweight, and high-performance management panel designed to transform how you control your Linux infrastructure. 

Built with **Go** and **React**, MTHAN provides a premium, unified experience for managing apps, users, and server services with zero overhead.

---

## 💎 Features at a Glance

*   **⚡ Lightning Fast**: Compiled Go binary for maximum performance and minimal memory footprint.
*   **🎨 Premium UI/UX**: Sleek, responsive dashboard with native Dark/Light mode support.
*   **🛡️ Secure Isolation**: Multi-user support with isolated environments for client panels.
*   **📦 On-Demand Ecosystem**: Intelligent installer that only downloads what you need, when you need it.
*   **🧩 Modules Included**: Manage Docker containers, System Services, Backups, and more from one hub.

---

## 🚀 Quick Start

Ensure you are running on a clean **Ubuntu, Debian, CentOS, or Arch** server, then execute:

### ✨ Installation (CLEAN INSTALL)
> [!WARNING]
> This command will **WIPE ALL DATA** in `/root/.mthan/`. Use this only for fresh installations.

```bash
curl -sSL https://raw.githubusercontent.com/antoine-mai/mthan-vps/main/install.sh | bash
```

### 🖥️ Accessing the Panel
*   **URL**: `http://YOUR_SERVER_IP:2205`
*   **Port**: `2205` (Default)
*   **Authentication**: Use your existing **Linux System Users** to log in.

---

## 🛠️ Maintenance & Repair

### 🔄 Updating (REPAIR MODE)
To update the binary or fix a corrupted installation **while keeping all your data and configurations**, use the repair flag:

```bash
curl -sSL https://raw.githubusercontent.com/antoine-mai/mthan-vps/main/install.sh | bash -s -- --repair
```

### 🗑️ Uninstallation
To completely remove the MTHAN platform and its associated services:

```bash
sudo /root/.mthan/vps/uninstall.sh
```

---

## 📂 System Structure

MTHAN follows a clean, standardized file hierarchy:

| Path | Description |
| :--- | :--- |
| `/usr/local/bin/mthan/` | Application binaries (CPanel/VPS) |
| `/root/.mthan/vps/` | Working directory, local configuration, and logs |
| `/root/.mthan/vps/database/` | Infrastructure metadata and SQLite stores |
| `/home/user*/.mthan/` | Isolated client panel data (User Ecosystem) |

---

## 🔒 Security Standards
- **Binary Integrity**: All platform binaries are compiled directly for your architecture.
- **Root-Level Precision**: Core services run with minimum required privileges where possible.
- **Firewall Aware**: Automatically detects and configures `UFW` or `Firewalld`.

---

&copy; 2026 **MTHAN**. Built with ❤️ for the modern cloud.