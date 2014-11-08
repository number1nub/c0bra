# Cobra Launcher
A powerful, feature packed application launcher utility that is highly customizable and very easy to use.

### Features
* Create and manage custom hotkeys on-the-fly
* Easy and quick  edit menus/buttons
* Fully customizable interface

### TO-DO
* Make sure delete button deletes all necessary JSON buttons
	* doesn't delete children yet
* Button adding and deleting needs to work properly
* No Run tray menu
* Closer tray menu
* Hotkeys tray menu
* Individual button color change
* SLR button color change
* enable adding different button types
* Automatically reposition gui if off screen... also side guis

### CHANGELOG
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
* Created a universal settings GUI that contains all settings, allowing easy access
2.5.4
* Fixed more reload handling. All setting changes now handled by quickReload
* Fixed Main Hotkey & Main Hotkey Hold menu items-- Now editable
* Added access to the Main/Side/SLR Gui Settings from the Gui's context menu
* Changed Font and Font Weight inputs to be free edit boxes instead of dropdowns
2.5.3
* Fixed bug caused by last merge-- change color GUI was being called twice
* Added error handling to JSON object parser to inform user of JSON errors instead of just stopping script
2.5.2
* c0bra icon changed to snake eye
* Tray menu overhauled
* Added a Gui to alter main settings
