<<<<<<< HEAD
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
	modules += new /obj/item/weapon/reagent_containers/borghypo/epi(src)
	modules += new /obj/item/device/healthanalyzer(src)

	modules += new /obj/item/weapon/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/weapon/wrench/cyborg(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	add_module(new /obj/item/stack/sheet/metal/cyborg())
	modules += new /obj/item/weapon/extinguisher(src)

	modules += new /obj/item/weapon/pickaxe(src)
	modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)

	modules += new /obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg(src)

	modules += new /obj/item/weapon/soap/nanotrasen(src)

	modules += new /obj/item/borg/cyborghug(src)

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
	modules += new /obj/item/borg/cyborghug(src)

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
	modules += new /obj/item/areaeditor/blueprints/cyborg(src)

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

/obj/item/weapon/robot_module/peacekeeper
	name = "peacekeeper robot module"

/obj/item/weapon/robot_module/peacekeeper/New()
	..()
	modules += new /obj/item/weapon/cookiesynth(src)
	modules += new /obj/item/device/harmalarm(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/peace(src)
	modules += new /obj/item/weapon/holosign_creator/cyborg(src)
	modules += new /obj/item/borg/cyborghug/peacekeeper(src)
	modules += new /obj/item/weapon/extinguisher(src)

	emag = new /obj/item/weapon/reagent_containers/borghypo/peace/hacked(src)

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
	modules += new /obj/item/toy/crayon/spraycan/borg(src)
	modules += new /obj/item/weapon/hand_labeler/borg(src)
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
	modules += new /obj/item/weapon/weldingtool/mini(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	modules += new /obj/item/device/t_scanner/adv_mining_scanner(src)
	modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/cyborg(src)
	modules += new /obj/item/device/gps/cyborg(src)
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
	modules += new /obj/item/weapon/pinpointer/syndicate/cyborg(src)
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
	modules += new /obj/item/weapon/pinpointer/syndicate/cyborg(src)
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
=======
/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	//icon_state = "std_module"
	w_class = W_CLASS_GIANT
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1

	var/list/modules = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null
	var/recharge_tick = 0
	var/recharge_time = 10 // when to recharge a consumable, only used for engi borgs atm
	var/list/sensor_augs
	var/languages
	var/list/added_languages
	var/list/upgrades = list()

/obj/item/weapon/robot_module/proc/recharge_consumable()
	return

/obj/item/weapon/robot_module/proc/on_emag()
	modules += emag
	rebuild()
	..()

/obj/item/weapon/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)
	if(emag)
		emag.emp_act(severity)
	..()
	return

/obj/item/weapon/robot_module/New(var/mob/living/silicon/robot/R)
	..()

	languages = list(	LANGUAGE_GALACTIC_COMMON = 1, LANGUAGE_TRADEBAND = 1, LANGUAGE_VOX = 0,
						LANGUAGE_ROOTSPEAK = 0, LANGUAGE_GREY = 0, LANGUAGE_CLATTER = 0,
						LANGUAGE_MONKEY = 0, LANGUAGE_UNATHI = 0, LANGUAGE_SIIK_TAJR = 0,
						LANGUAGE_SKRELLIAN = 0, LANGUAGE_GUTTER = 0, LANGUAGE_MONKEY = 0,
						LANGUAGE_MOUSE = 0, LANGUAGE_HUMAN = 0)
	added_languages = list()
	if(!isMoMMI(R)) add_languages(R)
	AddToProfiler()
	src.modules += new /obj/item/device/flashlight(src)
	src.modules += new /obj/item/device/flash(src)
	src.emag = new /obj/item/toy/sword(src)
	src.emag.name = "Placeholder Emag Item"
//		src.jetpack = new /obj/item/toy/sword(src)
//		src.jetpack.name = "Placeholder Upgrade Item"
	return

obj/item/weapon/robot_module/proc/fix_modules() //call this proc to enable clicking the slot of a module to equip it.
	for(var/obj/item/I in modules)
		I.mouse_opacity = 2
	if(emag)
		emag.mouse_opacity = 2

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

/obj/item/weapon/robot_module/standard/New()
	..()
	src.modules += new /obj/item/weapon/melee/baton/loaded(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/weapon/soap/nanotrasen(src)
	src.modules += new /obj/item/device/taperecorder(src)
	src.modules += new /obj/item/device/megaphone(src)
	src.emag = new /obj/item/weapon/melee/energy/sword(src)
	sensor_augs = list("Security", "Medical", "Mesons", "Disable")


	var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(src)
	B.max_amount = 15
	B.amount = 15
	src.modules += B

	var/obj/item/stack/medical/ointment/O = new /obj/item/stack/medical/ointment(src)
	O.max_amount = 15
	O.amount = 15
	src.modules += O

	fix_modules()

/obj/item/weapon/robot_module/standard/respawn_consumable(var/mob/living/silicon/robot/R)
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
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/medical))
				O.max_amount = 15
			src.modules += O
			O.amount = 1
	return



/obj/item/weapon/robot_module/medical
	name = "medical robot module"


/obj/item/weapon/robot_module/medical/New()
	..()
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg(src,src)
	src.modules += new /obj/item/weapon/reagent_containers/dropper/robodropper(src)
	src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
	src.modules += new /obj/item/weapon/storage/bag/chem(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/scalpel(src)
	src.modules += new /obj/item/weapon/hemostat(src)
	src.modules += new /obj/item/weapon/retractor(src)
	src.modules += new /obj/item/weapon/circular_saw(src)
	src.modules += new /obj/item/weapon/cautery(src)
	src.modules += new /obj/item/weapon/bonegel(src)
	src.modules += new /obj/item/weapon/bonesetter(src)
	src.modules += new /obj/item/weapon/FixOVein(src)
	src.modules += new /obj/item/weapon/surgicaldrill(src)
	src.modules += new /obj/item/weapon/revivalprod(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	sensor_augs = list("Medical", "Disable")

	src.emag.reagents.add_reagent(PACID, 250)
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

	fix_modules()

/obj/item/weapon/robot_module/medical/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/splint,
	)
	for (var/T in what)
		if (!(locate(T) in src.modules))
			src.modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/medical))
				O.max_amount = 15
			src.modules += O
			O.amount = 1
	return


/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"


/obj/item/weapon/robot_module/engineering/New()
	..()
	src.emag = new /obj/item/borg/stun(src)
	src.modules += new /obj/item/device/rcd/borg/engineering(src)
	src.modules += new /obj/item/device/rcd/rpd(src) //What could possibly go wrong?
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/extinguisher/foam(src)
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
	src.modules += new /obj/item/device/rcd/tile_painter(src)
	src.modules += new /obj/item/device/material_synth/robot(src)
	src.modules += new /obj/item/device/silicate_sprayer(src)
	src.modules += new /obj/item/device/holomap(src)
	sensor_augs = list("Mesons", "Disable")

	var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
	W.amount = 50
	W.max_amount = 50
	src.modules += W

	fix_modules()


/obj/item/weapon/robot_module/engineering/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/cable_coil
	)
	for (var/T in what)
		if (!(locate(T) in src.modules))
			src.modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/cable_coil))
				O.max_amount = 50
			src.modules += O
			O.amount = 1
	return

/obj/item/weapon/robot_module/engineering/recharge_consumable(var/mob/living/silicon/robot/R)
	for(var/T in src.modules)
		if(!(locate(T) in src.modules)) //Remove nulls
			src.modules -= null

	recharge_tick++
	if(recharge_tick < recharge_time) return 0
	recharge_tick = 0
	if(R && R.cell)
		respawn_consumable(R)
		var/list/um = R.contents|R.module.modules
		// ^ makes sinle list of active (R.contents) and inactive modules (R.module.modules)
		for(var/obj/item/stack/O in um)
			// Engineering
			if(istype(O,/obj/item/stack/cable_coil))
				if(O.amount < 50)
					O.amount += 1
					R.cell.use(50) 		//Take power from the borg...
				if(O.amount > 50)
					O.amount = 50


/obj/item/weapon/robot_module/security
	name = "security robot module"

/obj/item/weapon/robot_module/security/New()
	..()
	src.modules += new /obj/item/weapon/melee/baton/loaded(src)
	src.modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
	src.modules += new /obj/item/weapon/handcuffs/cyborg(src)
	src.modules += new /obj/item/weapon/reagent_containers/spray/pepper(src)
	src.modules += new /obj/item/taperoll/police(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)
	sensor_augs = list("Security", "Medical", "Disable")
	fix_modules()

/obj/item/weapon/robot_module/security/respawn_consumable(var/mob/living/silicon/robot/R)
	// Recharge baton battery
	for(var/obj/item/M in src.modules)
		if(istype(M,/obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B=M
			if(B && B.bcell)
				B.bcell.give(175)

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"


/obj/item/weapon/robot_module/janitor/New()
	..()
	src.modules += new /obj/item/weapon/soap/nanotrasen(src)
	src.modules += new /obj/item/weapon/storage/bag/trash(src)
	src.modules += new /obj/item/weapon/mop(src)
	src.modules += new /obj/item/device/lightreplacer/borg(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/bucket(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)

	src.emag.reagents.add_reagent(LUBE, 250)
	src.emag.name = "Lube spray"
	fix_modules()



/obj/item/weapon/robot_module/butler
	name = "service robot module"


/obj/item/weapon/robot_module/butler/New()
	languages = list(
					LANGUAGE_GALACTIC_COMMON	= 1,
					LANGUAGE_UNATHI		= 1,
					LANGUAGE_SIIK_TAJR	= 1,
					LANGUAGE_SKRELLIAN	= 1,
					LANGUAGE_ROOTSPEAK	= 1,
					LANGUAGE_TRADEBAND	= 1,
					LANGUAGE_GUTTER		= 1,
					LANGUAGE_MONKEY		= 1,
					)
	..()
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
	src.modules += new /obj/item/weapon/pen/robopen(src)

	src.modules += new /obj/item/device/rcd/borg/rsf(src)

	src.modules += new /obj/item/weapon/reagent_containers/dropper/robodropper(src)

	var/obj/item/weapon/lighter/zippo/L = new /obj/item/weapon/lighter/zippo(src)
	L.lit = 1
	L.update_brightness()
	src.modules += L

	src.modules += new /obj/item/weapon/tray/robotray(src)

	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)

	src.modules += new /obj/item/weapon/dice/borg(src)

	src.modules += new /obj/item/weapon/crowbar(src)

	src.emag = new /obj/item/weapon/reagent_containers/food/drinks/beer(src)

	var/datum/reagents/R = new/datum/reagents(50)
	src.emag.reagents = R
	R.my_atom = src.emag
	R.add_reagent(BEER2, 50)
	src.emag.name = "Mickey Finn's Special Brew"
	fix_modules()



/obj/item/weapon/robot_module/miner
	name = "supply robot module"

/obj/item/weapon/robot_module/miner/New()
	..()
	src.emag = new /obj/item/borg/stun(src)
	src.modules += new /obj/item/weapon/storage/bag/ore(src)
	src.modules += new /obj/item/weapon/pickaxe/drill/borg(src)
	src.modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	src.modules += new /obj/item/device/mining_scanner(src)
	src.modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/cyborg(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	sensor_augs = list("Mesons", "Disable")
//		src.modules += new /obj/item/weapon/pickaxe/shovel(src) Uneeded due to buffed drill

	var/obj/item/device/destTagger/tag = new /obj/item/device/destTagger(src)
	tag.mode = 1 //For editing the tag list
	src.modules += tag

	var/obj/item/stack/package_wrap/W = new /obj/item/stack/package_wrap(src)
	W.amount = 24
	W.max_amount = 24
	src.modules += W

	fix_modules()

/obj/item/weapon/robot_module/miner/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		/obj/item/stack/package_wrap
	)
	for (var/T in what)
		if (!(locate(T) in src.modules))
			src.modules -= null
			var/obj/item/stack/O = new T(src)
			if(istype(O,/obj/item/stack/package_wrap))
				O.max_amount = 24
			src.modules += O
			O.amount = 1

/obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"


/obj/item/weapon/robot_module/syndicate/New()
	src.modules += new /obj/item/weapon/melee/energy/sword(src)
	src.modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
	src.modules += new /obj/item/weapon/card/emag(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	sensor_augs = list("Security", "Medical", "Mesons", "Thermal", "Light Amplification", "Disable")
	fix_modules()

/obj/item/weapon/robot_module/combat
	name = "combat robot module"

/obj/item/weapon/robot_module/combat/New()
	src.modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
	src.modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
	src.modules += new /obj/item/borg/combat/shield(src)
	src.modules += new /obj/item/borg/combat/mobility(src)
	src.modules += new /obj/item/weapon/wrench(src) //Is a combat android really going to be stopped by a chair?
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = new /obj/item/weapon/gun/energy/lasercannon/cyborg(src)
	sensor_augs = list("Security", "Medical", "Mesons", "Thermal", "Light Amplification", "Disable")

	fix_modules()

/obj/item/weapon/robot_module/proc/add_languages(var/mob/living/silicon/robot/R)
	for(var/language in languages)
		if(R.add_language(language, languages[language]))
			added_languages |= language

/obj/item/weapon/robot_module/proc/remove_languages(var/mob/living/silicon/robot/R)
	for(var/language in added_languages)
		R.remove_language(language)
	added_languages.len = 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
