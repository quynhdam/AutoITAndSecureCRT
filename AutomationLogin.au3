#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:        Zelda

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIFiles.au3>

Opt("WinTitleMatchMode", 2)

HotKeySet("{ESC}", "Exitt")
#Region ### START Koda GUI section ### Form=
$Form = GUICreate("Automation Login Project", 491, 374, 307, 148)
$Group = GUICtrlCreateGroup("User interface", 8, 8, 473, 353)
$txtLog = GUICtrlCreateEdit("", 16, 24, 457, 297)
GUICtrlSetData(-1, "")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Label = GUICtrlCreateLabel("Author: Zelda", 400, 344, 68, 19)
GUICtrlSetFont(-1, 8, 400, 2, "Palatino Linotype")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
Global $s = ""
Global $User = "admin"
Global $g_sLogFilePath = "Log_" & @YEAR & "_" & @MON & "_" & @MDAY & ".log"
Global $FileMAC = "ListMAC.txt"
Global $sPass = ""
While 1
	_Log("=================================")
	_Log("Start to check!!!!")
	_Log("Waiting for connection from 192.168.1.1")
	Local $iPingRes = 0
	Local $sMAC_ADDRESS = ""
	While ($iPingRes = 0)
		$iPingRes = Ping("192.168.1.1", 500)
	WEnd
	_Log("Ping 192.168.1.1 success with roundtrip time: " & $iPingRes & "ms")
	Local $iPID = Run(@ComSpec & ' /C ' & 'arp -a', "", @SW_HIDE, $STDOUT_CHILD)
	ProcessWaitClose($iPID)
	$sMAC_ADDRESS = _Extract_MAC_FromARP(StdoutRead($iPID))
;~ 	Local $result = CheckMAC($sMAC_ADDRESS)
;~ 	If $result = 1 Then 
;~ 		$answer = MsgBox(4, "", "This MAC address is checked. Do you want to re-check?")
;~ 		_Log("This MAC address is checked")
;~ 		If $answer = 6 Then 
;~ 			_Log("Re-check MAC address " & $sMAC_ADDRESS)
;~ 			Handle()
;~ 		Else 
;~ 			_Log("Not re-check MAC address " & $sMAC_ADDRESS) 
;~ 		EndIf
;~ 	EndIf
;~ 	If $result = 0 Then 
		SaveMac($sMAC_ADDRESS)
		Handle()
;~ 	EndIf
	Sleep(50)
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd

Func SaveMac($MAC)
	ConsoleWrite("$File: " & $FileMAC &  @CRLF)
	$LogFile = FileOpen($FileMAC, $FO_APPEND)
	ConsoleWrite("$File: " & $FileMAC &  @CRLF)
	Local $sTime = StringFormat("[%04d-%02d-%02d - %02d:%02d:%2d]", @YEAR, @MON, @MDAY, @HOUR, @MIN, @MSEC)
	Local $sLog = StringFormat("%s %s" & @CRLF, $sTime, $MAC)
	If $LogFile <> -1 Then
		Local $LogWriteRes = FileWrite($FileMAC, $sLog &  @CRLF)
		If $LogWriteRes = 0 Then
			TrayTip("Error", "Can not write MAC address to file " & $FileMAC, 0, 0)
		Else
			FileClose($LogFile)
		EndIf
	Else
		TrayTip("Error", "Can not write MAC address to file " & $FileMAC, 0, 0)
	EndIf
EndFunc
Func Handle()
	If $sPass <> "" Then 
		$sPass = ""
	EndIf
	$sPass = Get_Pass($sMAC_ADDRESS)
	ConsoleWrite("$sPass: " & $sPass &  @CRLF)
	If $sPass <> "" Then 
		_Log("Router MAC address:" & $sMAC_ADDRESS)
		Sleep(100)
		_Log("New password is: " & $sPass )
		Sleep(100)
		Login($User, $sPass)
	EndIf
EndFunc
Func _Extract_MAC_FromARP($sString, $sIP = "192.168.1.1")
	Local $aLines = StringSplit($sString, @CRLF)
	Local $aTxt
	For $i = 1 To $aLines[0]
		If StringInStr($aLines[$i], $sIP) Then
			$aLines[$i] = StringStripWS($aLines[$i], $STR_STRIPSPACES)
			$aTxt = StringSplit($aLines[$i], " ")
			For $iTxt = 1 To $aTxt[0]
				If StringInStr($aTxt[$iTxt], $sIP) Then
					Return StringReplace($aTxt[$iTxt + 1], "-", ":")
				EndIf
			Next
			;_ArrayDisplay($aTxt)
			Return
		EndIf
	Next
EndFunc 
	
Func Get_Pass($sString)
	Local $data = ""
	ConsoleWrite($sString &  @CRLF)
	$string = StringSplit($sString, ":")
	For $i = 1 To $string[0] 
		$s &= $string[$i]   
    Next
	ConsoleWrite($s & @CRLF)
	ConsoleWrite(StringTrimLeft($s, 2) &  @CRLF) 
	Local $str = StringUpper(StringTrimLeft($s, 2))
	If StringLen($str)> 10 Then 
		$data = StringTrimLeft($str, StringLen($str) - 10)
	EndIf
	Return $data
EndFunc

Func Login($User, $Pass)
	ShellExecute("C:\Users\QuynhDam\Downloads\SecureCRTPortable\App\SecureCRT\SecureCRT.exe", "/SCRIPT LoginAndSendCommand.vbs /SSH2  /ACCEPTHOSTKEYS /L admin /PASSWORD " & $Pass & " 192.168.1.1" )
	$Pass = ""
	While Ping("192.168.1.1", 3000) 
		Sleep(1000)
		
	Wend
	WinClose("SecureCRT")
	Send("{ENTER}")
	TrayTip("RD", "SecureCRT closed", 0, 0)
EndFunc

Func _Log($sStr)
	Local $sTime = StringFormat("[%04d-%02d-%02d - %02d:%02d:%2d]", @YEAR, @MON, @MDAY, @HOUR, @MIN, @MSEC)
	Local $sLog = StringFormat("%s %s" & @CRLF, $sTime, $sStr)
	
	GUICtrlSetData($txtLog, $sLog, 1)     ;Append text to GUI

	;Write text to file
	$hLogFile = FileOpen($g_sLogFilePath, $FO_APPEND)
	If $hLogFile <> -1 Then
		$g_iLogWriteRes = FileWrite($hLogFile, $sLog)
		If $g_iLogWriteRes = 0 Then
			TrayTip("Error", "Can not write to debug file " & $g_sLogFilePath, 0, 0)
		Else
			FileClose($hLogFile)
		EndIf
	Else
		TrayTip("Error", "Can not write to debug file " & $g_sLogFilePath, 0, 0)
	EndIf
EndFunc   ;==>_Log

Func Exitt()
	Exit
EndFunc

Func CheckMAC($s)
	$file = FileOpen("ListMAC.txt", 0)
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop
			if $line = $s Then 
				$result = 1
			Else 
				$result = 0
			EndIf
	WEnd
	Return $result
	FileClose($file)
EndFunc 


