/obj/item/part/cyborg/module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT

	var/list/modules = list()
	var/obj/item/emag = null
	var/obj/item/part/cyborg/equipment/upgrade/jetpack = null


	emp_act(severity)
		if(modules)
			for(var/obj/O in modules)
				O.emp_act(severity)
		if(emag)
			emag.emp_act(severity)
		..()
		return


	New()
		modules += new /obj/item/tool/flashlight(src)
		modules += new /obj/item/security/flash(src)
		emag = new /obj/item/toy/sword(src)
		emag.name = "Placeholder Emag Item"
//		jetpack = new /obj/item/toy/sword(src)
//		jetpack.name = "Placeholder Upgrade Item"
		return


/obj/item/part/cyborg/module/proc/respawn_consumable(var/mob/living/silicon/robot/R)
	return

/obj/item/part/cyborg/module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O


/obj/item/part/cyborg/module/standard
	name = "standard robot module"

	New()
		..()
		modules += new /obj/item/weapon/melee/baton(src)
		modules += new /obj/item/tool/extinguisher(src)
		modules += new /obj/item/tool/wrench(src)
		modules += new /obj/item/tool/crowbar(src)
		modules += new /obj/item/device/scanner/health(src)
		emag = new /obj/item/weapon/melee/energy/sword(src)


/obj/item/part/cyborg/module/medical
	name = "medical robot module"

	New()
		..()
		modules += new /obj/item/part/cyborg/equipment/sight/hud/med(src)
		modules += new /obj/item/device/scanner/health(src)
		modules += new /obj/item/chem/borghypo(src)
		modules += new /obj/item/chem/glass/beaker/large(src)
		modules += new /obj/item/chem/dropper(src)
		modules += new /obj/item/chem/syringe(src)
		modules += new /obj/item/tool/extinguisher/mini(src)
		emag = new /obj/item/chem/spray(src)

		emag.reagents.add_reagent("pacid", 250)
		emag.name = "polyacid spray"



/obj/item/part/cyborg/module/engineering
	name = "engineering robot module"

	New()
		..()
		modules += new /obj/item/part/cyborg/equipment/sight/meson(src)
		emag = new /obj/item/part/cyborg/equipment/stun(src)
		modules += new /obj/item/tool/rcd/borg(src)
		modules += new /obj/item/tool/extinguisher(src)
//		modules += new /obj/item/tool/flashlight(src)
		modules += new /obj/item/tool/welder/largetank(src)
		modules += new /obj/item/tool/screwdriver(src)
		modules += new /obj/item/tool/wrench(src)
		modules += new /obj/item/tool/crowbar(src)
		modules += new /obj/item/part/wirecutters(src)
		modules += new /obj/item/tool/multitool(src)
		modules += new /obj/item/device/scanner/t_ray(src)
		modules += new /obj/item/device/scanner/atmospheric(src)

		var/obj/item/part/stack/sheet/metal/cyborg/M = new /obj/item/part/stack/sheet/metal/cyborg(src)
		M.amount = 50
		modules += M

		var/obj/item/part/stack/sheet/rglass/cyborg/G = new /obj/item/part/stack/sheet/rglass/cyborg(src)
		G.amount = 50
		modules += G

		var/obj/item/part/cable_coil/W = new /obj/item/part/cable_coil(src)
		W.amount = 50
		modules += W


	respawn_consumable(var/mob/living/silicon/robot/R)
		var/list/what = list (
			/obj/item/part/stack/sheet/metal,
			/obj/item/part/stack/sheet/rglass,
			/obj/item/part/cable_coil,
		)
		for(var/T in what)
			if(!(locate(T) in modules))
				modules -= null
				var/O = new T(src)
				modules += O
				O:amount = 1


/obj/item/part/cyborg/module/security
	name = "security robot module"

	New()
		..()
		modules += new /obj/item/part/cyborg/equipment/sight/hud/sec(src)
		modules += new /obj/item/security/handcuffs/cyborg(src)
		modules += new /obj/item/weapon/melee/baton(src)
		modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
		emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)


/obj/item/part/cyborg/module/janitor
	name = "janitorial robot module"

	New()
		..()
		modules += new /obj/item/service/soap/nanotrasen(src)
		modules += new /obj/item/storage/bag/trash(src)
		modules += new /obj/item/service/mop(src)
		modules += new /obj/item/service/lightreplacer(src)
		emag = new /obj/item/chem/spray(src)

		emag.reagents.add_reagent("lube", 250)
		emag.name = "lube spray"


/obj/item/part/cyborg/module/butler
	name = "service robot module"

	New()
		..()
		modules += new /obj/item/chem/food/drinks/beer(src)
		modules += new /obj/item/chem/food/condiment/enzyme(src)
		modules += new /obj/item/office/pen(src)
		modules += new /obj/item/service/razor(src)

		var/obj/item/service/rsf/M = new /obj/item/service/rsf(src)
		M.matter = 30
		modules += M

		modules += new /obj/item/chem/dropper(src)

		var/obj/item/part/lighter/zippo/L = new /obj/item/part/lighter/zippo(src)
		L.lit = 1
		modules += L

		modules += new /obj/item/service/tray(src)
		modules += new /obj/item/chem/food/drinks/shaker(src)
		emag = new /obj/item/chem/food/drinks/beer(src)

		var/datum/reagents/R = new/datum/reagents(50)
		emag.reagents = R
		R.my_atom = emag
		R.add_reagent("beer2", 50)
		emag.name = "Mickey Finn's Special Brew"


/obj/item/part/cyborg/module/miner
	name = "miner robot module"

	New()
		..()
		modules += new /obj/item/part/cyborg/equipment/sight/meson(src)
		emag = new /obj/item/part/cyborg/equipment/stun(src)
		modules += new /obj/item/storage/bag/ore(src)
		modules += new /obj/item/mining/pickaxe/borgdrill(src)
		modules += new /obj/item/storage/bag/sheetsnatcher/borg(src)
//		modules += new /obj/item/mining/shovel(src) Uneeded due to buffed drill


/obj/item/part/cyborg/module/syndicate
	name = "syndicate robot module"

	New()
		modules += new /obj/item/weapon/melee/energy/sword(src)
		modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
		modules += new /obj/item/security/card/emag(src)