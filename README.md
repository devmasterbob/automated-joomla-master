# Optional customization:

### ⚠️ Database Settings After First Installation

After the initial setup, all database-related variables (`MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`, `MYSQL_USER`, `MYSQL_DATABASE`) are locked and cannot be changed via `.env`. Any changes to these variables will be ignored and a warning will be shown. Only Joomla settings (admin password, site name, admin email) and ports can be changed safely.

If you need to change database settings, you must perform a fresh installation (remove the database volume and restart the project).
# 🚀 Automated Joomla Master

> **🌍 [Deutsch](README.de.md) | English | [Add your language](https://github.com/devmasterbob/automated-joomla-master/issues)**

**The ultimate automated Docker-based Joomla CMS development-to-production system** with Interactive Landing Page, MySQL, and phpMyAdmin - **no manual browser installation required!**

[![GitHub stars](https://img.shields.io/github/stars/devmasterbob/automated-joomla-master?style=social)](https://github.com/devmasterbob/automated-joomla-master/stargazers)
[![GitHub license](https://img.shields.io/github/license/devmasterbob/automated-joomla-master)](https://github.com/devmasterbob/automated-joomla-master/blob/main/LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Required-blue?logo=docker)](https://www.docker.com/)
[![Joomla](https://img.shields.io/badge/Joomla-5.0-orange?logo=joomla)](https://www.joomla.org/)

## 🎬 Quick Demo

**From zero to production-ready Joomla in under 4 steps!**

```bash
# 1. Clone repository
git clone https://github.com/devmasterbob/automated-joomla-master.git my-joomla-project
cd my-joomla-project

# 2. Prepare project
.\prepare.ps1

# 3. Configure (edit .env as needed)
# 4. Run
.\start-project.ps1
# Wait 2-3 minutes ⏰ 
# Open: http://localhost:81 🎉
```

## ⭐ **Why Choose Automated Joomla Master?**

**Problem:** Manual Joomla setup is time-consuming and error-prone  
**Solution:** Complete automation with professional development workflow

| Traditional Setup | Automated Joomla Master |
|-------------------|-------------------------|
| 🕐 30+ minutes manual configuration | ⚡ 3 minutes fully automated |
| 🐛 Error-prone browser setup | ✅ Zero-error installation |
| 📝 Complex documentation reading | 🎯 One command to rule them all |
| 🔧 Manual database setup | 🚀 Everything pre-configured |

## 🌟 Key Features

- ✅ **Fully Automated Joomla Installation** - Zero manual browser setup
- ✅ **4-Container Architecture** - Landing Page + Joomla 5 + MySQL 8.0 + phpMyAdmin  
- ✅ **Interactive Development History** - Complete project documentation in Landing Page
- ✅ **Provider Deployment Tools** - One-click database export for production
- ✅ **VS Code Integration** - Professional development workflow  
- ✅ **Environment-based Configuration** - All settings in .env file
- ✅ **Production-Ready Optimizations** (OPcache, Apache modules)
- ✅ **Multiple Complexity Levels** - Choose your version

## 🎯 Available Versions

| Branch | Description | Components | Best For |
|--------|-------------|------------|----------|
| **`main`** | **Complete Version** ⭐ | Landing + Joomla + MySQL + phpMyAdmin + Full Automation | **All Projects** |

## 🚀 Getting Started

### Prerequisites

- **Docker** & **Docker Compose** installed
- **4GB+ RAM** available
- **VS Code** recommended for development

### Quick Start for New Projects

#### 1. Create New Project Directory & Open VS Code
```bash
mkdir my-awesome-joomla-project
cd my-awesome-joomla-project
code .  # Opens VS Code
```

#### 2. Open Terminal in VS Code & Clone Repository
- **Terminal** → **New Terminal** (or `Ctrl+Shift+ö`)
- Clone repository directly into current directory:

```bash
git clone https://github.com/devmasterbob/automated-joomla-master.git .
```

#### 3. ⚙️ Prepare Project Environment
**RECOMMENDED APPROACH:** Use automated setup with folder name detection:

```powershell
# Automated setup - detects folder name automatically:
.\prepare.ps1
```

This script will:
- ✅ Create `.env` file with your actual folder name as PROJECT_NAME
- ✅ Validate Docker-compatible naming
- ✅ Guide you through password customization
- ✅ Show you exactly what to edit

**Alternative:** Manual `.env` creation:

```bash
# Manual approach (if you prefer):
cp .env-example .env
# Then edit .env manually
```

**🔧 Key Settings to Customize in .env:**

```env
# PROJECT_NAME automatically set by prepare.ps1
PROJECT_NAME=your-actual-project-name  

# Security - customize these passwords (minimum 12 characters required!):
MYSQL_PASSWORD=mysql12345678
MYSQL_ROOT_PASSWORD=mysql12345678
JOOMLA_ADMIN_PASSWORD=admin12345678
```

**⚠️ IMPORTANT:** All passwords must be **at least 12 characters** long, otherwise the automatic installation will fail!

# Optional customization:
JOOMLA_ADMIN_EMAIL=your-email@your-domain.com
JOOMLA_SITE_NAME=Your Project Name
```

#### 4. Start System (Option A - With Beautiful Notifications)
```powershell
# In VS Code Terminal - RECOMMENDED:
.\start-project.ps1
```

**OR**

#### 4. Start System (Option B - Standard)
```bash
# In VS Code Terminal:
docker-compose up -d
```

#### 5. ⏱️ **IMPORTANT: Wait 2-3 minutes!**
> **🚨 The system needs time for automatic installation!**
> 
> **What happens in the background:**
> - Joomla is downloaded
> - Database is automatically configured
> - Joomla is fully installed
> - Installation directory is automatically removed
> 
> **Please be patient!** Only open http://localhost:80 after **2-3 minutes**.
> 
> **Check status:**
> ```bash
> # Follow container logs (optional):
> docker-compose logs -f joomla
> ```

#### 6. ✅ Ready!
- **Project Info:** http://localhost:81
- **Joomla:** http://localhost:80
- **phpMyAdmin:** http://localhost:82

## 🔧 Configuration

### Default Ports
- **Project Info:** Port 81
- **Joomla:** Port 80
- **phpMyAdmin:** Port 82
- **MySQL:** Port 3306 (internal)

### Default Credentials
- **Joomla Admin:** 
  - Username: `joomla` (from .env: MYSQL_USER)
  - Password: `joomla@secured` (from .env: JOOMLA_ADMIN_PASSWORD)

- **phpMyAdmin:**
  - Username: `root`
  - Password: `rootpass` (from .env: MYSQL_ROOT_PASSWORD)

## 📦 Create Your Own GitHub Repository

After development, you'll probably want to save your project in your own GitHub repository:

### 🚀 **Automatic Repository Preparation**

**Good news:** On first `.\start-project.ps1` run, `.git` and `.github` folders are automatically removed!

Your project is then immediately ready for its own repository:

```powershell
# After first start, your project is already independent!
# Simply create a new Git repository:

git init
git add .
git commit -m "Initial Joomla project"

# Connect to your own GitHub repository:
git remote add origin https://github.com/YOUR-USERNAME/YOUR-PROJECT.git
git push -u origin main
```

### 💾 **What gets versioned:**
- ✅ **Joomla files** (`joomla/` folder) 
- ✅ **Docker configuration** (docker-compose.yaml, scripts)
- ❌ **Database content** (use `.\export-database.ps1` for backups)
- ❌ **.env file** (security best practice - `.env-example` as template)

### 💡 **Recommended .gitignore:**
```gitignore
# Environment files
.env
.env.local

# Joomla specific
joomla/cache/
joomla/tmp/
joomla/logs/

# Development
*.log
.DS_Store
```

## 🌐 Production Deployment

### Export Database for Provider Upload

Use the included PowerShell script for automated export:

```bash
# Windows (PowerShell)
.\export-database.ps1

# Manual export (Linux/macOS)
docker-compose exec db mysqldump -u root -p joomla_db > backup.sql
```

### Files to Upload to Provider

1. **Complete `joomla/` folder** → Upload to web directory
2. **SQL backup file** → Import via provider's phpMyAdmin
3. **Edit `joomla/configuration.php`** → Update database credentials for provider

### Provider Configuration

Update these values in `joomla/configuration.php`:
```php
public $host = 'your-provider-db-host';
public $user = 'your-provider-db-user'; 
public $password = 'your-provider-db-password';
public $db = 'your-provider-db-name';
```

## 🔧 Troubleshooting

### ❌ Error 500 / "This page isn't working"

**Most common causes:**
1. **Problematic password characters** - `§`, `$`, `` ` ``, `"`, `'`, `\`
2. **Old MySQL volumes** with wrong passwords

**Solutions:**
```bash
# Step 1: Check your passwords in .env
# Avoid: § $ ` " ' \ characters
# Safe: A-Z a-z 0-9 - _ . + * # @ % & ( ) = ? !

# Step 2: Complete cleanup and restart
docker-compose down -v --remove-orphans
.\start-project.ps1
```

### 🚨 Port Already in Use

**Error:** `port is already allocated`

**Solution:**
```bash
# Stop conflicting services
docker ps  # Check running containers
docker stop $(docker ps -q)  # Stop all containers
# Or stop specific services like MySQL, Apache, etc.
```

### Container Won't Start
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs joomla

# Restart containers
docker-compose restart
```

### Joomla Shows 404 Error
- Clear browser cache (`Ctrl+F5`)
- Wait 2-3 minutes for installation to complete
- Check if containers are running: `docker-compose ps`

### Database Connection Issues
```bash
# Test database connection
docker-compose exec joomla mysql -h db -u joomla -p

# Restart database container
docker-compose restart db
```

### Browser Shows "Site Offline"
This is normal during initial setup! Wait 2-3 minutes for automatic installation.

## 📋 System Requirements

- **Docker** 20.10+ and **Docker Compose** v2.0+
- **Minimum 4GB RAM** for all containers
- **Windows 10/11** with WSL2, **Linux**, or **macOS**
- **Modern browser** (Chrome, Firefox, Safari, Edge)
- **Free Ports:** 80, 81, 82, 3306 (stop any running MySQL/Apache containers first)

## 🤝 Contributing

We welcome contributions from the global community! 

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b amazing-feature`
3. **Commit** your changes: `git commit -am 'Add amazing feature'`
4. **Push** to the branch: `git push origin amazing-feature`
5. **Open** a Pull Request

### 🎯 Areas Where We Need Help

- 📚 **Documentation** improvements and translations
- 🐛 **Bug fixes** and testing on different platforms
- 🌐 **Translations** (Spanish, French, Italian, etc.)
- 🚀 **New features** and optimizations
- 🎨 **UI/UX** improvements for Landing Page

### ⚠️ **Developer Note**

Before committing, ensure `.env-example` contains `PROJECT_NAME=${CURRENT_FOLDER}`:
```powershell
.\check-env-example.ps1  # Quick protection check
```

## ⭐ Show Your Support

If this project helped you save time and effort:

- ⭐ **Star** the repository
- 🐛 **Report** issues you find
- 💡 **Suggest** new features
- 🗣️ **Share** with the Joomla community
- 🤝 **Contribute** code or documentation

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- 🧡 **Joomla Community** - For creating an amazing CMS
- 🐳 **Docker Team** - For making containerization accessible  
- 👥 **All Contributors** - Who help improve this project
- 💝 **Open Source Community** - For inspiring collaborative development

## 🆘 Support & Community

- 📚 **Documentation:** Complete guides available above
- 🐛 **Bug Reports:** [GitHub Issues](https://github.com/devmasterbob/automated-joomla-master/issues)
- 💬 **Feature Discussions:** [GitHub Discussions](https://github.com/devmasterbob/automated-joomla-master/discussions)  
- 📧 **Direct Contact:** Open an issue for any questions

---

<div align="center">

**Made with ❤️ for the global Joomla community**

⭐ **Star this repo if it helped you!** ⭐

[🌟 Star](https://github.com/devmasterbob/automated-joomla-master/stargazers) • [🐛 Issues](https://github.com/devmasterbob/automated-joomla-master/issues) • [💬 Discussions](https://github.com/devmasterbob/automated-joomla-master/discussions)

</div>