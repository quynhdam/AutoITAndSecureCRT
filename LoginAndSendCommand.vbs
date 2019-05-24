#$language = "VBScript"
#$interface = "1.0"
Set fso = CreateObject("Scripting.FileSystemObject")
Dim CurrentDirectory
CurrentDirectory = fso.GetAbsolutePathName(".")
strFileName = CurrentDirectory & "\mysession.log"

Sub Main
	Dim str, line,array
	crt.Screen.Synchronous = True
	crt.Screen.IgnoreEscape = True
	crt.Session.LogFileName = strFileName
	crt.Session.Log True, True
	crt.Screen.WaitForString "login: "
	crt.Screen.Send "ambit" & chr(13)
	crt.Screen.WaitForString "Password: "
	crt.Screen.Send "ambitdebug" & chr(13)
	crt.Screen.WaitForString "ftp-gpon$"
	crt.Screen.Send "retsh foxconn168!" & chr(13)
	crt.Screen.WaitForString("# ")
	crt.Screen.Send "echo =================================================================" & chr(13)
	crt.Screen.Send "echo Time at testing: " & now() & chr(13)
	crt.Screen.Send "cat /etc/mac.conf" & chr(13)
	crt.Screen.Send "cat /etc/fwver.conf" & chr(13)
	crt.Screen.Send "uptime" & chr(13)
	crt.Screen.Send "cat /proc/kmsg &" & chr(13)
	crt.Screen.Send "cat /proc/kmsg &" & chr(13)
	crt.Sleep(500)
	crt.Screen.Send "echo bip_cnt show > /proc/gpon/debug" & chr(13)
	crt.Screen.Send "echo =================================================================" & chr(13)
	crt.Screen.Send "echo Send command complete" & chr(13)
	str = crt.Screen.ReadString("Send command complete")
	crt.Screen.Send "echo " & str & chr(13)
	array=Split(str,vbCrlf)
	For Each line in array
		crt.Screen.Send "echo " & line & Chr(13)
		If InStr(line,"total_bip_cnt_counter") then 
			' crt.Screen.Send "echo " & line & Chr(13)
			strRight = Right(line,2)
			crt.Screen.Send "echo " & strRight & Chr(13)
			If strRight = 0 then 
				crt.Screen.Send "echo cnt_counter: " & strRight & Chr(13)
				crt.Screen.Send "echo Checked" & Chr(13)
				crt.Session.Disconnect	
				crt.Quit
			End If
			If strRight <> 0 then
				crt.Screen.Send "echo cnt_counter: " & strRight & Chr(13)
				result = crt.Dialog.MessageBox("cnt_counter is to max, this board fail!", "Error")
				If result = IDOK Then
					Exit For
				End If
			End If
		End If
	Next
	' If crt.screen.WaitForString("# ") = True Then
		' crt.Session.Log False
	' End If
	' Check
	' crt.Session.Log False
	crt.Screen.Synchronous = false
End Sub
