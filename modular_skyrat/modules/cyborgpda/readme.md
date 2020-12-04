https://github.com/Skyrat-SS13/Skyrat-tg/pull/241

## Title: Changeling Horror Form

MODULE ID: CYBORG_PDA

### Description:

Adds PDA functionality to all cyborgs, similar to that which AIs have.

### TG Proc Changes:

\code\_onclick\hud\robot.dm - added 2 HUD objects to New(), the HUD objects themselves are stored within this folder
\code\_onclick\hud\_defines.dm - added 2 defines for said HUD objects
\code\modules\mob\living\silicon\robot\robot.dm - added PDA to initialize() and a required proc for updating PDA info

### Defines:

- N/A

### Master file additions

- N/A

### Included files that are not contained in this module:

- N/A

### Credits:
Ranged66 - Code
