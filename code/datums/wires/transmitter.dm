/datum/wires/transmitter
	holder_type = /obj/machinery/media/transmitter/broadcast
	wire_count = 5
	var/counter = null

/datum/wires/transmitter/New()
	wire_names=list(
		"[TRANS_POWER]" 	= "Power",
		"[TRANS_RAD_ONE]" 	= "Rad 1",
		"[TRANS_RAD_TWO]" 	= "Rad 2",
		"[TRANS_LINK]" 		= "Link",
		"[TRANS_SETTINGS]" 	= "Settings"
	)
	..()

var/const/TRANS_POWER = 1 //Power. Cut for shock and off. Pulse toggles.
var/const/TRANS_RAD_ONE = 2 //Reduces rad output by 50%. Requires at least one to function. Pulse does nothing.
var/const/TRANS_RAD_TWO = 4 //Reduces rad output by 50%. Requires at least one to function. Pulse does nothing.
var/const/TRANS_LINK = 8 //Cut shocks. Pulse clears links.
var/const/TRANS_SETTINGS = 16 //Pulse shows percentage given by environment temperature over safe operating temperature.

/datum/wires/transmitter/CanUse(var/mob/living/L)
	var/obj/machinery/media/transmitter/broadcast/T = holder
	if(T.panel_open)
		return 1
	return 0

/datum/wires/transmitter/GetInteractWindow()
	var/obj/machinery/media/transmitter/broadcast/T = holder
	. += ..()
	. += {"<BR>The backlight is [IsIndexCut(TRANS_POWER) ? "dim" : "illuminated"].<BR>
	The radiation warning light is [T.count_rad_wires() > 1 ? "brightly" : ""] [T.count_rad_wires() ? "shining" : "off"].<BR>
	It has a cryptic display [counter ? "reading [counter]" : "that is blank"].<BR>"}

/datum/wires/transmitter/UpdatePulsed(var/index)
	var/obj/machinery/media/transmitter/broadcast/T = holder
	switch(index)
		if(TRANS_POWER)
			T.on = !T.on
			T.update_on()
		if(TRANS_LINK)
			T.unhook_media_sources()
		if(TRANS_SETTINGS)
			var/datum/gas_mixture/env = T.loc.return_air()
			counter = 100*(env.temperature / (T20C + 20))

/datum/wires/transmitter/UpdateCut(var/index, var/mended)
	var/obj/machinery/media/transmitter/broadcast/T = holder
	switch(index)
		if(TRANS_POWER)
			T.power_change()
			T.shock(usr, 50)
		if(TRANS_LINK)
			T.shock(usr, 50)
