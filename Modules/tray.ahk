#SingleInstance force
TrayTip, Settings, Click the tray icon to modify settings`nRight Click to Exit, 8, 1
Menu, Tray, NoStandard
Menu, Tray, Click, 1
Menu, Tray, Add, Settings, ShowSettings
Menu, Tray, Add
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Default, Settings
Return

;;================================== ShowSettings ==================================;;
ShowSettings:
IfWinExist, GitAssist Settings
    Return

try_height_of_menus := 20
try_number_of_menus := 3 + 1

GuiHeightTraySet := try_height_of_menus * (try_number_of_menus + 2)

;;------------------------------------ DBSETUP ----------------------------------------------;;
IniRead, LocalDB_loc, %DBSettingsFile%, LocalDB, LocalDB_loc, %LocalDB_loc%

Gui, Settings: Destroy

Gui, Settings: Add, Button, x5   y0 w65  h20 , Save
Gui, Settings: Add, Button, x70 y0 w65  h20 , Close

Gui, Settings: Add, Tab, x5 w300 h%GuiHeightTraySet%, Main Settings

Gui, Settings: Tab, Main Settings
Gui, Settings: Add, Text,   w260 h%try_height_of_menus% , Local DataBase Location
Gui, Settings: Add, Edit,   w260 h%try_height_of_menus% vlocalDB_loc, %LocalDB_loc%

Gui, Settings: Show, xCenter yCenter , GitAssist Settings
Return

SettingsGuiEscape:
SettingsGuiClose:
Gui, Settings: Destroy
Return

SettingsButtonSave:
Gui, Settings: Submit

;;------------------------------------ DB SETUP ----------------------------------------------;;
IniWrite, %localDB_loc%, %DBSettingsFile%, LocalDB, LocalDB_loc
msgbox Saved!
Gui, Settings: Destroy
Return

SettingsButtonClose:
Gui, Settings: Destroy
Return

ExitScript:
ExitApp


















