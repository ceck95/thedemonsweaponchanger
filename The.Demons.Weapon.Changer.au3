#RequireAdmin
#include <NomadMemory.au3>
#include "GUICtrlOnHover.au3"
#include "misc.au3"
#Include <WinAPI.au3>

Global $main, $HGWC_gui, $HGWC_stt, $HGWC_stt2, $HGWC_prg_info=0, $HGWC_prg, $red = 0xff6c20, $blue = 0x03a8ff, $reglink="HKEY_CURRENT_USER\Software\The Demons Gun Changer"
Global $exit, $exit_login, $exit_lb, $enter, $enter_lb, $user, $files, $ver = "v1.0.3", $cfdat = "crossfire.dat", $f6 = -1000, $f7 = -1000, $f8 = -1000, $f9 = -1000, $msg2
Global $guns[1000][4], $isload = 0, $add, $nore = 0, $changed_guns[1000][2], $hide = 0, $itemcount = 0, $lb_menu[100]
Global $head = 0x2049, $foot = 0x3187, $backup, $bute, $cb, $cf_path, $cf_path_split, $change, $lb1, $lb2, $list1, $lb2, $read1, $read2, $scan, $scan_old, $skin
Global $list1=-1000, $list2=-1000, $change=-1000, $backup=-1000, $skin=-1000, $bute=-1000, $open = -1000, $gun_selected, $time, $title, $ingame
Global $CShell, $pWeaponmgr, $Client

If ProcessExists($cfdat) then $isload = 1

Global $msg_waiting = "Waiting for crossfire"
Global $msg_loaderror = "Cannot load weapons"
Global $msg_loading = "Loading weapons"
Global $msg_loaded = "Loaded all weapons"
Global $msg_bypassing = "Bypassing XTrap"
Global $msg_bypassed = "Bypassed XTrap"
Global $msg_backingup = "Backing up the weapon"
Global $msg_backedup = "Backed up the weapon"
Global $msg_backingup_bute = $msg_backingup&"'s bute"
Global $msg_backedup_bute = $msg_backedup&"'s bute"
Global $msg_backingup_skin = $msg_backingup&"'s texture"
Global $msg_backedup_skin = $msg_backedup&"'s texture"
Global $msg_noselect = "Select a weapon"
Global $msg_change_error = "Cannot change the weapon"
Global $msg_changing = "Changing the weapon"
Global $msg_changed = "Changed the weapon"
Global $msg_nochange = "The weapon hasn't been changed"
Global $msg_gui_backup = "Backup"
Global $msg_gui_backup_all = "Backup all"
Global $msg_gui_backup_bute = "Backup bute"
Global $msg_gui_backup_bute_all = "Backup all butes"
Global $msg_gui_backup_skin = "Backup texture"
Global $msg_gui_backup_skin_all = "Backup all textures"
Global $msg_gui_change = "Change weapon"
Global $msg_gui_change_all = "Change all weapons"
Global $msg_gui_weaponlist = "Weapon list"
Global $msg_gui_changed_weaponlist = "Changed weapon list"

Opt("WinTitleMatchMode",3)
$gui = GUICreate("The Demons Weapon Changer",330,50,0,0,0x80000000)
GUISetBkColor(0x282828)
$msg = GUICtrlCreateLabel($msg_waiting,0,10,330,100,0x01)
GUICtrlSetColor(-1,0x00BB00)
GUICtrlSetFont(-1,20)
WinSetOnTop($gui, "", 1)
GUISetState()
while 1
	If $isload = 0 and ProcessExists("HGWC.exe") Then
		GUICtrlSetData($msg, $msg_bypassing)
		Wait("HGWC","HGWC.exe")
		$cf_path = _ProcessGetLocation(ProcessExists("HGWC.exe"))
		$cf_path_split = StringSplit($cf_path,"\",1)
		$cf_path = ""
		For $i = 1 to $cf_path_split[0]-1
			$cf_path &= $cf_path_split[$i] & "\"
		Next
		Wait("[CLASS:XPatch V3.6]","HGWC.exe")
		WaitClose("[CLASS:XPatch V3.6]","HGWC.exe")
		FileMove($cf_path&"\XTrap\XTrapVa.dll", $cf_path &"\XTrap\XTrapVa.bk")
		FileInstall("TheDemonsXTrapBypass.dll", $cf_path &"\XTrap\XTrapVa.dll",1)
		GUICtrlSetData($msg, $msg_bypassed)
		While $isload = 0
			If not ProcessExists("HGWC.exe") Then
				$isload = 2
				exit
			EndIf
			If ProcessExists($cfdat) Then $isload = 1
		WEnd
		ElseIf $isload = 1 and ProcessExists($cfdat) Then
		GUICtrlSetData($msg, $msg_loading)
		While not $Client
			$Client = _MemoryModuleGetBaseAddress(ProcessExists($cfdat), "ClientFx.fxd")
			Sleep(10)
		WEnd
		$title = WinGetTitle("[CLASS:CrossFire]")
		WinSetOnTop($title,"", 1)
		GUIDelete()
		CreateGUI()
		setpos()
		GUICtrlSetData($msg, $msg_loading)
		$CShell = _MemoryModuleGetBaseAddress(ProcessExists($cfdat), "cshell.dll")
		$mem = _MemoryOpen(ProcessExists($cfdat))
		$step = scangun()
		If $step = 0 Then
			GUICtrlSetData($msg, $msg_loaderror)
			Sleep(10000)
			Exit
		EndIf
		for $i = 1 To $step
			if $guns[$i][1] then
				$add &= StringUpper($guns[$i][1])
				If $i <> $step then $add &= "|"
			EndIf
		Next
		$add = StringReplace($add, "| |", "|")
		$isload = 2
		$time = TimerInit()
		GUICtrlSetData($list1, $add)
		GUICtrlSetData($list2, $add)
		GUICtrlSetData($msg, $msg_loaded)
	ElseIf $isload = 2 and TimerDiff($time) > 45000 Then
		ProcessClose("HGWC.exe")
		$isload = 3
	ElseIf $isload = 2 or $isload = 3 Then
		setpos()
		If not ProcessExists($cfdat) Then
			FileDelete($cf_path &"\XTrap\XTrapVa.dll")
			FileMove($cf_path &"\XTrap\XTrapVa.bk", $cf_path &"\XTrap\XTrapVa.dll")
			Exit
		EndIf
		If _IsPressed("75") Then
			st_change(1)
			while _IsPressed("2D")
				Sleep(50)
			WEnd
		ElseIf _IsPressed("76") Then
			st_skin(1)
			while _IsPressed("2D")
				Sleep(50)
			WEnd
		ElseIf _IsPressed("77") Then
			st_bute(1)
			while _IsPressed("2D")
				Sleep(50)
			WEnd
		Elseif _IsPressed("78") Then
			st_backup(1)
			while _IsPressed("2D")
				Sleep(50)
			WEnd
		Elseif _IsPressed("2D") Then
			hide()
			while _IsPressed("2D")
				Sleep(50)
			WEnd
		EndIf
	EndIf
	Switch GUIGetMsg()
		case $open
			If GUICtrlGetState($list1) = 80 Then
				GUICtrlSetState($list1,32)
				GUICtrlSetState($list2,32)
				GUICtrlSetData($open, $msg_gui_weaponlist & " [+]")
			ElseIf GUICtrlGetState($list1) = 96 Then
				GUICtrlSetState($list1,16)
				GUICtrlSetState($list2,16)
				GUICtrlSetData($open, $msg_gui_weaponlist & " [-]")
			EndIf
		case $change
			st_change(0)
		case $backup
			st_backup(0)
		case $skin
			st_skin(0)
		case $bute
			st_bute(0)
		case $f6
			st_change(1)
		case $f7
			st_skin(1)
		case $f8
			st_bute(1)
		case $f7
			st_backup(1)
	EndSwitch
WEnd
Func setpos()
	$pos = WinGetPos($title)
	WinMove($ingame,"",$pos[0],$pos[1])
EndFunc

Func hide()
	If $hide = 0 then
		GUISetState(@SW_HIDE, $ingame)
		$hide = 1
	Else
		GUISetState(@SW_SHOW, $ingame)
		$hide = 0
		WinActivate($title)
	EndIf
EndFunc
Func additem($data)
	$lb_menu[$itemcount] = GUICtrlCreateLabel($data,325,42+23*$itemcount,500,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover4", "_Leave4","Choose")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0x00FF00)
	GuiCtrlCreateBox(325-2,42+23*$itemcount-2,500+2,25+2,3,0x0)
EndFunc
Func GuiCtrlCreateBox($left = 0, $top = 0, $width = 100, $height = 100, $brush= 2, $color = 0xFFFFFF)
GUICtrlCreateLabel("", $left, $top, $brush, $height)
GUICtrlSetBkColor(-1, $color)
GUICtrlCreateLabel("", $left+$width-$brush, $top, $brush, $height)
GUICtrlSetBkColor(-1, $color)

GUICtrlCreateLabel("", $left, $top, $width, $brush)
GUICtrlSetBkColor(-1, $color)
GUICtrlCreateLabel("", $left, $top+$height-$brush, $width, $brush)
GUICtrlSetBkColor(-1, $color)
EndFunc
Func st_change($type)
	GUICtrlSetData($msg, $msg_changing)
	If $type = 0 Then
		$read1 = GUICtrlRead($list1)
		$read2 = GUICtrlRead($list2)
		If not $read1 or not $read2 Then
			GUICtrlSetData($msg, $msg_noselect)
			Return
		EndIf
		$index1 = 0
		$index2 = 0
		$stt = 0
		For $i = 1 to $step
			If $read1 = $guns[$i][1] And $index1 = 0 then
				$index1 = $i
				$stt += 1
			EndIf
			If $read2 = $guns[$i][1] And $index2 = 0 then
				$index2 = $i
				$stt += 1
			EndIf
			If $stt = 2 then ExitLoop
		Next
		If change_gun($index1,$index2) = 1 Then
			GUICtrlSetData($msg, $msg_changed)
			For $i_check = 1 to $changed_guns[0][0]
				If $changed_guns[$i_check][0] = $index1 then
					GUICtrlSetData($lb_menu[$i_check], $read1 &" -> "&$read2)
					GUICtrlSetColor($lb_menu[$i_check], 0x00FF00)
					$changed_guns[$i_check][1] = $index2
					$i_check += 100000
					ExitLoop
				EndIf
			Next
			If $i_check < 2100 Then
				$changed_guns[0][0] += 1
				$changed_guns[$changed_guns[0][0]][0] = $index1
				$changed_guns[$changed_guns[0][0]][1] = $index2
				$itemcount+=1
				additem($read1 &" => "&$read2)
			EndIf
		Else
			GUICtrlSetData($msg, $msg_change_error)
		EndIf
	Else
		For $i = 1 to $changed_guns[0][0]
			change_gun($changed_guns[$i][0], $changed_guns[$i][1])
			GUICtrlSetColor($lb_menu[$i], 0x00FF00)
		Next
		GUICtrlSetData($msg, $msg_changed)
	EndIf
EndFunc
Func st_backup($type)
	GUICtrlSetData($msg, $msg_backingup)
	If $type = 0 Then
		$read1 = StringSplit(GUICtrlRead($gun_selected)," => ",1)
		If @error Then
			GUICtrlSetData($msg, $msg_noselect)
			Return
		EndIf
		$read1 = $read1[1]
		For $i = 1 to $step
			If $guns[$i][1] = GUICtrlRead($list1) then
				GUICtrlSetColor($gun_selected, 0xFF0000)
				Backup($i)
				GUICtrlSetData($msg, $msg_backedup)
				ExitLoop
			EndIf
		Next
	Else
		For $i = 1 to $changed_guns[0][0]
			GUICtrlSetColor($lb_menu[$i], 0xFF0000)
			backup($changed_guns[$i][0])
		Next
		GUICtrlSetData($msg, $msg_backedup)
	EndIf
EndFunc
Func st_skin($type)
	GUICtrlSetData($msg, $msg_backingup_skin)
	If $type = 0 then
		$read1 = StringSplit(GUICtrlRead($gun_selected)," => ",1)
		If @error Then
			GUICtrlSetData($msg, $msg_noselect)
			Return
		EndIf
		$read1 = $read1[1]
		For $i = 1 to $step
			If $read1 = $guns[$i][1] then
				For $i_check = 1 to $changed_guns[0][0]
					If $changed_guns[$i_check][0] = $i Then
						GUICtrlSetColor($lb_menu[$i_check], 0xFFFF00)
						skin($i)
				        GUICtrlSetData($msg, $msg_backedup_skin)
						ExitLoop
					EndIf
				Next
			EndIf
		Next
	Else
		For $i = 1 to $changed_guns[0][0]
			skin($changed_guns[$i][0])
			GUICtrlSetColor($lb_menu[$i], 0xFFFF00)
		Next
		GUICtrlSetData($msg, $msg_backedup_skin)
	EndIf
EndFunc
Func st_bute($type)
	GUICtrlSetData($msg, $msg_backingup_bute)
	If $type = 0 Then
		$read1 = StringSplit(GUICtrlRead($gun_selected)," => ",1)
		If @error Then
			GUICtrlSetData($msg, $msg_noselect)
			Return
		EndIf
		$read1 = $read1[1]
		For $i = 1 to $step
		If $read1 = $guns[$i][1] then
			if not $guns[$i][2] Then
				GUICtrlSetData($msg, $msg_nochange)
				ExitLoop
			EndIf
			For $i_check = 1 to $changed_guns[0][0]
				If $changed_guns[$i_check][0] = $i Then
					GUICtrlSetColor($lb_menu[$i_check], 0xFFFF00)
					MsgBox(0,"","")
					bute($i)
					GUICtrlSetData($msg, $msg_backedup_bute)
					ExitLoop
				EndIf
			Next
		EndIf
		Next
	Else
		For $i = 1 to $changed_guns[0][0]
			bute($changed_guns[$i][0])
			GUICtrlSetColor($lb_menu[$i], 0xFFFF00)
		Next
		GUICtrlSetData($msg, $msg_backedup_bute)
	EndIf
EndFunc
Func Backup($index)
	_MemoryWrite($guns[$index][0], $mem,$guns[$index][2],"byte["&0x3187 + 0x2949&"]")
EndFunc
Func Bute($index)
	_MemoryWrite($guns[$index][0], $mem, StringLeft(BinaryToString($guns[$index][2]),0x9db),"byte["&0x9db&"]")
	_MemoryWrite($guns[$index][0]+0x2049-0x164D, $mem, StringMid(BinaryToString($guns[$index][2]),0x2049-0x164c,0x164c),"byte["&0x164c&"]")
EndFunc
Func Skin($index)
	Local $add_blank = ""
	For $i = 1 to 0x37 - StringLen($guns[$index][3])
		$add_blank &= BinaryToString("0x00")
	Next
	_MemoryWrite($guns[$index][0]+0x2049, $mem,$guns[$index][3]&$add_blank,"byte["&StringLen($guns[$index][3]&$add_blank)&"]")
EndFunc
Func scangun()
	Local $scan, $scan_old, $step = 0, $str, $str2, $start = $CShell + 0x96E0E0, $end
	Local $pattern = StringReplace(StringToBinary("ModelTextures\x5CPlayerView\x5CPV"),"0x","")
	Local $len = StringLen($pattern)/2
	Local $mask = ""
	For $i = 1 to $len
		$mask &= "x"
	Next
	$scan = _MemoryScanEx_special($mem, $pattern, $mask,False,0x00000000, 0x30000000)+0x19
	$scan_old = 0x00000000
	While $scan <> -3 +0x19
		If $scan <> -3 Then
			$str = BinaryToString(StringReplace(_MemoryRead($scan-0x166C, $mem, "byte["&0x20&"]"),"00",""))
			If Not StringRegExp($str,"\x5C",0) then
				$str2 = BinaryToString(StringReplace(_MemoryRead($scan, $mem, "byte["&0x37&"]"),"00",""))
				$step+=1
				$guns[$step][0] = "0x"&Hex($scan-0x2049)
				$guns[$step][1] = $str
				$guns[$step][3] = $str2
			EndIf
			$scan_old = $scan + 0x3187
		EndIf
		$scan = _MemoryScanEx_special($mem, $pattern, $mask,False,$scan_old,0x30000000)+0x19
	WEnd
	MsgBox(0,"",$step)
	return $step
EndFunc
Func change_gun($index1, $index2)
	Local $len = $head + $foot
	If $head = 0 Then
		$head_rv = 0x2049
	Else
		$head_rv = 0
	EndIf
	Local $gun2 = _MemoryRead($guns[$index2][0]+$head_rv, $mem, "byte["&$len&"]")
	If @error then Return 0
	If not $guns[$index2][2] then $guns[$index2][2] = _MemoryRead($guns[$index2][0], $mem, "byte["&0x3187 + 0x2049&"]")
	If not $guns[$index1][2] then $guns[$index1][2] = _MemoryRead($guns[$index1][0], $mem,"byte["&0x3187 + 0x2049&"]")
	_MemoryWrite($guns[$index1][0]+$head_rv, $mem,$gun2,"byte["&$len&"]")
	If @error then Return 0
	Return 1
EndFunc
Func CreateGUI()
	Local $pos = WinGetPos($title)
	$ingame = GUICreate("",1000,1000,$pos[0],$pos[1],0x80000000,0x00080000,WinGetHandle($title))
	GUISetBkColor(0xABCDEF)
	$list1 = GUICtrlCreateList("",20,305,300,180)
	GUICtrlSetFont(-1,12)
	GUICtrlSetColor(-1,0xffffff)
	GUICtrlSetBkColor(-1,0x282828)
	$list2 = GUICtrlCreateList("",20,480,300,180)
	GUICtrlSetFont(-1,12)
	GUICtrlSetColor(-1,0xffffff)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlCreateLabel("The Demons Weapon Changer",20,40,300,25,0x01)
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0x00FF00)
	GuiCtrlCreateBox(20-2,40-2,300+2,25+2,3,0x00FF00)
	$f6 = GUICtrlCreateLabel(" F6: " & $msg_gui_change_all,20,65,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover2", "_Leave2")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFFFFFF)
	GuiCtrlCreateBox(20-2,65-2,300+2,25+2,3,0x0)
	$f7 = GUICtrlCreateLabel(" F7: " & $msg_gui_backup_skin_all,20,88,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover2", "_Leave2")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFFFFFF)
	GuiCtrlCreateBox(20-2,88-2,300+2,25+2,3,0x0)
	$f8 = GUICtrlCreateLabel(" F8: " & $msg_gui_backup_bute_all,20,111,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover2", "_Leave2")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFFFFFF)
	GuiCtrlCreateBox(20-2,111-2,300+2,25+2,3,0x0)
	$f9 = GUICtrlCreateLabel(" F9: " & $msg_gui_backup_all,20,134,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover2", "_Leave2")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFFFFFF)
	GuiCtrlCreateBox(20-2,134-2,300+2,25+2,3,0x0)
	$change = GUICtrlCreateLabel($msg_gui_change,20,157,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover2", "_Leave2")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFFFFFF)
	GuiCtrlCreateBox(20-2,157-2,300+2,25+2,3,0x0)
	$backup = GUICtrlCreateLabel($msg_gui_backup,20,180,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover2", "_Leave2")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFFFFFF)
	GuiCtrlCreateBox(20-2,180-2,300+2,25+2,3,0x0)
	$skin = GUICtrlCreateLabel($msg_gui_backup_skin,20,203,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover2", "_Leave2")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFFFFFF)
	GuiCtrlCreateBox(20-2,203-2,300+2,25+2,3,0x0)
	$bute = GUICtrlCreateLabel($msg_gui_backup_bute,20,226,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover2", "_Leave2")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFFFFFF)
	GuiCtrlCreateBox(20-2,226-2,300+2,25+2,3,0x0)
	$msg = GUICtrlCreateLabel("",20,249,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover3", "_Leave3")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFF00FF)
	GuiCtrlCreateBox(20-2,249-2,300+2,25+2,3,0x0)
	$open = GUICtrlCreateLabel($msg_gui_weaponlist & " [+]",20,272,300,25,0x01)
	_GUICtrl_OnHoverRegister(-1, "_Hover3", "_Leave3")
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0xFF00FF)
	GuiCtrlCreateBox(20-2,272-2,300+2,25+2,3,0x0)
	GUICtrlCreateLabel($msg_gui_changed_weaponlist,325,40,500,25,0x01)
	GUICtrlSetFont(-1,12)
	GUICtrlSetBkColor(-1,0x282828)
	GUICtrlSetColor(-1,0x00FF00)
	GuiCtrlCreateBox(325-2,40-2,500+2,25+2,3,0x00FF00)
	_WinAPI_SetLayeredWindowAttributes($ingame, 0xABCDEF, 255)
	GUICtrlSetState($list1,32)
	GUICtrlSetState($list2,32)
	WinSetOnTop($ingame,"",1)
	GUISetState(@SW_SHOW)
EndFunc
Func _ProcessGetLocation($iPID)
    Local $aProc = DllCall('kernel32.dll', 'hwnd', 'OpenProcess', 'int', BitOR(0x0400, 0x0010), 'int', 0, 'int', $iPID)
    If $aProc[0] = 0 Then Return SetError(1, 0, '')
    Local $vStruct = DllStructCreate('int[1024]')
    DllCall('psapi.dll', 'int', 'EnumProcessModules', 'hwnd', $aProc[0], 'ptr', DllStructGetPtr($vStruct), 'int', DllStructGetSize($vStruct), 'int_ptr', 0)
    Local $aReturn = DllCall('psapi.dll', 'int', 'GetModuleFileNameEx', 'hwnd', $aProc[0], 'int', DllStructGetData($vStruct, 1), 'str', '', 'int', 2048)
    If StringLen($aReturn[3]) = 0 Then Return SetError(2, 0, '')
    Return $aReturn[3]
EndFunc
Func _Hover2($ctrl)
	GUICtrlSetColor($ctrl, 0x00FF00)
EndFunc
Func _Leave2($ctrl)
	GUICtrlSetColor($ctrl, 0xFFFFFF)
EndFunc
Func _Hover3($ctrl)
	GUICtrlSetColor($ctrl, 0xFFF00)
EndFunc
Func _Leave3($ctrl)
	GUICtrlSetColor($ctrl, 0xFF00FF)
EndFunc
Func _Hover4($ctrl)
	GUICtrlSetBkColor($ctrl, 0x383838)
EndFunc
Func _Leave4($ctrl)
	If $ctrl = $gun_selected Then
		GUICtrlSetBkColor($ctrl, 0x484848)
		Return
	EndIf
	GUICtrlSetBkColor($ctrl, 0x282828)
EndFunc
Func Open($ctrl)
	If GUICtrlGetState($list1) = 80 Then
		GUICtrlSetState($list1,32)
		GUICtrlSetState($list2,32)
		GUICtrlSetData($ctrl, "Full Weapons list [+]")
	Else
		GUICtrlSetState($list1,16)
		GUICtrlSetState($list2,16)
		GUICtrlSetData($ctrl, "Full Weapons list [-]")
	EndIf
EndFunc
Func choose($ctrl)
	For $i = 1 to $changed_guns[0][0]
		GUICtrlSetBkColor($lb_menu[$i],0x282828)
	Next
	GUICtrlSetBkColor($ctrl, 0x484848)
	$gun_selected = $ctrl
	Return 1
EndFunc
Func Wait($title, $prc)
	While not WinExists($title)
		If not ProcessExists($prc) Then
			Exit
		EndIf
		Sleep(50)
	WEnd
EndFunc
Func WaitClose($title, $prc)
	While WinExists($title)
		If not ProcessExists($prc) Then
			Exit
		EndIf
		Sleep(50)
	WEnd
EndFunc
