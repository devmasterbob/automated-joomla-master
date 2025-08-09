<?php
$projectName = getenv('PROJECT_NAME');
$joomlaDBUser = getenv('JOOMLA_DB_USER'); 
$joomlaDBPw = getenv('JOOMLA_DB_PASSWORD');
$joomlaAdmin = getenv('JOOMLA_ADMIN_USER');
if (!$projectName) {
    $projectName = 'Joomla Projekt';
}
$joomlaAdminPw = getenv('JOOMLA_ADMIN_PASSWORD');
$joomlaMailFrom = getenv('JOOMLA_MAIL_FROM');
$joomlaMailFromName = getenv('JOOMLA_MAIL_FROM_NAME'); 
$joomlaDbTyp = getenv('JOOMLA_DB_TYPE');
$joomlaDbHost = getenv('JOOMLA_DB_HOST');
$joomlaDbName = getenv('JOOMLA_DB_NAME');
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
</head>

<body>
    <h1>
        <?php echo $projectName; ?>
    </h1>
    <p>
        Diese Seite dient als Ausgangspunkt für die Entwicklung und Verwaltung des Joomla-Projekts <strong><?php echo $projectName; ?></strong>.
    </p>
    <h2>
        Entwicklungsumgebung
    </h2>

    <ul>
        <li><a href="test.php" target="_blank" rel="noopener noreferrer">PHP Info</a></li>
        <li><a href="db-test.php" target="_blank" rel="noopener noreferrer">Datenbank Test</a></li>
        <li><a href="http://localhost:8881" target="_blank" rel="noopener noreferrer">Joomla Frontside</a></li>
        <li><a href="http://localhost:8881/administrator" target="_blank" rel="noopener noreferrer">Joomla Administration</a></li>
        <li><a href="http://localhost:8882" target="_blank" rel="noopener noreferrer">PHPMyAdmin</a></li>
    </ul>
    <p>
    <ul>
        <li>Joomla Projekt:
            <?php echo $projectName; ?>
        </li>
        <li>Joomla User :
            <?php echo $joomlaDBUser; ?>
        </li>
        <li>Joomla User Pw :
            <?php echo $joomlaDBPw; ?>
        </li>
        <li>Joomla Admin Pw :
            <?php echo $joomlaAdminPw; ?>
        </li>
        <li>Mail From :
            <?php echo $joomlaMailFrom; ?>
        </li>
        <li>Mail From Name :
            <?php echo $joomlaMailFromName; ?>
        </li>
        <li>DB Typ :
            <?php echo $joomlaDbTyp; ?>
        </li>
        <li>DB Host :
            <?php echo $joomlaDbHost; ?>
        </li>
        <li>DB Name :
            <?php echo $joomlaDbName; ?>
        </li>
    </ul>
    </p>
</body>

</html>