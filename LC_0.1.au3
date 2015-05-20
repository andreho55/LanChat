#include <GUIConstants.au3>
#Include <ScrollBarConstants.au3>
#include <EditConstants.au3>
#Include <GUIEdit.au3>
#include <GuiIPAddress.au3>

$pr = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "Port")
$name = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "Name")
$ip1 = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "IP1")
$ip2 = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "IP2")
$file = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "HistoryFile")


if FileExists($file) then
	$hist = FileRead($file)
Else
	$hist = ""
endif
$MainWindow = GUICreate("LanChat - "&$name, 394, 293, 192, 124)
$history = GUICtrlCreateEdit("", 16, 16, 353, 201, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY))
GUICtrlSetData(-1, $hist)
$iEnd = StringLen(GUICtrlRead($history))
_GUICtrlEdit_SetSel($history, $iEnd, $iEnd)
_GUICtrlEdit_Scroll($history, $SB_SCROLLCARET)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$msg = GUICtrlCreateInput("", 16, 232, 353, 21, $GUI_SS_DEFAULT_INPUT)
$Send = GUICtrlCreateButton("Send", 296, 256, 75, 25)
$Opts = GUICtrlCreateButton("Options", 16, 256, 75, 25)
Dim $MainWindow_AccelTable[1][2] = [["{ENTER}", $Send]]
GUISetAccelerators($MainWindow_AccelTable)
GUISetState(@SW_SHOW)



TCPStartup()



$socket = TCPListen($IP1, $pr, 1)
If @error Then 
	msgbox(16,"","No socket")
endif

While 1
	$nMsg = GUIGetMsg()
    $Connect = TCPAccept($socket)
	if $connect <> -1 Then 
		$data = TCPRecv($connect,256)
	else
		$data = Null
	endif
	if $data <> Null then
		filldata($data)
;~ 		TrayTip ( "", $data,1)
	endif
    Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		case $Send
			$iSocket = TCPConnect($ip2, $pr)
			If @error Then msgbox(16,"","Please run LanChat on Second PC")
			$sendData = GUICtrlRead($msg)
			$senddata = $name&@CRLF&$sendData
			if $sendData <> "" Then
				TCPSend ( $iSocket , $senddata )
			EndIf
			GUICtrlSetData($msg,"")
			filldata($senddata )
		case $opts
			$Options = GUICreate("Options", 147, 340, 302, 244, $WS_SYSMENU)
			$NameInp = GUICtrlCreateInput("", 8, 32, 129, 21)
			GUICtrlSetData($NameInp, $name)
			$Label1 = GUICtrlCreateLabel("Name", 8, 8, 32, 17)
			$IP = GUICtrlCreateLabel("IP of this PC", 8, 64, 62, 17)
			$IPAddress1 = _GUICtrlIpAddress_Create($Options, 8, 80, 130, 21)
			_GUICtrlIpAddress_Set($IPAddress1, $ip1)
			$Label2 = GUICtrlCreateLabel("IP of second PC", 8, 104, 81, 17)
			$IPAddress2 = _GUICtrlIpAddress_Create($Options, 8, 120, 130, 21)
			_GUICtrlIpAddress_Set($IPAddress2, $ip2)
			$Label3 = GUICtrlCreateLabel("Port", 8, 144, 23, 17)
			$Input1 = GUICtrlCreateInput("", 8, 160, 49, 21)
			GUICtrlSetData($Input1, $pr)
			$Save = GUICtrlCreateButton("Save", 32, 264, 75, 25)
			$Label4 = GUICtrlCreateLabel("History file", 8, 184, 52, 17)
			$HistoryFileInp = GUICtrlCreateInput("", 8, 200, 129, 21)
			GUICtrlSetData($HistoryFileInp, "")
			$Browse = GUICtrlCreateButton("Browse", 32, 232, 75, 25)
			GUISetState(@SW_SHOW)
			
			While 1
				$nMsg = GUIGetMsg()
				Switch $nMsg
					Case $GUI_EVENT_CLOSE
						GUIDelete($Options)
;;;;; 					ExitLoop
					case $Save
						RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "Port", "REG_SZ", GUICtrlRead($Input1))
						RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "Name", "REG_SZ", GUICtrlRead($NameInp))
						RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "IP1", "REG_SZ", _GUICtrlIpAddress_Get($IPAddress1))
						RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "IP2", "REG_SZ", GUICtrlRead($IPAddress2))
						RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\LanChat", "HistoryFile", "REG_SZ", GUICtrlRead($HistoryFileInp))
						msgbox(0,"Done","Settings saved")
						GUIDelete($Options)
						ExitLoop
				EndSwitch
			WEnd
	EndSwitch
WEnd




func filldata($data)
	$data = @YEAR&"-"&@MON&"-"&@MDAY&" "&@HOUR&":"&@MIN&":"&@SEC&" "&$data
	GUICtrlSetData($history,GUICtrlRead($history)&@CRLF&$data)
	$iEnd = StringLen(GUICtrlRead($history))
	_GUICtrlEdit_SetSel($history, $iEnd, $iEnd)
	_GUICtrlEdit_Scroll($history, $SB_SCROLLCARET)
	FileWriteLine($file,$data)
endfunc




