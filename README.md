# 🚀 MTHAN APP Ecosystem

Welcome to the **MTHAN Public** repository – the official distribution hub for MTHAN cloud management tools. Our mission is to provide high-performance, beautifully designed, and developer-friendly infrastructure solutions.

---

## 💎 MTHAN APP (Control Panel)

MTHAN APP is a lightweight yet ultra-modern management panel for Linux servers. Built with a focus on speed, aesthetics, and simplicity, it provides everything you need to manage your server environment with ease.

### ✨ Key Features
- **Modern UI/UX**: Premium design with full Dark/Light mode support.
- **Unified Management**: Control your apps, users, and server services from a single hub.
- **On-Demand Loading**: Super lightweight installer that downloads components only when needed.
- **User Ecosystem**: Native support for independent User Panels with isolated environments.

### 🚀 Quick Start
Install MTHAN APP on any clean Linux server (**Ubuntu/Debian/CentOS/Arch**) by running:

```bash
curl -sSL https://raw.githubusercontent.com/antoine-mai/mthan-vps/main/install.sh | bash
```

### 🖥️ Accessing the Control Panel
- **URL**: `http://YOUR_SERVER_IP:2205`
- **Port**: `2205` (Default)
- **Security**: Root-level access required for administration.

---

## 👥 MTHAN User Panel (Client Access)

The ecosystem includes a dedicated **User Application**. This allows server administrators to provide a restricted, specialized management interface for their clients.

- **On-Demand**: The User Panel binary is automatically downloaded only when you enable it for the first time.
- **Isolation**: Runs under individual user accounts at `~/.mthan/user/`.
- **Automatic Setup**: Managed directly through the main MTHAN APP interface.

---

## 🛠️ Maintenance & Uninstallation

To update your installation, simply run the installer command again or use the **Reinstall** feature in the UI. To completely remove MTHAN APP and all associated services:

```bash
/root/.mthan/root/uninstall.sh
```

---

## 🔒 Security & Standards
- **Clean Structure**: Application data is organized under standardized paths:
    - Root: `/root/.mthan/root/`
    - Users: `/home/user*/.mthan/user/`
- **Binary Integrity**: All binaries (stored in `bin/`) are compiled from source.
- **Minimal Footprint**: Optimized performance for low-resource cloud environments.

---

&copy; 2026 MTHAN. Built with ❤️ for the cloud community.