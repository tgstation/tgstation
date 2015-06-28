/datum/wires/jukebox
	holder_type = /obj/machinery/media/jukebox
	wire_count = 8
	var/interference = 0 //Caused by pulsing the transmit wire

var/const/JUKE_POWER_ONE = 1 //Power. Cut for shock and off. Pulse toggles.
var/const/JUKE_POWER_TWO = 2 //Power. Cut for shock and off. Pulse toggles increased lum.
var/const/JUKE_POWER_THREE = 4 //Power. Cut for shock and off. Pulse toggles decreased lum.
var/const/JUKE_SHUFFLE = 8 //Cut to disable shuffle and move to play_once. Pulse immediately shuffles.
var/const/JUKE_CAPITAL = 16 //Cut to disable song picking. Pulse randomizes song pick price 1-10.
var/const/JUKE_TRANSMIT = 32 //Cut shocks and disables multitool. Pulse emits burst of rads.
var/const/JUKE_CONFIG = 64 //Cut emags. Pulse plays IAMERROR.ogg
var/const/JUKE_SETTING = 128 //Cut shocks. Pulse toggles settings menu.

/datum/wires/jukebox/CanUse(var/mob/living/L)
	var/obj/machinery/media/jukebox/J = holder
	if(J.panel_open)
		return 1
	return 0

/datum/wires/jukebox/GetInteractWindow()
	var/obj/machinery/media/jukebox/J = holder
	. += ..()
	. += "<BR>The decorative tube with bubbles is [!J.any_power_cut() ? "glowing" : "dim"].<BR>"
	. += "The green slider bar is [!IsIndexCut(JUKE_TRANSMIT) ? "modulating around full" : "empty"].<BR>"
	. += "The maintenance button is [J.access_unlocked ? "lit" : "off"].<BR>"
	. += "An unlabelled light is [J.emagged ? "dark" : "blinking occasionally"].<BR>"

/datum/wires/jukebox/UpdatePulsed(var/index)
	if(interference)
	var/obj/machinery/media/jukebox/J = holder
	switch(index)
		if(JUKE_POWER_ONE||JUKE_POWER_TWO||JUKE_POWER_THREE)
			J.playing=!J.playing
			J.update_music()
			J.update_icon()
			if(index==JUKE_POWER_TWO)
				if(J.luminosity<8)
					J.luminosity=8
				else
					J.luminosity=4
			if(index==JUKE_POWER_THREE)
				if(J.luminosity>2)
					J.luminosity=2
				else
					J.luminosity=4
		if(JUKE_SHUFFLE)
			J.current_song=rand(1,J.playlist.len)
		if(JUKE_CAPITAL)
			J.change_cost = rand(0,20)
		if(JUKE_TRANSMIT)
			J.rad_pulse()
			interference = 1
			spawn(50)
				interference = 0
		if(JUKE_CONFIG)
			playsound(J.loc, 'sound/effects/IAMERROR.ogg', 100, 1)
			usr << browse(null, "window=wires")
			usr.unset_machine(holder)
		if(JUKE_SETTING)
			J.access_unlocked = !J.access_unlocked

/datum/wires/jukebox/UpdateCut(var/index, var/mended)
	var/obj/machinery/media/jukebox/J = holder
	switch(index)
		if(JUKE_POWER_ONE||JUKE_POWER_TWO||JUKE_POWER_THREE)
			J.power_change()
			J.shock(usr, 50)
		if(JUKE_SHUFFLE)
			if(J.allowed_modes.Find("Shuffle"))
				J.allowed_modes = list(2 = "Single", 3 = "Once")
				J.loop_mode = 3 //JUKEMODE_PLAY_ONCE
			else
				J.allowed_modes = loopModeNames.Copy()
		if(JUKE_CAPITAL)
			//handled inside Jukebox
		if(JUKE_TRANSMIT)
			J.shock(usr, 50)
			if(J.machine_flags & MULTITOOL_MENU)
				J.machine_flags &= !MULTITOOL_MENU
			else
				J.machine_flags |= MULTITOOL_MENU
		if(JUKE_CONFIG)
			J.short()
		if(JUKE_SETTING)
			J.shock(usr, 50)
