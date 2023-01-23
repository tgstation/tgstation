/// Subsystem for controlling blinking of the adminhelp button
PROCESSING_SUBSYSTEM_DEF(home_page_blinking)
	name = "Home Page Blinking"
	flags = SS_NO_INIT
	runlevels = ALL
	wait = 2 SECONDS
