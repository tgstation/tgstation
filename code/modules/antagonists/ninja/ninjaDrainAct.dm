/**
 * Atom level proc for space ninja's glove interactions.
 *
 * Proc which only occurs when space ninja uses his gloves on an atom.
 * Does nothing by default, but effects will vary.
 * Arguments:
 * * ninja_suit - The offending space ninja's suit.
 * * ninja - The human mob wearing the suit.
 * * hacking_module - The offending space ninja's gloves.
 */
/atom/proc/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	return NONE

//APC//
/obj/machinery/power/apc/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/power/apc/proc/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0
	if(cell?.charge)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)
		while(cell.charge> 0 && !maxcapacity)
			drain = rand(hacking_module.mindrain, hacking_module.maxdrain)
			if(cell.charge < drain)
				drain = cell.charge
			if(hacking_module.mod.get_charge() + drain > hacking_module.mod.get_max_charge())
				drain = hacking_module.mod.get_max_charge() - hacking_module.mod.get_charge()
				maxcapacity = TRUE//Reached maximum battery capacity.
			if (do_after(ninja, 1 SECONDS, target = src))
				spark_system.start()
				playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				cell.use(drain)
				hacking_module.mod.add_charge(drain)
				drain_total += drain
			else
				break
		if(!(obj_flags & EMAGGED))
			flick("apc-spark", hacking_module)
			playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			obj_flags |= EMAGGED
			locked = FALSE
			update_appearance()
	hacking_module.charge_message(src, drain_total)

//SMES//
/obj/machinery/power/smes/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/power/smes/proc/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, loc)
	while(charge > 0 && !maxcapacity)
		drain = rand(hacking_module.mindrain, hacking_module.maxdrain)
		if(charge < drain)
			drain = charge
		if(hacking_module.mod.get_charge() + drain > hacking_module.mod.get_max_charge())
			drain = hacking_module.mod.get_max_charge() - hacking_module.mod.get_charge()
			maxcapacity = TRUE
		if (do_after(ninja, 1 SECONDS, target = src))
			spark_system.start()
			playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			charge -= drain
			hacking_module.mod.add_charge(drain)
			drain_total += drain
			maxcapacity = TRUE//Reached maximum battery capacity.
		else
			break
	hacking_module.charge_message(src, drain_total)

//CELL//
/obj/item/stock_parts/cell/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/stock_parts/cell/proc/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	var/drain_total = 0
	if(charge && !do_after(ninja, 3 SECONDS, target = src))
		drain_total = charge
		if(hacking_module.mod.get_charge() + charge > hacking_module.mod.get_max_charge())
			drain_total = hacking_module.mod.get_max_charge() - hacking_module.mod.get_charge()
		hacking_module.mod.add_charge(drain_total)
		use(drain_total)
		corrupt()
		update_appearance()
	hacking_module.charge_message(src, drain_total)

//RD SERVER//
/obj/machinery/rnd/server/master/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	// If the traitor theft objective is still present, this will destroy it...
	if(!source_code_hdd)
		return ..()
	to_chat(ninja, span_notice("Hacking \the [src]..."))
	AI_notify_hack()
	to_chat(ninja, span_notice("Encrypted source code detected. Overloading storage device..."))
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/rnd/server/master/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!do_after(ninja, 30 SECONDS, target = src))
		return
	overload_source_code_hdd()
	to_chat(ninja, span_notice("Sabotage complete. Storage device overloaded."))
	var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
	if(!ninja_antag)
		return
	var/datum/objective/research_secrets/objective = locate() in ninja_antag.objectives
	if(objective)
		objective.completed = TRUE

/obj/machinery/rnd/server/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	to_chat(ninja, span_notice("Research notes detected. Corrupting data..."))
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/rnd/server/proc/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!do_after(ninja, 30 SECONDS, target = src))
		return
	SSresearch.science_tech.modify_points_all(0)
	to_chat(ninja, span_notice("Sabotage complete. Research notes corrupted."))
	var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
	if(!ninja_antag)
		return
	var/datum/objective/research_secrets/objective = locate() in ninja_antag.objectives
	if(objective)
		objective.completed = TRUE

//SECURITY CONSOLE//
/obj/machinery/computer/records/security/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	if(!can_hack(ninja, feedback = TRUE))
		return NONE

	AI_notify_hack()
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/computer/records/security/proc/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!do_after(ninja, 20 SECONDS, src, extra_checks = CALLBACK(src, PROC_REF(can_hack), ninja)))
		return
	for(var/datum/record/crew/target in GLOB.manifest.general)
		target.wanted_status = WANTED_ARREST
	update_all_security_huds()

	var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
	if(!ninja_antag)
		return
	var/datum/objective/security_scramble/objective = locate() in ninja_antag.objectives
	if(objective)
		objective.completed = TRUE

/obj/machinery/computer/records/security/proc/can_hack(mob/living/hacker, feedback = FALSE)
	if(machine_stat & (NOPOWER|BROKEN))
		if(feedback && hacker)
			balloon_alert(hacker, "can't hack!")
		return FALSE
	var/area/console_area = get_area(src)
	if(!console_area || !(console_area.area_flags & VALID_TERRITORY))
		if(feedback && hacker)
			balloon_alert(hacker, "signal too weak!")
		return FALSE
	return TRUE

//COMMUNICATIONS CONSOLE//
/obj/machinery/computer/communications/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	if(hacking_module.communication_console_hack_success)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/computer/communications/proc/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!try_hack_console(ninja))
		return

	hacking_module.communication_console_hack_success = TRUE
	var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
	if(!ninja_antag)
		return
	var/datum/objective/terror_message/objective = locate() in ninja_antag.objectives
	if(objective)
		objective.completed = TRUE

//AIRLOCK//
/obj/machinery/door/airlock/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	if(!operating && density && hasPower() && !(obj_flags & EMAGGED) && hacking_module.mod.subtract_charge(DEFAULT_CHARGE_DRAIN * 5))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, emag_act))
		hacking_module.door_hack_counter++
		var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
		if(!ninja_antag)
			return NONE
		var/datum/objective/door_jack/objective = locate() in ninja_antag.objectives
		if(objective && objective.doors_required <= hacking_module.door_hack_counter)
			objective.completed = TRUE
	return COMPONENT_CANCEL_ATTACK_CHAIN

//WIRE//
/obj/structure/cable/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/cable/proc/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	var/maxcapacity = FALSE //Safety check
	var/drain = 0 //Drain amount
	var/drain_total = 0
	var/datum/powernet/wire_powernet = powernet
	while(!maxcapacity && src)
		drain = (round((rand(hacking_module.mindrain, hacking_module.maxdrain))/2))
		var/drained = 0
		if(wire_powernet && do_after(ninja, 1 SECONDS, target = src))
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
		if(hacking_module.mod.get_charge() + drain > hacking_module.mod.get_max_charge())
			drain = hacking_module.mod.get_max_charge() - hacking_module.mod.get_charge()
			maxcapacity = TRUE
		drain_total += drain
		hacking_module.mod.add_charge(drain)
		do_sparks(5, cardinal_only = FALSE, source = hacking_module.mod)
	hacking_module.charge_message(src, drain_total)

//MECH//
/obj/vehicle/sealed/mecha/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	to_chat(occupants, "[icon2html(src, occupants)][span_danger("Warning: Unauthorized access through sub-route 4, block H, detected.")]")
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/vehicle/sealed/mecha/proc/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	var/maxcapacity = FALSE //Safety check
	var/drain = 0 //Drain amount
	var/drain_total = 0
	if(get_charge())
		while(cell.charge > 0 && !maxcapacity)
			drain = rand(hacking_module.mindrain, hacking_module.maxdrain)
			if(cell.charge < drain)
				drain = cell.charge
			if(hacking_module.mod.get_charge() + drain > hacking_module.mod.get_max_charge())
				drain = hacking_module.mod.get_max_charge() - hacking_module.mod.get_charge()
				maxcapacity = TRUE
			if (do_after(ninja, 1 SECONDS, target = src))
				spark_system.start()
				playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				cell.use(drain)
				hacking_module.mod.add_charge(drain)
				drain_total += drain
			else
				break
	hacking_module.charge_message(src, drain_total)

//BORG//
/mob/living/silicon/robot/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module || (ROLE_NINJA in faction))
		return NONE

	to_chat(src, span_danger("Warni-***BZZZZZZZZZRT*** UPLOADING SPYDERPATCHER VERSION 9.5.2..."))
	INVOKE_ASYNC(src, PROC_REF(ninjadrain_charge), ninja, hacking_module)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/mob/living/silicon/robot/proc/ninjadrain_charge(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!do_after(ninja, 6 SECONDS, target = src))
		return
	spark_system.start()
	playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(src, span_danger("UPLOAD COMPLETE. NEW CYBORG MODEL DETECTED.  INSTALLING..."))
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
/mob/living/carbon/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!ninja || !hacking_module)
		return NONE
	//Default cell = 10,000 charge, 10,000/1000 = 10 uses without charging/upgrading
	if(hacking_module.mod.subtract_charge(DEFAULT_CHARGE_DRAIN*10))
		//Got that electric touch
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)
		playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		visible_message(span_danger("[ninja] electrocutes [src] with [ninja.p_their()] touch!"), span_userdanger("[ninja] electrocutes you with [ninja.p_their()] touch!"))
		Knockdown(3 SECONDS)
	return NONE

//CAMERAS//
/obj/machinery/camera/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(isEmpProof(TRUE))
		balloon_alert(ninja, "camera is shielded!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!hacking_module.mod.subtract_charge(DEFAULT_CHARGE_DRAIN * 5))
		return

	emp_act(EMP_HEAVY)
	return COMPONENT_CANCEL_ATTACK_CHAIN

//BOTS//
/mob/living/simple_animal/bot/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	to_chat(src, span_boldwarning("Your circutry suddenly begins heating up!"))
	if(!do_after(ninja, 1.5 SECONDS, target = src))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!hacking_module.mod.subtract_charge(DEFAULT_CHARGE_DRAIN * 7))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	do_sparks(number = 3, cardinal_only = FALSE, source = src)
	playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 35, TRUE)
	balloon_alert(ninja, "stand back!")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), src, 0, 1, 2, 3), 2.5 SECONDS)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/mob/living/simple_animal/bot/medbot/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	var/static/list/death_cry = list(
		MEDIBOT_VOICED_NO_SAD,
		MEDIBOT_VOICED_OH_FUCK,
	)
	speak(pick(death_cry))
	return ..()

//ENERGY WEAPONS//
/obj/item/gun/energy/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(cell.charge == 0)
		balloon_alert(ninja, "no energy!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!do_after(ninja, 1.5 SECONDS, target = src))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	hacking_module.mod.add_charge(cell.charge)
	hacking_module.charge_message(src, cell.charge)
	cell.charge = 0
	update_appearance()
	visible_message(span_warning("[ninja] drains the energy from the [src]!"))
	do_sparks(number = 3, cardinal_only = FALSE, source = src)
	return COMPONENT_CANCEL_ATTACK_CHAIN

//VENDING MACHINES//
/obj/machinery/vending/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(shoot_inventory)
		balloon_alert(ninja, "already hacked!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!do_after(ninja, 2 SECONDS, target = src))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!hacking_module.mod.subtract_charge(DEFAULT_CHARGE_DRAIN * 5))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	do_sparks(number = 3, cardinal_only = FALSE, source = src)
	balloon_alert(ninja, "system overloaded!")
	wires.on_pulse(WIRE_THROW)
	return COMPONENT_CANCEL_ATTACK_CHAIN

//RECYCLER//
/obj/machinery/recycler/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(obj_flags & EMAGGED)
		balloon_alert(ninja, "already hacked!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	AI_notify_hack()
	if(!do_after(ninja, 30 SECONDS, target = src))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	do_sparks(3, cardinal_only = FALSE, source = src)
	emag_act(ninja)

	return COMPONENT_CANCEL_ATTACK_CHAIN

//ELEVATOR CONTROLS//
/obj/machinery/elevator_control_panel/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(obj_flags & EMAGGED)
		balloon_alert(ninja, "already hacked!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!do_after(ninja, 2 SECONDS, target = src))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	do_sparks(3, cardinal_only = FALSE, source = src)
	emag_act(ninja)

	return COMPONENT_CANCEL_ATTACK_CHAIN

//TRAM CONTROLS//
/obj/machinery/computer/tram_controls/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	var/datum/round_event/tram_malfunction/malfunction_event = locate(/datum/round_event/tram_malfunction) in SSevents.running
	if(malfunction_event)
		balloon_alert(ninja, "tram is already malfunctioning!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(specific_lift_id != MAIN_STATION_TRAM)
		balloon_alert(ninja, "cannot hack this tram!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	AI_notify_hack()

	if(!do_after(ninja, 20 SECONDS, target = src)) //Shorter due to how incredibly easy it is for someone to (even accidentally) interrupt.
		return COMPONENT_CANCEL_ATTACK_CHAIN

	force_event(/datum/round_event_control/tram_malfunction, "ninja interference")
	malfunction_event = locate(/datum/round_event/tram_malfunction) in SSevents.running
	malfunction_event.end_when *= 3

	return COMPONENT_CANCEL_ATTACK_CHAIN

//WINDOOR//
/obj/machinery/door/window/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(!operating && density && hasPower() && !(obj_flags & EMAGGED) && hacking_module.mod.subtract_charge(DEFAULT_CHARGE_DRAIN * 5))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, emag_act))
	return COMPONENT_CANCEL_ATTACK_CHAIN

//BUTTONS//
/obj/machinery/button/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	if(is_operational && !(obj_flags & EMAGGED))
		emag_act(ninja)
	return COMPONENT_CANCEL_ATTACK_CHAIN

//FIRELOCKS//
/obj/machinery/door/firedoor/ninjadrain_act(mob/living/carbon/human/ninja, obj/item/mod/module/hacker/hacking_module)
	crack_open()
