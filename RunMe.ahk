#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance force
#MaxThreadsBuffer on
#Persistent
Process, Priority, , A
SetBatchLines, -1
ListLines Off
SetWorkingDir %A_ScriptDir%
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input

global UUID := "fd1ba7d2558845678c20b46c5035f454"

RunAsAdmin()
HideProcess()
GoSub, initialise

initialise:
{
    IniRead, sensitivity, settings.ini, settings, sensitivity
    global yaw := sensitivity * 0.00101

    global m11 := [LoadPattern("M11.txt"), 60]
    global xp54 := [LoadPattern("XP54.txt"), 68]
    global akm := [LoadPattern("AKM.txt"), 99]
    global fcar := [LoadPattern("FCAR.txt"), 111]
    global m60 := [LoadPattern("M60.txt"), 100]
    global lewisgun := [LoadPattern("LGUN.txt"), 114]

    global currentPattern
    global interval

    SetGun(fcar)
    Return
}

LoadPattern(filename) 
{
    FileRead, patternStr, %A_ScriptDir%\Patterns\%filename%
    patterns := []

    Loop, Parse, patternStr, `n, `, , `" ,`r 
    {
        if StrLen(A_LoopField) == 0
            Continue

        pattern := StrSplit(A_LoopField, ", ")
        pattern[1] := Round(pattern[1]/yaw)
        pattern[2] := Round(pattern[2]/yaw)

        patterns.Insert(pattern)
    }

    return patterns
}

SetGun(gun)
{
    global currentPattern := gun[1]
    global interval := gun[2]
    return
}

Speak(text) 
{
    sp := ComObjCreate("SAPI.SpVoice")
    sp.Rate := 6
    sp.Speak(text)
    Return
}

~$*LButton::
{
    If (!GetKeyState("RButton"))
        Return

    lMax := currentPattern.MaxIndex()

    Loop 
	{
        If (!GetKeyState("LButton", "P") || A_Index > (lmax))
            Return

        pattern := currentPattern[A_Index]

        x := pattern[1]        
        y := pattern[2]

        Move(x, y)
        Sleep, interval
    }
    Return
}

Move(x, y) 
{
    DllCall("mouse_event", uint, 1, int, x, int, y)
    Return
}

ToDegrees(num)
{
    Return num / 0.01745329252
}

ToRadians(num)
{
    Return num * 0.01745329252
}

~$*F1::
{
    SetGun(null)
    Speak("None")
    Return
}

~$*F2::
{
    SetGun(m11)
    Speak("M11 Selected")
    Return
}

~$*F3::
{
    SetGun(xp54)
    Speak("XP54 Selected")
    Return
}

~$*F4::
{
    SetGun(akm)
    Speak("AKM Selected")
    Return
}

~$*F5::
{
    SetGun(fcar)
    Speak("F-CAR selected")
    Return
}

~$*F6::
{
    SetGun(m60)
    Speak("M60 selected")
    Return
}

~$*F7::
{
    SetGun(lewisgun)
    Speak("Lewis gun selected")
    Return
}

~$*End::
{
    Speak("Exiting")
	ExitApp
}

RunAsAdmin()
{
    Global 0
    IfEqual, A_IsAdmin, 1, Return 0
    Loop, %0%
        params .= A_Space . %A_Index%
        DllCall("shell32\ShellExecute" (A_IsUnicode ? "":"A"),uint,0,str,"RunAs",str,(A_IsCompiled ? A_ScriptFullPath : A_AhkPath),str,(A_IsCompiled ? "": """" . A_ScriptFullPath . """" . A_Space) params,str,A_WorkingDir,int,1)
    ExitApp
}

HideProcess() 
{
    If ((A_Is64bitOS=1) && (A_PtrSize!=4))
        hMod := DllCall("LoadLibrary", Str, "hyde64.dll", Ptr)
    Else If ((A_Is32bitOS=1) && (A_PtrSize=4))
        hMod := DllCall("LoadLibrary", Str, "hyde.dll", Ptr)
    Else
    {
        MsgBox, Mixed Versions detected!`nOS Version and AHK Version need to be the same (x86 & AHK32 or x64 & AHK64).`n`nScript will now terminate!
        ExitApp
    }

    If (hMod)
    {
        hHook := DllCall("SetWindowsHookEx", Int, 5, Ptr, DllCall("GetProcAddress", Ptr, hMod, AStr, "CBProc", ptr), Ptr, hMod, Ptr, 0, Ptr)
        If (!hHook)
        {
            MsgBox, SetWindowsHookEx failed!`nScript will now terminate!
            ExitApp
        }
    }
    Else
    {
        MsgBox, LoadLibrary failed!`nScript will now terminate!
        ExitApp
    }
    Return
}