// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "A borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/construction_time = 120
	var/construction_cost = list("metal"=10000)
	var/locked = 0
	var/require_module = 0
	var/installed = 0
	w_type=RECYK_ELECTRONIC

/obj/item/borg/upgrade/recycle(var/datum/materials/rec)
	for(var/material in construction_cost)
		var/rec_mat=material
		var/CCPS=CC_PER_SHEET_MISC
		if(rec_mat=="metal")
			rec_mat="iron"
			CCPS=CC_PER_SHEET_METAL
		if(rec_mat=="glass")
			CCPS=CC_PER_SHEET_GLASS
		rec.addAmount(material,construction_cost[material]/CCPS)
	return w_type

/obj/item/borg/upgrade/proc/action(var/mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		usr << "\red The [src] will not function on a deceased robot."
		return 1
	if(isMoMMI(R))
		usr << "\red The [src] only functions on Nanotrasen Cyborgs."
	return 0



// Medical Cyborg Stuff

/obj/item/borg/upgrade/medical/surgery
	name = "medical module board"
	desc = "Used to give a medical cyborg advanced care tools."
	icon_state = "cyborg_upgrade"
	construction_cost = list("metal"=80000 , "glass"=6000)
	require_module = 1

/obj/item/borg/upgrade/medical/surgery/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	if(!istype(R.module, /obj/item/weapon/robot_module/medical))
		R << "Upgrade mounting error!  This module is reserved for medical modules!"
		usr << "There's no mounting point for the module!"
		return 0
	else
/*		R.module.modules += new/obj/item/weapon/circular_saw
		R.module.modules += new/obj/item/weapon/scalpel
		R.module.modules += new/obj/item/weapon/bonesetter
		R.module.modules += new/obj/item/weapon/bonegel // Requested by Hoshi-chan
		R.module.modules += new/obj/item/weapon/FixOVein
		R.module.modules += new/obj/item/weapon/surgicaldrill
		R.module.modules += new/obj/item/weapon/cautery
		R.module.modules += new/obj/item/weapon/hemostat
		R.module.modules += new/obj/item/weapon/retractor*/
		R.module.modules += new/obj/item/weapon/melee/defibrillator
		R.module.modules += new /obj/item/weapon/reagent_containers/borghypo/upgraded(src)

		return 1

// End of Medical Cyborg Stuff

/obj/item/borg/upgrade/reset
	name = "robotic module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the robot."
	icon_state = "cyborg_upgrade1"
	require_module = 1

/obj/item/borg/upgrade/reset/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	R.uneq_all()
	R.hands.icon_state = "nomod"
	R.icon_state = "robot"
	R.base_icon = "robot"
	del(R.module)
	R.module = null
	R.camera.network.Remove(list("Engineering","Medical","MINE"))
	R.updatename("Default")
	R.status_flags |= CANPUSH
	R.updateicon()
	R.luminosity = 0 //flashlight fix

	return 1

/obj/item/borg/upgrade/rename
	name = "robot reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	construction_cost = list("metal"=35000)
	var/heldname = "default name"

/obj/item/borg/upgrade/rename/attack_self(mob/user as mob)
	heldname = stripped_input(user, "Enter new robot name", "Robot Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	R.name = heldname
	R.custom_name = heldname
	R.real_name = heldname

	return 1

/obj/item/borg/upgrade/restart
	name = "robot emergency restart module"
	desc = "Used to force a restart of a disabled-but-repaired robot, bringing it back online."
	construction_cost = list("metal"=60000 , "glass"=5000)
	icon_state = "cyborg_upgrade1"


/obj/item/borg/upgrade/restart/action(var/mob/living/silicon/robot/R)
	if(R.health < 0)
		usr << "You have to repair the robot before using this module!"
		return 0

	if(!R.key)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	R.stat = CONSCIOUS
	return 1


/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	construction_cost = list("metal"=80000 , "glass"=6000 , "gold"= 5000)
	icon_state = "cyborg_upgrade2"
	require_module = 1

/obj/item/borg/upgrade/vtec/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.speed == -1)
		return 0

	R.speed--
	return 1


/obj/item/borg/upgrade/tasercooler
	name = "robotic Rapid Taser Cooling Module"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate."
	construction_cost = list("metal"=80000 , "glass"=6000 , "gold"= 2000, "diamond" = 500)
	icon_state = "cyborg_upgrade3"
	require_module = 1


/obj/item/borg/upgrade/tasercooler/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!istype(R.module, /obj/item/weapon/robot_module/security))
		R << "Upgrade mounting error!  No suitable hardpoint detected!"
		usr << "There's no mounting point for the module!"
		return 0

	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
	if(!T)
		T = locate() in R.module.modules
	if(!T)
		usr << "This robot has had its taser removed!"
		return 0

	if(T.recharge_time <= 2)
		R << "Maximum cooling achieved for this hardpoint!"
		usr << "There's no room for another cooling unit!"
		return 0

	else
		T.recharge_time = max(2 , T.recharge_time - 4)

	return 1

/obj/item/borg/upgrade/jetpack
	name = "mining robot jetpack"
	desc = "A carbon dioxide jetpack suitable for low-gravity mining operations."
	construction_cost = list("metal"=10000,"plasma"=15000,"uranium" = 20000)
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/jetpack/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!istype(R.module, /obj/item/weapon/robot_module/miner)&&!isMoMMI(R))
		R << "Upgrade mounting error!  No suitable hardpoint detected!"
		usr << "There's no mounting point for the module!"
		return 0
	else
		R.module.modules += new/obj/item/weapon/tank/jetpack/carbondioxide
		for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
			R.internals = src
		//R.icon_state="Miner+j"
		return 1


/obj/item/borg/upgrade/syndicate/
	name = "Illegal Equipment Module"
	desc = "Unlocks the hidden, deadlier functions of a robot"
	construction_cost = list("metal"=10000,"glass"=15000,"diamond" = 10000)
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/syndicate/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.emagged == 1)
		return 0

	R.emagged = 1
	return 1