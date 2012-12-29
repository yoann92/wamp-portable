@ECHO OFF
SETLOCAL EnableDelayedExpansion

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                                ::
::  Wamp-Portable                                                                 ::
::                                                                                ::
::  Author: Cr@zy                                                                 ::
::  Contact: http://www.crazyws.fr                                                ::
::  Related post: http://goo.gl/g0rWG                                             ::
::                                                                                ::
::  This program is free software: you can redistribute it and/or modify it       ::
::  under the terms of the GNU General Public License as published by the Free    ::
::  Software Foundation, either version 3 of the License, or (at your option)     ::
::  any later version.                                                            ::
::                                                                                ::
::  This program is distributed in the hope that it will be useful, but WITHOUT   ::
::  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS ::
::  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more         ::
::  details.                                                                      ::
::                                                                                ::
::  You should have received a copy of the GNU General Public License along       ::
::  with this program.  If not, see http://www.gnu.org/licenses/.                 ::
::                                                                                ::
::  Usage: wamp-portable.bat                                                      ::
::                                                                                ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
TITLE WamPortable v1.1

ECHO.
ECHO.
ECHO    #########################################################################
ECHO    #                                                                       #
ECHO    #   @   @ @@@@@ @   @ @@@@@ @@@@@ @@@@@ @@@@@ @@@@@ @@@@@ @     @@@@@   #
ECHO    #   @   @ @   @ @@ @@ @   @ @   @ @   @   @   @   @ @   @ @     @       #
ECHO    #   @   @ @@@@@ @ @ @ @@@@@ @   @ @@@@@   @   @@@@@ @@@@@ @     @@@@    #
ECHO    #    @@@  @   @ @   @ @     @   @ @  @    @   @   @ @   @ @     @       #
ECHO    #    @ @  @   @ @   @ @     @@@@@ @   @   @   @   @ @@@@@ @@@@@ @@@@@   #
ECHO    #                                                                       #
ECHO    #   Author : Cr@zy                               Date    : 12/29/2012   #
ECHO    #   Email  : webmaster@crazyws.fr                Version : 1.1          #
ECHO    #                                                                       #
ECHO    #########################################################################

:: Wamp launcher
SET wampLauncher=%TEMP%\wampLauncher.vbs

:: Get the latest version of PHP on Wamp
FOR /R bin\php %%v IN (php.*exe) DO (
    SET PHP=%%v
)

:: Run PHP
%PHP% -n -d output_buffering=1 -f "%~f0"
ENDLOCAL
EXIT /b

:: wampserver-portable PHP script
<?php

while(@ob_end_clean());

////////////////////////////////////////////////
// Properties
////////////////////////////////////////////////

$timezone = 'Europe/Paris';
$enableLogs = true;
$autoLaunch = false;
$maxBackups = 10;

////////////////////////////////////////////////
// No edits necessary beyond this line
////////////////////////////////////////////////

date_default_timezone_set($timezone);

$scriptName = basename(__FILE__);
$wampConfigPath = getcwd() . '\\wampmanager.conf';
$wampIniPath = getcwd() . '\\wampmanager.ini';
$wampTplPath = getcwd() . '\\wampmanager.tpl';
$rootBackupPath = getcwd() . '\\backups\\';
$backupsPath = $rootBackupPath . date('YmdHis');
$logsPath = getcwd() . '\\wamp-portable.log';

if ($enableLogs) file_put_contents($logsPath, "@@@\n@@@ START WAMP-PORTABLE " . date('YmdHis') . "\n@@@", FILE_APPEND);

function echoListener($str) {
    global $logsPath, $enableLogs;
    if ($enableLogs) {
        file_put_contents($logsPath, $str, FILE_APPEND);
    }
    echo $str;
}

echoListener("\n");

function startWith($string, $search) {
    $length = strlen($search);
    return (substr($string, 0, $length) === $search);
}

function endWith($string, $search) {
    $length = strlen($search);
    $start  = $length * -1;
    return (substr($string, $start) === $search);
}

function exitApp() {
    echoListener("\n\An error occurred during the operation, exit...");
    echoListener("\n");
    exit();
}

function logInfo($str, $status, $values=array(), $withKey=true, $withValue=true) {
    $count = strlen($str);
    $dots = "";
    for ($i=$count; $i<=50; $i++) {
        $dots .= ".";
    }
    echoListener(logTitle($str . " " . $dots . " " . ($status ? "OK" : "KO")));
    if (!empty($values) && is_array($values)) {
        foreach ($values as $key => $value) {
            $count = strlen($key);
            $spaces = "";
            for ($i=$count; $i<=7; $i++) {
                $spaces .= " ";
            }
            echoListener("\n" . ($withKey ? $key : "") . ($withKey && $withValue ? $spaces . " : " : "") . ($withValue ? $value : ""));
        }
    }
    if (!$status) exitApp();
}

function logTitle($title) {
    $logTitle = "\n\n\n\n======================================================================\n";
    $logTitle .= $title;
    $logTitle .= "\n======================================================================";
    return $logTitle;
}

function versionsAppList($dir, $substr, $bins) {
    $appArr = array();
    if ($appDirHandle = opendir($dir)) {
        while (false !== ($appDirName = readdir($appDirHandle))) {
            $appPath = getcwd() . "\\" . str_replace("/", "\\", $dir) . "\\" . $appDirName;
            if ($appDirName != '.' && $appDirName != '..' && is_dir($appPath) ) {
                $appVersion = substr($appDirName, $substr);
                foreach ($bins as $bin) {
                    $appBin = str_replace("/", "\\", $bin);
                    if (is_file($appPath . '\\' . $appBin)) {
                        $appArr[$appVersion] = array(
                            'path'  =>  $appPath,
                            'bin'   =>  $appBin
                        );
                    }
                }
            }
        }
        ksort($appArr, SORT_NUMERIC);
    }
    return $appArr;
}

function versionsAppPaths($list, $type) {
    $paths = array();
    foreach ($list as $versions => $value) {
        if (count(array_keys($paths, $type . ';' . $value['path'])) == 0) {
            $paths[] = $type . ';' . $value['path'];
        }
    }
    return $paths;
}

function foundFiles($path, $toFound) {
    $files = array();
    if ($handle = opendir($path)) {
        while (false !== ($file = readdir($handle))) {
            if ($file != "." && $file != ".." && is_file($path . '\\' . $file)) {
                foreach($toFound as $elt) {
                    if (endWith($file, $elt) || empty($elt)) {
                        $files[] = $path . '\\' . $file;
                    }
                }
            } elseif ($file != "." && $file != ".." && is_dir($path . '\\' . $file)) {
                $tmpFiles = foundFiles($path . '\\' . $file, $toFound);
                foreach($tmpFiles as $tmpFile) {
                    $files[] = $tmpFile;
                }
            }
        }
    }
    return $files;
}

function writeToFile($file, $string) {
    $handle = fopen($file, 'w');
    fwrite($handle, $string);
    fclose($handle);
}

function getAltPath($path) {
    $pathAlt[] = ucfirst($path);
    $pathAlt[] = str_replace('/', '\\', ucfirst($path));
    $pathAlt[] = lcfirst($path);
    $pathAlt[] = str_replace('/', '\\', lcfirst($path));
    return $pathAlt;
}

function replaceWithNewPath($oldPath, $newPath, $filePath) {
    $fileContent = file_get_contents($filePath);
    $oldPathAlt = getAltPath($oldPath);
    $newPathAlt = getAltPath($newPath);
    $count = 0;
    foreach($oldPathAlt as $key => $rpcPath) {
        if (preg_match("#" . str_replace('\\', '\\\\', $rpcPath) . "#", $fileContent)) {
            if ($key == 0 || $key == 2) {
                $fileContent = str_replace($rpcPath, $newPathAlt[0], $fileContent, $countRpc);
                $count += $countRpc;
            } else {
                $fileContent = str_replace($rpcPath, $newPathAlt[1], $fileContent);
                $count += $countRpc;
            }
        }
    }
    writeToFile($filePath, $fileContent);
    return $count;
}

function deleteFolder($folderpath) {
    if (is_dir($folderpath)) {
        $dir_handle = opendir($folderpath);
    }
    if (!$dir_handle) {
        return false;
    }
    while ($file = readdir( $dir_handle )) {
        if ($file != '.' && $file != '..') {
            if (!is_dir($folderpath . '/' . $file)) {
                unlink($folderpath . '/' . $file);
            } else {
                deleteFolder($folderpath . '/' . $file);
            }
        }
    }
    closedir($dir_handle);
    rmdir($folderpath);
    return true;
}

////////////////////////////////////////////////
// Start process
////////////////////////////////////////////////

// Get wamp config
$wampConfig = parse_ini_file($wampConfigPath, true);
logInfo("Parse wampanager.conf", isset($wampConfig['main']['installDir']));

// Get oldPath and newPath
$oldPath = $wampConfig['main']['installDir'];
$newPath = str_replace('\\', '/', getcwd());
logInfo("Paths", !empty($oldPath) && !empty($newPath), array(
    "oldPath"   =>  $oldPath,
    "newPath"   =>  $newPath,
));

// Get php versions list
$phpArr = versionsAppList("bin/php", 3, array("php.exe"));
logInfo("PHP versions", !empty($phpArr), $phpArr, true, false);

// Get apache versions list
$apacheArr = versionsAppList("bin/apache", 6, array("bin/apache.exe", "bin/httpd.exe"));
logInfo("Apache versions", !empty($apacheArr), $apacheArr, true, false);

// Get mysql versions list
$mysqlArr = versionsAppList("bin/mysql", 5, array("bin/mysqld.exe", "bin/mysqld-nt.exe"));
logInfo("MySQL versions", !empty($mysqlArr), $mysqlArr, true, false);

// Stop wampmanager
logInfo("Stop wampmanager", true);
echoListener("\n");
`TASKKILL /IM wampmanager.exe /F`;

// Stop wampapache service
logInfo("Stop wampapache service", true);
echoListener("\n");
`NET STOP wampapache`;

// Uninstall wampapache service
logInfo("Uninstall wampapache service", true);
echoListener("\n");
$apachePath = end($apacheArr);
$apachePath = $apachePath['path'] . '\\' . $apachePath['bin'];
$apacheScript = $apachePath . " -k uninstall -n wampapache";
`$apacheScript`;

// Stop wampmysqld service
logInfo("Stop wampmysqld service", true);
echoListener("\n");
`NET STOP wampmysqld`;

// Uninstall wampmysqld service
logInfo("Uninstall wampmysqld service", true);
echoListener("\n");
$mysqlPath = end($mysqlArr);
$mysqlPath = $mysqlPath['path'] . '\\' . $mysqlPath['bin'];
$mysqlScript = $mysqlPath . " --remove wampmysqld";
`$mysqlScript`;

// First launch ?
if (!is_dir($rootBackupPath)) {
    $backupsPath = $rootBackupPath . "#original";
}

// Create backups directory
if (!is_dir($backupsPath)) {
    mkdir($backupsPath, null, true);
}
logInfo("Create backups directory", is_dir($backupsPath));

// Get files to scan
$eltToScan = array(
    'alias'     =>  array(''),
    'apache'    =>  array('.ini', '.conf'),
    'mysql'     =>  array('my.ini'),
    'php'       =>  array('.ini'),
);

$pathsToScan = array();
foreach ($eltToScan as $type => $elt) {
    if ($type == 'alias') {
        $pathsToScan[] = $type . ';' . getcwd() . '\\alias';
    } elseif ($type == 'apache') {
        $versionsAppPaths = versionsAppPaths($apacheArr, $type);
        foreach ($versionsAppPaths as $value) {
            $pathsToScan[] = $value;
        }
    } elseif ($type == 'mysql') {
        $versionsAppPaths = versionsAppPaths($mysqlArr, $type);
        foreach ($versionsAppPaths as $value) {
            $pathsToScan[] = $value;
        }
    } elseif ($type == 'php') {
        $versionsAppPaths = versionsAppPaths($phpArr, $type);
        foreach ($versionsAppPaths as $value) {
            $pathsToScan[] = $value;
        }
    }
}

$filesToScan[] = $wampConfigPath;
$filesToScan[] = $wampTplPath;
$filesToScan[] = $wampIniPath;
foreach ($pathsToScan as $elt) {
    $path = explode(";", $elt);
    $type = $path[0];
    $path = $path[1];
    $foundFiles = foundFiles($path, $eltToScan[$type]);
    foreach ($foundFiles as $value) {
        $filesToScan[] = $value;
    }
}

logInfo("Files to scan", count($filesToScan) > 2, $filesToScan, false);

// Backup files before edit
$backupFiles = array();
foreach ($filesToScan as $file) {
    $infofile = pathinfo($file);
    $backupFileFolder = $backupsPath . str_replace(str_replace('/', '\\', $newPath), '', $infofile['dirname']);
    $backupFile = $backupFileFolder . "\\" . $infofile['basename'];
    if (!is_dir($backupFileFolder)) {
        mkdir($backupFileFolder, null, true);
    }
    if (copy($file, $backupFile)) {
        $backupFiles[] = $backupFile;
    }
}

logInfo("Backup files", count($backupFiles) > 2, $backupFiles, false);

// Replace old path in files
$rpcFiles = array();
foreach ($filesToScan as $file) {
    $echoStr = $file;
    $dots = "";
    for ($i=strlen($echoStr); $i<=90; $i++) $dots .= ".";
    $countRpc = replaceWithNewPath($oldPath, $newPath, $file);
    $rpcFiles[] = $echoStr . " " . $dots . " " . ($countRpc > 0 ? $countRpc . " found" : "none");
}

logInfo("Replace old path in files", count($rpcFiles) > 2, $rpcFiles, false);

// Install wampmysqld service
$mysqlVersion = $wampConfig['mysql']['mysqlVersion'];
$mysqlVersion = str_replace('"', '', $mysqlVersion);
$mysqlPath = $mysqlArr[$mysqlVersion]['path'] . '\\' . $mysqlArr[$mysqlVersion]['bin'];
$mysqlInstallParams = $wampConfig['mysql']['mysqlServiceInstallParams'];
$mysqlInstallParams = str_replace('"', '', $mysqlInstallParams);
$mysqlService = $mysqlPath . " " . $mysqlInstallParams;

logInfo("Install wampmysqld service", true);
echoListener("\n");
`$mysqlService`;

// Install wampapache service
$apacheVersion = $wampConfig['apache']['apacheVersion'];
$apacheVersion = str_replace('"', '', $apacheVersion);
$apachePath = $apacheArr[$apacheVersion]['path'] . '\\' . $apacheArr[$apacheVersion]['bin'];
$apacheInstallParams = $wampConfig['apache']['apacheServiceInstallParams'];
$apacheInstallParams = str_replace('"', '', $apacheInstallParams);
$apacheService = $apachePath . " " . $apacheInstallParams;

logInfo("Install wampapache service", true);
echoListener("\n");
`$apacheService`;

// Delete old backups
if ($maxBackups > 0) {
    $listBackups = array();
    if ($handle = opendir($rootBackupPath)) {
        while (false !== ($file = readdir($handle))) {
            if ($file != "." && $file != ".." && is_dir($rootBackupPath . $file) && is_numeric($file)) {
                $listBackups[] = $rootBackupPath . $file;
            }
        }
    }
    if (!empty($listBackups) && count($listBackups) > $maxBackups) {
        sort($listBackups);
        $toDelete = count($listBackups) - $maxBackups;
        $listBackupsDelete = array();
        for ($i=0; $i<$toDelete; $i++) {
            $listBackupsDelete[] = $listBackups[$i];
            deleteFolder($listBackups[$i]);
        }
        logInfo("Delete old backups", count($listBackupsDelete) > 0, $listBackupsDelete, false);
    }
}

// Now ready to use
echoListener("\n\n");
echoListener("Operation completed successfully!\nWamp is now ready to use!");
echoListener("\n\n");
if (!$autoLaunch) {
    echoListener("Press any key to launch Wamp...");
    `pause`;
}

// Launch wampmanager
echoListener("\n\nLaunch wampmanager");
`ECHO set args = WScript.Arguments >%wampLauncher%`;
`ECHO num = args.Count >>%wampLauncher%`;
`ECHO. >>%wampLauncher%`;
`ECHO if num = 0 then >>%wampLauncher%`;
`ECHO   WScript.Quit 1 >>%wampLauncher%`;
`ECHO end if >>%wampLauncher%`;
`ECHO. >>%wampLauncher%`;
`ECHO sargs = "" >>%wampLauncher%`;
`ECHO if num ^> 1 then >>%wampLauncher%`;
`ECHO   sargs = " " >>%wampLauncher%`;
`ECHO   for k = 1 to num - 1 >>%wampLauncher%`;
`ECHO       anArg = args.Item(k) >>%wampLauncher%`;
`ECHO       sargs = sargs ^& anArg ^& " " >>%wampLauncher%`;
`ECHO   next >>%wampLauncher%`;
`ECHO end if >>%wampLauncher%`;
`ECHO. >>%wampLauncher%`;
`ECHO Set WshShell = WScript.CreateObject("WScript.Shell") >>%wampLauncher%`;
`ECHO. >>%wampLauncher%`;
`ECHO WshShell.Run """" ^& WScript.Arguments(0) ^& """" ^& sargs, 0, False >>%wampLauncher%`;

`wscript.exe %wampLauncher% wampmanager.exe`;

if ($enableLogs) file_put_contents($logsPath, "@@@\n@@@ END WAMP-PORTABLE " . date('YmdHis') . "\n@@@\n\n\n\n\n\n\n\n\n\n\n\n", FILE_APPEND);

?>