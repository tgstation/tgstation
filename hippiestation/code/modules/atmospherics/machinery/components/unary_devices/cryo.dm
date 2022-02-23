#define CRYO_MULTIPLY_FACTOR 25	//required for the process proc
#define CRYO_TX_QTY 0.5
#define CRYO_MIN_GAS_MOLES 5

/atom/movable/visual/cryo_occupant/proc/on_set_occupant(datum/source, mob/living/new_occupant)	//removed immobilized tag so relaymove will work
	SIGNAL_HANDLER

	if(occupant)
		vis_contents -= occupant
		REMOVE_TRAIT(occupant, TRAIT_IMMOBILIZED, CRYO_TRAIT)
		REMOVE_TRAIT(occupant, TRAIT_FORCED_STANDING, CRYO_TRAIT)


	occupant = new_occupant
	if(!occupant)
		return

	occupant.setDir(SOUTH)
	vis_contents += occupant
	pixel_y = 22
	// Keep them standing! They'll go sideways in the tube when they fall asleep otherwise.
	ADD_TRAIT(occupant, TRAIT_FORCED_STANDING, CRYO_TRAIT)

/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/living/user, direction)	//allow exiting on relaymove, if you're a player. if you're not... trapped forever!
	if(message_cooldown <= world.time && user.client)	//we'll use this anyway to make relaymove doesn't get spammed
		message_cooldown = world.time + 50
		if(is_operational)	//if power is on to cryo, it's quicker to get out
			to_chat(user, "<span class='notice'>You open the doors of [src].</span>")
			open_machine()
		else	//more difficult to get out if there's no power
			to_chat(user, "<span class='notice'>The power is out to [src], so you fumble for the manual release lever...</span>")
			container_resist_act(user)	//start the act of resisting out

/obj/machinery/atmospherics/components/unary/cryo_cell/open_machine(drop = FALSE)	//add some extra cryoxadone so the cold doesn't prevent you from exiting at full health
	if(!state_open && !panel_open)
		set_on(FALSE)
	for(var/mob/M in contents) //only drop mobs
		var/mob/living/carbon/human/H = M
		if(H && H.bodytemperature)	//if they process body temperature, adjust temperature on exit so it does not damage them. the cryoxadone won't heal them enough even when cold on exiting
			H.adjust_coretemperature(BODYTEMP_COLD_DAMAGE_LIMIT + 10, BODYTEMP_COLD_DAMAGE_LIMIT + 10)	//make sure this is the lowest allowed core temp
		M.forceMove(get_turf(src))
	set_occupant(null)
	flick("pod-open-anim", src)
	..()

/obj/machinery/atmospherics/components/unary/cryo_cell/close_machine(mob/living/carbon/user)	//switch on cryo if there is an occupant
	..()
	if(occupant)
		set_on(TRUE)

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user)	//show the name of who is in cryo
	. = ..()
	if(occupant)
		if(on && occupant.name)	//no null.name or empty name errors here
			. += "You can see [occupant.name] floating in [src]."
		else
			. += "You can barely make out a form floating in [src]."	//too dark to see who is in
	else
		. += "[src] seems empty."

/obj/machinery/atmospherics/components/unary/cryo_cell/process(delta_time)	//removed sleep & unconscious tags, why is this even a thing. allows you to inventory manage while in cryo!
	..()

	if(!on)
		return
	if(!occupant)
		return

	var/mob/living/mob_occupant = occupant
	if(mob_occupant.on_fire)
		mob_occupant.extinguish_mob()
	if(!check_nap_violations())
		return
	if(mob_occupant.stat == DEAD) // We don't bother with dead people.
		return
	if(mob_occupant.get_organic_health() >= mob_occupant.getMaxHealth()) // Don't bother with fully healed people.
		if(iscarbon(mob_occupant))
			var/mob/living/carbon/C = mob_occupant
			if(C.all_wounds)
				if(!treating_wounds) // if we have wounds and haven't already alerted the doctors we're only dealing with the wounds, let them know
					treating_wounds = TRUE
					playsound(src, 'sound/machines/cryo_warning.ogg', volume) // Bug the doctors.
					var/msg = "Patient vitals fully recovered, continuing automated wound treatment."
					radio.talk_into(src, msg, radio_channel)
			else // otherwise if we were only treating wounds and now we don't have any, turn off treating_wounds so we can boot 'em out
				treating_wounds = FALSE

		if(!treating_wounds)
			set_on(FALSE)
			playsound(src, 'sound/machines/cryo_warning.ogg', volume) // Bug the doctors.
			var/msg = "Patient fully restored."
			if(autoeject) // Eject if configured.
				msg += " Auto ejecting patient now."
				open_machine()
			radio.talk_into(src, msg, radio_channel)
			return

	var/datum/gas_mixture/air1 = airs[1]

	if(air1.gases[/datum/gas/oxygen][MOLES] > CRYO_MIN_GAS_MOLES)	//removed sleep factor
		if(beaker)
			beaker.reagents.trans_to(occupant, (CRYO_TX_QTY / (efficiency * CRYO_MULTIPLY_FACTOR)) * delta_time, efficiency * CRYO_MULTIPLY_FACTOR, methods = VAPOR) // Transfer reagents.
			consume_gas = TRUE
	return TRUE

#undef CRYO_MULTIPLY_FACTOR
#undef CRYO_TX_QTY
#undef CRYO_MIN_GAS_MOLES
