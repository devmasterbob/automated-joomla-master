# 🚀 Automatisierte Joomla Entwicklungsumgebung

Eine vollständig automatisierte Docker-basierte Joomla CMS Entwicklungsumgebung mit MySQL und phpMyAdmin - **keine manuelle Browser-Installation erforderlich!**

## 🌟 Features

- ✅ **Vollautomatische Joomla Installation** - kein manuelles Setup im Browser
- ✅ **Joomla 5** mit PHP 8.3 und Apache
- ✅ **MySQL 8.0** Datenbank
- ✅ **phpMyAdmin** für Datenbankmanagement
- ✅ **Konfiguration über .env Datei** - alles in einer Datei
- ✅ **Produktionsreife Optimierungen** (OPcache, Apache Module)
- ✅ **Zwei Versionen verfügbar** - einfach und erweitert

## 🎯 Verfügbare Versionen

| Branch | Beschreibung | Komponenten |
|--------|--------------|-------------|
| `automated-joomla-phpmyadmin` | **Erweiterte Version** (empfohlen) | Joomla + MySQL + phpMyAdmin + Vollautomatisierung |
| `rollback-to-646a5ab` | **Einfache Version** | Joomla + MySQL (minimal) |

## 🚀 Schnellstart für neue Projekte

### 1. Repository klonen
```bash
git clone https://github.com/devmasterbob/web-joomla-master-2508-09.git mein-neues-projekt
cd mein-neues-projekt
```

### 2. Branch wählen
```bash
# Für erweiterte Version (empfohlen):
git checkout automated-joomla-phpmyadmin

# Oder für einfache Version:
git checkout rollback-to-646a5ab
```

### 3. ⚠️ .env Datei anpassen
**WICHTIG:** Bearbeiten Sie die `.env` Datei und ändern Sie mindestens:

```env
# MUSS geändert werden - Name des Projektordners verwenden:
PROJECT_NAME=mein-neues-projekt

# Sicherheit - eigene Passwörter verwenden:
MYSQL_PASSWORD=mein-sicheres-passwort
MYSQL_ROOT_PASSWORD=mein-root-passwort
JOOMLA_ADMIN_PASSWORD=mein-admin-passwort

# Optional anpassen:
JOOMLA_ADMIN_EMAIL=admin@meinedomain.com
JOOMLA_SITE_NAME=Mein Joomla Projekt
```

### 4. System starten
```bash
docker-compose up -d
```

### 5. ✅ Fertig!
- **Joomla:** http://localhost:80
- **phpMyAdmin:** http://localhost:82 (nur erweiterte Version)

## 🔧 Konfiguration

### Standard-Ports
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
├── .env                   # Alle Einstellungen hier!
├── Dockerfile            # Custom Joomla Build (für Entwicklung)
├── docker-entrypoint.sh  # Automatisierungsskript
├── setup-joomla.sh       # Joomla Setup Automatisierung
├── install-joomla-db.php # Datenbank Installation
└── joomla/               # Joomla Dateien (Volume Mount)
```

## 🛠️ Entwicklung

### Container verwalten
```bash
# Starten
docker-compose up -d

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

## 🔒 Sicherheitshinweise

⚠️ **Vor Produktionseinsatz:**
- Alle Passwörter in `.env` ändern
- `MYSQL_ROOT_PASSWORD` besonders stark wählen
- `JOOMLA_ADMIN_PASSWORD` komplex gestalten
- Ports je nach Bedarf anpassen

## 🎨 Anpassungen

### Andere Ports verwenden
In `.env` ändern:
```env
PORT_JOOMLA=8080
PORT_PHPMYADMIN=8082
```

### Andere Joomla Version
Im `Dockerfile` die Download-URL anpassen:
```dockerfile
curl -o joomla.tar.zst -SL https://github.com/joomla/joomla-cms/releases/download/[VERSION]/[PACKAGE].tar.zst
```

## 🐛 Troubleshooting

### Container starten nicht
```bash
# Ports überprüfen
netstat -an | grep :80
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

## 🤝 Beitragen

1. Fork des Repositories
2. Feature-Branch erstellen: `git checkout -b mein-feature`
3. Änderungen committen: `git commit -am 'Neues Feature'`
4. Branch pushen: `git push origin mein-feature`
5. Pull Request erstellen

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz - siehe [LICENSE](LICENSE) für Details.

## 🆘 Support

Bei Problemen:
1. Erst die Troubleshooting-Sektion prüfen
2. GitHub Issues verwenden
3. Logs immer mit anhängen: `docker-compose logs`

## 🎉 Credits

- **Joomla CMS:** https://www.joomla.org/
- **Docker:** https://www.docker.com/
- **phpMyAdmin:** https://www.phpmyadmin.net/

---
**Entwickelt für maximale Automatisierung und Entwicklerfreundlichkeit** 🚀
