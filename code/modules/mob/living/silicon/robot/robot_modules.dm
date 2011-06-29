/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'module.dmi'
	icon_state = "std_module"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT
	var/list/modules = list()
	var/obj/item/emag

	emp_act(severity)
		if(modules)
			for(var/obj/O in modules)
				O.emp_act(severity)
		if(emag)
			emag.emp_act(severity)
		..()

	proc/respawn_consumable(var/mob/living/silicon/robot/R)
		return

/obj/item/weapon/robot_module/standard
	name = "standard robot module"
/*
/obj/item/weapon/robot_module/medical
	name = "medical robot module"
*/
/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"

/obj/item/weapon/robot_module/security
	name = "security robot module"

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"

/*
/obj/item/weapon/robot_module/brobot
	name = "brobot robot module"
*/
/obj/item/weapon/robot_module/butler
	name = "service robot module"

/obj/item/weapon/robot_module/miner
	name = "miner robot module"

obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"

/obj/item/weapon/robot_module/New()//Shit all the mods have
	src.modules += new /obj/item/device/flash(src)
	src.emag = new /obj/item/toy/sword(src)
	src.emag.name = "Placeholder Emag Item"


/obj/item/weapon/robot_module/standard/New()
	..()
	src.modules += new /obj/item/weapon/melee/baton(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.emag = new /obj/item/weapon/melee/energy/sword(src)

/obj/item/weapon/robot_module/engineering/New()
	..()
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/weldingtool/largetank(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/device/analyzer(src)
	src.modules += new /obj/item/device/flashlight(src)

	var/obj/item/weapon/rcd/R = new /obj/item/weapon/rcd(src)
	R.matter = 30
	src.modules += R

	src.modules += new /obj/item/device/t_scanner(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)

	var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(src)
	M.amount = 50
	src.modules += M

	var/obj/item/stack/sheet/rglass/G = new /obj/item/stack/sheet/rglass(src)
	G.amount = 50
	src.modules += G

	var/obj/item/weapon/cable_coil/W = new /obj/item/weapon/cable_coil(src)
	W.amount = 50
	src.modules += W
	src.modules += new /obj/item/weapon/borg/sight/meson(src)

	src.emag = new /obj/item/weapon/borg/stun(src)


/obj/item/weapon/robot_module/engineering/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/rglass,
		/obj/item/weapon/cable_coil,
	)
	for (var/T in what)
		if (!(locate(T) in src.modules))
			src.modules -= null
			var/O = new T(src)
			src.modules += O
			O:amount = 1

/*
/obj/item/weapon/robot_module/medical/New()
	..()
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/stack/medical/ointment/medbot(src)
	src.modules += new /obj/item/stack/medical/bruise_pack/medbot(src)
	src.modules += new /obj/item/weapon/reagent_containers/syringe/robot(src)
	src.modules += new /obj/item/weapon/scalpel(src)
	src.modules += new /obj/item/weapon/circular_saw(src)
*/


/obj/item/weapon/robot_module/butler/New()
	..()
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/pen(src)

	var/obj/item/weapon/rsf/M = new /obj/item/weapon/rsf(src)
	M.matter = 30
	src.modules += M

	src.modules += new /obj/item/weapon/reagent_containers/robodropper(src)

	var/obj/item/weapon/zippo/L = new /obj/item/weapon/zippo(src)
	L.lit = 1
	src.modules += L

	src.modules += new /obj/item/weapon/tray(src)
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)
//	src.emag = new /obj/item/weapon/reagent_containers/food/snacks/roburgerbig(src)
//	src.emag.name = "Last Meal"
	src.emag = new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	var/datum/reagents/R = new/datum/reagents(50)
	src.emag.reagents = R
	R.my_atom = src.emag
	R.add_reagent("beer2", 50)
	src.emag.name = "Mickey Finn's Special Brew"


/obj/item/weapon/robot_module/security/New()
	..()
	src.modules += new /obj/item/weapon/melee/baton(src)
	src.modules += new /obj/item/weapon/handcuffs(src)
	src.modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
	src.emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)


/obj/item/weapon/robot_module/janitor/New()
	..()
	src.modules += new /obj/item/weapon/cleaner(src)
	src.modules += new /obj/item/weapon/mop(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/bucket(src)
	src.emag = new /obj/item/weapon/cleaner(src)
	var/datum/reagents/R = new/datum/reagents(1000)
	src.emag.reagents = R
	R.my_atom = src.emag
	R.add_reagent("lube", 1000)
	src.emag.name = "Lube spray"


/obj/item/weapon/robot_module/miner/New()
	..()
	src.modules += new /obj/item/weapon/pickaxe/jackhammer(src)
	src.modules += new /obj/item/weapon/shovel(src)
	src.modules += new /obj/item/weapon/satchel(src)
	src.modules += new /obj/item/weapon/borg/sight/meson(src)
	src.emag = new /obj/item/weapon/borg/stun(src)

/* /obj/item/weapon/robot_module/brobot/New()
	..()
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/spacecash(src)
	src.emag = new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	var/datum/reagents/R = new/datum/reagents(50)
	src.emag.reagents = R
	R.my_atom = src.emag
	R.add_reagent("beer2", 50)
	src.emag.name = "Mickey Finn's Special Brew"
*/ //Merged with Service borg, not a death, just a transformation

obj/item/weapon/robot_module/syndicate/New()
	src.modules += new /obj/item/weapon/gun/energy/crossbow/cyborg(src)
	src.modules += new /obj/item/weapon/card/emag(src)


/obj/item/weapon/borg/stun
	name = "Electrified Arm"
	icon = 'decals.dmi'
	icon_state = "shock"

	attack(mob/M as mob, mob/living/silicon/robot/user as mob)

		M.attack_log += text("<font color='orange'>[world.time] - has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("<font color='red'>[world.time] - has used the [src.name] to attack [M.name] ([M.ckey])</font>")
		user.cell.charge -= 30
		if (M.weakened < 5)
			M.weakened = 5
		if (M.stuttering < 5)
			M.stuttering = 5
		if (M.stunned < 5)
			M.stunned = 5
		for(var/mob/O in viewers(M, null))
			if (O.client)
				O.show_message("\red <B>[user] has prodded [M] with an electrically-charged arm!</B>", 1, "\red You hear someone fall", 2)

/obj/item/weapon/borg/sight
	icon = 'decals.dmi'
	icon_state = "securearea"
	var/sight_mode

/obj/item/weapon/borg/sight/xray
	name = "X-ray Vision"
	sight_mode = BORGXRAY

/obj/item/weapon/borg/sight/thermal
	name = "Thermal Vision"
	sight_mode = BORGTHERM

/obj/item/weapon/borg/sight/meson
	name = "Meson Vision"
	sight_mode = BORGMESON
