<?php
// Fehlermeldungen anzeigen
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Datenbankverbindung mit Umgebungsvariablen
$host = 'db';  // Container-Name aus docker-compose.yaml
$dbname = getenv('JOOMLA_DB_NAME');
$user = getenv('JOOMLA_DB_USER');
$pass = getenv('JOOMLA_DB_PASSWORD');

try {
    $pdo = new PDO(
        "mysql:host=$host;dbname=$dbname",
        $user,
        $pass
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Datenbankverbindung erfolgreich!";
} catch(PDOException $e) {
    echo "Verbindungsfehler: " . $e->getMessage();
}
?>