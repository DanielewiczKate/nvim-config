#SingleInstance Force ; Standard v2 formatting

RControl::Shift
CapsLock::Esc
Esc::CapsLock
RAlt::Enter

; Disable the default Win+Space behavior
#Space::Return

; Set Ctrl+Win+Space to trigger the layout switch
^#Space::Send("#{Space}")

!d::Send("{PgDn}") ; Alt + J = Page Down
!u::Send("{PgUp}") ; Alt + K = Page Up


#t::
{
    if WinExist("ahk_exe WindowsTerminal.exe")
        WinActivate("ahk_exe WindowsTerminal.exe")
    else
        Run("wt.exe")
}


; 1. Word-Wise Selection (Ctrl + Shift + Alt + HJKL)
^+!h::Send("^+{Left}")
^+!j::Send("^+{Down}")
^+!k::Send("^+{Up}")
^+!l::Send("^+{Right}")

; 2. Word-Wise Movement (Ctrl + Alt + HJKL)
^!h::Send("^{Left}")
^!j::Send("^{Down}")
^!k::Send("^{Up}")
^!l::Send("^{Right}")

; 3. Selection Movement (Shift + Alt + HJKL)
+!h::Send("+{Left}")
+!j::Send("+{Down}")
+!k::Send("+{Up}")
+!l::Send("+{Right}")

; 4. Standard Vim-style Movement (Alt + HJKL)
!h::Send("{Left}")
!j::Send("{Down}")
!k::Send("{Up}")
!l::Send("{Right}")

; Configurable number of lines to scroll
n := 5 

; --- Home & End Mappings ---
!0::Send("{Home}")
!+$4::Send("{End}")

; --- Dynamic N-Line Scrolling ---
!+d::
{
    Loop n
        Send("{WheelDown}")
}

!+u::
{
    Loop n
        Send("{WheelUp}")
}
