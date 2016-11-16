// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	origin_tech = "programming=2"
	var/locked = 0
	var/installed = 0
	var/require_module = 0
	var/module_type = null

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		usr << "<span class='notice'>[src] will not function on a deceased cyborg.</span>"
		return 1
	if(module_type && !istype(R.module, module_type))
		R << "Upgrade mounting error!  No suitable hardpoint detected!"
		usr << "There's no mounting point for the module!"
		return 1

/obj/item/borg/upgrade/reset
	name = "cyborg module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the cyborg."
	icon_state = "cyborg_upgrade1"
	require_module = 1

/obj/item/borg/upgrade/reset/action(mob/living/silicon/robot/R)
	if(..())
		return

	R.ResetModule()

	return 1

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "default name"

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(mob/living/silicon/robot/R)
	if(..())
		return

	R.fully_replace_character_name(R.name, heldname)

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

	R.revive()

	return 1

/obj/item/borg/upgrade/vtec
	name = "cyborg VTEC module"
	desc = "Used to kick in a cyborg's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = 1
	origin_tech = "engineering=4;materials=5;programming=4"

/obj/item/borg/upgrade/vtec/action(mob/living/silicon/robot/R)
	if(..())
		return
	if(R.speed < 0)
		R << "<span class='notice'>A VTEC unit is already installed!</span>"
		usr << "<span class='notice'>There's no room for another VTEC unit!</span>"
		return

	R.speed = -2 // Gotta go fast.

	return 1

/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/security
	origin_tech = "engineering=4;powerstorage=4;combat=4"

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/R)
	if(..())
		return

	var/obj/item/weapon/gun/energy/disabler/cyborg/T = locate() in R.module.modules
	if(!T)
		usr << "<span class='notice'>There's no disabler in this unit!</span>"
		return
	if(T.charge_delay <= 2)
		R << "<span class='notice'>A cooling unit is already installed!</span>"
		usr << "<span class='notice'>There's no room for another cooling unit!</span>"
		return

	T.charge_delay = max(2 , T.charge_delay - 4)

	return 1

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "A energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;powerstorage=4"

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/R)
	if(..())
		return

	if(R.ionpulse)
		usr << "<span class='notice'>This unit already has ion thrusters installed!</span>"
		return

	R.ionpulse = TRUE
	return 1

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner
	origin_tech = "engineering=4;materials=5"

/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/weapon/pickaxe/drill/cyborg/D in R.module)
		R.module.remove_module(D, TRUE)
	for(var/obj/item/weapon/shovel/S in R.module)
		R.module.remove_module(S, TRUE)

	var/obj/item/weapon/pickaxe/drill/cyborg/diamond/DD = new /obj/item/weapon/pickaxe/drill/cyborg/diamond(R.module)
	R.module.basic_modules += DD
	R.module.add_module(DD, FALSE, TRUE)
	return 1

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner
	origin_tech = "engineering=4;materials=4;bluespace=4"

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/weapon/storage/bag/ore/cyborg/S in R.module)
		R.module.remove_module(S, TRUE)

	var/obj/item/weapon/storage/bag/ore/holding/H = new /obj/item/weapon/storage/bag/ore/holding(R.module)
	R.module.basic_modules += H
	R.module.add_module(H, FALSE, TRUE)
	return 1

/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg"
	icon_state = "cyborg_upgrade3"
	require_module = 1
	origin_tech = "combat=4;syndicate=1"

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/R)
	if(..())
		return

	if(R.emagged)
		return

	R.SetEmagged(1)

	return 1

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof tracks"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to mining cyborg tracks, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_module = 1
	module_type = /obj/item/weapon/robot_module/miner
	origin_tech = "engineering=4;materials=4;plasmatech=4"

/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/R)
	if(..())
		return
	R.weather_immunities += "lava"
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
		return

	var/obj/item/borg/upgrade/selfrepair/U = locate() in R
	if(U)
		usr << "<span class='warning'>This unit is already equipped with a self-repair module.</span>"
		return 0

	cyborg = R
	icon_state = "selfrepair_off"
	var/datum/action/A = new /datum/action/item_action/toggle(src)
	A.Grant(R)
	return 1

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	on = !on
	if(on)
		cyborg << "<span class='notice'>You activate the self-repair module.</span>"
		START_PROCESSING(SSobj, src)
	else
		cyborg << "<span class='notice'>You deactivate the self-repair module.</span>"
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/item/borg/upgrade/selfrepair/update_icon()
	if(cyborg)
		icon_state = "selfrepair_[on ? "on" : "off"]"
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
	else
		icon_state = "cyborg_upgrade5"

/obj/item/borg/upgrade/selfrepair/proc/deactivate()
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	update_icon()

/obj/item/borg/upgrade/selfrepair/process()
	if(!repair_tick)
		repair_tick = 1
		return

	if(cyborg && (cyborg.stat != DEAD) && on)
		if(!cyborg.cell)
			cyborg << "<span class='warning'>Self-repair module deactivated. Please, insert the power cell.</span>"
			deactivate()
			return

		if(cyborg.cell.charge < powercost * 2)
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

		if((world.time - 2000) > msg_cooldown )
			var/msgmode = "standby"
			if(cyborg.health < 0)
				msgmode = "critical"
			else if(cyborg.health < cyborg.maxHealth)
				msgmode = "normal"
			cyborg << "<span class='notice'>Self-repair is active in <span class='boldnotice'>[msgmode]</span> mode.</span>"
			msg_cooldown = world.time
	else
		deactivate()
