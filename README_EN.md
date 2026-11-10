# Elite Dangerous -- Auto Landing Gear

**Author: Revahar**

Automatic deployment and retraction of the landing gear in Elite
Dangerous using AutoHotkey v2.

This script automatically manages the landing gear during approach,
docking, and takeoff.

It provides two independent automation options: - Automatic landing gear
deployment. - Automatic landing gear retraction.

Each user can choose which features they want to enable.

------------------------------------------------------------------------

## Features

### Orbital stations

**Note:** Automatic deployment can be disabled in the settings.

For orbital stations such as Coriolis, Orbis, Ocellus, and Asteroid
Base:

-   Detects the `Starport` music track in the game journal. This track
    appears in the journal after passing through the mail slot.
-   Automatically deploys the landing gear after a configurable delay.

### Other stations and installations

For Fleet Carriers, planetary bases, outposts, and other installations:

1.  The pilot requests docking permission.
2.  The game records the `DockingGranted` event in its journal.
3.  The script monitors for the appearance of Mass Lock.
4.  As soon as Mass Lock appears, a configurable delay starts.
5.  The landing gear is automatically deployed when the delay expires.

### Automatic retraction

**Note:** Automatic retraction can be disabled in the settings.

During the following events: - `Undocked`: the landing gear is
automatically retracted. - `DockingCancelled`: the landing gear is
automatically retracted.

------------------------------------------------------------------------

## Requirements

-   AutoHotkey v2.0 or later.
-   Access to the Elite Dangerous journal and `Status.json` file on your
    PC.

### Download AutoHotkey

https://www.autohotkey.com/download/

**Important:** This script is designed for AutoHotkey v2. It is not
compatible with AutoHotkey v1 without modifications.

------------------------------------------------------------------------

## Installation

1.  Download and install AutoHotkey v2.
2.  Download the `AutoLandingGear.ahk` file.
3.  Place the script in a folder of your choice.
4.  Check the script settings if necessary.
5.  Double-click the script, or right-click it and select **Open with
    AutoHotkey**.
6.  Launch Elite Dangerous.

The script automatically monitors the game journal.

No changes to the game files are required.

------------------------------------------------------------------------

## Configuration

The configurable settings are located at the beginning of the script.

``` autohotkey
; Key assigned to the landing gear
GearKey := "g"

; Starport delay (in milliseconds)
DeployDelay := 1500

; Delay after Mass Lock appears
MassLockDelay := 2500

; Mass Lock polling interval
MassLockPollDelay := 500

; Automatically deploy the landing gear
AutoDeploy := true

; Automatically retract the landing gear
AutoRetract := true
```

### Available settings

  -----------------------------------------------------------------------
  Setting                 Description             Default value
  ----------------------- ----------------------- -----------------------
  `GearKey`               Key assigned to the     `g`
                          landing gear in Elite   
                          Dangerous               

  `DeployDelay`           Delay after detecting   1500 ms
                          Starport                

  `MassLockDelay`         Delay after Mass Lock   2500 ms
                          appears                 

  `MassLockPollDelay`     Mass Lock polling       500 ms
                          interval                

  `AutoDeploy`            Enables or disables     `true`
                          automatic deployment    

  `AutoRetract`           Enables or disables     `true`
                          automatic retraction    
  -----------------------------------------------------------------------

Delays are expressed in milliseconds.

Example: `2500` corresponds to 2.5 seconds.

------------------------------------------------------------------------

## Choosing the automation mode

The two options work independently.

  AutoDeploy   AutoRetract   Behaviour
  ------------ ------------- -----------------------------------------
  `true`       `true`        Automatic deployment and retraction
  `false`      `true`        Manual deployment, automatic retraction
  `true`       `false`       Automatic deployment, manual retraction
  `false`      `false`       Manual deployment and retraction

To disable a feature, change `true` to `false`.

Example: to keep automatic retraction only:

``` autohotkey
AutoDeploy := false
AutoRetract := true
```

------------------------------------------------------------------------

## Technical details

The script uses two sources of in-game data:

### Elite Dangerous journal

The journal is used to detect the following events: - `DockingGranted` -
`DockingCancelled` - `Undocked` - `MusicTrack: Starport`

### Status.json

The `Status.json` file is used to read the actual state of the landing
gear and Mass Lock.

The script uses this information to avoid issuing unnecessary landing
gear commands when the gear is already in the correct state.

The default monitored folder is:

``` text
%USERPROFILE%\Saved Games\Frontier Developments\Elite Dangerous
```

------------------------------------------------------------------------

## Usage tips

-   Make sure the key assigned to the landing gear in the game matches
    `GearKey`.
-   The game must be active when the script sends a keyboard command.
-   If you change the settings, restart the script for the changes to
    take effect.
-   Automatic deployment is optional: you can keep manual control of the
    landing gear.

------------------------------------------------------------------------

## Troubleshooting

### The landing gear does not deploy

Check that: - `AutoDeploy := true`. - The `GearKey` key matches the
in-game configuration. - The game is active and in the foreground when
the trigger occurs. - The journal and `Status.json` files are
accessible.

### The landing gear does not retract automatically

Check that:

``` autohotkey
AutoRetract := true
```

### The script does not start

Check that: - AutoHotkey v2 is installed. - The script is being run with
AutoHotkey v2. - The Saved Games folder path is correct.

------------------------------------------------------------------------

## Testing

Functional tests have been carried out at:

-   Fleet Carriers
-   Planetary bases
-   Outposts
-   Orbital stations

The various deployment and retraction mechanisms have been checked in
these environments.

------------------------------------------------------------------------

## Author

**Revahar**

Contact: - Discord (DM): Revahar - Email: revahar@hotmail.com
