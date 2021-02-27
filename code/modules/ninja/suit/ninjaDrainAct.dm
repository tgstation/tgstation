/**
 * Atom level proc for space ninja's glove interactions.
 *
 * Proc which only occurs when space ninja uses his gloves on an atom.
 * Does nothing by default, but effects will vary.
 * Arguments:
 * * ninja_suit - The offending space ninja's suit.
 * * ninja - The human mob wearing the suit.
 * * ninja_gloves - The offending space ninja's gloves.
 */
/atom/proc/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	return INVALID_DRAIN

//APC//
/obj/machinery/power/apc/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0

	if(cell?.charge)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)

		while(cell.charge> 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)

			if(cell.charge < drain)
				drain = cell.charge

			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE//Reached maximum battery capacity.

			if (do_after(ninja ,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				cell.use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break

		if(!(obj_flags & EMAGGED))
			flick("apc-spark", ninja_gloves)
			playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			obj_flags |= EMAGGED
			locked = FALSE
			update_appearance()

	return drain_total

//SMES//
/obj/machinery/power/smes/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0

	if(charge)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)

		while(charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)

			if(charge < drain)
				drain = charge

			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE

			if (do_after(ninja,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				charge -= drain
				ninja_suit.cell.give(drain)
				drain_total += drain

			else
				break

	return drain_total

//CELL//
/obj/item/stock_parts/cell/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	var/drain_total = 0

	if(charge)
		if(do_after(ninja, 30, target = src))
			drain_total = charge
			if(ninja_suit.cell.charge + charge > ninja_suit.cell.maxcharge)
				ninja_suit.cell.charge = ninja_suit.cell.maxcharge
			else
				ninja_suit.cell.give(charge)
			charge = 0
			corrupt()
			update_appearance()

	return drain_total

//RDCONSOLE//
/obj/machinery/computer/rdconsole/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	. = DRAIN_RD_HACK_FAILED

	to_chat(ninja, "<span class='notice'>Hacking \the [src]...</span>")
	AI_notify_hack()

	if(stored_research)
		to_chat(ninja, "<span class='notice'>Copying files...</span>")
		if(do_after(ninja, ninja_suit.s_delay, target = src) && src)
			stored_research.copy_research_to(ninja_suit.stored_research)
	to_chat(ninja, "<span class='notice'>Data analyzed. Process finished.</span>")

//RD SERVER//
/obj/machinery/rnd/server/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	. = DRAIN_RD_HACK_FAILED

	to_chat(ninja, "<span class='notice'>Hacking \the [src]...</span>")
	AI_notify_hack()

	if(stored_research)
		to_chat(ninja, "<span class='notice'>Copying files...</span>")
		if(do_after(ninja, ninja_suit.s_delay, target = src) && src)
			stored_research.copy_research_to(ninja_suit.stored_research)
	to_chat(ninja, "<span class='notice'>Data analyzed. Process finished.</span>")

//SECURITY CONSOLE//
/obj/machinery/computer/secure_data/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN
	AI_notify_hack()
	if(do_after(ninja, 200))
		for(var/datum/data/record/rec in sortRecord(GLOB.data_core.general, sortBy, order))
			for(var/datum/data/record/security_record in GLOB.data_core.security)
				security_record.fields["criminal"] = "*Arrest*"
		var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
		if(!ninja_antag)
			return
		var/datum/objective/security_scramble/objective = locate() in ninja_antag.objectives
		if(objective)
			objective.completed = TRUE

//COMMUNICATIONS CONSOLE//
/obj/machinery/computer/communications/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN
	if(ninja_gloves.communication_console_hack_success)
		return
	AI_notify_hack()
	if(do_after(ninja, 300))
		var/announcement_pick = rand(0, 1)
		switch(announcement_pick)
			if(0)
				priority_announce("Attention crew, it appears that someone on your station has made unexpected communication with an alien device in nearby space.", "[command_name()] High-Priority Update")
				var/datum/round_event_control/spawn_swarmer/swarmer_event = new/datum/round_event_control/spawn_swarmer
				swarmer_event.runEvent()
			if(1)
				priority_announce("Attention crew, it appears that someone on your station has made unexpected communication with a syndicate ship in nearby space.", "[command_name()] High-Priority Update")
				var/datum/round_event_control/pirates/pirate_event = new/datum/round_event_control/pirates
				pirate_event.runEvent()
		ninja_gloves.communication_console_hack_success = TRUE
		var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
		if(!ninja_antag)
			return
		var/datum/objective/terror_message/objective = locate() in ninja_antag.objectives
		if(objective)
			objective.completed = TRUE

//AIRLOCK//
/obj/machinery/door/airlock/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	if(!operating && density && hasPower() && !(obj_flags & EMAGGED))
		emag_act()
		ninja_gloves.door_hack_counter++
		var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
		if(!ninja_antag)
			return
		var/datum/objective/door_jack/objective = locate() in ninja_antag.objectives
		if(objective && objective.doors_required <= ninja_gloves.door_hack_counter)
			objective.completed = TRUE

//WIRE//
/obj/structure/cable/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check
	var/drain = 0 //Drain amount

	var/drain_total = 0

	var/datum/powernet/wire_powernet = powernet
	while(!maxcapacity && src)
		drain = (round((rand(ninja_gloves.mindrain, ninja_gloves.maxdrain))/2))
		var/drained = 0
		if(wire_powernet && do_after(ninja ,10, target = src))
			drained = min(drain, delayed_surplus())
			add_delayedload(drained)
			if(drained < drain)//if no power on net, drain apcs
				for(var/obj/machinery/power/terminal/affected_terminal in wire_powernet.nodes)
					if(istype(affected_terminal.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/AP = affected_terminal.master
						if(AP.operating && AP.cell && AP.cell.charge > 0)
							AP.cell.charge = max(0, AP.cell.charge - 5)
							drained += 5
		else
			break

		ninja_suit.cell.give(drain)
		if(ninja_suit.cell.charge > ninja_suit.cell.maxcharge)
			drain_total += (drained-(ninja_suit.cell.charge - ninja_suit.cell.maxcharge))
			ninja_suit.cell.charge = ninja_suit.cell.maxcharge
			maxcapacity = TRUE
		else
			drain_total += drained
		ninja_suit.spark_system.start()

	return drain_total

//MECH//
/obj/vehicle/sealed/mecha/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check
	var/drain = 0 //Drain amount
	var/drain_total = 0

	to_chat(occupants, "[icon2html(src, occupants)]<span class='danger'>Warning: Unauthorized access through sub-route 4, block H, detected.</span>")
	if(get_charge())
		while(cell.charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)
			if(cell.charge < drain)
				drain = cell.charge
			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE
			if (do_after(ninja, 10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				cell.use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break

	return drain_total

//BORG//
/mob/living/silicon/robot/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || (ROLE_NINJA in faction))
		return INVALID_DRAIN

	to_chat(src, "<span class='danger'>Warni-***BZZZZZZZZZRT*** UPLOADING SPYDERPATCHER VERSION 9.5.2...</span>")
	if (do_after(ninja, 60, target = src))
		spark_system.start()
		playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		to_chat(src, "<span class='danger'>UPLOAD COMPLETE. NEW CYBORG MODEL DETECTED.  INSTALLING...</span>")
		faction = list(ROLE_NINJA)
		bubble_icon = "syndibot"
		UnlinkSelf()
		ionpulse = TRUE
		laws = new /datum/ai_laws/ninja_override()
		model.transform_to(pick(/obj/item/robot_model/syndicate, /obj/item/robot_model/syndicate_medical, /obj/item/robot_model/saboteur))

		var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
		if(!ninja_antag)
			return
		var/datum/objective/cyborg_hijack/objective = locate() in ninja_antag.objectives
		if(objective)
			objective.completed = TRUE

//CARBON MOBS//
/mob/living/carbon/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	. = DRAIN_MOB_SHOCK_FAILED

	//Default cell = 10,000 charge, 10,000/1000 = 10 uses without charging/upgrading
	if(ninja_suit.cell?.charge && ninja_suit.cell.use(1000))
		. = DRAIN_MOB_SHOCK
		//Got that electric touch
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)
		playsound(src, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		visible_message("<span class='danger'>[ninja] electrocutes [src] with [ninja.p_their()] touch!</span>", "<span class='userdanger'>[ninja] electrocutes you with [ninja.p_their()] touch!</span>")
		Knockdown(3 SECONDS)
