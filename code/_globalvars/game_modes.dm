GLOBAL_VAR(common_report) //Contains common part of roundend report
GLOBAL_VAR(survivor_report) //Contains shared survivor report for roundend report (part of personal report)

GLOBAL_DATUM(start_state, /datum/station_state) // Used in round-end report

/// We want reality_smash_tracker to exist only once and be accessible from anywhere.
GLOBAL_DATUM_INIT(reality_smash_track, /datum/reality_smash_tracker, new)

GLOBAL_DATUM(deathmatch_game, /datum/deathmatch_controller) // Deathmatch Minigame controller
