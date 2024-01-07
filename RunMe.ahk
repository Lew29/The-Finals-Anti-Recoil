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