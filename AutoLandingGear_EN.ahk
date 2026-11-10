
; ==========================================
; ELITE DANGEROUS - Auto Landing Gear
; Made by Revahar
; ==========================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; INSTALLATION
; ==========================================

; Install the latest version of AutoHotkey:
; https://www.autohotkey.com/download/
;
; Right-click this script -> Open with AutoHotkey


; ==========================================
; CONFIGURABLE SETTINGS
; ==========================================

; Key assigned to the landing gear
GearKey := "g"

; Orbital stations:
; delay before deploying the landing gear after passing the mail slot
DeployDelay := 1500

; Other stations:
; delay before deploying the landing gear after Mass Lock appears
MassLockDelay := 2500

; Mass Lock polling interval
MassLockPollDelay := 500

; Automatically deploy the landing gear
AutoDeploy := true

; Automatically retract the landing gear
AutoRetract := true


; ==========================================
; JOURNAL CONFIGURATION
; ==========================================

JournalFolder := EnvGet("USERPROFILE")
    . "\Saved Games\Frontier Developments\Elite Dangerous"

StatusFile := JournalFolder "\Status.json"

; Currently detected station type
CurrentStationIsOrbital := false

; Actual landing gear state at startup
GearDown := ReadGearState()

; Prevents an outdated Status.json from being read again
LastCommandAt := 0

; Journal file currently being monitored
CurrentJournal := FindLatestJournal()

if (CurrentJournal != "")
    LastPosition := FileGetSize(CurrentJournal)
else
    LastPosition := 0

; Monitor the journal
SetTimer(Poll, 500)


; ==========================================
; READ LANDING GEAR STATE
; ==========================================

ReadGearState() {
    global StatusFile

    if !FileExist(StatusFile)
        return ""

    try {
        Data := FileRead(StatusFile, "UTF-8")

        if RegExMatch(Data, '"Flags"\s*:\s*(\d+)', &Match) {
            Flags := Integer(Match[1])

            ; Bit 2 = Landing Gear Down
            return (Flags & 4) != 0
        }
    }

    return ""
}


; ==========================================
; READ MASS LOCK STATE
; ==========================================

ReadMassLockState() {
    global StatusFile

    if !FileExist(StatusFile)
        return ""

    try {
        Data := FileRead(StatusFile, "UTF-8")

        if RegExMatch(Data, '"Flags"\s*:\s*(\d+)', &Match) {
            Flags := Integer(Match[1])

            ; Bit 16 = FSD MassLocked
            return (Flags & 0x10000) != 0
        }
    }

    return ""
}


; ==========================================
; FIND THE LATEST JOURNAL FILE
; ==========================================

FindLatestJournal() {
    global JournalFolder

    LatestFile := ""
    LatestTime := ""

    if !DirExist(JournalFolder)
        return ""

    Loop Files, JournalFolder "\Journal.*.log", "F" {
        if (LatestTime = ""
            || A_LoopFileTimeModified > LatestTime) {

            LatestTime := A_LoopFileTimeModified
            LatestFile := A_LoopFileFullPath
        }
    }

    return LatestFile
}


; ==========================================
; LANDING GEAR CONTROL
; ==========================================

SetGear(Down) {
    global GearDown, GearKey, LastCommandAt
    global AutoDeploy, AutoRetract

    ; Check whether the automatic action is enabled
    if (Down && !AutoDeploy)
        return

    if (!Down && !AutoRetract)
        return

    ; Do nothing if the landing gear is already
    ; in the correct state
    if (GearDown != "" && GearDown = Down)
        return

    ; The game must be active
    if !WinActive("ahk_exe EliteDangerous64.exe")
        return

    SendInput(GearKey)

    GearDown := Down
    LastCommandAt := A_TickCount
}


; ==========================================
; LANDING GEAR DEPLOYMENT - STARPORT
; Orbital stations
; ==========================================

DeployGearDelayed() {
    SetGear(true)
}


; ==========================================
; CONTINUOUS MASS LOCK MONITORING
; Non-orbital stations
; ==========================================

MassLockWatch() {
    global MassLockDelay

    MassLock := ReadMassLockState()

    ; Status unavailable:
    ; keep monitoring
    if (MassLock = "")
        return

    ; Mass Lock not detected:
    ; wait
    if !MassLock
        return

    ; Mass Lock detected:
    ; stop continuous monitoring
    SetTimer(MassLockWatch, 0)

    ; Start the 2.5-second delay
    SetTimer(DeployGearMassLockDelayed, 0)
    SetTimer(DeployGearMassLockDelayed, -MassLockDelay)
}


; ==========================================
; LANDING GEAR DEPLOYMENT AFTER MASS LOCK
; ==========================================

DeployGearMassLockDelayed() {
    global GearDown

    ; Read the actual landing gear state again
    ActualGear := ReadGearState()

    ; If the status is unavailable:
    ; do nothing
    if (ActualGear = "")
        return

    ; Synchronize the actual state
    GearDown := ActualGear

    ; Deploy the landing gear only if it is retracted
    if !ActualGear
        SetGear(true)
}


; ==========================================
; PROCESS JOURNAL EVENTS
; ==========================================

ProcessJournalLine(Line) {
    global DeployDelay
    global MassLockPollDelay
    global CurrentStationIsOrbital

    if RegExMatch(Line, '"event"\s*:\s*"([^"]+)"', &Match) {
        EventName := Match[1]

        switch EventName {

            ; ----------------------------------
            ; TAKEOFF
            ; ----------------------------------

            case "Undocked":

                ; Cancel all pending deployments
                SetTimer(DeployGearDelayed, 0)
                SetTimer(MassLockWatch, 0)
                SetTimer(DeployGearMassLockDelayed, 0)

                ; Reset the station type
                CurrentStationIsOrbital := false

                ; Retract the landing gear immediately
                SetGear(false)
				
			; ----------------------------------
            ; TAKEOFF D'UNE PLANETE
            ; ----------------------------------

            case "Liftoff":

                ; Check that the takeoff is player-controlled
                if RegExMatch(
                    Line,
                    '"PlayerControlled"\s*:\s*true'
                ) {

                    ; Annule les sorties en attente
                    SetTimer(DeployGearDelayed, 0)
                    SetTimer(MassLockWatch, 0)
                    SetTimer(DeployGearMassLockDelayed, 0)

                    ; Retract the landing gear immediately
                    SetGear(false)
                }


            ; ----------------------------------
            ; DOCKING CANCELLED
            ; ----------------------------------

            case "DockingCancelled":

                ; Cancel all pending deployments
                SetTimer(DeployGearDelayed, 0)
                SetTimer(MassLockWatch, 0)
                SetTimer(DeployGearMassLockDelayed, 0)

                ; Reset the station type
                CurrentStationIsOrbital := false

                ; Retract the landing gear immediately
                SetGear(false)


            ; ----------------------------------
            ; DOCKING GRANTED
            ; ----------------------------------

            case "DockingGranted":

                ; Read the station type
                if RegExMatch(
                    Line,
                    '"StationType"\s*:\s*"([^"]+)"',
                    &StationMatch
                ) {

                    StationType := StationMatch[1]

                    ; Orbital stations
                    IsOrbital := (
                        StationType = "Coriolis"
                        || StationType = "Orbis"
                        || StationType = "Ocellus"
                        || StationType = "AsteroidBase"
                    )

                    ; Store the station type
                    CurrentStationIsOrbital := IsOrbital

                    ; Non-orbital stations :
                    ; continuous Mass Lock monitoring
                    if !IsOrbital {

                        ; Cancel any existing timers
                        SetTimer(DeployGearDelayed, 0)
                        SetTimer(MassLockWatch, 0)
                        SetTimer(DeployGearMassLockDelayed, 0)

                        ; Start monitoring Mass Lock
                        SetTimer(
                            MassLockWatch,
                            MassLockPollDelay
                        )
                    }
                }
        }
    }


    ; ======================================
    ; STARPORT MUSIC DETECTION
    ; Orbital stations uniquement
    ; ======================================

    if (
        CurrentStationIsOrbital
        && RegExMatch(
            Line,
            '"MusicTrack"\s*:\s*"Starport"'
        )
    ) {

        ; Cancel any Mass Lock timers
        SetTimer(MassLockWatch, 0)
        SetTimer(DeployGearMassLockDelayed, 0)

        ; Keep the 1.5-second Starport delay
        SetTimer(DeployGearDelayed, 0)
        SetTimer(DeployGearDelayed, -DeployDelay)
    }
}


; ==========================================
; JOURNAL MONITORING
; ==========================================

Poll() {
    global CurrentJournal, LastPosition
    global GearDown, LastCommandAt

    ; Resynchronize with the actual in-game state
    if (A_TickCount - LastCommandAt > 2000) {

        ActualState := ReadGearState()

        if (ActualState != "")
            GearDown := ActualState
    }

    ; Find the most recent journal file
    NewJournal := FindLatestJournal()

    if (NewJournal = "")
        return

    if (NewJournal != CurrentJournal) {
        CurrentJournal := NewJournal
        LastPosition := 0
    }

    try {
        FileObj := FileOpen(
            CurrentJournal,
            "r",
            "UTF-8-RAW"
        )

        if !IsObject(FileObj)
            return

        FileObj.Seek(LastPosition)

        NewData := FileObj.Read()

        LastPosition := FileObj.Pos

        FileObj.Close()

        for Line in StrSplit(NewData, "`n", "`r") {
            if (Line != "")
                ProcessJournalLine(Line)
        }
    }
}
