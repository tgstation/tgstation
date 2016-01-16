#define JUKEMODE_PLAY_ONCE 3

/datum/wires/jukebox
	holder_type = /obj/machinery/media/jukebox
	wire_count = 8
	var/interference = 0 //Caused by pulsing the transmit wire
	var/last = 0 //Value of the last JukeWire we pulsed
	var/list/freq_config_data = list(0,0,0,0) //Set up in new

/datum/wires/jukebox/New(var/atom/holder)
	..()
	last = rand(1,14)
	freq_config_data[JUKE_POWER_ONE] = rand(1,14)
	freq_config_data[JUKE_POWER_TWO] = rand(1,14)
	freq_config_data[JUKE_POWER_THREE] = rand(1,14)

var/const/JUKE_POWER_ONE = 1 //Power. Cut for shock and off. Pulse toggles.
var/const/JUKE_POWER_TWO = 2 //Power. Cut for shock and off. Pulse toggles.
var/const/JUKE_POWER_THREE = 4 //Power. Cut for shock and off. Pulse toggles.
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
	. += {"<BR>The decorative tube with bubbles is [!J.any_power_cut() ? "glowing" : "dim"].<BR>
	The green slider bar is [!IsIndexCut(JUKE_TRANSMIT) ? "modulating around full" : "empty"].<BR>
	The maintenance button is [J.access_unlocked ? "lit" : "off"].<BR>
	An unlabelled light is [J.emagged ? "dark" : "blinking occasionally"].<BR>"}

/datum/wires/jukebox/UpdatePulsed(var/index)
	if(interference) return
	var/obj/machinery/media/jukebox/J = holder
	switch(index)
		if(JUKE_POWER_ONE,JUKE_POWER_TWO,JUKE_POWER_THREE)
			J.playing=!J.playing
			J.update_music()
			J.update_icon()
			var/calc = freq_config_data[index] - last
			J.visible_message("[J] hums and outputs: [calc]")
			last = freq_config_data[index]
		if(JUKE_SHUFFLE)
			J.current_song=rand(1,J.playlist.len)
		if(JUKE_CAPITAL)
			J.change_cost = rand(0,20)
		if(JUKE_TRANSMIT)
			J.rad_pulse()
			interference = 1
			sleep(50)
			interference = 0
		if(JUKE_CONFIG)
			playsound(J.loc, 'sound/effects/IAMERROR.ogg', 100, 1)
		if(JUKE_SETTING)
			J.access_unlocked = !J.access_unlocked

/datum/wires/jukebox/UpdateCut(var/index, var/mended)
	var/obj/machinery/media/jukebox/J = holder
	switch(index)
		if(JUKE_POWER_ONE,JUKE_POWER_TWO,JUKE_POWER_THREE)
			J.power_change()
			J.shock(usr, 50)
			if(freq_config_data[index]==0)
				freq_config_data[index] = 14
			else
				freq_config_data[index] -= 1
		if(JUKE_SHUFFLE)
			if(IsIndexCut(JUKE_SHUFFLE))
				J.allowed_modes = list(2 = "Single", 3 = "Once")
				J.loop_mode = JUKEMODE_PLAY_ONCE //Dammit Comic you're relentless there's no reason to define something for one use
			else
				J.allowed_modes = loopModeNames.Copy()
		if(JUKE_TRANSMIT)
			J.shock(usr, 50)
			if(IsIndexCut(JUKE_TRANSMIT))
				J.machine_flags &= !MULTITOOL_MENU
			else
				J.machine_flags |= MULTITOOL_MENU
		if(JUKE_CONFIG)
			for(var/e in freq_config_data)
				if(e != 0)
					return
			J.short()
		if(JUKE_SETTING)
			J.shock(usr, 50)
