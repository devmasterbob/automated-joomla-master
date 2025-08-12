<?php
$projectName = getenv('PROJECT_NAME');
$joomlaAdmin = getenv('JOOMLA_ADMIN_USERNAME');
$joomlaAdminPw = getenv('JOOMLA_ADMIN_PASSWORD');
$joomlaDBUser = getenv('JOOMLA_DB_USER'); 
$joomlaDBPw = getenv('JOOMLA_DB_PASSWORD');
$mysqlRootPw = getenv('MYSQL_ROOT_PASSWORD');
$joomlaSiteName = getenv('JOOMLA_SITE_NAME');
$joomlaDBName = getenv('JOOMLA_DB_NAME');
$joomlaAdminEmail = getenv('JOOMLA_ADMIN_EMAIL');
$joomlaDbTyp = getenv('JOOMLA_DB_TYPE');
$joomlaDbHost = getenv('JOOMLA_DB_HOST');

$portJoomla = getenv('PORT_JOOMLA') ?: '80';
$portPhpMyAdmin = getenv('PORT_PHPMYADMIN') ?: '8082';





?>
<!DOCTYPE html>
<html lang="de">

<head>
    <meta charset="UTF-8">
    <link rel="icon" href="favicon.ico" type="image/x-icon">
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
    <title>
        <?php echo $projectName; ?>
    </title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">
    <meta name="description" content="This is the starting point for the Joomla project development and management.">
    <script>
        function toggleChatHistory() {
            var content = document.getElementById('chat-history-content');
            var button = document.getElementById('toggle-button');
            if (content.style.display === 'none' || content.style.display === '') {
                content.style.display = 'block';
                button.textContent = '📖 Entwicklungsgeschichte ausblenden';
            } else {
                content.style.display = 'none';
                button.textContent = '📖 Entwicklungsgeschichte anzeigen (2 Sessions)';
            }
        }
    </script>
</head>

<body>
    <h1>
        <?php echo $projectName; ?>
    </h1>
    <p>
        Diese Seite dient als Ausgangspunkt für die Entwicklung und Verwaltung des Joomla-Projekts <strong><?php echo $projectName; ?></strong>.
    </p>
    
    <!-- Entwicklungsgeschichte Button -->
    <div style="margin: 20px 0; text-align: center;">
        <button id="toggle-button" onclick="toggleChatHistory()" style="padding: 12px 24px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: bold; box-shadow: 0 4px 15px rgba(0,0,0,0.2); transition: all 0.3s ease;">
            📖 Entwicklungsgeschichte anzeigen (2 Sessions)
        </button>
    </div>

    <!-- Chat History Content (versteckt per default) -->
    <div id="chat-history-content" style="display: none; margin: 30px 0; padding: 20px; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); border-radius: 10px; box-shadow: 0 8px 25px rgba(0,0,0,0.1);">
        <?php
        // CHAT_HISTORY.md einlesen und als HTML formatieren
        $chatHistoryPath = '/var/www/CHAT_HISTORY.md';
        if (file_exists($chatHistoryPath)) {
            $chatContent = file_get_contents($chatHistoryPath);
            
            // Markdown zu HTML konvertieren (einfache Version)
            $chatContent = htmlspecialchars($chatContent);
            
            // Überschriften formatieren
            $chatContent = preg_replace('/^# (.*$)/m', '<h1 style="color: #4a5568; border-bottom: 3px solid #667eea; padding-bottom: 10px; margin-top: 30px;">$1</h1>', $chatContent);
            $chatContent = preg_replace('/^## (.*$)/m', '<h2 style="color: #2d3748; margin-top: 25px; margin-bottom: 15px;">$1</h2>', $chatContent);
            $chatContent = preg_replace('/^### (.*$)/m', '<h3 style="color: #4a5568; margin-top: 20px; margin-bottom: 10px;">$1</h3>', $chatContent);
            $chatContent = preg_replace('/^#### (.*$)/m', '<h4 style="color: #718096; margin-top: 15px; margin-bottom: 8px;">$1</h4>', $chatContent);
            
            // Listen formatieren
            $chatContent = preg_replace('/^- (.*$)/m', '<li style="margin: 5px 0; line-height: 1.6;">$1</li>', $chatContent);
            $chatContent = preg_replace('/(<li.*<\/li>)/s', '<ul style="margin: 15px 0; padding-left: 20px;">$1</ul>', $chatContent);
            
            // Code-Blöcke
            $chatContent = preg_replace('/```(\w+)?\n(.*?)\n```/s', '<pre style="background: #2d3748; color: #e2e8f0; padding: 15px; border-radius: 5px; overflow-x: auto; margin: 15px 0;"><code>$2</code></pre>', $chatContent);
            $chatContent = preg_replace('/`([^`]+)`/', '<code style="background: #edf2f7; color: #2d3748; padding: 2px 6px; border-radius: 3px; font-family: monospace;">$1</code>', $chatContent);
            
            // Emojis und Status-Symbole hervorheben
            $chatContent = preg_replace('/✅/', '<span style="color: #48bb78; font-size: 1.2em;">✅</span>', $chatContent);
            $chatContent = preg_replace('/📋|📊|🚀|🔧|🎯|📝|📤|🔍|🎉|📚/', '<span style="font-size: 1.1em;">$0</span>', $chatContent);
            
            // Zeilenumbrüche beibehalten
            $chatContent = nl2br($chatContent);
            
            echo '<div style="font-family: -apple-system, BlinkMacSystemFont, \'Segoe UI\', Roboto, sans-serif; line-height: 1.8; color: #2d3748;">';
            echo $chatContent;
            echo '</div>';
        } else {
            echo '<p style="color: #e53e3e; font-weight: bold;">CHAT_HISTORY.md nicht gefunden!</p>';
        }
        ?>
    </div>

    <h2>
        Entwicklungsumgebung
    </h2>

    <ul>
        <li><a href="test.php" target="_blank" rel="noopener noreferrer">PHP Info</a></li>
        <li><a href="db-test.php" target="_blank" rel="noopener noreferrer">Datenbank Test</a></li>
        <li><a href="http://localhost:<?php echo $portJoomla; ?>" target="_blank" rel="noopener noreferrer">Joomla Frontside</a></li>
        <li><a href="http://localhost:<?php echo $portJoomla; ?>/administrator" target="_blank" rel="noopener noreferrer">Joomla Administration</a></li>
        <li><a href="http://localhost:<?php echo $portPhpMyAdmin; ?>" target="_blank" rel="noopener noreferrer">PHPMyAdmin</a></li>
    </ul>
    <p>
    <ul>
        <li>Projekt Name:
            <?php echo $projectName; ?>
        </li>
        <li>Joomla Site Name:
            <?php echo $joomlaSiteName; ?>
        </li>
        <li>Joomla Admin :
            <?php echo $joomlaAdmin; ?>
        </li>
        <li>Joomla Admin Pw :
            <?php echo $joomlaAdminPw; ?>
        </li>
         <li>Joomla DB User :
            <?php echo $joomlaDBUser; ?>
        </li>
        <li>Joomla DB User Pw :
            <?php echo $joomlaDBPw; ?>
        </li>
         <li>MySQL Root Pw :
            <?php echo $mysqlRootPw; ?>
        </li>
         <li>DB Name :
            <?php echo $joomlaDbName; ?>
        </li>
        <li>Joomla Admin E-Mail :
            <?php echo $joomlaAdminEmail; ?>
        </li>
        <li>DB Typ :
            <?php echo $joomlaDbTyp; ?>
        </li>
        <li>DB Host :
            <?php echo $joomlaDbHost; ?>
        </li>
    </ul>
    </p>
</body>

</html>