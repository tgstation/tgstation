/**
 * Blood Drying SS
 * Used as a low priority background system to handling the drying of blood on the ground
 * (basically just handles reducing their bloodiness value over time)
 */
PROCESSING_SUBSYSTEM_DEF(blood_drying)
	name = "Blood Drying"
	flags = SS_NO_INIT | SS_BACKGROUND
	priority = FIRE_PRIORITY_BLOOD_DRYING
	runlevels = RUNLEVEL_GAME
	wait = 4 SECONDS
