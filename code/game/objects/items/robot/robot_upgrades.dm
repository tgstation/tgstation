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
	origin_tech = "engineering=4;materials=4;bluespace=4"

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/R)
	if(..())
		return

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
	var/repair_amount = 1
	var/repair_amount_crit = 2.5
	var/repair_delay = 1
	var/repair_tick = 0
	var/msg_cooldown = 0
	var/on = 0
	var/powercost_normal = 10
	var/powercost_crit = 30
	var/powercost_passive = 5
	var/power_threshold = 300
	var/mob/living/silicon/robot/cyborg

/obj/item/borg/upgrade/selfrepair/peacekeeper
	name = "repair swarm"
	power_threshold = 1000
	repair_delay = 0
	powercost_normal = 30
	powercost_crit = 60
	powercost_passive = 0

/obj/item/borg/upgrade/selfrepair/peacekeeper/process()
	if(cyborg.emagged)
		cyborg << "<span class='userdanger'>WARNING: Repair controller driver not found at /syndiOS/modules/drivers.</span>"	//This is shit I know.
		deactivate()
	..()

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
	if(repair_tick)
		repair_tick--
		return

	if(cyborg && (cyborg.stat != DEAD) && on && !repair_tick)
		if(!cyborg.cell)
			cyborg << "<span class='warning'>Self-repair module deactivated. Please, insert the power cell.</span>"
			deactivate()
			return

		if(cyborg.cell.charge < power_threshold)
			cyborg << "<span class='warning'>Self-repair module deactivated. Please recharge.</span>"
			deactivate()
			return

		if(cyborg.health < cyborg.maxHealth)
			var/powercost = 10
			var/repair = 1
			if(cyborg.health < 0)
				repair = -repair_amount_crit
				powercost = powercost_crit
			else
				repair = -repair_amount
				powercost = powercost_normal
			cyborg.adjustBruteLoss(repair)
			cyborg.adjustFireLoss(repair)
			cyborg.updatehealth()
			cyborg.cell.use(powercost)
		else
			cyborg.cell.use(powercost_passive)
		repair_tick = repair_delay

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

//None/Flashes cause blindness/Flashes cause nearsightedness/Flashes cause blurring/Flashes completely blocked
#define FLASH_PROTECTION_NONE 0
#define FLASH_PROTECTION_BLIND 1
#define FLASH_PROTECTION_NEAR 2
#define FLASH_PROTECTION_BLUR 3
#define FLASH_PROTECTION_FULL 4

//None/Stays active when EMPed and blocks cell damage/Lessens EMP by one severity degree/Blocks EMPs
#define EMP_PROTECTION_NONE 0
#define EMP_PROTECTION_IGNORE 1
#define EMP_PROTECTION_LESSEN 2
#define EMP_PROTECTION_FULL 3

/obj/item/borg/upgrade/shield
	name = "Combat Energy Shielding"
	desc = "Advanced energy shielding that draws directly from a cyborg's internal power cell to provide shielding against hostile forces."
	icon_state = "cyborg_upgrade5"
	/*var/activatingoverlay =
	var/deactivatingoverlay =
	var/activeoverlay =
	var/flickeroverlay =*/
	var/active = 0
	var/passivepower = 10	//Passively use this amount of power when active per process() tick.

	var/flashprotect = FLASH_PROTECTION_NONE
	var/maxflashprotect = FLASH_PROTECTION_BLUR
	var/flashprotectpower = 300				//On flash, consume: flashprotectpower + (flashprotectadd * (flashprotect - 1) * flashprotectmultiplier)
	var/flashprotectadd = 200
	var/flashprotectmultiplier = 1
	var/flashprotectbuffer = 10				//Buffer: The shield can not protect from as many flashes as you think, this is to prevent bluespace cell'd bots from being immune to everything.
	var/flashprotectbufferheal = 0.25

	var/empprotect = EMP_PROTECTION_NONE
	var/maxempprotect = EMP_PROTECTION_LESSEN
	var/empprotectpower = 500				//Same as above
	var/empprotectadd = 1000
	var/empprotectmultiplier = 1
	var/empprotectbuffer = 5
	var/empprotectbufferheal = 0.25

	var/damagemitigation = 0
	var/damagemultiplier = 1				//Actual damage mitigation multiplier, (1 - damagemitigation/100)
	var/damagemitigationmax = 80
	var/damagehitpower = 50					//Base mitigation power cost
	var/damagepowermultiplier = 20			//Damage blocked * multiplier = power used. At 100% mitigation and 20 burn laser with 20 multiplier, 1.00 * 20 * 20 = 400 + 50(per hit base power) = 450 power used

	var/activationdelay = 10				//How long it takes to activate
	var/activationmovementallow = TRUE		//Whether moving will interrupt activation
	var/activationmovementpenalty = 20		//How longer it will take if you move
	var/allowmoduleuse = TRUE				//Can you use modules?
	var/modulewhitelistcheck = FALSE		//Can you use only whitelisted modules?
	var/modulemitigationpenalty = 10		//Mitigation reduction per active module
	var/modulepowerpenalty = 20				//Power use per active module

	var/powercutthreshold = 800

	var/mob/living/silicon/robot/user

/obj/item/borg/upgrade/shield/examine(mob/M)
	..()

/obj/item/borg/upgrade/shield/action(mob/living/silicon/robot/R)
	if(..())
		return

	var/obj/item/borg/upgrade/shield/S = locate() in R
	if(S)
		usr << "<span class='warning'>This unit is already equipped with a combat shielding module.</span>"
		return 0
	/*
	icon_state = "selfrepair_off"
	var/datum/action/A = new /datum/action/item_action/toggle(src)
	A.Grant(R)
	*/



	user = R

/obj/item/borg/upgrade/shield/process()
	if(!active)
		STOP_PROCESSING(SSObj, src)
		return
	processpoweruse()
	processmitigation()
	processHUD()
	handlebuffer()
	updateicon()

/obj/item/borg/upgrade/shield/proc/activemodulecount()
	var/penalty = 0
	if(user.module_state_1)
		penalty++
	if(user.module_state_2)
		penalty++
	if(user.module_state_3)
		penalty++
	return penalty

/obj/item/borg/upgrade/shield/proc/processpoweruse()
	var/power = user.cell.charge
	user.cell.use(passivepower)
	if(modulepowerpenalty)
		user.cell.use((activemodulecount()*modulepowerpenalty))
	if(power < powercutthreshold)
		if(activationmovementallow)
			deactivate()
		else
			user << "<span class='userdanger'>WARNING: CELL VOLTAGE CRITICAL. DEACTIVATING ENERGY SHI-ZZZZZZzzzz....</span>"
			deactivate(1)

/obj/item/borg/upgrade/shield/proc/processmitigation()
	var/multiplier = 1
	var/mitigation = damagemitigation
	mitigation -= (activemodulecount() * modulemitigationpenalty)
	multiplier = Clamp((1 - (mitigation/100)), 0, 1)
	damagemultiplier = multiplier

/obj/item/borg/upgrade/shield/proc/activate(force = 0)
	//SOUND EFFECT
	//ACTIVATING OVERLAYS
	user << "<span class='boldnotice'>Energizing energy shielding. Please remain still...</span>"
	if(!force)
		sleep(activationdelay)
		if(user.cell.charge < powercutthreshold)
			user << "<span class='boldwarning'>WARNING: Insufficient cell power to maintain shielding.</span>"
			return 0
		if(!do_after(user, activationdelay))
			user << "<span class='boldwarning'>WARNING: Calculated offsets disrupted by movement.</span>"
			if(activationmovementallow)
				user << "<span class='boldnotice'>Compensating for movement. This will take longer...</span>"
				sleep(activationmovementpenalty)
			else
				return 0
			if(!activationmovementpenalty)
				user << "<span class='boldnotice'>Automatically compensated for movement. Resuming... </span>"
	active = 1
	START_PROCESSING(SSObj, src)
	//DELETE ACTIVATING OVERLAYS
	//ACTIVE OVERLAYS
	var/power = "weak"
	if(damagemitigationmax > 75)
		power = "powerful"
	if(maxempprotect > EMP_PROTECTION_NONE)
		power += " magnetically charged"
	if(maxflashprotect > FLASH_PROTECTION_NONE)
		power += " photonically reactive"
	user << "<span class='boldnotice'>Energy shielding at full integrity!</span>"
	user.visible_message("<span class='warning'>[user]'s chassis projects a [power] energy shield around them!</span>")
	//SOUND EFFECT
	return 1

/obj/item/borg/upgrade/shield/proc/deactivate(force = 0)
	//SOUND EFFECT
	if(force)
		user << "<span class='boldwarning'>WARNING: Energy shield collapsing! ZZZZZzzzzTTtttt....</span>"
		user.visible_message("<span class='warning'>[user]'s energy shielding collapses in a burst of sparks!</span>")
		user.spark_system.start()
	else
		user << "<span class='boldnotice'>Energy shield discharging! Please remain still!</span>"
		//DEACTIVATING OVERLAY
		//DELETE ORIGINAL OVERLAY
		sleep(activationdelay)
		if(!do_after(user, activationdelay) && !activationmovementallow)
			user << "<span class='boldwarning'>WARNING: Energy shield can not deactivate while chassis is in motion. Doing so will result in shield collapse and power overload!</span>"
			//RETURN ORIGINAL OVERLAY
			//DELETE DEACTIVATION OVERLAY
			return 0
		user.visible_message("<span class='warning'>[user]'s energy shielding discharges in a flash of light!</span>")
	user << "<span class='boldnotice'>Energy Combat Shield discharged!</span>"

	active = 0
	STOP_PROCESSING(SSObj, src)
	//DELETE OVERLAYS
	//SOUND EFFECT

/obj/item/borg/upgrade/shield/peacekeeper
	name = "cyborg riot shield"
	desc = "For when you need to be a punching bag, AND not die in the process."
	maxflashprotect = FLASH_PROTECTION_BLIND	//Shouldn't be TOO unbalanced.
	maxempprotect = EMP_PROTECTION_NONE	//RIP, EMPs still hard counter the poor eggbots.
	damagemitigationmax = 70
	damagepowermultiplier = 25
	activationdelay = 20
	activationmovementpenalty = 30
	modulewhitelistcheck = TRUE
	modulemitigationpenalty = 5
	modulepowerpenalty = 10


