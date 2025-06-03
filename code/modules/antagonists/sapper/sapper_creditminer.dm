#define RADIO_ALERT 80 // Precentage near explosion to begin announcing on radio
#define POWER_FOR_PAYOUT (20 KILO WATTS) // How much do we draw for a payout
#define PAYOUT 100 // How much is the energy worth
#define DRAIN_FORMULA (0.1 * STANDARD_BATTERY_CHARGE) //How much % per tick gets drained from the powernet. standard cell because thats what APCs start with

/obj/item/powersink/creditminer
	name = "converted power sink"
	desc = "A highly modified power sink, functionally the same on one exception, it transforms the power into minted holo credit - still gets extremely hot while working; keep the temperature in check or suffer the explosive consequence."
	w_class = WEIGHT_CLASS_HUGE
	max_heat = 150 * STANDARD_BATTERY_CHARGE // 1.5x the heat of its parent type, can last a long time unless the station is running a God engine
	/// The amount of power the machine has converted to credits.
	var/cash_out = 0
	///The machine's internal radio, used to broadcast alerts.
	var/obj/item/radio/radio
	///The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/syndicate
	///The channel we announce over.
	var/radio_channel = RADIO_CHANNEL_SYNDICATE
	///Amount of time before the next warning over the radio is announced.
	var/next_warning = 0
	///The amount of time we have between warnings
	var/minimum_time_between_warnings = 15 SECONDS

/obj/item/powersink/creditminer/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

/obj/item/powersink/creditminer/examine(mob/user)
	. = ..()
	if(cash_out)
		. += span_blue("[src] has mined [trunc(cash_out)] credits.")
	if(mode) //can only print when in structure mode, not object mode
		. += span_blue("<b>Ctrl-click</b> to print a holochip.")

/obj/item/powersink/creditminer/item_ctrl_click(mob/user)
	. = ..()
	if(!mode) // Unwrenched
		return CLICK_ACTION_BLOCKING
	print()
	return CLICK_ACTION_SUCCESS

/obj/item/powersink/creditminer/attack_hand(mob/user, list/modifiers)
	. = ..()
	switch(mode)
		if(1) //On turning off
			playsound(src, 'sound/machines/credit_miner/creditminer_stop.ogg', 50, FALSE)

		if(2) //On turning on
			playsound(src, 'sound/machines/credit_miner/creditminer_start.ogg', 50, FALSE)

/obj/item/powersink/creditminer/process()
	. = ..()
	if(internal_heat > max_heat * RADIO_ALERT / 100)
		if(next_warning < world.time && prob(15))
			var/area/hazardous_area = get_area(loc)
			var/message = "OVERHEAT IMMINENT at [initial(hazardous_area.name)]!!"
			radio.talk_into(src, message, radio_channel)
			next_warning = world.time + minimum_time_between_warnings

/obj/item/powersink/creditminer/proc/print()
	if(cash_out > 0)
		playsound(src, 'sound/items/poster/poster_being_created.ogg', 100, TRUE)
		balloon_alert_to_viewers("printed [trunc(cash_out)] credits")
		new /obj/item/holochip(drop_location(), trunc(cash_out)) //get the loot
		cash_out = 0

/obj/item/powersink/creditminer/drain_power()
	var/drained = 0 // How much raw energy we've siphoned
	set_light(5)

	drained = attached.newavail()
	attached.add_delayedload(drained)

	var/datum/powernet/powernet = attached.powernet
	for(var/obj/machinery/power/terminal/terminal in powernet.nodes)
		if(istype(terminal.master, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc = terminal.master
			if(apc.operating && apc.cell)
				drained += apc.cell.use(DRAIN_FORMULA, force = TRUE)
	internal_heat += drained
	var/cash_pulse = min(energy_to_power(drained) / POWER_FOR_PAYOUT, PAYOUT)
	if(cash_pulse >= 1)
		cash_out += cash_pulse
		balloon_alert_to_viewers("mined [trunc(cash_pulse)]cr")
		playsound(src, 'sound/machines/credit_miner/creditminer_drain.ogg', 50, FALSE)

/obj/item/powersink/creditminer/release_heat()
	. = ..()
	if(!internal_heat)
		return
	if(mode < 2) //sfx if we release heat, but don't overlap the drain sfx
		playsound(src, 'sound/machines/credit_miner/creditminer_vent.ogg', 50, FALSE)
	new /obj/effect/temp_visual/mook_dust(get_turf(src))

#undef RADIO_ALERT
#undef POWER_FOR_PAYOUT
#undef PAYOUT
#undef DRAIN_FORMULA
