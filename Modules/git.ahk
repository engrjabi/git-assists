^+RButton::
Full_Project_Location := ActiveFolderPath()
SplitPath, Full_Project_Location , Full_Prj_Loc_FileName, Full_Prj_Loc_Dir, , , 

IfNotExist, %DBSettingsFile%
	Goto, No_Reg_Location

IniRead, Back_Up_Path, %DBSettingsFile%, LocalDB , LocalDB_loc

Gui, GAAgent:Add, Button, x0  y0  w90 h30 , Initialize
Gui, GAAgent:Add, Button, x0  y30 w90 h30 , Take
Gui, GAAgent:Add, Button, x90 y0  w90 h30 , Update
Gui, GAAgent:Add, Button, x90 y30 w90 h30 , TimeLine
Gui, GAAgent:Show, xCenter yCenter h60 w180, GA Agent
Return

GAAgentGuiEscape:
GAAgentGuiClose:
Gui, GAAgent:Destroy
Return

;;--------------------------------AI INIT--------------------------------------------------;;
GAAgentButtonInitialize:

Gui, GAAgent:Destroy
Gui, GitLog:Destroy

FileRead, det_if_ignore, %Full_Project_Location%\.gitignore
genGitIgnore(det_if_ignore, Full_Project_Location)

FormatTime, Today_Date_Time, , yyyy_MM_dd_

IfExist, %Back_Up_Path%\%Full_Prj_Loc_FileName%
	Goto, Err_Exist_Back_Up

FileCreateDir, %Full_Project_Location%_jabi_backup
Sleep 250

FileCopyDir, %Full_Project_Location%, %Full_Project_Location%_jabi_backup, 1

If (ErrorLevel = 1)
	Goto, Err_Moving_Files

FileRemoveDir, %Full_Project_Location%, 1

FileCreateDir, %Back_Up_Path%\%Today_Date_Time%%Full_Prj_Loc_FileName%

If (ErrorLevel = 1)
	Goto, Err_Create

RunWait, %ComSpec% /c git init --bare, %Back_Up_Path%\%Today_Date_Time%%Full_Prj_Loc_FileName%, Hide
RunWait, %ComSpec% /c git clone "%Back_Up_Path%\%Today_Date_Time%%Full_Prj_Loc_FileName%", %Full_Prj_Loc_Dir%, Hide

FileCopyDir, %Full_Project_Location%_jabi_backup, %Full_Prj_Loc_Dir%\%Today_Date_Time%%Full_Prj_Loc_FileName%, 1
FileRemoveDir, %Full_Project_Location%_jabi_backup, 1

RunWait, %ComSpec% /c "git add . > "%A_Temp%\git_log.txt"", %Full_Prj_Loc_Dir%\%Today_Date_Time%%Full_Prj_Loc_FileName%, Hide
RunWait, %ComSpec% /c "git commit -m "Initialized" >> "%A_Temp%\git_log.txt"", %Full_Prj_Loc_Dir%\%Today_Date_Time%%Full_Prj_Loc_FileName%, Hide
RunWait, %ComSpec% /c "git push origin -v >> "%A_Temp%\git_log.txt" 2>&1", %Full_Prj_Loc_Dir%\%Today_Date_Time%%Full_Prj_Loc_FileName%, Hide

FileRead, res_git_log, %A_Temp%\git_log.txt
RegExMatch(res_git_log, "is)[0-9]+\s*file.+" , res_git_log)

If res_git_log = 
	{
	FileRead, res_git_log, %A_Temp%\git_log.txt
	res_git_log := "**********************" . "`r`nERROR OCCURRED`r`n" . "**********************`r`n" . res_git_log
	}

Gui, GitLog:Destroy
Gui, GitLog:Add,Edit,R14 ReadOnly,%res_git_log%
Gui, GitLog:Show, , Backup Summary

Return

;;--------------------------------AI UPDATE--------------------------------------------------;;
GAAgentButtonUpdate:

Gui, GAAgent:Destroy
Gui, GitLog:Destroy

FileRead, det_if_ignore, %Full_Project_Location%\.gitignore
genGitIgnore(det_if_ignore, Full_Project_Location)

RunWait, %ComSpec% /c "git fetch > "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
RunWait, %ComSpec% /c "git status >> "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
FileRead, res_git_log, %A_Temp%\git_log.txt

If !(RegExMatch(res_git_log, "im)On branch master"))
	{
		Msgbox Not in Present Timeline, Please jump to present before updating.
		Return
	}

If (RegExMatch(res_git_log, "im)On branch master\r?\nYour branch is up-to-date with 'origin/master'\.(?:\r?\n)+nothing to commit, working tree clean"))
	{
		RunWait, %ComSpec% /c "git log --oneline > "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
		FileRead, res_git_log, %A_Temp%\git_log.txt
		res_git_log := "**********************" . "`r`nProject Updated`r`n" . "**********************`r`n" . res_git_log
		Gui, GitLog:Add,Edit,R14 ReadOnly,%res_git_log%
		Gui, GitLog:Show, x0 y0, Backup Summary
		Return
	}

RunWait, %ComSpec% /c "git remote show origin >> "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
FileRead, res_git_log, %A_Temp%\git_log.txt

Gui, GitLog:Add,Edit,R14 ReadOnly,%res_git_log%
Gui, GitLog:Show, x0 y0, Backup Summary
Gui +LastFound +OwnDialogs +AlwaysOnTop
InputBox, desc_prj_up, Description of TimeStamp, Please enter the description of this TimeStamp.

If (ErrorLevel = 1)
	Return

If desc_prj_up = 
{
	Msgbox Description Cannot be Empty
	Return
}

RunWait, %ComSpec% /c "git add . > "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
RunWait, %ComSpec% /c "git commit -m "%desc_prj_up%" >> "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
RunWait, %ComSpec% /c "git push origin -v >> "%A_Temp%\git_log.txt" 2>&1", %Full_Project_Location%, Hide

FileRead, res_git_log, %A_Temp%\git_log.txt
RegExMatch(res_git_log, "is)[0-9]+\s*file.+" , res_git_log)

If res_git_log = 
	{
	FileRead, res_git_log, %A_Temp%\git_log.txt
	res_git_log := "**********************" . "`r`nERROR OCCURRED`r`n" . "**********************`r`n" . res_git_log
	}

Gui, GitLog:Destroy
Gui, GitLog:Add,Edit,R14 ReadOnly,%res_git_log%
Gui, GitLog:Show, , Backup Summary

Return

;;--------------------------------AI TAKE--------------------------------------------------;;
GAAgentButtonTake:
Gui, GAAgent:Destroy
Gui, GitLog:Destroy
Menu List_Menu,Add
Menu List_Menu,DeleteAll
chk_if_empty := 

IfExist, %Full_Project_Location%\.git
{
	
	Msgbox,1,, Warning You are about to take local repository state.
	
	IfMsgBox, Cancel
		Return
	
	RunWait, %ComSpec% /c "git fetch > "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
	RunWait, %ComSpec% /c "git status >> "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
	FileRead, res_git_log, %A_Temp%\git_log.txt
	Gui, GitLog:Add,Edit,R14 ReadOnly,%res_git_log%
	Gui, GitLog:Show, x0 y0, Backup Summary
	Msgbox,1,, Do you want to take state of repository?
		
	IfMsgBox, Cancel
		Return
		
	RunWait, %ComSpec% /c "git pull > "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
	FileRead, res_git_log, %A_Temp%\git_log.txt
	Gui, GitLog:Destroy
	Gui, GitLog:Add,Edit,R14 ReadOnly,%res_git_log%
	Gui, GitLog:Show, , Backup Summary
	Return
}

Else
{
	kywrd_srch := 
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	InputBox, kywrd_srch, Key Word Search, Please enter a keyword of the projects you want to list `nyou can enter any of the following: `n`n1. DATE FORMAT [YYYYMM]`n2. Any KeyWord in ProjectName `n3. Just leave blank to list all, , , 300
	
	StringUpper, kywrd_srch_all_caps, kywrd_srch
	
	If (ErrorLevel = 1)
		Return
	
	If (RegExMatch(kywrd_srch, "i)^[0-9]"))
		kywrd_srch := SubStr(kywrd_srch, 1 , 4) . "_" . SubStr(kywrd_srch, 5 , 6)
		
		If kywrd_srch != 
			{
				Loop, Files, %Back_Up_Path%\*%kywrd_srch%* , D
					{
						chk_if_empty := A_LoopFileName
						Menu List_Menu,Add, %A_LoopFileName%, Take_Project
					}
				
				If chk_if_empty = 
					{
						MsgBox No Such Project found in Database
						Return
					}
				
				Menu List_Menu,Show,0 ,0 
				Return
			}
		
		Else
			{
				Loop, Files, %Back_Up_Path%\* , D
					{
						chk_if_empty := A_LoopFileName
						Menu List_Menu,Add, %A_LoopFileName%, Take_Project
					}
				
				If chk_if_empty = 
					{
						MsgBox Database Empty
						Return
					}
				
				Menu List_Menu,Show,0 ,0 
				Return
			}
}

Return
;;--------------------------------AI TIMELINE--------------------------------------------------;;
GAAgentButtonTimeLine:
Gui, GAAgent:Destroy
Gui, GitLog:Destroy
Menu List_Timeline,Add
Menu List_Timeline,DeleteAll

RunWait, %ComSpec% /c "git fetch > "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
RunWait, %ComSpec% /c "git status >> "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
FileRead, res_git_log, %A_Temp%\git_log.txt
Gui, GitLog:Add,Edit,R14 ReadOnly,%res_git_log%
Gui, GitLog:Show, x0 y0, Backup Summary

If (RegExMatch(res_git_log, "im)On branch master([^*]+)Changes not staged for commit:"))
{
	MsgBox, 4097,, You have currently modified files that are not registered in the timeline. `nDo you want to proceed to Jump?
	
	IfMsgBox, Cancel
		Return
	
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	InputBox, desc_prj_up, Description of TimeStamp, Please enter the description of this TimeStamp. `nLeave it blank to use default description. `n`nDEFAULT DESCRIPTION FORMAT BELOW:`nFrom: "PREVIOUS_TIME" || Jumping To: "TARGET_TIME"

	If (ErrorLevel = 1)
		Return

	If desc_prj_up != 
		{
			RunWait, %ComSpec% /c "git add . > "%A_Temp%\git_log.txt" 2>&1", %Full_Project_Location%, Hide
			RunWait, %ComSpec% /c "git commit -m "%desc_prj_up%" >> "%A_Temp%\git_log.txt" 2>&1", %Full_Project_Location%, Hide
		}
}

Gui, GitLog:Destroy
RunWait, %ComSpec% /c "git log --oneline > "%A_Temp%\git_log.txt"", %Full_Project_Location%, Hide
FileRead, res_git_log, %A_Temp%\git_log.txt

Loop, Parse, res_git_log , `n, `r
	{
		Menu List_Timeline,Add, %A_LoopField%, goto_timeline
	}

Menu List_Timeline,Add, Present, goto_timeline
Menu List_Timeline,Show,0 ,0 
Return

;;-------------------------------------Take Project-------------------------------------------------------------;;
Take_Project:
IfExist, %Full_Project_Location%\%A_ThisMenuItem%
	{
		Msgbox Project Already Exists in Folder. Either Rename or Delete it First.
		Return
	}

Progress, b fs9 CW800080 CTFFFFFF zh0, %A_ThisMenuItem%...`nPulling Project Please Wait...
RunWait, %ComSpec% /c git clone "%Back_Up_Path%\%A_ThisMenuItem%", %Full_Project_Location%, Hide
Progress, Off
Msgbox Project: %A_ThisMenuItem% `nSuccessfully Pulled from Database
Return

;;-------------------------------------Goto TimeLine-------------------------------------------------------------;;
goto_timeline:
If (A_ThisMenuItem != "Present")
{
	Loop, Parse, A_ThisMenuItem , %A_Space%
		{
			If (A_Index > 1)
				Break
				
			Id_of_timeline := A_LoopField
		}
	Label_Id_of_timeline := Id_of_timeline
}
Else
{
	Id_of_timeline := "master"
	Label_Id_of_timeline := "Present"
}

Progress, b fs9 CW800080 CTFFFFFF zh0, Going to: %Label_Id_of_timeline%...`nMoving TimeLine...

RunWait, %ComSpec% /c "git status > "%A_Temp%\git_log.txt" 2>&1", %Full_Project_Location%, Hide
FileRead, res_git_log, %A_Temp%\git_log.txt

If (RegExMatch(res_git_log, "im)HEAD detached at ([^\r\n]+)" , Head_current_location))
	Previous_time_line := Head_current_location1

Else If (RegExMatch(res_git_log, "im)On branch master"))
	Previous_time_line := "Present"

RunWait, %ComSpec% /c "git add . > "%A_Temp%\git_log.txt" 2>&1", %Full_Project_Location%, Hide
RunWait, %ComSpec% /c "git commit -m "From: %Previous_time_line% || Jumping To: %Label_Id_of_timeline%" >> "%A_Temp%\git_log.txt" 2>&1", %Full_Project_Location%, Hide
RunWait, %ComSpec% /c "git checkout %Id_of_timeline% >> "%A_Temp%\git_log.txt" 2>&1", %Full_Project_Location%, Hide

Progress, Off

Msgbox Move from %Previous_time_line% to %Label_Id_of_timeline%
Return

;;---------------------------------------ERROR LABELS----------------------------------------------------------;;
No_Reg_Location:
Msgbox No Registered Location
Return

Err_Exist_Back_Up:
Msgbox Project Already Exists in Backup Location. Please Check.
Return

Err_Moving_Files:
Msgbox Files Cannot be moved. Other Process are still using it.
Return

Err_Create:
Msgbox Connot Create Folders
Return

;;---------------------------------------GENERATE GITIGNORE----------------------------------------------------------;;
genGitIgnore(genGitIgnore_rawFile, genGitIgnore_loc) {
If !(RegExMatch(genGitIgnore_rawFile, "im)#Jabi_Ignores"))
{
FileAppend,
(

#Jabi_Ignores
~$*.doc*
~$*.xls*
*.xlk
~$*.ppt*
*.~vsd*
node_modules
), %genGitIgnore_loc%\.gitignore
}
}

;;---------------------------------------GET LOC FUNC----------------------------------------------------------;;
ActiveFolderPath()
{
	IfWinActive ahk_class Progman
		Return %A_Desktop%
	
	Return PathCreateFromURL( ExplorerPath(WinExist("A")) )
}

; slightly modified version of function by jethrow
; on AHK forums.
;
ExplorerPath(_hwnd)
{
   for Item in ComObjCreate("Shell.Application").Windows
      if (Item.hwnd = _hwnd)
         return, Item.LocationURL
}

; function by SKAN on AHK forums
;
PathCreateFromURL( URL )
{
 VarSetCapacity( fPath, Sz := 2084, 0 )
 DllCall( "shlwapi\PathCreateFromUrl" ( A_IsUnicode ? "W" : "A" )
         , Str,URL, Str,fPath, UIntP,Sz, UInt,0 )
 return fPath
}