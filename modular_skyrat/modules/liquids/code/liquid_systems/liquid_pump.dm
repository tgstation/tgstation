//Right now it's a structure that works off of magic, as it'd require an internal power source for what its supposed to do
/obj/structure/liquid_pump
	name = "portable liquid pump"
	desc = "An industrial grade pump, capable of either siphoning or spewing liquids. Needs to be anchored first to work. Has a limited capacity internal storage."
	icon = 'modular_skyrat/modules/liquids/icons/obj/structures/liquid_pump.dmi'
	icon_state = "liquid_pump"
	density = TRUE
	max_integrity = 500
	anchored = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// How many reagents at maximum can it hold
	var/max_volume = 10000
	/// Whether spewing reagents out, instead of siphoning them
	var/spewing_mode = FALSE
	/// Whether its turned on and processing
	var/turned_on = FALSE
	/// How fast does the pump work, in percentages relative to the volume we're working with
	var/pump_speed_percentage = 0.4
	/// How fast does the pump work, in flat values. Flat values on top of percentages to help processing
	var/pump_speed_flat = 20

/obj/structure/liquid_pump/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	default_unfasten_wrench(user, I, 40)
	if(!anchored && turned_on)
		toggle_working()
	return TRUE

/obj/structure/liquid_pump/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] needs to be anchored first!</span>")
		return
	to_chat(user, "<span class='notice'>You turn [src] [turned_on ? "off" : "on"].</span>")
	toggle_working()

/obj/structure/liquid_pump/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	to_chat(user, "<span class='notice'>You flick [src]'s spewing mode [spewing_mode ? "off" : "on"].</span>")
	spewing_mode = !spewing_mode
	update_icon()

/obj/structure/liquid_pump/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's anchor bolts are [anchored ? "down and secured" : "up"].</span>"
	. += "<span class='notice'>It's currently [turned_on ? "ON" : "OFF"].</span>"
	. += "<span class='notice'>It's mode currently is set to [spewing_mode ? "SPEWING" : "SIPHONING"].</span> (Alt-click to switch)"
	. += "<span class='notice'>The pressure gauge shows [reagents.total_volume]/[reagents.maximum_volume].</span>"

/obj/structure/liquid_pump/process()
	if(!isturf(loc))
		return
	var/turf/T = loc
	if(spewing_mode)
		if(!reagents.total_volume)
			return
		var/datum/reagents/tempr = new(10000)
		reagents.trans_to(tempr, (reagents.total_volume * pump_speed_percentage) + pump_speed_flat, no_react = TRUE)
		T.add_liquid_from_reagents(tempr)
		qdel(tempr)
	else
		if(!T.liquids)
			return
		var/free_space = reagents.maximum_volume - reagents.total_volume
		if(!free_space)
			return
		var/target_siphon_amt = (T.liquids.total_reagents * pump_speed_percentage) + pump_speed_flat
		if(target_siphon_amt > free_space)
			target_siphon_amt = free_space
		var/datum/reagents/tempr = T.liquids.take_reagents_flat(target_siphon_amt)
		tempr.trans_to(reagents, tempr.total_volume)
		qdel(tempr)
	return

/obj/structure/liquid_pump/update_icon()
	. = ..()
	if(turned_on)
		if(spewing_mode)
			icon_state = "[initial(icon_state)]_spewing"
		else
			icon_state = "[initial(icon_state)]_siphoning"
	else
		icon_state = "[initial(icon_state)]"

/obj/structure/liquid_pump/proc/toggle_working()
	if(turned_on)
		STOP_PROCESSING(SSobj, src)
	else
		START_PROCESSING(SSobj, src)
	turned_on = !turned_on
	update_icon()

/obj/structure/liquid_pump/Initialize()
	. = ..()
	create_reagents(max_volume)

/obj/structure/liquid_pump/Destroy()
	if(turned_on)
		STOP_PROCESSING(SSobj, src)
	qdel(reagents)
	return ..()
