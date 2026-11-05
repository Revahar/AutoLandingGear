
; ==========================================
; ELITE DANGEROUS - Auto Landing Gear
; Made by Revahar
; ==========================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; INSTALLATION
; ==========================================

; Installer la dernière version d'AutoHotkey :
; https://www.autohotkey.com/download/
;
; Clic droit sur ce script -> Ouvrir avec AutoHotkey


; ==========================================
; PARAMETRES MODIFIABLES
; ==========================================

; Touche clavier affectée aux trains
GearKey := "g"

; Station orbitale :
; délai avant sortie des trains après passage de la BAL
DeployDelay := 1500

; Autres stations :
; délai de sortie des trains après apparition du Mass Lock
MassLockDelay := 2500

; Fréquence de surveillance du Mass Lock
MassLockPollDelay := 500

; Automatiser le déploiement des trains
AutoDeploy := true

; Automatiser le repli des trains
AutoRetract := true


; ==========================================
; CONFIGURATION DU JOURNAL
; ==========================================

JournalFolder := EnvGet("USERPROFILE")
    . "\Saved Games\Frontier Developments\Elite Dangerous"

StatusFile := JournalFolder "\Status.json"

; Type de station actuellement connu
CurrentStationIsOrbital := false

; Etat réel des trains au lancement
GearDown := ReadGearState()

; Evite de relire un Status.json ancien
LastCommandAt := 0

; Journal actuellement surveillé
CurrentJournal := FindLatestJournal()

if (CurrentJournal != "")
    LastPosition := FileGetSize(CurrentJournal)
else
    LastPosition := 0

; Surveillance du journal
SetTimer(Poll, 500)


; ==========================================
; LECTURE DE L'ETAT DES TRAINS
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
; LECTURE DE L'ETAT DU MASS LOCK
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
; RECHERCHE DU DERNIER JOURNAL
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
; COMMANDE DES TRAINS
; ==========================================

SetGear(Down) {
    global GearDown, GearKey, LastCommandAt
    global AutoDeploy, AutoRetract

    ; Vérifie si l'action automatique est autorisée
    if (Down && !AutoDeploy)
        return

    if (!Down && !AutoRetract)
        return

    ; Ne rien faire si les trains sont déjà
    ; dans le bon état
    if (GearDown != "" && GearDown = Down)
        return

    ; Le jeu doit être actif
    if !WinActive("ahk_exe EliteDangerous64.exe")
        return

    SendInput(GearKey)

    GearDown := Down
    LastCommandAt := A_TickCount
}


; ==========================================
; SORTIE DES TRAINS - STARPORT
; Stations orbitales
; ==========================================

DeployGearDelayed() {
    SetGear(true)
}


; ==========================================
; SURVEILLANCE CONTINUE DU MASS LOCK
; Stations non orbitales
; ==========================================

MassLockWatch() {
    global MassLockDelay

    MassLock := ReadMassLockState()

    ; Statut indisponible :
    ; on continue à surveiller
    if (MassLock = "")
        return

    ; Mass Lock absent :
    ; on attend
    if !MassLock
        return

    ; Mass Lock détecté :
    ; arrêt de la surveillance continue
    SetTimer(MassLockWatch, 0)

    ; Démarrage du délai de 2,5 secondes
    SetTimer(DeployGearMassLockDelayed, 0)
    SetTimer(DeployGearMassLockDelayed, -MassLockDelay)
}


; ==========================================
; SORTIE DES TRAINS APRES MASS LOCK
; ==========================================

DeployGearMassLockDelayed() {
    global GearDown

    ; Relit l'état réel des trains
    ActualGear := ReadGearState()

    ; Si le statut est indisponible :
    ; on ne fait rien
    if (ActualGear = "")
        return

    ; Synchronise l'état réel
    GearDown := ActualGear

    ; Sort les trains uniquement s'ils sont rentrés
    if !ActualGear
        SetGear(true)
}


; ==========================================
; TRAITEMENT DES EVENEMENTS DU JOURNAL
; ==========================================

ProcessJournalLine(Line) {
    global DeployDelay
    global MassLockPollDelay
    global CurrentStationIsOrbital

    if RegExMatch(Line, '"event"\s*:\s*"([^"]+)"', &Match) {
        EventName := Match[1]

        switch EventName {

            ; ----------------------------------
            ; DECOLLAGE
            ; ----------------------------------

            case "Undocked":

                ; Annule toutes les sorties en attente
                SetTimer(DeployGearDelayed, 0)
                SetTimer(MassLockWatch, 0)
                SetTimer(DeployGearMassLockDelayed, 0)

                ; Réinitialise le type de station
                CurrentStationIsOrbital := false

                ; Rentrée immédiate des trains
                SetGear(false)


            ; ----------------------------------
            ; ANNULATION D'APPONTAGE
            ; ----------------------------------

            case "DockingCancelled":

                ; Annule toutes les sorties en attente
                SetTimer(DeployGearDelayed, 0)
                SetTimer(MassLockWatch, 0)
                SetTimer(DeployGearMassLockDelayed, 0)

                ; Réinitialise le type de station
                CurrentStationIsOrbital := false

                ; Rentrée immédiate des trains
                SetGear(false)


            ; ----------------------------------
            ; AUTORISATION D'APPONTAGE
            ; ----------------------------------

            case "DockingGranted":

                ; Lecture du type de station
                if RegExMatch(
                    Line,
                    '"StationType"\s*:\s*"([^"]+)"',
                    &StationMatch
                ) {

                    StationType := StationMatch[1]

                    ; Stations orbitales
                    IsOrbital := (
                        StationType = "Coriolis"
                        || StationType = "Orbis"
                        || StationType = "Ocellus"
                        || StationType = "AsteroidBase"
                    )

                    ; Mémorise le type de station
                    CurrentStationIsOrbital := IsOrbital

                    ; Stations non orbitales :
                    ; surveillance continue du Mass Lock
                    if !IsOrbital {

                        ; Annule les timers éventuels
                        SetTimer(DeployGearDelayed, 0)
                        SetTimer(MassLockWatch, 0)
                        SetTimer(DeployGearMassLockDelayed, 0)

                        ; Démarre la surveillance du Mass Lock
                        SetTimer(
                            MassLockWatch,
                            MassLockPollDelay
                        )
                    }
                }
        }
    }


    ; ======================================
    ; DETECTION MUSIQUE STARPORT
    ; Stations orbitales uniquement
    ; ======================================

    if (
        CurrentStationIsOrbital
        && RegExMatch(
            Line,
            '"MusicTrack"\s*:\s*"Starport"'
        )
    ) {

        ; Annule les timers Mass Lock éventuels
        SetTimer(MassLockWatch, 0)
        SetTimer(DeployGearMassLockDelayed, 0)

        ; Conserve le délai Starport de 1,5 seconde
        SetTimer(DeployGearDelayed, 0)
        SetTimer(DeployGearDelayed, -DeployDelay)
    }
}


; ==========================================
; SURVEILLANCE DU JOURNAL
; ==========================================

Poll() {
    global CurrentJournal, LastPosition
    global GearDown, LastCommandAt

    ; Resynchronisation avec l'état réel du jeu
    if (A_TickCount - LastCommandAt > 2000) {

        ActualState := ReadGearState()

        if (ActualState != "")
            GearDown := ActualState
    }

    ; Recherche du journal le plus récent
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
