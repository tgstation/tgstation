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

	if(cell && cell.charge)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)

		while(ninja_gloves.candrain && cell.charge> 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)

			if(cell.charge < drain)
				drain = cell.charge

			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE//Reached maximum battery capacity.

			if (do_after(ninja ,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE)
				cell.use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break

		if(!(obj_flags & EMAGGED))
			flick("apc-spark", ninja_gloves)
			playsound(loc, "sparks", 50, TRUE)
			obj_flags |= EMAGGED
			locked = FALSE
			update_icon()

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

		while(ninja_gloves.candrain && charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)

			if(charge < drain)
				drain = charge

			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE

			if (do_after(ninja,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE)
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
		if(ninja_gloves.candrain && do_after(ninja, 30, target = src))
			drain_total = charge
			if(ninja_suit.cell.charge + charge > ninja_suit.cell.maxcharge)
				ninja_suit.cell.charge = ninja_suit.cell.maxcharge
			else
				ninja_suit.cell.give(charge)
			charge = 0
			corrupt()
			update_icon()
			
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
		if(do_after(ninja, ninja_suit.s_delay, target = src) && ninja_gloves.candrain && src)
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
		if(do_after(ninja, ninja_suit.s_delay, target = src) && ninja_gloves.candrain && src)
			stored_research.copy_research_to(ninja_suit.stored_research)
	to_chat(ninja, "<span class='notice'>Data analyzed. Process finished.</span>")

//SECURITY CONSOLE//
/obj/machinery/computer/secure_data/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN
	if(ninja_gloves.security_console_hacks <= 0)
		return
	AI_notify_hack()
	if(do_after(ninja, 200))
		for(var/datum/data/record/rec in sortRecord(GLOB.data_core.general, sortBy, order))
			for(var/datum/data/record/security_record in GLOB.data_core.security)
				security_record.fields["criminal"] = "*Arrest*"
		ninja_gloves.security_console_hacks--
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
	if(ninja_gloves.communication_console_hacks <= 0)
		return
	if(do_after(ninja, 250))
		var/announcement_pick = rand(0, 5)
		switch(announcement_pick)
			if(0)
				priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/ai/outbreak5.ogg')
			if(1)
				priority_announce("A large organic energy flux has been recorded near [station_name()], please stand by.", "Lifesign Alert")
			if(2)
				priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/ai/aliens.ogg')
			if(3)
				priority_announce("Our long-range sensors have detected that your station's defenses have been breached by some sort of alien device.  We suggest searching for and destroying it as soon as possible.", "[command_name()] High-Priority Update")
			if(4)
				priority_announce("Unidentified armed ship detected near the station.")
		ninja_gloves.communication_console_hacks--
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
	while(ninja_gloves.candrain && !maxcapacity && src)
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
		while(ninja_gloves.candrain && cell.charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)
			if(cell.charge < drain)
				drain = cell.charge
			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE
			if (do_after(ninja, 10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE)
				cell.use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break

	return drain_total

//BORG//
/mob/living/silicon/robot/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves)
		return INVALID_DRAIN

	if(ninja_gloves.cyborg_hijacks > 0)
		to_chat(src, "<span class='danger'>Warni-***BZZZZZZZZZRT*** UPLOADING SPYDERPATCHER VERSION 9.5.2...</span>")
		if (do_after(ninja, 60, target = src))
			ninja_gloves.cyborg_hijacks--
			spark_system.start()
			playsound(loc, "sparks", 50, TRUE)
			to_chat(src, "<span class='danger'>UPLOAD COMPLETE.  NEW CYBORG MODULE DETECTED.  INSTALLING...</span>")
			faction = list(ROLE_NINJA)
			bubble_icon = "syndibot"
			lawupdate = FALSE
			scrambledcodes = TRUE
			ionpulse = TRUE
			laws = new /datum/ai_laws/ninja_override()
			module.transform_to(pick(/obj/item/robot_module/syndicate, /obj/item/robot_module/syndicate_medical, /obj/item/robot_module/saboteur))
			
			var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
			if(!ninja_antag)
				return
			var/datum/objective/cyborg_hijack/objective = locate() in ninja_antag.objectives
			if(objective)
				objective.completed = TRUE
		return
	
	var/maxcapacity = FALSE //Safety check
	var/drain = 0 //Drain amount
	var/drain_total = 0

	to_chat(src, "<span class='danger'>Warning: Unauthorized access through sub-route 12, block C, detected.</span>")

	if(cell && cell.charge)
		while(ninja_gloves.candrain && cell.charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)
			if(cell.charge < drain)
				drain = cell.charge
			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE
			if(do_after(ninja ,10))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE)
				cell.use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break

	return drain_total
