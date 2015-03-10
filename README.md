# ![](http://wsnhapps.com/images/c0bra-logo-sm.png) Cobra Launcher
A powerful, feature packed application launcher utility that is highly customizable and very easy to use.

### Features
* Create and manage custom hotkeys on-the-fly
* Easy and quick  edit menus/buttons
* Fully customizable interface

### CHANGELOG
3.0.7
- Lots of code cleanup & file restructuring
- Changed handling of global settings (file paths) to use one global object instead of multiple vars

3.0.6
- Fixed version update handling; now updates user's version to version in script config\Settings.c0bra file
- Lots of cleaning up/re-structuring of config files

3.0.5
- Added option to open config dir from tray context menu
- Fixed search bar handling of "Ctrl+Enter" hotkey and URL entries containing a valid url to open site instead of search

3.0.4
- Changed the "Rename <button>" command to "Edit <button>"
- Fixed behavior of rename/edit button command to properly handle editing top-level parent buttons & child buttons

3.0.3
- Added Search Bar Height and Go Button Width settings to settings GUI

3.0.2
- Updated Settings GUI to auto-populate the font ComboBoxes with the current font settings. Also adds the current fonts to the ComboBox lists if not one of the default fonts
- Fixed Delete and Rename button commands
- Changed Bookmarks button to recurse all favorites folders and list all bookmarks
- Removed unnecessary cIni.ahk file

3.0.1
- Added file install handlers to allow running the executable as a standalone for first time users

3.0.0
- Fixed major issues in the config file templates in order to allow new user to run for first time
- Adding executable to directory allowing use for users without AutoHotkey

2.6.6
- Fixed typo in version updater file name

2.6.5
- Cleaned up unecessary files
- Added a check to update user's config version based on version in the c0bra.ahk \config folder

2.6.4
- Removed unecessary bits here and there
- Minor modifications to the settings GUI

2.6.3
- Fixed issue in accessing the settings GUI from right-click menu

2.6.1
- Working release version
- Multiple bug fixes and merge resolves

2.6.0
- Created a universal settings GUI that contains all settings, allowing easy access

2.5.4
- Fixed more reload handling. All setting changes now handled by quickReload
- Fixed Main Hotkey & Main Hotkey Hold menu items-- Now editable
- Added access to the Main/Side/SLR Gui Settings from the Gui's context menu
- Changed Font and Font Weight inputs to be free edit boxes instead of dropdowns

2.5.3
- Fixed bug caused by last merge-- change color GUI was being called twice
- Added error handling to JSON object parser to inform user of JSON errors instead of just stopping script

2.5.2
- c0bra icon changed to snake eye
- Tray menu overhauled
- Added a Gui to alter main settings
