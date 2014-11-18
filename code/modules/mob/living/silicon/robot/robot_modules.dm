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
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash(src)
		src.emag = new /obj/item/toy/sword(src)
		src.emag.name = "Placeholder Emag Item"
//		src.jetpack = new /obj/item/toy/sword(src)
//		src.jetpack.name = "Placeholder Upgrade Item"
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
		src.modules += new /obj/item/weapon/melee/baton/loaded(src)
		src.modules += new /obj/item/weapon/extinguisher(src)
		src.modules += new /obj/item/weapon/wrench(src)
		src.modules += new /obj/item/weapon/crowbar(src)
		src.modules += new /obj/item/device/healthanalyzer(src)
		src.modules += new /obj/item/weapon/soap/nanotrasen(src)
		src.emag = new /obj/item/weapon/melee/energy/sword(src)

		var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(src)
		B.max_amount = 15
		B.amount = 15
		src.modules += B

		var/obj/item/stack/medical/ointment/O = new /obj/item/stack/medical/ointment(src)
		O.max_amount = 15
		O.amount = 15
		src.modules += O

		return

	respawn_consumable(var/mob/living/silicon/robot/R)
		// Recharge baton battery
		for(var/obj/item/weapon/melee/baton/B in src.modules)
			if(B && B.bcell)
				B.bcell.give(175)
		// Replenish ointment and bandages
		var/list/what = list (
			/obj/item/stack/medical/bruise_pack,
			/obj/item/stack/medical/ointment,
		)
		for (var/T in what)
			if (!(locate(T) in src.modules))
				src.modules -= null
				var/O = new T(src)
				if(istype(O,/obj/item/stack/medical))
					O:max_amount = 15
				src.modules += O
				O:amount = 1
		return



/obj/item/weapon/robot_module/medical
	name = "medical robot module"


	New()
		..()
		//src.modules += new /obj/item/borg/sight/hud/med(src)
		src.modules += new /obj/item/device/healthanalyzer(src)
		src.modules += new /obj/item/weapon/reagent_containers/borghypo(src)
		src.modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		src.modules += new /obj/item/weapon/reagent_containers/robodropper(src)
		src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
		src.modules += new /obj/item/weapon/storage/bag/chem(src)
		src.modules += new /obj/item/weapon/extinguisher/mini(src)
		src.modules += new /obj/item/weapon/scalpel
		src.modules += new /obj/item/weapon/hemostat
		src.modules += new /obj/item/weapon/retractor
		src.modules += new /obj/item/weapon/circular_saw
		src.modules += new /obj/item/weapon/cautery
		src.modules += new /obj/item/weapon/bonegel
		src.modules += new /obj/item/weapon/bonesetter
		src.modules += new /obj/item/weapon/FixOVein
		src.modules += new /obj/item/weapon/surgicaldrill
		src.modules += new /obj/item/weapon/revivalprod
		src.emag = new /obj/item/weapon/reagent_containers/spray(src)

		src.emag.reagents.add_reagent("pacid", 250)
		src.emag.name = "Polyacid spray"

		var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
		B.max_amount = 10
		B.amount = 10
		src.modules += B

		var/obj/item/stack/medical/advanced/ointment/O = new /obj/item/stack/medical/advanced/ointment(src)
		O.max_amount = 10
		O.amount = 10
		src.modules += O

		var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
		S.max_amount = 10
		S.amount = 10
		src.modules += S

		return

	respawn_consumable(var/mob/living/silicon/robot/R)
		var/list/what = list (
			/obj/item/stack/medical/advanced/bruise_pack,
			/obj/item/stack/medical/advanced/ointment,
			/obj/item/stack/medical/splint,
		)
		for (var/T in what)
			if (!(locate(T) in src.modules))
				src.modules -= null
				var/O = new T(src)
				if(istype(O,/obj/item/stack/medical))
					O:max_amount = 15
				src.modules += O
				O:amount = 1
		return


/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"


	New()
		..()
		src.modules += new /obj/item/borg/sight/meson(src)
		src.emag = new /obj/item/borg/stun(src)
		src.modules += new /obj/item/weapon/rcd/borg(src)
		src.modules += new /obj/item/weapon/pipe_dispenser(src) //What could possibly go wrong?
		src.modules += new /obj/item/weapon/extinguisher(src)
		src.modules += new /obj/item/weapon/extinguisher/foam(src)
//		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/weapon/weldingtool/largetank(src)
		src.modules += new /obj/item/weapon/screwdriver(src)
		src.modules += new /obj/item/weapon/wrench(src)
		src.modules += new /obj/item/weapon/crowbar(src)
		src.modules += new /obj/item/weapon/wirecutters(src)
		src.modules += new /obj/item/device/multitool(src)
		src.modules += new /obj/item/device/t_scanner(src)
		src.modules += new /obj/item/device/analyzer(src)
		src.modules += new /obj/item/taperoll/atmos(src)
		src.modules += new /obj/item/taperoll/engineering(src)

		var/obj/item/stack/sheet/metal/cyborg/M = new /obj/item/stack/sheet/metal/cyborg(src)
		M.amount = 50
		src.modules += M

		var/obj/item/stack/tile/plasteel/F = new /obj/item/stack/tile/plasteel(src)
		F.amount = 50
		src.modules += F

		var/obj/item/stack/rods/O = new /obj/item/stack/rods(src)
		O.amount = 50
		src.modules += O

		var/obj/item/stack/sheet/glass/cyborg/G = new /obj/item/stack/sheet/glass/cyborg(src)
		G.amount = 50
		src.modules += G

		var/obj/item/stack/sheet/rglass/cyborg/R = new /obj/item/stack/sheet/rglass/cyborg(src)
		R.amount = 50
		src.modules += R

		var/obj/item/weapon/cable_coil/W = new /obj/item/weapon/cable_coil(src)
		W.amount = 50
		W.max_amount = 50
		src.modules += W

		return


	respawn_consumable(var/mob/living/silicon/robot/R)
		var/list/what = list (
			/obj/item/stack/sheet/metal,
			/obj/item/stack/tile/plasteel,
			/obj/item/stack/rods,
			/obj/item/stack/sheet/glass,
			/obj/item/stack/sheet/rglass,
			/obj/item/weapon/cable_coil,
		)
		for (var/T in what)
			if (!(locate(T) in src.modules))
				src.modules -= null
				var/O = new T(src)
				if(istype(O,/obj/item/weapon/cable_coil))
					O:max_amount = 50
				src.modules += O
				O:amount = 1
		return



/obj/item/weapon/robot_module/security
	name = "security robot module"

	New()
		..()
		//src.modules += new /obj/item/borg/sight/hud/sec(src)
		src.modules += new /obj/item/weapon/melee/baton/loaded(src)
		src.modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
		src.modules += new /obj/item/weapon/handcuffs/cyborg(src)
		src.modules += new /obj/item/weapon/reagent_containers/spray/pepper(src)
		src.modules += new /obj/item/taperoll/police(src)
		src.emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)
		return

	respawn_consumable(var/mob/living/silicon/robot/R)
		// Recharge baton battery
		for(var/obj/item/M in src.modules)
			if(istype(M,/obj/item/weapon/melee/baton))
				var/obj/item/weapon/melee/baton/B=M
				if(B && B.bcell)
					B.bcell.give(175)

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"


	New()
		..()
		src.modules += new /obj/item/weapon/soap/nanotrasen(src)
		src.modules += new /obj/item/weapon/storage/bag/trash(src)
		src.modules += new /obj/item/weapon/mop(src)
		src.modules += new /obj/item/device/lightreplacer(src)
		src.emag = new /obj/item/weapon/reagent_containers/spray(src)

		src.emag.reagents.add_reagent("lube", 250)
		src.emag.name = "Lube spray"
		return



/obj/item/weapon/robot_module/butler
	name = "service robot module"


	New()
		..()
		src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
		src.modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
		src.modules += new /obj/item/weapon/pen/robopen(src)

		var/obj/item/weapon/rsf/M = new /obj/item/weapon/rsf(src)
		M.matter = 30
		src.modules += M

		src.modules += new /obj/item/weapon/reagent_containers/robodropper(src)

		var/obj/item/weapon/lighter/zippo/L = new /obj/item/weapon/lighter/zippo(src)
		L.lit = 1
		src.modules += L

		src.modules += new /obj/item/weapon/tray/robotray(src)
		src.modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)
		src.modules += new /obj/item/device/soundsynth(src)
		src.emag = new /obj/item/weapon/reagent_containers/food/drinks/beer(src)

		var/datum/reagents/R = new/datum/reagents(50)
		src.emag.reagents = R
		R.my_atom = src.emag
		R.add_reagent("beer2", 50)
		src.emag.name = "Mickey Finn's Special Brew"
		return



/obj/item/weapon/robot_module/miner
	name = "miner robot module"


	New()
		..()
		src.modules += new /obj/item/borg/sight/meson(src)
		src.emag = new /obj/item/borg/stun(src)
		src.modules += new /obj/item/weapon/storage/bag/ore(src)
		src.modules += new /obj/item/weapon/pickaxe/borgdrill(src)
		src.modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
		src.modules += new /obj/item/device/mining_scanner(src)
		src.modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/cyborg(src)
//		src.modules += new /obj/item/weapon/shovel(src) Uneeded due to buffed drill
		return


/obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"


	New()
		src.modules += new /obj/item/weapon/melee/energy/sword(src)
		src.modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
		src.modules += new /obj/item/weapon/card/emag(src)
		return

/obj/item/weapon/robot_module/combat
	name = "combat robot module"

	New()
		src.modules += new /obj/item/borg/sight/thermal(src)
		src.modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
		src.modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
		src.modules += new /obj/item/borg/combat/shield(src)
		src.modules += new /obj/item/borg/combat/mobility(src)
		src.modules += new /obj/item/weapon/wrench(src) //Is a combat android really going to be stopped by a chair?
		src.emag = new /obj/item/weapon/gun/energy/lasercannon/cyborg(src)
		return
