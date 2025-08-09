<?php
/**
 * Joomla Database Installation Script
 * 
 * This script creates the Joomla database schema and admin user
 */

// Database configuration from environment variables
$db_host = $_ENV['JOOMLA_DB_HOST'] ?? 'db';
$db_user = $_ENV['JOOMLA_DB_USER'] ?? 'joomla';
$db_pass = $_ENV['JOOMLA_DB_PASSWORD'] ?? 'examplepass';
$db_name = $_ENV['JOOMLA_DB_NAME'] ?? 'joomla_db';
$db_prefix = $_ENV['JOOMLA_DB_PREFIX'] ?? 'joom_';

// Admin user configuration
$admin_user = $_ENV['JOOMLA_ADMIN_USERNAME'] ?? 'admin';
$admin_name = $_ENV['JOOMLA_ADMIN_USER'] ?? 'Administrator';
$admin_email = $_ENV['JOOMLA_ADMIN_EMAIL'] ?? 'admin@example.com';
$admin_password = $_ENV['JOOMLA_ADMIN_PASSWORD'] ?? 'admin';

echo "Starte Joomla Datenbank Installation...\n";

try {
    // Connect to MySQL
    $dsn = "mysql:host={$db_host};dbname={$db_name};charset=utf8mb4";
    $pdo = new PDO($dsn, $db_user, $db_pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
    ]);
    
    echo "Datenbankverbindung hergestellt.\n";
    
    // Read and execute SQL installation file
    $sql_file = '/var/www/html/installation/sql/mysql/joomla.sql';
    if (!file_exists($sql_file)) {
        throw new Exception("SQL installation file not found: {$sql_file}");
    }
    
    $sql_content = file_get_contents($sql_file);
    $sql_content = str_replace('#__', $db_prefix, $sql_content);
    
    // Split SQL into individual statements
    $statements = array_filter(array_map('trim', explode(';', $sql_content)));
    
    echo "Führe Datenbankinstallation durch...\n";
    foreach ($statements as $statement) {
        if (!empty($statement) && !preg_match('/^(--|\#)/', $statement)) {
            $pdo->exec($statement);
        }
    }
    
    echo "Datenbank-Schema erstellt.\n";
    
    // Create admin user
    $password_hash = password_hash($admin_password, PASSWORD_BCRYPT);
    $admin_id = 42; // Standard admin user ID
    
    // Insert admin user
    $stmt = $pdo->prepare("
        INSERT INTO `{$db_prefix}users` 
        (`id`, `name`, `username`, `email`, `password`, `block`, `sendEmail`, `registerDate`, `lastvisitDate`, `activation`, `params`)
        VALUES 
        (?, ?, ?, ?, ?, 0, 1, NOW(), NOW(), '', '')
    ");
    $stmt->execute([$admin_id, $admin_name, $admin_user, $admin_email, $password_hash]);
    
    // Assign admin to Super User group
    $stmt = $pdo->prepare("
        INSERT INTO `{$db_prefix}user_usergroup_map` (`user_id`, `group_id`)
        VALUES (?, 8)
    ");
    $stmt->execute([$admin_id]);
    
    echo "Admin-Benutzer erstellt: {$admin_user}\n";
    echo "Joomla Datenbank-Installation abgeschlossen!\n";
    
} catch (Exception $e) {
    echo "Fehler bei der Installation: " . $e->getMessage() . "\n";
    exit(1);
}
?>
