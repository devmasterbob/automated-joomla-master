#!/bin/bash
# Quick Fix: Setup Joomla Database manually

echo "🔧 Setting up Joomla Database..."

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL..."
sleep 10

# Import Joomla database structure
echo "📊 Creating database structure..."

# Create a basic Joomla installation
mysql -h db -u joomla -pexamplepass joomla_db << 'EOF'
-- Minimal Joomla tables for basic functionality
CREATE TABLE IF NOT EXISTS `joom_session` (
  `session_id` varbinary(192) NOT NULL,
  `client_id` tinyint unsigned NOT NULL,
  `guest` tinyint unsigned DEFAULT '1',
  `time` int NOT NULL DEFAULT '0',
  `data` mediumtext,
  `userid` int DEFAULT '0',
  `username` varchar(150) DEFAULT '',
  PRIMARY KEY (`session_id`),
  KEY `userid` (`userid`),
  KEY `time` (`time`),
  KEY `client_id_guest` (`client_id`,`guest`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `joom_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(400) NOT NULL DEFAULT '',
  `username` varchar(150) NOT NULL DEFAULT '',
  `email` varchar(100) NOT NULL DEFAULT '',
  `password` varchar(100) NOT NULL DEFAULT '',
  `block` tinyint NOT NULL DEFAULT '0',
  `sendEmail` tinyint DEFAULT '0',
  `registerDate` datetime NOT NULL,
  `lastvisitDate` datetime DEFAULT NULL,
  `activation` varchar(100) NOT NULL DEFAULT '',
  `params` text NOT NULL,
  `lastResetTime` datetime DEFAULT NULL,
  `resetCount` int NOT NULL DEFAULT '0',
  `otpKey` varchar(1000) NOT NULL DEFAULT '',
  `otep` varchar(1000) NOT NULL DEFAULT '',
  `requireReset` tinyint NOT NULL DEFAULT '0',
  `authProvider` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`),
  KEY `idx_name` (`name`(100)),
  KEY `idx_block` (`block`),
  KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert admin user
INSERT IGNORE INTO `joom_users` 
(`id`, `name`, `username`, `email`, `password`, `block`, `sendEmail`, `registerDate`, `lastvisitDate`, `activation`, `params`) 
VALUES 
(42, 'Joomla Hero', 'joomla', 'joomla@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 0, 1, NOW(), NOW(), '', '{}');

EOF

echo "✅ Database setup completed!"
echo "🎯 You can now access Joomla at http://localhost/"
