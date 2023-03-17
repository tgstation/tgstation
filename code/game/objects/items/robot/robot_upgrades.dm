// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	w_class = WEIGHT_CLASS_SMALL
	var/locked = FALSE
	var/installed = FALSE
	var/require_model = FALSE
	var/list/model_type = null
	/// Bitflags listing model compatibility. Used in the exosuit fabricator for creating sub-categories.
	var/list/model_flags = NONE
	// if true, is not stored in the robot to be ejected
	// if model is reset
	var/one_use = FALSE

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/R, user = usr)
	if(R.stat == DEAD)
		to_chat(user, span_warning("[src] will not function on a deceased cyborg!"))
		return FALSE
	if(model_type && !is_type_in_list(R.model, model_type))
		to_chat(R, span_alert("Upgrade mounting error! No suitable hardpoint detected."))
		to_chat(user, span_warning("There's no mounting point for the module!"))
		return FALSE
	return TRUE

/obj/item/borg/upgrade/proc/deactivate(mob/living/silicon/robot/R, user = usr)
	if (!(src in R.upgrades))
		return FALSE
	return TRUE

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = ""
	one_use = TRUE

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = sanitize_name(tgui_input_text(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN), allow_numbers = TRUE)
	user.log_message("set \"[heldname]\" as a name in a cyborg reclassification board at [loc_name(user)]", LOG_GAME)

/obj/item/borg/upgrade/rename/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/oldname = R.real_name
		var/oldkeyname = key_name(R)
		R.custom_name = heldname
		R.updatename()
		if(oldname == R.real_name)
			R.notify_ai(AI_NOTIFICATION_CYBORG_RENAMED, oldname, R.real_name)
		usr.log_message("used a cyborg reclassification board to rename [oldkeyname] to [key_name(R)]", LOG_GAME)

/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/security)
	model_flags = BORG_MODEL_SECURITY

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.model.modules
		if(!T)
			to_chat(user, span_warning("There's no disabler in this unit!"))
			return FALSE
		if(T.charge_delay <= 2)
			to_chat(R, span_warning("A cooling unit is already installed!"))
			to_chat(user, span_warning("There's no room for another cooling unit!"))
			return FALSE

		T.charge_delay = max(2 , T.charge_delay - 4)

/obj/item/borg/upgrade/disablercooler/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.model.modules
		if(!T)
			return FALSE
		T.charge_delay = initial(T.charge_delay)

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "An energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.ionpulse)
			to_chat(user, span_warning("This unit already has ion thrusters installed!"))
			return FALSE

		R.ionpulse = TRUE
		R.toggle_ionpulse() //Enabled by default

/obj/item/borg/upgrade/thrusters/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.ionpulse = FALSE

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining model's standard drill."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER

/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/pickaxe/drill/cyborg/D in R.model)
			R.model.remove_module(D, TRUE)
		for(var/obj/item/shovel/S in R.model)
			R.model.remove_module(S, TRUE)

		var/obj/item/pickaxe/drill/cyborg/diamond/DD = new /obj/item/pickaxe/drill/cyborg/diamond(R.model)
		R.model.basic_modules += DD
		R.model.add_module(DD, FALSE, TRUE)

/obj/item/borg/upgrade/ddrill/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/pickaxe/drill/cyborg/diamond/DD in R.model)
			R.model.remove_module(DD, TRUE)

		var/obj/item/pickaxe/drill/cyborg/D = new (R.model)
		R.model.basic_modules += D
		R.model.add_module(D, FALSE, TRUE)
		var/obj/item/shovel/S = new (R.model)
		R.model.basic_modules += S
		R.model.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/ore/cyborg/S in R.model)
			R.model.remove_module(S, TRUE)

		var/obj/item/storage/bag/ore/holding/H = new /obj/item/storage/bag/ore/holding(R.model)
		R.model.basic_modules += H
		R.model.add_module(H, FALSE, TRUE)

/obj/item/borg/upgrade/soh/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/storage/bag/ore/holding/H in R.model)
			R.model.remove_module(H, TRUE)

		var/obj/item/storage/bag/ore/cyborg/S = new (R.model)
		R.model.basic_modules += S
		R.model.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/tboh
	name = "janitor cyborg trash bag of holding"
	desc = "A trash bag of holding replacement for the janiborg's standard trash bag."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR

/obj/item/borg/upgrade/tboh/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/trash/cyborg/TB in R.model.modules)
			R.model.remove_module(TB, TRUE)

		var/obj/item/storage/bag/trash/bluespace/cyborg/B = new /obj/item/storage/bag/trash/bluespace/cyborg(R.model)
		R.model.basic_modules += B
		R.model.add_module(B, FALSE, TRUE)

/obj/item/borg/upgrade/tboh/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/trash/bluespace/cyborg/B in R.model.modules)
			R.model.remove_module(B, TRUE)

		var/obj/item/storage/bag/trash/cyborg/TB = new (R.model)
		R.model.basic_modules += TB
		R.model.add_module(TB, FALSE, TRUE)

/obj/item/borg/upgrade/amop
	name = "janitor cyborg advanced mop"
	desc = "An advanced mop replacement for the janiborg's standard mop."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR

/obj/item/borg/upgrade/amop/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		for(var/obj/item/mop/cyborg/M in R.model.modules)
			R.model.remove_module(M, TRUE)

		var/obj/item/mop/advanced/cyborg/mop = new /obj/item/mop/advanced/cyborg(R.model)
		R.model.basic_modules += mop
		R.model.add_module(mop, FALSE, TRUE)

/obj/item/borg/upgrade/amop/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/mop/advanced/cyborg/A in R.model.modules)
			R.model.remove_module(A, TRUE)

		var/obj/item/mop/cyborg/M = new (R.model)
		R.model.basic_modules += M
		R.model.add_module(M, FALSE, TRUE)

/obj/item/borg/upgrade/prt
	name = "janitor cyborg plating repair tool"
	desc = "A tiny heating device to repair burnt and damaged hull platings with."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR

/obj/item/borg/upgrade/prt/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		var/obj/item/cautery/prt/P = new (R.model)
		R.model.basic_modules += P
		R.model.add_module(P, FALSE, TRUE)

/obj/item/borg/upgrade/prt/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/cautery/prt/P in R.model.modules)
			R.model.remove_module(P, TRUE)

/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.emagged)
			return FALSE

		R.SetEmagged(TRUE)
		R.logevent("WARN: hardware installed with missing security certificate!") //A bit of fluff to hint it was an illegal tech item
		R.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error

		return TRUE

/obj/item/borg/upgrade/syndicate/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.SetEmagged(FALSE)

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER

/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		ADD_TRAIT(R, TRAIT_LAVA_IMMUNE, type)

/obj/item/borg/upgrade/lavaproof/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		REMOVE_TRAIT(R, TRAIT_LAVA_IMMUNE, type)

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "cyborg_upgrade5"
	require_model = TRUE
	var/repair_amount = -1
	/// world.time of next repair
	var/next_repair = 0
	/// Minimum time between repairs in seconds
	var/repair_cooldown = 4
	var/on = FALSE
	var/powercost = 10
	var/datum/action/toggle_action

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/upgrade/selfrepair/U = locate() in R
		if(U)
			to_chat(user, span_warning("This unit is already equipped with a self-repair module!"))
			return FALSE

		icon_state = "selfrepair_off"
		toggle_action = new /datum/action/item_action/toggle(src)
		toggle_action.Grant(R)

/obj/item/borg/upgrade/selfrepair/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		toggle_action.Remove(R)
		QDEL_NULL(toggle_action)
		deactivate_sr()

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	if(on)
		to_chat(toggle_action.owner, span_notice("You deactivate the self-repair module."))
		deactivate_sr()
	else
		to_chat(toggle_action.owner, span_notice("You activate the self-repair module."))
		activate_sr()


/obj/item/borg/upgrade/selfrepair/update_icon_state()
	if(toggle_action)
		icon_state = "selfrepair_[on ? "on" : "off"]"
	else
		icon_state = "cyborg_upgrade5"
	return ..()

/obj/item/borg/upgrade/selfrepair/proc/activate_sr()
	START_PROCESSING(SSobj, src)
	on = TRUE
	update_appearance()

/obj/item/borg/upgrade/selfrepair/proc/deactivate_sr()
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	update_appearance()

/obj/item/borg/upgrade/selfrepair/process()
	if(world.time < next_repair)
		return

	var/mob/living/silicon/robot/cyborg = toggle_action.owner

	if(istype(cyborg) && (cyborg.stat != DEAD) && on)
		if(!cyborg.cell)
			to_chat(cyborg, span_alert("Self-repair module deactivated. Please insert power cell."))
			deactivate_sr()
			return

		if(cyborg.cell.charge < powercost * 2)
			to_chat(cyborg, span_alert("Self-repair module deactivated. Please recharge."))
			deactivate_sr()
			return

		if(cyborg.health < cyborg.maxHealth)
			if(cyborg.health < 0)
				repair_amount = -2.5
				powercost = 30
			else
				repair_amount = -1
				powercost = 10
			cyborg.adjustBruteLoss(repair_amount)
			cyborg.adjustFireLoss(repair_amount)
			cyborg.updatehealth()
			cyborg.cell.use(powercost)
		else
			cyborg.cell.use(5)
		next_repair = world.time + repair_cooldown * 10 // Multiply by 10 since world.time is in deciseconds

		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_BORG_SELF_REPAIR))
			TIMER_COOLDOWN_START(src, COOLDOWN_BORG_SELF_REPAIR, 200 SECONDS)
			var/msgmode = "standby"
			if(cyborg.health < 0)
				msgmode = "critical"
			else if(cyborg.health < cyborg.maxHealth)
				msgmode = "normal"
			to_chat(cyborg, span_notice("Self-repair is active in [span_boldnotice("[msgmode]")] mode."))
	else
		deactivate_sr()

/obj/item/borg/upgrade/hypospray
	name = "medical cyborg hypospray advanced synthesiser"
	desc = "An upgrade to the Medical model cyborg's hypospray, allowing it \
		to produce more advanced and complex medical reagents."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL
	var/list/additional_reagents = list()

/obj/item/borg/upgrade/hypospray/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/reagent_containers/borghypo/medical/H in R.model.modules)
			H.upgrade_hypo()

/obj/item/borg/upgrade/hypospray/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/reagent_containers/borghypo/medical/H in R.model.modules)
			H.remove_hypo_upgrade()

/obj/item/borg/upgrade/hypospray/expanded
	name = "medical cyborg expanded hypospray"
	desc = "An upgrade to the Medical model's hypospray, allowing it \
		to treat a wider range of conditions and problems."

/obj/item/borg/upgrade/piercing_hypospray
	name = "cyborg piercing hypospray"
	desc = "An upgrade to a cyborg's hypospray, allowing it to \
		pierce armor and thick material."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/piercing_hypospray/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/found_hypo = FALSE
		for(var/obj/item/reagent_containers/borghypo/H in R.model.modules)
			H.bypass_protection = TRUE
			found_hypo = TRUE

		if(!found_hypo)
			return FALSE

/obj/item/borg/upgrade/piercing_hypospray/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/reagent_containers/borghypo/H in R.model.modules)
			H.bypass_protection = initial(H.bypass_protection)

/obj/item/borg/upgrade/defib
	name = "medical cyborg defibrillator"
	desc = "An upgrade to the Medical model, installing a built-in \
		defibrillator, for on the scene revival."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/defib/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/upgrade/defib/backpack/BP = locate() in R //If a full defib unit was used to upgrade prior, we can just pop it out now and replace
		if(BP)
			BP.deactivate(R, user)
			to_chat(user, span_notice("You remove the defibrillator unit to make room for the compact upgrade."))
		var/obj/item/shockpaddles/cyborg/S = new(R.model)
		R.model.basic_modules += S
		R.model.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/defib/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/shockpaddles/cyborg/S = locate() in R.model
		R.model.remove_module(S, TRUE)

///A version of the above that also acts as a holder of an actual defibrillator item used in place of the upgrade chip.
/obj/item/borg/upgrade/defib/backpack
	var/obj/item/defibrillator/defib_instance

/obj/item/borg/upgrade/defib/backpack/Initialize(mapload, obj/item/defibrillator/D)
	. = ..()
	if(!D)
		D = new /obj/item/defibrillator
	defib_instance = D
	name = defib_instance.name
	defib_instance.moveToNullspace()
	RegisterSignals(defib_instance, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(on_defib_instance_qdel_or_moved))

/obj/item/borg/upgrade/defib/backpack/proc/on_defib_instance_qdel_or_moved(obj/item/defibrillator/D)
	SIGNAL_HANDLER
	defib_instance = null
	if(!QDELETED(src))
		qdel(src)

/obj/item/borg/upgrade/defib/backpack/Destroy()
	if(!QDELETED(defib_instance))
		QDEL_NULL(defib_instance)
	return ..()

/obj/item/borg/upgrade/defib/backpack/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		defib_instance?.forceMove(R.drop_location()) // [on_defib_instance_qdel_or_moved()] handles the rest.

/obj/item/borg/upgrade/processor
	name = "medical cyborg surgical processor"
	desc = "An upgrade to the Medical model, installing a processor \
		capable of scanning surgery disks and carrying \
		out procedures"
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical)
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/processor/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/surgical_processor/SP = new(R.model)
		R.model.basic_modules += SP
		R.model.add_module(SP, FALSE, TRUE)

/obj/item/borg/upgrade/processor/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/surgical_processor/SP = locate() in R.model
		R.model.remove_module(SP, TRUE)

/obj/item/borg/upgrade/ai
	name = "B.O.R.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon_state = "boris"

/obj/item/borg/upgrade/ai/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.shell)
			to_chat(user, span_warning("This unit is already an AI shell!"))
			return FALSE
		if(R.key) //You cannot replace a player unless the key is completely removed.
			to_chat(user, span_warning("Intelligence patterns detected in this [R.braintype]. Aborting."))
			return FALSE

		R.make_shell(src)

/obj/item/borg/upgrade/ai/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		if(R.shell)
			R.undeploy()
			R.notify_ai(AI_NOTIFICATION_AI_SHELL)

/obj/item/borg/upgrade/expand
	name = "borg expander"
	desc = "A cyborg resizer, it makes a cyborg huge."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/expand/action(mob/living/silicon/robot/robot, user = usr)
	. = ..()
	if(.)

		if(robot.hasExpanded)
			to_chat(usr, span_warning("This unit already has an expand module installed!"))
			return FALSE

		robot.notransform = TRUE
		var/prev_lockcharge = robot.lockcharge
		robot.SetLockdown(TRUE)
		robot.set_anchored(TRUE)
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(1, holder = robot, location = robot.loc)
		smoke.start()
		sleep(0.2 SECONDS)
		for(var/i in 1 to 4)
			playsound(robot, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, TRUE, -1)
			sleep(1.2 SECONDS)
		if(!prev_lockcharge)
			robot.SetLockdown(FALSE)
		robot.set_anchored(FALSE)
		robot.notransform = FALSE
		robot.resize = 2
		robot.hasExpanded = TRUE
		robot.update_transform()

/obj/item/borg/upgrade/expand/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		if (R.hasExpanded)
			R.hasExpanded = FALSE
			R.resize = 0.5
			R.update_transform()

/obj/item/borg/upgrade/rped
	name = "engineering cyborg RPED"
	desc = "A rapid part exchange device for the engineering cyborg."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "borgrped"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur)
	model_flags = BORG_MODEL_ENGINEERING

/obj/item/borg/upgrade/rped/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		var/obj/item/storage/part_replacer/cyborg/RPED = locate() in R
		if(RPED)
			to_chat(user, span_warning("This unit is already equipped with a RPED module!"))
			return FALSE

		RPED = new(R.model)
		R.model.basic_modules += RPED
		R.model.add_module(RPED, FALSE, TRUE)

/obj/item/borg/upgrade/rped/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/storage/part_replacer/cyborg/RPED = locate() in R.model
		if (RPED)
			R.model.remove_module(RPED, TRUE)

/obj/item/borg/upgrade/pinpointer
	name = "medical cyborg crew pinpointer"
	desc = "A crew pinpointer module for the medical cyborg. Permits remote access to the crew monitor."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer_crew"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical)
	model_flags = BORG_MODEL_MEDICAL
	var/datum/action/crew_monitor

/obj/item/borg/upgrade/pinpointer/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		var/obj/item/pinpointer/crew/PP = locate() in R.model
		if(PP)
			to_chat(user, span_warning("This unit is already equipped with a pinpointer module!"))
			return FALSE

		PP = new(R.model)
		R.model.basic_modules += PP
		R.model.add_module(PP, FALSE, TRUE)
		crew_monitor = new /datum/action/item_action/crew_monitor(src)
		crew_monitor.Grant(R)
		icon_state = "scanner"


/obj/item/borg/upgrade/pinpointer/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		icon_state = "pinpointer_crew"
		crew_monitor.Remove(R)
		QDEL_NULL(crew_monitor)
		var/obj/item/pinpointer/crew/PP = locate() in R.model
		R.model.remove_module(PP, TRUE)

/obj/item/borg/upgrade/pinpointer/ui_action_click()
	if(..())
		return
	var/mob/living/silicon/robot/Cyborg = usr
	GLOB.crewmonitor.show(Cyborg,Cyborg)

/datum/action/item_action/crew_monitor
	name = "Interface With Crew Monitor"

/obj/item/borg/upgrade/transform
	name = "borg model picker (Standard)"
	desc = "Allows you to to turn a cyborg into a standard cyborg."
	icon_state = "cyborg_upgrade3"
	var/obj/item/robot_model/new_model = null

/obj/item/borg/upgrade/transform/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(. && new_model)
		R.model.transform_to(new_model)

/obj/item/borg/upgrade/transform/clown
	name = "borg model picker (Clown)"
	desc = "Allows you to to turn a cyborg into a clown, honk."
	icon_state = "cyborg_upgrade3"
	new_model = /obj/item/robot_model/clown

/obj/item/borg/upgrade/circuit_app
	name = "circuit manipulation apparatus"
	desc = "An engineering cyborg upgrade allowing for manipulation of circuit boards."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur)
	model_flags = BORG_MODEL_ENGINEERING

/obj/item/borg/upgrade/circuit_app/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/apparatus/circuit/C = locate() in R.model.modules
		if(C)
			to_chat(user, span_warning("This unit is already equipped with a circuit apparatus!"))
			return FALSE

		C = new(R.model)
		R.model.basic_modules += C
		R.model.add_module(C, FALSE, TRUE)

/obj/item/borg/upgrade/circuit_app/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/borg/apparatus/circuit/C = locate() in R.model.modules
		if (C)
			R.model.remove_module(C, TRUE)

/obj/item/borg/upgrade/beaker_app
	name = "beaker storage apparatus"
	desc = "A supplementary beaker storage apparatus for medical cyborgs."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/beaker_app/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/apparatus/beaker/extra/E = locate() in R.model.modules
		if(E)
			to_chat(user, span_warning("This unit has no room for additional beaker storage!"))
			return FALSE

		E = new(R.model)
		R.model.basic_modules += E
		R.model.add_module(E, FALSE, TRUE)

/obj/item/borg/upgrade/beaker_app/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/borg/apparatus/beaker/extra/E = locate() in R.model.modules
		if (E)
			R.model.remove_module(E, TRUE)

/obj/item/borg/upgrade/broomer
	name = "experimental push broom"
	desc = "An experimental push broom used for efficiently pushing refuse."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR

/obj/item/borg/upgrade/broomer/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (!.)
		return
	var/obj/item/pushbroom/cyborg/BR = locate() in R.model.modules
	if (BR)
		to_chat(user, span_warning("This janiborg is already equipped with an experimental broom!"))
		return FALSE
	BR = new(R.model)
	R.model.basic_modules += BR
	R.model.add_module(BR, FALSE, TRUE)

/obj/item/borg/upgrade/broomer/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (!.)
		return
	var/obj/item/pushbroom/cyborg/BR = locate() in R.model.modules
	if (BR)
		R.model.remove_module(BR, TRUE)

///This isn't an upgrade or part of the same path, but I'm gonna just stick it here because it's a tool used on cyborgs.
//A reusable tool that can bring borgs back to life. They gotta be repaired first, though.
/obj/item/borg_restart_board
	name = "cyborg emergency reboot module"
	desc = "A reusable firmware reset tool that can force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade1"

/obj/item/borg_restart_board/pre_attack(mob/living/silicon/robot/borgo, mob/living/user, params)
	if(!istype(borgo))
		return ..()
	if(!borgo.opened)
		to_chat(user, span_warning("You must access the cyborg's internals!"))
		return ..()
	if(borgo.health < 0)
		to_chat(user, span_warning("You have to repair the cyborg before using this module!"))
		return ..()
	if(!(borgo.stat & DEAD))
		to_chat(user, span_warning("This cyborg is already operational!"))
		return ..()

	if(borgo.mind)
		borgo.mind.grab_ghost()
		playsound(loc, 'sound/voice/liveagain.ogg', 75, TRUE)
	else
		playsound(loc, 'sound/machines/ping.ogg', 75, TRUE)

	borgo.revive()
	borgo.logevent("WARN -- System recovered from unexpected shutdown.")
	borgo.logevent("System brought online.")
	return ..()
