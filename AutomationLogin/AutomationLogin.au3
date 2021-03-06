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
#include <Debug.au3>
Opt("WinTitleMatchMode", 2)

HotKeySet("{ESC}", "Exitt")
#Region ### START Koda GUI section ### Form=
$Form = GUICreate("Automation Login Project", 491, 374, 307, 148)
$Group = GUICtrlCreateGroup("User interface", 8, 8, 473, 353)
$txtLog = GUICtrlCreateEdit("", 16, 24, 457, 297, ($ES_AUTOVSCROLL + $ES_AUTOHSCROLL + $ES_READONLY), $ES_READONLY)
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
Global $sMAC_ADDRESS = ""
Global $data = ""
While 1
	$data = ""
	$sPass = ""
	$sMAC_ADDRESS = ""
	$s = ""
	ConsoleWrite("Pass=" & $sPass &  @CRLF)
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
;~ 	Local $result
;~ 	If Not FileExists($FileMAC) Then 
;~ 		$result = 0
;~ 	Else 
;~ 		$result = CheckMAC($sMAC_ADDRESS)
;~ 	EndIf 
;~ 	ConsoleWrite("$result: " & $result & @CRLF)
;~ 	If $result > 0 Then 
;~ 		$answer = MsgBox(4, "", "This MAC address is checked. Do you want to re-check?")
;~ 		_Log("This MAC address is checked")
;~ 		If $answer = 6 Then 
;~ 			_Log("Re-check MAC address " & $sMAC_ADDRESS)
;~ 			SaveMac($sMAC_ADDRESS)
;~ 			Handle()
;~ 		Else 
;~ 			_Log("Not re-check MAC address " & $sMAC_ADDRESS) 
;~ 		EndIf
;~ 	EndIf
;~ 	If $result = 0  Then 
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
		Local $LogWriteRes = FileWrite($FileMAC, $sLog)
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
	Local $string = ""
	ConsoleWrite("MAC addr: " & $sString &  @CRLF)
	$string = StringSplit($sString, ":")
;~ 	_DebugArrayDisplay($string)
	For $i = 1 To $string[0] 	
		$s &= $string[$i]	  
    Next
	ConsoleWrite("MAC add after cut: " & $s &  @CRLF)
	ConsoleWrite(StringTrimLeft($s, 2) &  @CRLF) 
	Local $str = StringUpper(StringTrimLeft($s, 2))
;~ 	If StringLen($str)> 10 Then 
;~ 		$data = StringTrimLeft($str, StringLen($str) - 10)
;~ 	EndIf
	Return $str
EndFunc

Func Login($User, $Pass)
	ShellExecuteWait(@ScriptDir & "\SecureCRTPortable\App\SecureCRT\SecureCRT.exe", "/SCRIPT LoginAndSendCommand.vbs /SSH2  /ACCEPTHOSTKEYS /L admin /PASSWORD " & $Pass & " 192.168.1.1" ) 
	WinWaitClose("192.168.1.1 - SecureCRT")
	ConsoleWrite("SecureCRT is closed" &  @CRLF)
	Local $File = FileOpen(@ScriptDir & "\Result.txt")
	Local $Line = FileRead($File)
	If $Line = "cnt_counter: 0" Then 
		_Log($Line)
		_Log("Done")
		FileClose($File)
		FileDelete(@ScriptDir & "\Result.txt")
		While Ping("192.168.1.1", 3000) 
			Sleep(1000)	
		Wend
		;~ 	WinClose("SecureCRT")
		;~ 	Send("{ENTER}")
		TrayTip("RD", "SecureCRT closed", 0, 0)
	Else
		_Log("Disconnect")
		_Log("Re-Connecting")
		Login($User,  $Pass)
	EndIf
	
	
EndFunc

Func Re_Connect()
	Local $File1 = FileOpen(@ScriptDir & "\Check.txt")
	Local $Line1 = FileRead($File1)
	_Log($Line1)
	FileClose($File1)
	FileDelete(@ScriptDir & "\Check.txt")	
	Return $Line1
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
	Local $result = 0
	$file = FileOpen($FileMAC, 0)
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop
			if $line = "" Then 
				
			EndIf
			if StringInStr($line, $s) Then 
				ConsoleWrite("$line: " & $line & @CRLF)
				$result += 1
			EndIf
	WEnd
	Return $result
	FileClose($file)
EndFunc 


