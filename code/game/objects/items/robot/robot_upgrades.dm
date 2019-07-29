
///This is basically the borg version of /obj/item/organ.
/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/installed = 0
	var/module_type = null
	// if true, is not stored in the robot to be ejected
	// if module is reset
	///Holds robot_upgrade_flags. Mostly used for determining if an upgrade can be inserted.
	var/robot_upgrade_flags = NONE
	var/mob/living/silicon/robot/owner

/obj/item/borg/upgrade/Destroy()
	if(owner)
		Remove(owner, FALSE)
	return ..()

///Comparable to Insert on organs. Try to avoid overriding this if at all possible, src can be deleted at the end of the proc. Returns the message that should get generated for the user.
/obj/item/borg/upgrade/proc/Insert(mob/living/silicon/robot/R)
	if(!(robot_upgrade_flags & R_UPGRADE_WORKS_ON_DEAD) && R.stat == DEAD)
		return "<span class='notice'>[R] is broken. You can't use [src] on [R.p_them()].</span>"
	if(robot_upgrade_flags & R_UPGRADE_IS_HIGHLANDER)
		for(var/i in R.upgrades)
			var/datum/D = i
			if(D.type == type)
				return "<span class='notice'>[R] already has \a [src].</span>"
	if(module_type && !istype(R.module, module_type))
		return "<span class='notice'>There's no mounting point for the module!</span>"
	var/failure_message = action(R)
	if(failure_message)
		return failure_message
	if(robot_upgrade_flags & R_UPGRADE_ONE_USE)
		. = "<span class='notice'>You insert [src] into [R]. It got used up in the process.</span>"
		qdel(src)
		return
	owner = R
	R.upgrades.Add(src)
	moveToNullspace()
	return R_UPGRADE_SUCCESSFUL_INSERTION

///Don't call this directly. Returning anything except FALSE or null will abort Insertion. The return value gets displayed as error message.
/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/R)
	return

///Comparable to Remove on organs.
/obj/item/borg/upgrade/proc/Remove(mob/living/silicon/robot/R, drop_to_ground = TRUE)
	owner = null
	if(!R)
		return
	R.upgrades.Remove(src)
	deactivate(R)
	if(!drop_to_ground)
		return
	forceMove(R.drop_location())

///Don't call this directly either.
/obj/item/borg/upgrade/proc/deactivate(mob/living/silicon/robot/R)
	return

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = ""
	robot_upgrade_flags = R_UPGRADE_ONE_USE

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	var/oldname = R.real_name
	R.custom_name = heldname
	R.updatename()
	if(oldname == R.real_name)
		R.notify_ai(RENAME, oldname, R.real_name)

/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"
	robot_upgrade_flags = R_UPGRADE_ONE_USE|R_UPGRADE_WORKS_ON_DEAD

/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	if(R.health < 0)
		return "<span class='warning'>You have to repair the cyborg before using this module!</span>"

	if(R.mind)
		R.mind.grab_ghost()
		playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)

	R.revive()

/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	module_type = /obj/item/robot_module/security

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		return
	var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.module.modules
	if(!T)
		return "<span class='notice'>There's no disabler in this unit!</span>"
	if(T.charge_delay <= 2)
		to_chat(R, "<span class='notice'>A cooling unit is already installed!</span>")
		return "<span class='notice'>There's no room for another cooling unit!</span>"
	T.charge_delay = max(2 , T.charge_delay - 4)

/obj/item/borg/upgrade/disablercooler/deactivate(mob/living/silicon/robot/R)
	. = ..()
	var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.module.modules
	if(!T)
		return
	T.charge_delay = initial(T.charge_delay)

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "An energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"
	robot_upgrade_flags = R_UPGRADE_IS_HIGHLANDER

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/R) ///TO DO. This needs to be made a lot saner.
	. = ..()
	if(.)
		return
	if(R.ionpulse)
		return "<span class='notice'>This unit already has ion thrusters installed!</span>"
	R.ionpulse = TRUE

/obj/item/borg/upgrade/thrusters/deactivate(mob/living/silicon/robot/R)
	. = ..()
	R.ionpulse = FALSE

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	module_type = /obj/item/robot_module/miner

/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	for(var/obj/item/pickaxe/drill/cyborg/D in R.module)
		R.module.remove_module(D, TRUE)
	for(var/obj/item/shovel/S in R.module)
		R.module.remove_module(S, TRUE)
	var/obj/item/pickaxe/drill/cyborg/diamond/DD = new /obj/item/pickaxe/drill/cyborg/diamond(R.module)
	R.module.basic_modules += DD
	R.module.add_module(DD, FALSE, TRUE)

/obj/item/borg/upgrade/ddrill/deactivate(mob/living/silicon/robot/R)
	. = ..()
	if (.)
		return
	for(var/obj/item/pickaxe/drill/cyborg/diamond/DD in R.module)
		R.module.remove_module(DD, TRUE)
	var/obj/item/pickaxe/drill/cyborg/D = new (R.module)
	R.module.basic_modules += D
	R.module.add_module(D, FALSE, TRUE)
	var/obj/item/shovel/S = new (R.module)
	R.module.basic_modules += S
	R.module.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	module_type = /obj/item/robot_module/miner

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	for(var/obj/item/storage/bag/ore/cyborg/S in R.module)
		R.module.remove_module(S, TRUE)
	var/obj/item/storage/bag/ore/holding/H = new /obj/item/storage/bag/ore/holding(R.module)
	R.module.basic_modules += H
	R.module.add_module(H, FALSE, TRUE)

/obj/item/borg/upgrade/soh/deactivate(mob/living/silicon/robot/R)
	. = ..()
	for(var/obj/item/storage/bag/ore/holding/H in R.module)
		R.module.remove_module(H, TRUE)
	var/obj/item/storage/bag/ore/cyborg/S = new (R.module)
	R.module.basic_modules += S
	R.module.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/tboh
	name = "janitor cyborg trash bag of holding"
	desc = "A trash bag of holding replacement for the janiborg's standard trash bag."
	icon_state = "cyborg_upgrade3"
	module_type = /obj/item/robot_module/janitor

/obj/item/borg/upgrade/tboh/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	for(var/obj/item/storage/bag/trash/cyborg/TB in R.module.modules)
		R.module.remove_module(TB, TRUE)
	var/obj/item/storage/bag/trash/bluespace/cyborg/B = new /obj/item/storage/bag/trash/bluespace/cyborg(R.module)
	R.module.basic_modules += B
	R.module.add_module(B, FALSE, TRUE)

/obj/item/borg/upgrade/tboh/deactivate(mob/living/silicon/robot/R)
	for(var/obj/item/storage/bag/trash/bluespace/cyborg/B in R.module.modules)
		R.module.remove_module(B, TRUE)
	var/obj/item/storage/bag/trash/cyborg/TB = new (R.module)
	R.module.basic_modules += TB
	R.module.add_module(TB, FALSE, TRUE)

/obj/item/borg/upgrade/amop
	name = "janitor cyborg advanced mop"
	desc = "An advanced mop replacement for the janiborg's standard mop."
	icon_state = "cyborg_upgrade3"
	module_type = /obj/item/robot_module/janitor

/obj/item/borg/upgrade/amop/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	for(var/obj/item/mop/cyborg/M in R.module.modules)
		R.module.remove_module(M, TRUE)
	var/obj/item/mop/advanced/cyborg/A = new /obj/item/mop/advanced/cyborg(R.module)
	R.module.basic_modules += A
	R.module.add_module(A, FALSE, TRUE)

/obj/item/borg/upgrade/amop/deactivate(mob/living/silicon/robot/R)
	. = ..()
	for(var/obj/item/mop/advanced/cyborg/A in R.module.modules)
		R.module.remove_module(A, TRUE)
	var/obj/item/mop/cyborg/M = new (R.module)
	R.module.basic_modules += M
	R.module.add_module(M, FALSE, TRUE)

/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	if(R.emagged)
		return "<span class='warning'>This unit is already hacked!</span>"
	R.SetEmagged(TRUE)

/obj/item/borg/upgrade/syndicate/deactivate(mob/living/silicon/robot/R)
	. = ..()
	R.SetEmagged(FALSE)

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof tracks"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to mining cyborg tracks, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	module_type = /obj/item/robot_module/miner

/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	R.weather_immunities += "lava"

/obj/item/borg/upgrade/lavaproof/deactivate(mob/living/silicon/robot/R)
	. = ..()
	R.weather_immunities -= "lava"

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "cyborg_upgrade5"
	robot_upgrade_flags = R_UPGRADE_IS_HIGHLANDER
	var/repair_amount = -1
	var/repair_tick = 1
	var/msg_cooldown = 0
	var/on = FALSE
	var/powercost = 10
	var/datum/action/toggle_action

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	icon_state = "selfrepair_off"
	toggle_action = new /datum/action/item_action/toggle(src)
	toggle_action.Grant(R)

/obj/item/borg/upgrade/selfrepair/deactivate(mob/living/silicon/robot/R)
	. = ..()
	toggle_action.Remove(R)
	QDEL_NULL(toggle_action)
	deactivate_sr()

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	if(on)
		to_chat(toggle_action.owner, "<span class='notice'>You deactivate the self-repair module.</span>")
		deactivate_sr()
	else
		to_chat(toggle_action.owner, "<span class='notice'>You activate the self-repair module.</span>")
		activate_sr()


/obj/item/borg/upgrade/selfrepair/update_icon()
	if(toggle_action)
		icon_state = "selfrepair_[on ? "on" : "off"]"
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
	else
		icon_state = "cyborg_upgrade5"

/obj/item/borg/upgrade/selfrepair/proc/activate_sr()
	START_PROCESSING(SSobj, src)
	on = TRUE
	update_icon()

/obj/item/borg/upgrade/selfrepair/proc/deactivate_sr()
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	update_icon()

/obj/item/borg/upgrade/selfrepair/process()
	if(!repair_tick)
		repair_tick = 1
		return

	var/mob/living/silicon/robot/cyborg = toggle_action.owner

	if(istype(cyborg) && (cyborg.stat != DEAD) && on)
		if(!cyborg.cell)
			to_chat(cyborg, "<span class='warning'>Self-repair module deactivated. Please, insert the power cell.</span>")
			deactivate_sr()
			return

		if(cyborg.cell.charge < powercost * 2)
			to_chat(cyborg, "<span class='warning'>Self-repair module deactivated. Please recharge.</span>")
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
		repair_tick = 0

		if((world.time - 2000) > msg_cooldown )
			var/msgmode = "standby"
			if(cyborg.health < 0)
				msgmode = "critical"
			else if(cyborg.health < cyborg.maxHealth)
				msgmode = "normal"
			to_chat(cyborg, "<span class='notice'>Self-repair is active in <span class='boldnotice'>[msgmode]</span> mode.</span>")
			msg_cooldown = world.time
	else
		deactivate_sr()

/obj/item/borg/upgrade/hypospray
	name = "medical cyborg hypospray advanced synthesiser"
	desc = "An upgrade to the Medical module cyborg's hypospray, allowing it \
		to produce more advanced and complex medical reagents."
	icon_state = "cyborg_upgrade3"
	module_type = /obj/item/robot_module/medical
	robot_upgrade_flags = R_UPGRADE_IS_HIGHLANDER
	var/list/additional_reagents = list()

/obj/item/borg/upgrade/hypospray/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
		if(H.accepts_reagent_upgrades)
			for(var/re in additional_reagents)
				H.add_reagent(re)

/obj/item/borg/upgrade/hypospray/deactivate(mob/living/silicon/robot/R)
	. = ..()
	for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
		if(H.accepts_reagent_upgrades)
			for(var/re in additional_reagents)
				H.del_reagent(re)

/obj/item/borg/upgrade/hypospray/expanded
	name = "medical cyborg expanded hypospray"
	desc = "An upgrade to the Medical module's hypospray, allowing it \
		to treat a wider range of conditions and problems."
	additional_reagents = list(/datum/reagent/medicine/mannitol, /datum/reagent/medicine/oculine, /datum/reagent/medicine/inacusiate,
		/datum/reagent/medicine/mutadone, /datum/reagent/medicine/haloperidol, /datum/reagent/medicine/oxandrolone, /datum/reagent/medicine/sal_acid, 
		/datum/reagent/medicine/rezadone, /datum/reagent/medicine/pen_acid)

/obj/item/borg/upgrade/piercing_hypospray
	name = "cyborg piercing hypospray"
	desc = "An upgrade to a cyborg's hypospray, allowing it to \
		pierce armor and thick material."
	icon_state = "cyborg_upgrade3"
	robot_upgrade_flags = R_UPGRADE_IS_HIGHLANDER

/obj/item/borg/upgrade/piercing_hypospray/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	var/found_hypo = FALSE
	for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
		H.bypass_protection = TRUE
		found_hypo = TRUE

	if(!found_hypo)
		return "<span class='warning'>This unit does not have any hyposprays.</span>"

/obj/item/borg/upgrade/piercing_hypospray/deactivate(mob/living/silicon/robot/R)
	for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
		H.bypass_protection = initial(H.bypass_protection)

/obj/item/borg/upgrade/defib
	name = "medical cyborg defibrillator"
	desc = "An upgrade to the Medical module, installing a built-in \
		defibrillator, for on the scene revival."
	icon_state = "cyborg_upgrade3"
	module_type = /obj/item/robot_module/medical

/obj/item/borg/upgrade/defib/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	var/obj/item/twohanded/shockpaddles/cyborg/S = new(R.module)
	R.module.basic_modules += S
	R.module.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/defib/deactivate(mob/living/silicon/robot/R)
	. = ..()
	var/obj/item/twohanded/shockpaddles/cyborg/S = locate() in R.module
	R.module.remove_module(S, TRUE)

/obj/item/borg/upgrade/processor
	name = "medical cyborg surgical processor"
	desc = "An upgrade to the Medical module, installing a processor \
		capable of scanning surgery disks and carrying \
		out procedures"
	icon_state = "cyborg_upgrade3"
	module_type = /obj/item/robot_module/medical

/obj/item/borg/upgrade/processor/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	var/obj/item/surgical_processor/SP = new(R.module)
	R.module.basic_modules += SP
	R.module.add_module(SP, FALSE, TRUE)

/obj/item/borg/upgrade/processor/deactivate(mob/living/silicon/robot/R)
	var/obj/item/surgical_processor/SP = locate() in R.module
	R.module.remove_module(SP, TRUE)

/obj/item/borg/upgrade/ai
	name = "B.O.R.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon_state = "boris"

/obj/item/borg/upgrade/ai/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	if(R.shell)
		return "<span class='warning'>This unit is already an AI shell!</span>"
	if(R.key) //You cannot replace a player unless the key is completely removed.
		return "<span class='warning'>Intelligence patterns detected in this [R.braintype]. Aborting.</span>"
	R.make_shell(src)

/obj/item/borg/upgrade/ai/deactivate(mob/living/silicon/robot/R)
	. = ..()
	if(R.shell)
		R.undeploy()
		R.notify_ai(AI_SHELL)

/obj/item/borg/upgrade/expand
	name = "borg expander"
	desc = "A cyborg resizer, it makes a cyborg huge."
	icon_state = "cyborg_upgrade3"
	robot_upgrade_flags = R_UPGRADE_IS_HIGHLANDER

/obj/item/borg/upgrade/expand/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	var/prev_lockcharge = R.lockcharge
	R.SetLockdown(1)
	R.resize = 2
	R.update_transform()
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, R.loc)
	smoke.start()
	for(var/i in 1 to 4) //This is where the fun begins
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, R, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1), 2 + 12 * i)
	addtimer(CALLBACK(R, /mob/living/silicon/robot/proc/SetLockdown, prev_lockcharge), 50)

/obj/item/borg/upgrade/expand/deactivate(mob/living/silicon/robot/R)
	. = ..()
	R.resize = 0.5
	R.update_transform()

/obj/item/borg/upgrade/rped
	name = "engineering cyborg RPED"
	desc = "A rapid part exchange device for the engineering cyborg."
	icon = 'icons/obj/storage.dmi'
	icon_state = "borgrped"
	module_type = /obj/item/robot_module/engineering
	robot_upgrade_flags = R_UPGRADE_IS_HIGHLANDER

/obj/item/borg/upgrade/rped/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	var/obj/item/storage/part_replacer/cyborg/RPED = new(R.module)
	R.module.basic_modules += RPED
	R.module.add_module(RPED, FALSE, TRUE)

/obj/item/borg/upgrade/rped/deactivate(mob/living/silicon/robot/R)
	. = ..()
	var/obj/item/storage/part_replacer/cyborg/RPED = locate() in R.module
	if (RPED)
		R.module.remove_module(RPED, TRUE)

/obj/item/borg/upgrade/pinpointer
	name = "medical cyborg crew pinpointer"
	desc = "A crew pinpointer module for the medical cyborg."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer_crew"
	module_type = /obj/item/robot_module/medical
	robot_upgrade_flags = R_UPGRADE_IS_HIGHLANDER

/obj/item/borg/upgrade/pinpointer/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	var/obj/item/pinpointer/crew/PP = new(R.module)
	R.module.basic_modules += PP
	R.module.add_module(PP, FALSE, TRUE)

/obj/item/borg/upgrade/pinpointer/deactivate(mob/living/silicon/robot/R)
	var/obj/item/pinpointer/crew/PP = locate() in R.module
	if (PP)
		R.module.remove_module(PP, TRUE)

/obj/item/borg/upgrade/transform
	name = "borg module picker (Standard)"
	desc = "Allows you to to turn a cyborg into a standard cyborg."
	icon_state = "cyborg_upgrade3"
	var/obj/item/robot_module/new_module = /obj/item/robot_module/standard

/obj/item/borg/upgrade/transform/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		return
	R.module.transform_to(new_module)

/obj/item/borg/upgrade/transform/clown
	name = "borg module picker (Clown)"
	desc = "Allows you to to turn a cyborg into a clown, honk."
	icon_state = "cyborg_upgrade3"
	new_module = /obj/item/robot_module/clown
