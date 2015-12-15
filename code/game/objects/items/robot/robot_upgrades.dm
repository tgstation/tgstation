	// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	origin_tech = "programming=4"
	var/locked = 0
	var/require_module = 0
	var/installed = 0
	var/module_type = null

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		usr << "<span class='notice'>[src] will not function on a deceased cyborg.</span>"
		return 1
	if(module_type && !istype(R.module, module_type))
		R << "Upgrade mounting error!  No suitable hardpoint detected!"
		usr << "There's no mounting point for the module!"
		return 1
	return 0

/obj/item/borg/upgrade/reset
	name = "cyborg module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the cyborg."
	icon_state = "cyborg_upgrade1"
	require_module = 1

/obj/item/borg/upgrade/reset/action(mob/living/silicon/robot/R)
	if(..()) return 0
	R.uneq_all()
	R.hands.icon_state = "nomod"
	R.icon_state = "robot"
	qdel(R.module)
	R.module = null
	R.modtype = "robot"
	R.updatename("Default")
	R.status_flags |= CANPUSH
	R.designation = "Default"
	R.notify_ai(2)
	R.update_icons()
	R.update_headlamp()
	R.magpulse = 0

	return 1


/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "default name"

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(mob/living/silicon/robot/R)
	if(..()) return 0
	R.notify_ai(3, R.name, heldname)
	R.name = heldname
	R.real_name = heldname
	R.camera.c_tag = heldname
	R.custom_name = heldname //Required or else if the cyborg's module changes, their name is lost.

	return 1


/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/R)
	if(R.health < 0)
		usr << "<span class='warning'>You have to repair the cyborg before using this module!</span>"
		return 0

	if(!R.key)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	R.stat = CONSCIOUS
	dead_mob_list -= R //please never forget this ever kthx
	living_mob_list += R
	R.notify_ai(1)

	return 1


/obj/item/borg/upgrade/vtec
	name = "cyborg VTEC module"
	desc = "Used to kick in a cyborg's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = 1
	origin_tech = "engineering=4;materials=5"

/obj/item/borg/upgrade/vtec/action(mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.speed == -1)
		return 0

	R.speed--
	return 1


/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/security
	origin_tech = "engineering=4;powerstorage=4"

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/R)
	if(..()) return 0

	var/obj/item/weapon/gun/energy/disabler/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
	if(!T)
		T = locate() in R.module.modules
	if(!T)
		usr << "This cyborg has had its disabler removed!"
		return 0

	if(T.charge_delay <= 2)
		R << "Maximum cooling achieved for this hardpoint!"
		usr << "There's no room for another cooling unit!"
		return 0

	else
		T.charge_delay = max(2 , T.charge_delay - 4)

	return 1


/obj/item/borg/upgrade/jetpack
	name = "mining cyborg jetpack"
	desc = "A carbon dioxide jetpack suitable for low-gravity mining operations."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner
	origin_tech = "engineering=4;powerstorage=4"

/obj/item/borg/upgrade/jetpack/action(mob/living/silicon/robot/R)
	if(..()) return 0

	R.module.modules += new/obj/item/weapon/tank/jetpack/carbondioxide(R.module)
	for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
		R.internals = src
	R.jetpackoverlay = 1
	R.module.rebuild()
	return 1


/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner
	origin_tech = "engineering=5;materials=5"

/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/R)
	if(..()) return 0

	for(var/obj/item/weapon/pickaxe/drill/cyborg/D in R.module.modules)
		qdel(D)
	for(var/obj/item/weapon/shovel/S in R.module.modules)
		qdel(S)
	R.module.modules += new /obj/item/weapon/pickaxe/drill/cyborg/diamond(R.module)
	R.module.rebuild()
	return 1


/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner
	origin_tech = "engineering=5;materials=5;bluespace=3"

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/R)
	if(..()) return 0

	for(var/obj/item/weapon/storage/bag/ore/cyborg/S in R.module.modules)
		qdel(S)
	R.module.modules += new /obj/item/weapon/storage/bag/ore/holding(R.module)
	R.module.rebuild()
	return 1


/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg"
	icon_state = "cyborg_upgrade3"
	require_module = 1
	origin_tech = "combat=4;syndicate=2"

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.emagged == 1)
		return 0

	R.SetEmagged(1)
	return 1

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "cyborg_upgrade5"
	require_module = 1
	var/repair_amount = -1
	var/repair_tick = 1
	var/msg_cooldown = 0
	var/on = 0
	var/powercost = 10
	var/mob/living/silicon/robot/cyborg

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/R)
	if(..())
		return 0
	var/obj/item/borg/upgrade/selfrepair/U = locate() in R
	if(U)
		usr << "<span class='warning'>This unit is already equipped with a self-repair module.</span>"
		return 0
	cyborg = R
	icon_state = "selfrepair_off"
	action_button_name = "Toggle Self-Repair"
	return 1

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	on = !on
	if(on)
		cyborg << "<span class='notice'>You activate the self-repair module.</span>"
		SSobj.processing |= src
	else
		cyborg << "<span class='notice'>You deactivate the self-repair module.</span>"
		SSobj.processing -= src
	update_icon()

/obj/item/borg/upgrade/selfrepair/update_icon()
	if(cyborg)
		icon_state = "selfrepair_[on ? "on" : "off"]"
	else
		icon_state = "cyborg_upgrade5"

/obj/item/borg/upgrade/selfrepair/proc/deactivate()
	SSobj.processing -= src
	on = 0
	update_icon()

/obj/item/borg/upgrade/selfrepair/process()
	if(!repair_tick)
		repair_tick = 1
		return

	if( cyborg && (cyborg.stat != DEAD) && on)
		if(cyborg.cell.charge < powercost*2)
			cyborg << "<span class='warning'>Self-repair module deactivated. Please recharge.</span>"
			deactivate()
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

		if( (world.time - 2000) > msg_cooldown )
			var/msgmode = "standby"
			if(cyborg.health < 0)
				msgmode = "critical"
			else if(cyborg.health < cyborg.maxHealth)
				msgmode = "normal"
			cyborg << "<span class='notice'>Self-repair is active in <span class='boldnotice'>[msgmode]</span> mode.</span>"
			msg_cooldown = world.time
	else
		deactivate()
