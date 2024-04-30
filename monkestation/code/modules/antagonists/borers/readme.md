https://github.com/Monkestation/Monkestation2.0/pull/976

## Cortical Borers

MODULE ID: CORTICAL_BORERS

### Description:

This file is responsible for all cortical worm related files
Cortical worms are antagonists whose sole purpose is to reproduce infintelly

### TG Proc/File Changes:

code/__DEFINES/research/anomalies.dm -- Needed to blacklist the borer organs from the bioscrambler
code/__DEFINES/role_preferences.dm -- Needed a define here for cortical borers
code/__DEFINES/~monkestation/actionspeed_modification.dm -- Added the actionspeed modifier ID for the borers here... maybe should move it
code/__DEFINES/~monkestation/antagonists.dm -- Bunch of bitflags, iscorticalborer() check and evolution defines
code/__DEFINES/~monkestation/role_preferences.dm -- Role preference for borers
code/_globalvars/lists/poll_ignore.dm -- Somethin to ignore any future votes to become a borer
code/datums/mutations/_mutations.dm -- Borers automatically will prevent you from getting anymore genetic mutations
code/modules/admin/sql_ban_system.dm -- Ban system was simply needed for borers
code/modules/antagonists/changeling/powers/panacea.dm -- If you are a changeling, panacea will take the pest off of you

### Included files that are not contained in this module:
code/__DEFINES/~monkestation/actionspeed_modification.dm -- Added the actionspeed modifier ID for the borers here... maybe should move it
code/__DEFINES/~monkestation/antagonists.dm -- Bunch of bitflags, iscorticalborer() check and evolution defines
code/__DEFINES/~monkestation/role_preferences.dm -- Role preference for borers

monkestation/code/modules/uplink/uplink_items/misc.dm -- Uplink entry for spawning neutered borers in
monkestation/code/modules/cargo/crates/security.dm -- Contains the cargo crate for getting borer cages out of

tgui/packages/tgui/interfaces/AntagInfoBorer.tsx -- TGUI window explaining what the borers objectives are, and how to use abilities
tgui/packages/tgui/interfaces/BorerChem.js -- Allows the borers to inject chemicals, very sensitive
tgui/packages/tgui/interfaces/BorerEvolution.tsx -- Allows you to evolve abilities

### Credits:

Jake Park - Original borer Code
/vg/station - Partial Icons
Zonespace - Lots of TGUI work, and gave borers the evolution tree
Gboster - Porting the code to monkestation
