SendMode Input
#SingleInstance Force
#Persistent
#Warn
#Warn LocalSameAsGlobal, Off
#Warn UseUnsetLocal, Off
#Warn UseUnsetGlobal, Off
;;--------------------------------RETRIEVAL OF ENV VARIABLES----------------------------------;;
#NoEnv
EnvGet USERPROFILE, USERPROFILE
;;--------------------------------PROJECT SPECIFIC INIT----------------------------------;;
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2
SetDefaultMouseSpeed, 0

GroupAdd,ExplorerGroup, ahk_class CabinetWClass
GroupAdd,ExplorerGroup, ahk_class ExploreWClass
GroupAdd,ExplorerGroup, ahk_class Progman

#include Modules\config.ahk
#include Modules\tray.ahk

#IfWinActive ahk_group ExplorerGroup
#include Modules\git.ahk

^!End::Reload ;;RESTART PROGRAM


