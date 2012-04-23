// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade/
	name = "A borg upgrade module."
	desc = "Protected by FRM."
	icon = 'module.dmi'
	icon_state = "id_mod"
	var/construction_time = 120
	var/construction_cost = list("metal"=10000)
	var/locked = 0
	var/require_module = 0
	var/installed = 0

/obj/item/borg/upgrade/proc/action()
	return


/obj/item/borg/upgrade/reset/
	name = "Borg module reset board"
	desc = "Used to reset a borg's module. Destroys any other upgrades applied to the borg."
	require_module = 1

/obj/item/borg/upgrade/reset/action(var/mob/living/silicon/robot/R)
	R.uneq_all()
	R.hands.icon_state = "nomod"
	R.icon_state = "robot"
	del(R.module)
	R.module = null
	R.modtype = "robot"
	R.real_name = "Cyborg [R.ident]"
	R.name = R.real_name
	R.nopush = 0
	R.updateicon()

	return 1



/obj/item/borg/upgrade/flashproof/
	name = "Borg Flash-Supression"
	desc = "A highly advanced, complicated system for supressing incoming flashes directed at the borg's optical processing system."
	construction_cost = list("metal"=10000,"gold"=2000,"silver"=3000,"glass"=2000, "diamond"=5000)
	require_module = 1


/obj/item/borg/upgrade/flashproof/New()   // Why the fuck does the fabricator make a new instance of all the items?
	//desc = "Sunglasses with duct tape." // Why?  D:

/obj/item/borg/upgrade/flashproof/action(var/mob/living/silicon/robot/R)
	if(R.module)
		R.module += src

	return 1

/obj/item/borg/upgrade/restart/
	name = "Borg emergancy restart module"
	desc = "Used to force a restart of a disabled-but-repaired borg, bringing it back online."
	construction_cost = list("metal"=60000 , "glass"=5000)


/obj/item/borg/upgrade/restart/action(var/mob/living/silicon/robot/R)
	if(!R.key)
		for(var/mob/dead/observer/ghost in world)
			if(ghost.corpse == R && ghost.client)
				ghost.client.mob = ghost.corpse

	if(R.health < 0)
		usr << "You have to repair the borg before using this module!"
		return 0

	R.stat = 0
	return 1


/obj/item/borg/upgrade/vtec/
	name = "Borg VTEC Module"
	desc = "Used to kick in a borgs VTEC systems, increasing their speed."
	construction_cost = list("metal"=80000 , "glass"=6000 , "gold"= 5000)
	require_module = 1

/obj/item/borg/upgrade/vtec/action(var/mob/living/silicon/robot/R)
	if(R.speed == -1)
		return 0

	R.speed--
	return 1


/obj/item/borg/upgrade/tasercooler/
	name = "Borg Rapid Taser Cooling Module"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate.."
	construction_cost = list("metal"=80000 , "glass"=6000 , "gold"= 2000, "diamond" = 500)
	require_module = 1


/obj/item/borg/upgrade/tasercooler/action(var/mob/living/silicon/robot/R)
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
		usr << "This cyborg has had its taser removed!"
		return 0

	if(T.recharge_time <= 2)
		R << "Maximum cooling achieved for this hardpoint!"
		usr << "There's no room for another cooling unit!"
		return 0

	else
		T.recharge_time = max(2 , T.recharge_time - 4)

	return 1