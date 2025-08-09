# Template Development Checklist
# Für optimale Provider-Kompatibilität

## ✅ Template-Entwicklung:
- [ ] Template in joomla/templates/ entwickeln
- [ ] Auf verschiedenen Bildschirmgrößen testen
- [ ] Joomla Standard-Features nutzen (nicht zu viele Custom PHP Scripts)
- [ ] Bilder optimiert (Web-tauglich)

## ✅ Provider-Transfer:
- [ ] Backup-Script ausführen
- [ ] Datenbank exportieren  
- [ ] Bei Provider: MySQL-Datenbank erstellen
- [ ] Joomla-Dateien hochladen
- [ ] configuration.php anpassen
- [ ] DNS/Domain konfigurieren

## ✅ Templates die gut funktionieren:
- Standard Joomla Templates (Cassiopeia)
- Template-Frameworks (T3, Gantry)
- Commercial Templates von JoomShaper, RocketTheme etc.

## ⚠️ Vermeiden für bessere Provider-Kompatibilität:
- Zu viele Server-spezifische Anpassungen
- Hardcoded Pfade
- Spezielle PHP-Extensions die nicht standard sind
