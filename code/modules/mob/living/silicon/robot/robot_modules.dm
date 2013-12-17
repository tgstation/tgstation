/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT

	var/list/modules = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null


	emp_act(severity)
		if(modules)
			for(var/obj/O in modules)
				O.emp_act(severity)
		if(emag)
			emag.emp_act(severity)
		..()
		return


	New()
		modules += new /obj/item/device/flashlight(src)
		modules += new /obj/item/device/flash(src)
		emag = new /obj/item/toy/sword(src)
		emag.name = "Placeholder Emag Item"
//		jetpack = new /obj/item/toy/sword(src)
//		jetpack.name = "Placeholder Upgrade Item"
		return


/obj/item/weapon/robot_module/proc/respawn_consumable(var/mob/living/silicon/robot/R)
	return

/obj/item/weapon/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O


/obj/item/weapon/robot_module/standard
	name = "standard robot module"

	New()
		..()
		modules += new /obj/item/weapon/melee/baton/loaded(src)
		modules += new /obj/item/weapon/extinguisher(src)
		modules += new /obj/item/weapon/wrench(src)
		modules += new /obj/item/weapon/crowbar(src)
		modules += new /obj/item/device/healthanalyzer(src)
		emag = new /obj/item/weapon/melee/energy/sword(src)


/obj/item/weapon/robot_module/medical
	name = "medical robot module"

	New()
		..()
		modules += new /obj/item/borg/sight/hud/med(src)
		modules += new /obj/item/device/healthanalyzer(src)
		modules += new /obj/item/weapon/reagent_containers/borghypo(src)
		modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		modules += new /obj/item/weapon/reagent_containers/dropper(src)
		modules += new /obj/item/weapon/reagent_containers/syringe(src)
		modules += new /obj/item/weapon/extinguisher/mini(src)
		emag = new /obj/item/weapon/reagent_containers/spray(src)

		emag.reagents.add_reagent("pacid", 250)
		emag.name = "polyacid spray"



/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"

	New()
		..()
		modules += new /obj/item/borg/sight/meson(src)
		emag = new /obj/item/borg/stun(src)
		modules += new /obj/item/weapon/rcd/borg(src)
		modules += new /obj/item/weapon/extinguisher(src)
		modules += new /obj/item/weapon/weldingtool/largetank/cyborg(src)
		modules += new /obj/item/weapon/screwdriver(src)
		modules += new /obj/item/weapon/wrench(src)
		modules += new /obj/item/weapon/crowbar(src)
		modules += new /obj/item/weapon/wirecutters(src)
		modules += new /obj/item/device/multitool(src)
		modules += new /obj/item/device/t_scanner(src)
		modules += new /obj/item/device/analyzer(src)

		var/obj/item/stack/sheet/metal/cyborg/M = new /obj/item/stack/sheet/metal/cyborg(src)
		M.amount = 50
		modules += M

		var/obj/item/stack/sheet/rglass/cyborg/G = new /obj/item/stack/sheet/rglass/cyborg(src)
		G.amount = 50
		modules += G

		var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
		R.amount = 50
		modules += R

		var/obj/item/weapon/cable_coil/W = new /obj/item/weapon/cable_coil(src)
		W.amount = 50
		modules += W

		var/obj/item/stack/tile/plasteel/cyborg/F = new /obj/item/stack/tile/plasteel/cyborg(src) //"Plasteel" is the normal metal floor tile, Don't be confused - RR
		F.amount = 50
		modules += F //'F' for floor tile - RR


	respawn_consumable(var/mob/living/silicon/robot/R)
		var/list/what = list (
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/rglass,
			/obj/item/stack/rods,
			/obj/item/weapon/cable_coil,
			/obj/item/stack/tile/plasteel/cyborg,
		)
		for(var/T in what)
			if(!(locate(T) in modules))
				modules -= null
				var/O = new T(src)
				modules += O
				O:amount = 1


/obj/item/weapon/robot_module/security
	name = "security robot module"

	New()
		..()
		modules += new /obj/item/borg/sight/hud/sec(src)
		modules += new /obj/item/weapon/handcuffs/cyborg(src)
		modules += new /obj/item/weapon/melee/baton/loaded(src)
		modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
		emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)


/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"

	New()
		..()
		modules += new /obj/item/weapon/soap/nanotrasen(src)
		modules += new /obj/item/weapon/storage/bag/trash(src)
		modules += new /obj/item/weapon/mop(src)
		modules += new /obj/item/device/lightreplacer(src)
		emag = new /obj/item/weapon/reagent_containers/spray(src)

		emag.reagents.add_reagent("lube", 250)
		emag.name = "lube spray"


/obj/item/weapon/robot_module/butler
	name = "service robot module"

	New()
		..()
		modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
		modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
		modules += new /obj/item/weapon/pen(src)
		modules += new /obj/item/weapon/razor(src)
		modules += new /obj/item/device/violin(src)

		var/obj/item/weapon/rsf/M = new /obj/item/weapon/rsf(src)
		M.matter = 30
		modules += M

		modules += new /obj/item/weapon/reagent_containers/dropper(src)

		var/obj/item/weapon/lighter/zippo/L = new /obj/item/weapon/lighter/zippo(src)
		L.lit = 1
		modules += L

		modules += new /obj/item/weapon/tray(src)
		modules += new /obj/item/weapon/reagent_containers/borghypo/borgshaker(src)
		emag = new /obj/item/weapon/reagent_containers/food/drinks/beer(src)

		var/datum/reagents/R = new/datum/reagents(50)
		emag.reagents = R
		R.my_atom = emag
		R.add_reagent("beer2", 50)
		emag.name = "Mickey Finn's Special Brew"


/obj/item/weapon/robot_module/miner
	name = "miner robot module"

	New()
		..()
		modules += new /obj/item/borg/sight/meson(src)
		emag = new /obj/item/borg/stun(src)
		modules += new /obj/item/weapon/storage/bag/ore(src)
		modules += new /obj/item/weapon/pickaxe/borgdrill(src)
		modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)


/obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"

	New()
		modules += new /obj/item/weapon/melee/energy/sword(src)
		modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
		modules += new /obj/item/weapon/card/emag(src)