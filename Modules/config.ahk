
DBSettingsFile = %A_ScriptDir%\BackupPathLocations.ini

IfExist, %A_ScriptDir%\BackupPathLocations.ini
{
	IniRead, LocalDB_loc, %DBSettingsFile%, LocalDB, LocalDB_loc, %LocalDB_loc%
} 

Else
{
	MsgBox, 4100, ,Would you like to use the default local backup location?`n`nLocal: %USERPROFILE%\Project_BackUps

	IfMsgBox No
	{		
		Loop, 
		{
			FileSelectFolder, registeredLocalDB , , , Please Select Local Folder
			
			If (ErrorLevel = 0)
				Break

			MsgBox, An error occurred, Please select another folder
		}
	}

	IniWrite, %registeredLocalDB%, %DBSettingsFile%, LocalDB , LocalDB_loc
}





