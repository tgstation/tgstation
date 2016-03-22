/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100
	item_state = "electronic"
	flags = CONDUCT

	var/list/modules = list()
	var/obj/item/emag = null
	var/list/storages = list()

/obj/item/weapon/robot_module/Destroy()
	modules.Cut()
	emag = null
	storages.Cut()
	return ..()

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

/obj/item/weapon/robot_module/proc/get_or_create_estorage(var/storage_type)
	for(var/datum/robot_energy_storage/S in storages)
		if(istype(S, storage_type))
			return S

	return new storage_type(src)

/obj/item/weapon/robot_module/proc/add_module(var/obj/item/I)
	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I

		if(is_type_in_list(S, list(/obj/item/stack/sheet/metal, /obj/item/stack/rods, /obj/item/stack/tile/plasteel)))
			if(S.materials[MAT_METAL])
				S.cost = S.materials[MAT_METAL] * 0.25
			S.source = get_or_create_estorage(/datum/robot_energy_storage/metal)

		else if(istype(S, /obj/item/stack/sheet/glass))
			S.cost = 500
			S.source = get_or_create_estorage(/datum/robot_energy_storage/glass)

		else if(istype(S, /obj/item/stack/medical))
			S.cost = 250
			S.source = get_or_create_estorage(/datum/robot_energy_storage/medical)

		else if(istype(S, /obj/item/stack/cable_coil))
			S.cost = 1
			S.source = get_or_create_estorage(/datum/robot_energy_storage/wire)

		if(S && S.source)
			S.materials = list()
			S.is_cyborg = 1

	if(istype(I, /obj/item/weapon/restraints/handcuffs/cable))
		var/obj/item/weapon/restraints/handcuffs/cable/C = I
		C.wirestorage = get_or_create_estorage(/datum/robot_energy_storage/wire)

	I.loc = src
	modules += I
	rebuild()

/obj/item/weapon/robot_module/New()
	modules += new /obj/item/device/assembly/flash/cyborg(src)
	emag = new /obj/item/toy/sword(src)
	emag.name = "Placeholder Emag Item"
	return

/obj/item/weapon/robot_module/proc/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	for(var/datum/robot_energy_storage/st in storages)
		st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)

	for(var/obj/item/I in get_usable_modules())
		if(istype(I, /obj/item/device/assembly/flash))
			var/obj/item/device/assembly/flash/F = I
			F.times_used = 0
			F.crit_fail = 0
			F.update_icon()
		if(istype(I, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = I
			if(B.bcell)
				B.bcell.charge = B.bcell.maxcharge

	R.toner = R.tonermax

/obj/item/weapon/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O
	fix_modules()

/obj/item/weapon/robot_module/proc/fix_modules()
	for(var/obj/item/I in modules)
		I.flags |= NODROP
		I.mouse_opacity = 2
	if(emag)
		emag.flags |= NODROP
		emag.mouse_opacity = 2

/obj/item/weapon/robot_module/proc/on_emag()
	return

/obj/item/weapon/robot_module/standard
	name = "standard robot module"

/obj/item/weapon/robot_module/standard/New()
	..()
	modules += new /obj/item/weapon/melee/baton/loaded(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/wrench/cyborg(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	modules += new /obj/item/device/healthanalyzer(src)
	emag = new /obj/item/weapon/melee/energy/sword/cyborg(src)
	fix_modules()



/obj/item/weapon/robot_module/medical
	name = "medical robot module"

/obj/item/weapon/robot_module/medical/New()
	..()
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo(src)
	modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	modules += new /obj/item/weapon/reagent_containers/dropper(src)
	modules += new /obj/item/weapon/reagent_containers/syringe(src)
	modules += new /obj/item/weapon/surgical_drapes(src)
	modules += new /obj/item/weapon/retractor(src)
	modules += new /obj/item/weapon/hemostat(src)
	modules += new /obj/item/weapon/cautery(src)
	modules += new /obj/item/weapon/surgicaldrill(src)
	modules += new /obj/item/weapon/scalpel(src)
	modules += new /obj/item/weapon/circular_saw(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/roller/robo(src)

	add_module(new /obj/item/stack/medical/gauze/cyborg())

	emag = new /obj/item/weapon/reagent_containers/borghypo/hacked(src)

	fix_modules()

/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"

/obj/item/weapon/robot_module/engineering/New()
	..()
	modules += new /obj/item/borg/sight/meson(src)
	emag = new /obj/item/borg/stun(src)
	modules += new /obj/item/weapon/rcd/borg(src)
	modules += new /obj/item/weapon/pipe_dispenser(src) //What could possibly go wrong?
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/weapon/screwdriver/cyborg(src)
	modules += new /obj/item/weapon/wrench/cyborg(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	modules += new /obj/item/weapon/wirecutters/cyborg(src)
	modules += new /obj/item/device/multitool/cyborg(src)
	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/device/analyzer(src)

	add_module(new /obj/item/stack/sheet/metal/cyborg())
	add_module(new /obj/item/stack/sheet/glass/cyborg())

	var/obj/item/stack/sheet/rglass/cyborg/G = new /obj/item/stack/sheet/rglass/cyborg(src)
	G.metsource = get_or_create_estorage(/datum/robot_energy_storage/metal)
	G.glasource = get_or_create_estorage(/datum/robot_energy_storage/glass)
	add_module(G)

	add_module(new /obj/item/stack/rods/cyborg())
	add_module(new /obj/item/stack/tile/plasteel/cyborg())
	add_module(new /obj/item/stack/cable_coil/cyborg(src,MAXCOIL,"red"))

	fix_modules()

/obj/item/weapon/robot_module/security
	name = "security robot module"

/obj/item/weapon/robot_module/security/New()
	..()
	modules += new /obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg(src)
	modules += new /obj/item/weapon/melee/baton/loaded(src)
	modules += new /obj/item/weapon/gun/energy/disabler/cyborg(src)
	modules += new /obj/item/clothing/mask/gas/sechailer/cyborg(src)
	emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)
	fix_modules()

/obj/item/weapon/robot_module/security/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/weapon/gun/energy/gun/advtaser/cyborg/T = locate(/obj/item/weapon/gun/energy/gun/advtaser/cyborg) in get_usable_modules()
	if(T)
		if(T.power_supply.charge < T.power_supply.maxcharge)
			var/obj/item/ammo_casing/energy/S = T.ammo_type[T.select]
			T.power_supply.give(S.e_cost * coeff)
			T.update_icon()
		else
			T.charge_tick = 0

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"
	var/obj/item/weapon/reagent_containers/spray/drying_agent

/obj/item/weapon/robot_module/janitor/New()
	..()
	modules += new /obj/item/weapon/soap/nanotrasen(src)
	modules += new /obj/item/weapon/storage/bag/trash/cyborg(src)
	modules += new /obj/item/weapon/mop/cyborg(src)
	modules += new /obj/item/device/lightreplacer/cyborg(src)
	modules += new /obj/item/weapon/holosign_creator(src)
	drying_agent = new(src)
	drying_agent.reagents.add_reagent("drying_agent", 250)
	drying_agent.name = "drying agent spray"
	drying_agent.color = "#A000A0"
	modules += drying_agent
	emag = new /obj/item/weapon/reagent_containers/spray(src)

	emag.reagents.add_reagent("lube", 250)
	emag.name = "lube spray"
	fix_modules()

/obj/item/weapon/robot_module/janitor/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/device/lightreplacer/LR = locate(/obj/item/device/lightreplacer) in get_usable_modules()
	if(LR)
		for(var/i = 1, i <= coeff, i++)
			LR.Charge(R)

	drying_agent.reagents.add_reagent("drying_agent", 5 * coeff)

	if(R.emagged && istype(emag, /obj/item/weapon/reagent_containers/spray))
		emag.reagents.add_reagent("lube", 2 * coeff)


/obj/item/weapon/robot_module/butler
	name = "service robot module"

/obj/item/weapon/robot_module/butler/New()
	..()
	modules += new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
	modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
	modules += new /obj/item/weapon/pen(src)
	modules += new /obj/item/weapon/razor(src)
	modules += new /obj/item/device/instrument/violin(src)
	modules += new /obj/item/device/instrument/guitar(src)
	modules += new /obj/item/weapon/rsf{matter = 30}(src)
	modules += new /obj/item/weapon/reagent_containers/dropper(src)
	modules += new /obj/item/weapon/lighter{lit = 1}(src)
	modules += new /obj/item/weapon/storage/bag/tray(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/borgshaker(src)
	emag = new /obj/item/weapon/reagent_containers/borghypo/borgshaker/hacked(src)
	fix_modules()

/obj/item/weapon/robot_module/butler/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()

	var/obj/item/weapon/reagent_containers/O = locate(/obj/item/weapon/reagent_containers/food/condiment/enzyme) in get_usable_modules()
	if(O)
		O.reagents.add_reagent("enzyme", 2 * coeff)

/obj/item/weapon/robot_module/miner
	name = "miner robot module"

/obj/item/weapon/robot_module/miner/New()
	..()
	modules += new /obj/item/borg/sight/meson(src)
	emag = new /obj/item/borg/stun(src)
	modules += new /obj/item/weapon/storage/bag/ore/cyborg(src)
	modules += new /obj/item/weapon/pickaxe/drill/cyborg(src)
	modules += new /obj/item/weapon/shovel(src)
	modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	modules += new /obj/item/device/t_scanner/adv_mining_scanner(src)
	modules += new /obj/item/weapon/gun/energy/kinetic_accelerator(src)
	fix_modules()

/obj/item/weapon/robot_module/syndicate
	name = "syndicate assault robot module"

/obj/item/weapon/robot_module/syndicate/New()
	..()
	modules += new /obj/item/weapon/melee/energy/sword/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/printer(src)
	modules += new /obj/item/weapon/gun/projectile/revolver/grenadelauncher/cyborg(src)
	modules += new /obj/item/weapon/card/emag(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	modules += new /obj/item/weapon/pinpointer/operative(src)
	emag = null
	fix_modules()

/obj/item/weapon/robot_module/syndicate_medical
	name = "syndicate medical robot module"

/obj/item/weapon/robot_module/syndicate_medical/New()
	..()
	modules += new /obj/item/weapon/reagent_containers/borghypo/syndicate(src)
	modules += new /obj/item/weapon/twohanded/shockpaddles/syndicate(src)
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/weapon/surgical_drapes(src)
	modules += new /obj/item/weapon/retractor(src)
	modules += new /obj/item/weapon/hemostat(src)
	modules += new /obj/item/weapon/cautery(src)
	modules += new /obj/item/weapon/scalpel(src)
	modules += new /obj/item/weapon/melee/energy/sword/cyborg/saw(src) //Energy saw -- primary weapon
	modules += new /obj/item/roller/robo(src)
	modules += new /obj/item/weapon/card/emag(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	modules += new /obj/item/weapon/pinpointer/operative(src)
	emag = null

	add_module(new /obj/item/stack/medical/gauze/cyborg())
	fix_modules()

/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy = 30000
	var/recharge_rate = 1000
	var/energy

/datum/robot_energy_storage/New(var/obj/item/weapon/robot_module/R = null)
	energy = max_energy
	if(R)
		R.storages |= src
	return

/datum/robot_energy_storage/proc/use_charge(amount)
	if (energy >= amount)
		energy -= amount
		if (energy == 0)
			return 1
		return 2
	else
		return 0

/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/metal
	name = "Metal Synthesizer"

/datum/robot_energy_storage/glass
	name = "Glass Synthesizer"

/datum/robot_energy_storage/wire
	max_energy = 50
	recharge_rate = 2
	name = "Wire Synthesizer"

/datum/robot_energy_storage/medical
	max_energy = 2500
	recharge_rate = 250
	name = "Medical Synthesizer"
