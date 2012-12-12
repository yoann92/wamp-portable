WamPortable
===========

A DOS Batch script to make [WampServer](http://www.wampserver.com/) portable.

Tested on Windows XP, Windows Vista and Windows 7.

Requirements
------------

* [WampServer](http://www.wampserver.com/) minimal version 2.0 and 32-bit.
* PHP minimal version 5.2.x
* [WSH (Windows Script Host)](http://support.microsoft.com/kb/232211) : Open a command prompt and type ``wscript`` to check.
* Be [Admin user](http://windows.microsoft.com/en-US/windows7/How-do-I-log-on-as-an-administrator).

Installation
------------

Before running the script, you can change some variables.

* **$timezone** - The default timezone used by all date/time functions. Default : ``Europe/Paris``
* **$enableLogs** - Enable wamp-portable log file. Generate ``wamp-portable.log`` file. Default : ``true``
* **$autoLaunch** - Automatically closes the wamp-portable window. Default : ``false``

Next,

* Download and install [WampServer](http://www.wampserver.com/) 32-bit >= 2.0.
* Copy wamp folder where ever you want.
* Remove WampServer from [Programs and Features](http://windows.microsoft.com/en-US/windows7/Uninstall-or-change-a-program).
* Delete ``unins000.dat`` and ``unins000.exe`` from the copied folder.
* Put the ``wamp-portable.bat`` in the same directory as ``wampmanager.exe``.

Usage
-----

* Run ``wamp-portable.bat`` to start the process and launch WampServer.
* A backup folder is created each time you launch wamp-portable in the ``backups`` directory. This folder contains all files edited by the wamp-portable script.

More infos
----------

http://www.crazyws.fr/dev/applis-et-scripts/wamportable-mettre-wampserver-sur-cle-usb-G5980.html
