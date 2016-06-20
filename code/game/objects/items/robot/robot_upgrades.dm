// robot_upgrades.dm
// Contains various borg upgrades.

#define FAILED_TO_ADD 1

/obj/item/borg/upgrade
	name = "A borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = 0
	var/list/required_module = list()
	var/add_to_mommis = 0
	var/list/modules_to_add = list()
	var/multi_upgrades = 0
	w_type=RECYK_ELECTRONIC


/obj/item/borg/upgrade/proc/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(!R.module)
		to_chat(user, "<span class='warning'>The borg must choose a module before he can be upgraded!</span>")
		return FAILED_TO_ADD

	if(required_module.len)
		if(!(R.module.type in required_module))
			to_chat(user, "<span class='warning'>\The [src] will not fit into \the [R.module.name]!</span>")
			return FAILED_TO_ADD

	if(R.stat == DEAD)
		to_chat(user, "<span class='warning'>\The [src] will not function on a deceased robot.</span>")
		return FAILED_TO_ADD

	if(!R.opened)
		to_chat(user, "<span class='warning'>You must first open \the [src]'s cover!</span>")
		return FAILED_TO_ADD

	if(isMoMMI(R) && !add_to_mommis)
		to_chat(user, "<span class='warning'>\The [src] only functions on Nanotrasen Cyborgs.</span>")
		return FAILED_TO_ADD

	if(!multi_upgrades && (src.type in R.module.upgrades))
		to_chat(user, "<span class='warning'>There is already \a [src] in [R].</span>")
		return FAILED_TO_ADD

	R.module.upgrades += src.type

	if(modules_to_add.len)
		for(var/module_to_add in modules_to_add)
			R.module.modules += new module_to_add(R.module)

	to_chat(user, "<span class='notice'>You successfully apply \the [src] to [R].</span>")
	user.drop_item(src, R)

// Medical Cyborg Stuff

/obj/item/borg/upgrade/medical/surgery
	name = "medical module board"
	desc = "Used to give a medical cyborg advanced care tools."
	icon_state = "cyborg_upgrade"
	required_module = list(/obj/item/weapon/robot_module/medical)
	modules_to_add = list(/obj/item/weapon/melee/defibrillator,/obj/item/weapon/reagent_containers/borghypo/upgraded)

/obj/item/borg/upgrade/reset
	name = "robotic module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the robot."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/reset/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	R.uneq_all()
	if(R.hands)
		R.hands.icon_state = "nomod"
	R.icon_state = "robot"
	R.base_icon = "robot"
	R.module.remove_languages(R)
	qdel(R.module)
	R.module = null
	R.camera.network.Remove(list("Engineering","Medical","MINE"))
	R.updatename("Default")
	R.status_flags |= CANPUSH
	R.updateicon()
	R.luminosity = 0 //flashlight fix
	R.resurrect()

/obj/item/borg/upgrade/rename
	name = "robot reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "default name"

/obj/item/borg/upgrade/rename/attack_self(mob/user as mob)
	heldname = stripped_input(user, "Enter new robot name", "Robot Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	R.name = ""
	R.custom_name = null
	R.real_name = ""
	R.updatename()
	R.updateicon()
	to_chat(R, "<span class='warning'>You may now change your name.</span>")

/obj/item/borg/upgrade/restart
	name = "robot emergency restart module"
	desc = "Used to force a restart of a disabled-but-repaired robot, bringing it back online."
	icon_state = "cyborg_upgrade1"


/obj/item/borg/upgrade/restart/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(R.health < 0)
		to_chat(user, "You have to repair the robot before using this module!")
		return 0

	if(!R.key)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	R.stat = CONSCIOUS


/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	multi_upgrades = 1
	add_to_mommis = 1

/obj/item/borg/upgrade/vtec/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)

	if(R.speed == -1)
		return FAILED_TO_ADD
	if(..())
		return FAILED_TO_ADD

	R.speed--


/obj/item/borg/upgrade/tasercooler
	name = "robotic Rapid Taser Cooling Module"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	required_module = list(/obj/item/weapon/robot_module/security)
	multi_upgrades = 1


/obj/item/borg/upgrade/tasercooler/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)


	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
	if(!T)
		T = locate() in R.module.modules
	if(!T)
		to_chat(user, "This robot has had its taser removed!")
		return FAILED_TO_ADD

	if(T.recharge_time <= 2)
		to_chat(R, "Maximum cooling achieved for this hardpoint!")
		to_chat(user, "There's no room for another cooling unit!")
		return FAILED_TO_ADD

	if(..())
		return FAILED_TO_ADD
	else
		T.recharge_time = max(2 , T.recharge_time - 4)

/obj/item/borg/upgrade/jetpack
	name = "mining robot jetpack"
	desc = "A carbon dioxide jetpack suitable for low-gravity mining operations."
	icon_state = "cyborg_upgrade3"
	required_module = list(/obj/item/weapon/robot_module/miner,/obj/item/weapon/robot_module/engineering)
	modules_to_add = list(/obj/item/weapon/tank/jetpack/carbondioxide)
	add_to_mommis = 1

/obj/item/borg/upgrade/jetpack/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
		R.internals = src

/obj/item/borg/upgrade/syndicate/
	name = "Illegal Equipment Module"
	desc = "Unlocks the hidden, deadlier functions of a robot."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/syndicate/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)

	if(R.emagged == 1)
		return FAILED_TO_ADD

	if(..())
		return FAILED_TO_ADD

	message_admins("[key_name_admin(user)] ([user.type]) used \a [name] on [R] (a [R.type]).")

	R.SetEmagged(2)

/obj/item/borg/upgrade/engineering/
	name = "Engineering Equipment Module"
	desc = "Adds several tools and materials for the robot to use."
	icon_state = "cyborg_upgrade3"
	required_module = list(/obj/item/weapon/robot_module/engineering)
	modules_to_add = list(/obj/item/weapon/wrench/socket)

/obj/item/borg/upgrade/engineering/attempt_action(var/mob/living/silicon/robot/R,var/mob/living/user)
	if(..())
		return FAILED_TO_ADD

	var/obj/item/device/material_synth/S = locate(/obj/item/device/material_synth) in R.module.modules
	if(!S)
		return FAILED_TO_ADD

	S.materials_scanned |= list("plasma glass" = /obj/item/stack/sheet/glass/plasmaglass,
								"reinforced plasma glass" = /obj/item/stack/sheet/glass/plasmarglass,
								"carpet tiles" = /obj/item/stack/tile/carpet)

/obj/item/borg/upgrade/service
	name = "service module board"
	desc = "Used to give a service cyborg cooking tools."
	icon_state = "cyborg_upgrade2"
	required_module = list(/obj/item/weapon/robot_module/butler)
	modules_to_add = list(/obj/item/weapon/reagent_containers/glass/beaker/large/cyborg,/obj/item/weapon/kitchen/utensil/knife/large,/obj/item/weapon/storage/bag/food/borg)