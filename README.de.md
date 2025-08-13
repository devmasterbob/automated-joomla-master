# 🚀 Automated Joomla Master

> **🌍 Deutsch | [English](README.md) | [Weitere Sprachen](https://github.com/devmasterbob/automated-joomla-master/issues)**

**Das ultimative automatisierte Docker-basierte Joomla CMS Development-to-Production System** mit interaktiver Landing Page, MySQL und phpMyAdmin - **keine manuelle Browser-Installation erforderlich!**

[![GitHub stars](https://img.shields.io/github/stars/devmasterbob/automated-joomla-master?style=social)](https://github.com/devmasterbob/automated-joomla-master/stargazers)
[![GitHub license](https://img.shields.io/github/license/devmasterbob/automated-joomla-master)](https://github.com/devmasterbob/automated-joomla-master/blob/main/LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Required-blue?logo=docker)](https://www.docker.com/)
[![Joomla](https://img.shields.io/badge/Joomla-5.0-orange?logo=joomla)](https://www.joomla.org/)

## 🎬 Quick Demo

1. **Clone** → 2. **Prepare** → 3. **Configure** → 4. **Run** → **✨ Ready!**

```bash
git clone https://github.com/devmasterbob/automated-joomla-master.git my-joomla-project
cd my-joomla-project
.\prepare.ps1                # Creates .env with correct project name
# Edit .env file and customize passwords (minimum 12 characters!)
.\start-project.ps1          # Starts all containers
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

- ✅ **Fully Automated Joomla Installation** - zero manual browser setup
- ✅ **4-Container Architecture** - Landing Page + Joomla 5 + MySQL 8.0 + phpMyAdmin  
- ✅ **Interactive Development History** - Complete project documentation in Landing Page
- ✅ **Provider Deployment Tools** - One-click database export for production
- ✅ **VS Code Integration** - Professional development workflow  
- ✅ **Environment-based Configuration** - All settings in .env file
- ✅ **Production-Ready Optimizations** (OPcache, Apache modules)
- ✅ **Multiple Complexity Levels** - Choose your version

## 🎯 Available Versions

| Branch | Description | Components |
|--------|-------------|------------|
| **`main`** | **Complete Version** (recommended) | Landing Page + Joomla + MySQL + phpMyAdmin + Full Automation |

## 🚀 Schnellstart für neue Projekte

### 1. Neues Projektverzeichnis erstellen & VS Code öffnen
```bash
# Neuen Ordner erstellen und VS Code öffnen
mkdir mein-neues-projekt
cd mein-neues-projekt
code .
```

### 2. Terminal in VS Code öffnen & Repository klonen
- **Terminal** → **New Terminal** (oder `Strg+Shift+ö`)
- Repository direkt ins aktuelle Verzeichnis klonen:

```bash
git clone https://github.com/devmasterbob/automated-joomla-master.git .
```

### 3. 🔧 Projekt vorbereiten
**NEU:** Verwenden Sie das Prepare-Script für einfache Einrichtung:

```powershell
# Projekt automatisch vorbereiten (empfohlen)
.\prepare.ps1
```

Das Script:
- ✅ Aktualisiert `.env-example` mit dem korrekten Projektnamen
- ✅ Erstellt `.env` Datei automatisch
- ✅ Zeigt klare Anweisungen für Passwort-Anpassung

**Alternativ (manuell):**
```bash
# Manuelle .env Erstellung (nur wenn prepare.ps1 nicht verwendet)
cp .env-example .env
```

Ändern Sie in der `.env` Datei mindestens:

```env
# MUSS geändert werden - Name des Projektordners verwenden:
PROJECT_NAME=mein-neues-projekt

# Sicherheit - eigene Passwörter verwenden (mindestens 12 Zeichen!):
MYSQL_PASSWORD=mysql12345678
MYSQL_ROOT_PASSWORD=mysql12345678
JOOMLA_ADMIN_PASSWORD=admin12345678
```

**⚠️ WICHTIG:** Alle Passwörter müssen **mindestens 12 Zeichen** lang sein, sonst schlägt die automatische Installation fehl!

# Optional anpassen:
JOOMLA_ADMIN_EMAIL=admin@meinedomain.com
JOOMLA_SITE_NAME=Mein Joomla Projekt
```

### 4. System starten
```powershell
# Im VS Code Terminal:
.\start-project.ps1
```

### 5. ⏱️ **WICHTIG: Warten Sie 2-3 Minuten!**
> **🚨 Das System braucht Zeit für die automatische Installation!**
> 
> **Was passiert im Hintergrund:**
> - Joomla wird heruntergeladen
> - Datenbank wird automatisch eingerichtet
> - Joomla wird vollständig installiert
> - Installation-Verzeichnis wird automatisch entfernt
> 
> **Bitte haben Sie Geduld!** Öffnen Sie http://localhost:80 erst nach **2-3 Minuten**.
> 
> **Status prüfen:**
> ```bash
> # Container-Logs verfolgen (optional):
> docker-compose logs -f joomla
> ```

### 6. ✅ Fertig!
- **Projekt-Info:** http://localhost:81
- **Joomla:** http://localhost:80
- **phpMyAdmin:** http://localhost:82

## 🔧 Konfiguration

### Standard-Ports
- **Projekt-Info:** Port 81
- **Joomla:** Port 80
- **phpMyAdmin:** Port 82
- **MySQL:** Port 3306 (intern)

### Standard-Zugangsdaten
- **Joomla Admin:** 
  - Benutzername: `joomla` (aus .env: MYSQL_USER)
  - Passwort: `joomla@secured` (aus .env: JOOMLA_ADMIN_PASSWORD)

- **phpMyAdmin:**
  - Benutzername: `root`
  - Passwort: `rootpass` (aus .env: MYSQL_ROOT_PASSWORD)

## 📁 Projektstruktur

```
.
├── docker-compose.yaml    # Hauptkonfiguration
├── .env-example          # Vorlage für Konfiguration
├── .env                  # Ihre lokalen Einstellungen (wird erstellt)
├── README.md             # Diese Anleitung
├── CHAT_HISTORY.md       # Entwicklungsdokumentation
├── export-database.ps1   # Provider-Export Skript
├── Dockerfile            # Custom Joomla Build (für Entwicklung)
├── docker-entrypoint.sh  # Automatisierungsskript
├── setup-joomla.sh       # Joomla Setup Automatisierung
├── install-joomla-db.php # Datenbank Installation
├── landing/              # Projekt Landing-Page (Port 81)
│   ├── index.php        # Projekt-Informationsseite
│   ├── style.css        # Styling
│   └── favicon.*        # Icons
└── joomla/               # Joomla Dateien (Volume Mount)
```

## 🛠️ Entwicklung

### Container verwalten
```powershell
# Im VS Code Terminal:

# Starten
.\start-project.ps1

# Stoppen
docker-compose down

# Logs anzeigen
docker-compose logs -f

# Neustart nach Änderungen
docker-compose down && docker-compose up -d
```

### Dateien bearbeiten
Alle Joomla-Dateien befinden sich im `joomla/` Ordner und können direkt bearbeitet werden.

### Datenbank-Zugriff
- **Über phpMyAdmin:** http://localhost:82
- **Direkt über MySQL:** `mysql -h localhost -P 3306 -u root -p`

## 📤 Provider-Upload & Deployment

### Datenbank exportieren
```powershell
# Im VS Code Terminal (PowerShell):
.\export-database.ps1
```

**Das Skript:**
- ✅ Liest automatisch die `.env` Konfiguration
- ✅ Erstellt SQL-Datei: `projektname_database_export_2025-08-10_15-30.sql`
- ✅ Zeigt detaillierte Upload-Anleitung

### Kompletter Provider-Upload Workflow

#### 1. 📋 Vorbereitung
```bash
# Stelle sicher, dass Container laufen:
docker-compose ps

# Exportiere die Datenbank:
.\export-database.ps1
```

#### 2. 📁 Dateien sammeln
**Benötigte Dateien:**
- **Datenbank:** `projektname_database_export_DATUM.sql` (vom Skript erstellt)
- **Joomla-Dateien:** Kompletter Inhalt des `joomla/` Ordners

#### 3. 🌐 Beim Provider hochladen
**Schritt A: FTP-Upload**
```bash
# Alle Dateien aus joomla/ ins Web-Verzeichnis des Providers
# Beispiel-Struktur beim Provider:
/public_html/
├── index.php
├── administrator/
├── components/
├── configuration.php  # ← Diese Datei anpassen!
└── ...
```

**Schritt B: Datenbank importieren**
1. Provider-phpMyAdmin öffnen
2. Neue Datenbank erstellen (falls nötig)
3. **Importieren** → SQL-Datei hochladen
4. Import durchführen

**Schritt C: Configuration.php anpassen**
```php
<?php
class JConfig {
    // Provider-Datenbankdaten eintragen:
    public $host = 'provider-mysql-host';      // z.B. 'localhost' oder 'mysql.provider.com'
    public $user = 'provider-db-username';     // Vom Provider erhalten
    public $password = 'provider-db-password'; // Vom Provider erhalten
    public $db = 'provider-db-name';          // Datenbankname beim Provider
    
    // Andere Einstellungen bleiben meist unverändert:
    public $dbtype = 'mysqli';
    public $dbprefix = 'joom_';
    // ... rest bleibt gleich
}
```

#### 4. ✅ Live-Test
- Website unter Provider-Domain aufrufen
- Frontend testen
- Admin-Login testen: `/administrator`

### 🔄 Regelmäßige Backups
```powershell
# Wöchentlichen Export für Backup:
.\export-database.ps1

# Zusätzlich Joomla-Dateien sichern:
# Kopiere joomla/ Ordner an sicheren Ort
```

## � Eigenes GitHub-Repository erstellen

Nach der Entwicklung möchten Sie Ihr Projekt wahrscheinlich in einem eigenen GitHub-Repository sichern:

### 🚀 **Automatische Repository-Vorbereitung**

**Gute Nachricht:** Beim ersten `.\start-project.ps1` Aufruf werden automatisch `.git` und `.github` Ordner entfernt!

Ihr Projekt ist dann sofort bereit für ein eigenes Repository:

```powershell
# Nach dem ersten Start ist Ihr Projekt bereits unabhängig!
# Erstellen Sie einfach ein neues Git-Repository:

git init
git add .
git commit -m "Initial Joomla project"

# Mit eigenem GitHub-Repository verbinden:
git remote add origin https://github.com/IHR-USERNAME/IHR-PROJEKT.git
git push -u origin main
```

### 💾 **Was wird versioniert:**
- ✅ **Joomla-Dateien** (`joomla/` Ordner) 
- ✅ **Docker-Konfiguration** (docker-compose.yaml, Dockerfile)
- ✅ **Scripts** (prepare.ps1, start-project.ps1, export-database.ps1)
- ❌ **Datenbank-Inhalte** (für Backups: `.\export-database.ps1` verwenden)
- ❌ **.env Datei** (aus Sicherheitsgründen)

## �🔒 Sicherheitshinweise

⚠️ **Vor Produktionseinsatz:**
- Alle Passwörter in `.env` ändern
- `MYSQL_ROOT_PASSWORD` besonders stark wählen
- `JOOMLA_ADMIN_PASSWORD` komplex gestalten
- Ports je nach Bedarf anpassen

## 🎨 Anpassungen

### Andere Ports verwenden
In `.env` ändern:
```env
PORT_LANDING=8081
PORT_JOOMLA=8080
PORT_PHPMYADMIN=8082
```

### Andere Joomla Version
Im `Dockerfile` die Download-URL anpassen:
```dockerfile
curl -o joomla.tar.zst -SL https://github.com/joomla/joomla-cms/releases/download/[VERSION]/[PACKAGE].tar.zst
```

## 🐛 Troubleshooting

### ⏱️ "Joomla lädt nicht" / "Seite nicht verfügbar"
**LÖSUNG:** Warten Sie 2-3 Minuten nach `docker-compose up -d`!
```bash
# Status der Container prüfen:
docker-compose ps

# Installation verfolgen:
docker-compose logs -f joomla

# Warten bis Sie sehen: "Complete! Joomla has been successfully copied"
```

### Container starten nicht
```bash
# Ports überprüfen
netstat -an | grep :80
netstat -an | grep :81
netstat -an | grep :82

# Container-Status prüfen
docker-compose ps
docker-compose logs
```

### Joomla zeigt Fehler
```bash
# Container-Logs prüfen
docker-compose logs joomla

# In Container einsteigen
docker-compose exec joomla bash
```

### Datenbank-Verbindungsfehler
```bash
# MySQL-Container prüfen
docker-compose logs db

# Datenbank-Verbindung testen
docker-compose exec joomla mysql -h db -u joomla -p
```

### Browser zeigt 404
- Browser-Cache leeren (Strg+F5)
- Container neu starten: `docker-compose restart`

## 📋 Systemanforderungen

- **Docker** und **Docker Compose**
- **Mindestens 4GB RAM** für alle Container
- **Windows 10/11** mit WSL2 oder **Linux/macOS**

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b amazing-feature`
3. **Commit** your changes: `git commit -am 'Add amazing feature'`
4. **Push** to the branch: `git push origin amazing-feature`
5. **Open** a Pull Request

### 🎯 Areas where we need help:
- 📚 Documentation improvements
- 🐛 Bug fixes and testing
- 🌐 Translations
- 🚀 New features and optimizations

## ⭐ Show Your Support

If this project helped you, please consider:
- ⭐ **Starring** the repository
- 🐛 **Reporting** issues
- 💡 **Suggesting** new features
- 🗣️ **Sharing** with the Joomla community

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Joomla Community** for the amazing CMS
- **Docker Team** for containerization technology
- **All Contributors** who help improve this project

## 🆘 Support & Community

- 📚 **Documentation:** Check our comprehensive guides above
- 🐛 **Issues:** [GitHub Issues](https://github.com/devmasterbob/automated-joomla-master/issues)
- 💬 **Discussions:** [GitHub Discussions](https://github.com/devmasterbob/automated-joomla-master/discussions)
- 📧 **Contact:** Open an issue for any questions

---

**Made with ❤️ for the Joomla community** | **Star ⭐ if this project helped you!**
2. GitHub Issues verwenden
3. Logs immer mit anhängen: `docker-compose logs`

## 🎉 Credits

- **Joomla CMS:** https://www.joomla.org/
- **Docker:** https://www.docker.com/
- **phpMyAdmin:** https://www.phpmyadmin.net/

---
**Entwickelt für maximale Automatisierung und Entwicklerfreundlichkeit** 🚀
