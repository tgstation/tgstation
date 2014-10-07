/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100.0
	item_state = "electronic"
	flags = CONDUCT

	var/list/modules = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null
	var/list/storages = list()

/obj/item/weapon/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)
	if(emag)
		emag.emp_act(severity)
	..()
	return

/obj/item/weapon/robot_module/proc/get_usable_modules()
	. = modules.Copy()
	var/mob/living/silicon/robot/R = loc
	if(R.emagged)
		. += emag

/obj/item/weapon/robot_module/proc/get_inactive_modules()
	. = list()
	var/mob/living/silicon/robot/R = loc
	for(var/m in get_usable_modules())
		if((m != R.module_state_1) && (m != R.module_state_2) && (m != R.module_state_3))
			. += m


/obj/item/weapon/robot_module/New()
	modules += new /obj/item/device/flashlight(src)
	modules += new /obj/item/device/flash/cyborg(src)
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

/obj/item/weapon/robot_module/proc/on_emag()
	return


/obj/item/weapon/robot_module/standard
	name = "standard robot module"

/obj/item/weapon/robot_module/standard/New()
	..()
	modules += new /obj/item/weapon/melee/baton/loaded(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/device/healthanalyzer(src)
	emag = new /obj/item/weapon/melee/energy/sword/cyborg(src)


/obj/item/weapon/robot_module/medical
	name = "medical robot module"

/obj/item/weapon/robot_module/medical/New()
	..()
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

/obj/item/weapon/robot_module/engineering/New()
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

	var/datum/robot_energy_storage/metal/metstore = new /datum/robot_energy_storage/metal(src)
	var/datum/robot_energy_storage/glass/glastore = new /datum/robot_energy_storage/glass(src)
	var/datum/robot_energy_storage/wire/wirestore = new /datum/robot_energy_storage/wire(src)

	var/obj/item/stack/sheet/metal/cyborg/M = new /obj/item/stack/sheet/metal/cyborg(src)
	M.source = metstore
	modules += M

	var/obj/item/stack/sheet/glass/cyborg/Q = new /obj/item/stack/sheet/glass/cyborg(src)
	Q.source = glastore
	modules += Q

	var/obj/item/stack/sheet/rglass/cyborg/G = new /obj/item/stack/sheet/rglass/cyborg(src)
	G.metsource = metstore
	G.glasource = glastore
	modules += G

	var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
	R.source = metstore
	modules += R

	var/obj/item/stack/cable_coil/cyborg/W = new /obj/item/stack/cable_coil/cyborg(src)
	W.source = wirestore
	modules += W

	var/obj/item/stack/tile/plasteel/cyborg/F = new /obj/item/stack/tile/plasteel/cyborg(src) //"Plasteel" is the normal metal floor tile, Don't be confused - RR
	F.source = metstore
	modules += F //'F' for floor tile - RR(src)

	storages += metstore
	storages += glastore
	storages += wirestore

/obj/item/weapon/robot_module/security
	name = "security robot module"

/obj/item/weapon/robot_module/security/New()
	..()
	modules += new /obj/item/weapon/handcuffs/cyborg(src)
	modules += new /obj/item/weapon/melee/baton/loaded(src)
	modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
	modules += new /obj/item/clothing/mask/gas/sechailer/cyborg(src)
	emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)


/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"

/obj/item/weapon/robot_module/janitor/New()
	..()
	modules += new /obj/item/weapon/soap/nanotrasen(src)
	modules += new /obj/item/weapon/storage/bag/trash/cyborg(src)
	modules += new /obj/item/weapon/mop/cyborg(src)
	modules += new /obj/item/device/lightreplacer/cyborg(src)
	emag = new /obj/item/weapon/reagent_containers/spray(src)

	emag.reagents.add_reagent("lube", 250)
	emag.name = "lube spray"


/obj/item/weapon/robot_module/butler
	name = "service robot module"

/obj/item/weapon/robot_module/butler/New()
	..()
	modules += new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
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

	modules += new /obj/item/weapon/storage/bag/tray(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/borgshaker(src)
	emag = new /obj/item/weapon/reagent_containers/borghypo/borgshaker/hacked(src)


/obj/item/weapon/robot_module/miner
	name = "miner robot module"

/obj/item/weapon/robot_module/miner/New()
	..()
	var/mob/living/silicon/robot/R = loc
	modules += new /obj/item/borg/sight/meson(src)
	emag = new /obj/item/borg/stun(src)
	modules += new /obj/item/weapon/storage/bag/ore(src)
	if(R.emagged)
		modules += new /obj/item/weapon/pickaxe/diamonddrill(src)
	else
		modules += new /obj/item/weapon/pickaxe/borgdrill(src)
	modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	modules += new /obj/item/device/t_scanner/mining_scanner(src)
	modules += new /obj/item/weapon/gun/energy/kinetic_accelerator(src)

/obj/item/weapon/robot_module/miner/on_emag()
	..()
	for(var/obj/item/weapon/pickaxe/borgdrill/D in modules)
		qdel(D)
	modules += new /obj/item/weapon/pickaxe/diamonddrill(src)
	rebuild()


/obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"

/obj/item/weapon/robot_module/syndicate/New()
	..()
	modules += new /obj/item/weapon/melee/energy/sword/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/crossbow/cyborg(src)
	modules += new /obj/item/weapon/card/emag(src)
	modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
	modules += new /obj/item/weapon/tank/jetpack/carbondioxide(src)
	modules += new /obj/item/weapon/crowbar(src)
	emag = null

/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy = 30000
	var/recharge_rate = 1000
	var/energy

/datum/robot_energy_storage/New()
	energy = max_energy
	return

/datum/robot_energy_storage/proc/use_charge(var/amount)
	if (energy >= amount)
		energy -= amount
		if (energy == 0)
			return 1
		return 2
	else
		return 0

/datum/robot_energy_storage/proc/add_charge(var/amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/metal
	name = "Metal Synthesizer"

/datum/robot_energy_storage/glass
	name = "Glass Synthesizer"

/datum/robot_energy_storage/wire
	max_energy = 50
	recharge_rate = 2
	name = "Wire Synthesizer"
