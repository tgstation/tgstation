# STATFILE FORMAT DOCUMENTATION
Because let's be honest, reading the statfiles themselves tells you nothing, and reading the code isn't the most convenient thing to see exactly what was intended.
## Iteration 1.0
This is what statfiles look like in the first iteration of this format. There should be a new documentation file for every iteration, even if it's just "only X has changed since the last version".

### STATLOG_START
Always shows up in every log file. If it isn't there, __PANIC__

#### Format:
`STATLOG_START|statistics format revision number|map's long name|round start time|round end time`

#### Example:
`STATLOG_START|1.0|Box Station|5033469952|5033470976`

### WRITE_COMPLETE
A single line at the end of every stat file. This is written in case the server crashes, closes, or writing is interrupted, so that we know a stat file is incomplete and should not be parsed because it's fucked.

Format and example:
`WRITE_COMPLETE`

### MASTERMODE
The master game mode that's running. Could be `secret`, could be `mixed`, could be an actual gamemode like `extended`. Taken from global variable `master_mode`

#### Format:
`MASTERMODE|master_mode`

#### Example:
`MASTERMODE|sandbox`

### GAMEMODE
This is the value taken from `ticker.mode`, parsed in case it's `mixed` so that it actually outputs all gamemodes.

#### Format:
`GAMEMODE|ticker.mode` or `GAMEMODE|mixedmode1|mixedmode2|etc`

#### Examples:

`GAMEMODE|extended`

`GAMEMODE|traitor|wizard|changeling`


### TECH_TOTAL
This value is equal to all the levels of standard techs (non-illegal) added together, gathered from the R&D server. For more information, see `get_research_score()` in `statcollection.dm`

#### Format:
`TECH_TOTAL|techlevelssum`

#### Example:
`TECH_TOTAL|9`


### BLOOD_SPILLED
The sum of the volume of all blood lost via `/mob/living/carbon/human/proc/drip()`. As such this only cares about human blood, although there's not a whole lot of other things that bleed as far as I'm aware. Value is in centiliters.

#### Example and format:
`BLOOD_SPILLED|0`

### CRATES_ORDERED
Sum of all crates ordered by Supply.

#### Example and format:
`CRATES_ORDERED|0`

### ARTIFACTS_DISCOVERED
Sum of all artifacts uncovered.

#### Example and format:
`ARTIFACTS_DISCOVERED|0`


### CREWSCORE
This is the value calculated and shown at the in-game end of round scoreboard.

#### Example and format:
`CREWSCORE|2488`

### ESCAPEES
Sum of people who got off on the shuttle alive.

#### Example and format:
`ESCAPEES|0`

### NUKED
Whether or not the station was nuked. `0` is false, `1` is true.

#### Example and format:
`NUKED|1`

### MOB_DEATH
A big old log of a mob's death.

#### Format:
`MOB_DEATH|typepath|special role|timeofdeath|lAssailant|death location x|death locaton y|death location z|mind key|mind name`

#### Example:
`MOB_DEATH|/mob/living/carbon/monkey|null|782.3|Lorenzo Gibson|102|160|1|null|monkey (735)`

#### Notes:
 - At time of writing, LAssailant isn't as good as it could be, and is an unreliable indicator of who killed who.
 - timeofdeath is time since server start (not round start, or world time.)


### EXPLOSION
A log file of an explosion, including all its parameters.

#### Format:
`EXPLOSION|epicenter_x|epicenter_y|epicenter_z|devastation_range|heavy_impact_range|light_impact_range|max_range`

### CULTSTATS
A whole conglomeration of cultist-related stats.

#### Format:
`CULTSTATS|runes written|runes fumbled|runes nulled|num people converted to cult|tomes created|narsie summoned|narsie corpses fed|surviving cultists|deconverted cult members`

#### Example:
`CULTSTATS|120|5002|3|15|3|1|30|10|2`


### XENOSTATS
A conglomeration of stats related to xenos.

#### Format:
`XENOSTATS|eggs laid|successful facehugger impregnations|number of facehuggers rebuffed by proper face protection`

#### Example:
`XENOSTATS|20|5|10`
