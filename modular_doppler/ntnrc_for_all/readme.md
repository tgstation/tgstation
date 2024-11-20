## Title: NTNRC For All

MODULE ID: NTNRC_FOR_ALL

### Description:

Implements a general NTNRC channel every crewmember is added to by default, and related username pref.

### TG Proc Changes:

- `/datum/computer_file/program/chatclient/ui_act(...)` - Blocked passwords from being set on `strong` channels.
- `/obj/item/modular_computer/ui_act(...)` - Emergency mode exit program swaps between NTNRC and messenger.

### Defines:

- `code\__DEFINES\~doppler_defines\ntnrc.dm`

### Master file additions

N/A

### Included files that are not contained in this module:

N/A

### Credits:

- Ephe
