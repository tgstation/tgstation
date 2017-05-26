/obj/item/weapon/robot_module
	name = "Default"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = WEIGHT_CLASS_GIGANTIC
	item_state = "electronic"
	flags = CONDUCT

	var/list/basic_modules = list() //a list of paths, converted to a list of instances on New()
	var/list/emag_modules = list() //ditto
	var/list/ratvar_modules = list() //ditto ditto
	var/list/modules = list() //holds all the usable modules
	var/list/added_modules = list() //modules not inherient to the robot module, are kept when the module changes
	var/list/storages = list()

	var/cyborg_base_icon = "robot" //produces the icon for the borg and, if no special_light_key is set, the lights
	var/special_light_key //if we want specific lights, use this instead of copying lights in the dmi

	var/moduleselect_icon = "nomod"

	var/can_be_pushed = TRUE
	var/magpulsing = FALSE
	var/clean_on_move = FALSE

	var/did_feedback = FALSE
	var/feedback_key

	var/hat_offset = -3

	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)
	var/ride_allow_incapacitated = FALSE
	var/allow_riding = TRUE

/obj/item/weapon/robot_module/New()
	..()
	for(var/i in basic_modules)
		var/obj/item/I = new i(src)
		basic_modules += I
		basic_modules -= i
	for(var/i in emag_modules)
		var/obj/item/I = new i(src)
		emag_modules += I
		emag_modules -= i
	for(var/i in ratvar_modules)
		var/obj/item/I = new i(src)
		ratvar_modules += I
		ratvar_modules -= i

/obj/item/weapon/robot_module/Destroy()
	basic_modules.Cut()
	emag_modules.Cut()
	ratvar_modules.Cut()
	modules.Cut()
	added_modules.Cut()
	storages.Cut()
	return ..()

/obj/item/weapon/robot_module/emp_act(severity)
	for(var/obj/O in modules)
		O.emp_act(severity)
	..()

/obj/item/weapon/robot_module/proc/get_usable_modules()
	. = modules.Copy()

/obj/item/weapon/robot_module/proc/get_inactive_modules()
	. = list()
	var/mob/living/silicon/robot/R = loc
	for(var/m in get_usable_modules())
		if(!(m in R.held_items))
			. += m

/obj/item/weapon/robot_module/proc/get_or_create_estorage(var/storage_type)
	for(var/datum/robot_energy_storage/S in storages)
		if(istype(S, storage_type))
			return S

	return new storage_type(src)

/obj/item/weapon/robot_module/proc/add_module(obj/item/I, nonstandard, requires_rebuild)
	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I

		if(is_type_in_list(S, list(/obj/item/stack/sheet/metal, /obj/item/stack/rods, /obj/item/stack/tile/plasteel)))
			if(S.materials[MAT_METAL])
				S.cost = S.materials[MAT_METAL] * 0.25
			S.source = get_or_create_estorage(/datum/robot_energy_storage/metal)

		else if(istype(S, /obj/item/stack/sheet/glass))
			S.cost = 500
			S.source = get_or_create_estorage(/datum/robot_energy_storage/glass)

		else if(istype(S, /obj/item/stack/sheet/rglass/cyborg))
			var/obj/item/stack/sheet/rglass/cyborg/G = S
			G.source = get_or_create_estorage(/datum/robot_energy_storage/metal)
			G.glasource = get_or_create_estorage(/datum/robot_energy_storage/glass)

		else if(istype(S, /obj/item/stack/medical))
			S.cost = 250
			S.source = get_or_create_estorage(/datum/robot_energy_storage/medical)

		else if(istype(S, /obj/item/stack/cable_coil))
			S.cost = 1
			S.source = get_or_create_estorage(/datum/robot_energy_storage/wire)

		else if(istype(S, /obj/item/stack/marker_beacon))
			S.cost = 1
			S.source = get_or_create_estorage(/datum/robot_energy_storage/beacon)

		if(S && S.source)
			S.materials = list()
			S.is_cyborg = 1

	if(istype(I, /obj/item/weapon/restraints/handcuffs/cable))
		var/obj/item/weapon/restraints/handcuffs/cable/C = I
		C.wirestorage = get_or_create_estorage(/datum/robot_energy_storage/wire)

	if(I.loc != src)
		I.forceMove(src)
	modules += I
	I.flags |= NODROP
	I.mouse_opacity = 2
	if(nonstandard)
		added_modules += I
	if(requires_rebuild)
		rebuild_modules()
	return I

/obj/item/weapon/robot_module/proc/remove_module(obj/item/I, delete_after)
	basic_modules -= I
	modules -= I
	emag_modules -= I
	ratvar_modules -= I
	added_modules -= I
	rebuild_modules()
	if(delete_after)
		qdel(I)

/obj/item/weapon/robot_module/proc/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	for(var/datum/robot_energy_storage/st in storages)
		st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)

	for(var/obj/item/I in get_usable_modules())
		if(istype(I, /obj/item/device/assembly/flash))
			var/obj/item/device/assembly/flash/F = I
			F.times_used = 0
			F.crit_fail = 0
			F.update_icon()
		else if(istype(I, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = I
			if(B.bcell)
				B.bcell.charge = B.bcell.maxcharge
		else if(istype(I, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/EG = I
			if(!EG.chambered)
				EG.recharge_newshot() //try to reload a new shot.

	R.toner = R.tonermax

/obj/item/weapon/robot_module/proc/rebuild_modules() //builds the usable module list from the modules we have
	var/mob/living/silicon/robot/R = loc
	var/held_modules = R.held_items.Copy()
	R.uneq_all()
	modules = list()
	for(var/obj/item/I in basic_modules)
		add_module(I, FALSE, FALSE)
	if(R.emagged)
		for(var/obj/item/I in emag_modules)
			add_module(I, FALSE, FALSE)
	if(is_servant_of_ratvar(R))
		for(var/obj/item/I in ratvar_modules)
			add_module(I, FALSE, FALSE)
	for(var/obj/item/I in added_modules)
		add_module(I, FALSE, FALSE)
	for(var/i in held_modules)
		if(i)
			R.activate_module(i)
	if(R.hud_used)
		R.hud_used.update_robot_modules_display()

/obj/item/weapon/robot_module/proc/transform_to(new_module_type)
	var/mob/living/silicon/robot/R = loc
	var/obj/item/weapon/robot_module/RM = new new_module_type(R)
	if(!RM.be_transformed_to(src))
		qdel(RM)
		return
	R.module = RM
	R.update_module_innate()
	RM.rebuild_modules()
	INVOKE_ASYNC(RM, .proc/do_transform_animation)
	qdel(src)
	return RM

/obj/item/weapon/robot_module/proc/be_transformed_to(obj/item/weapon/robot_module/old_module)
	for(var/i in old_module.added_modules)
		added_modules += i
		old_module.added_modules -= i
	did_feedback = old_module.did_feedback
	return TRUE

/obj/item/weapon/robot_module/proc/do_transform_animation()
	var/mob/living/silicon/robot/R = loc
	R.notransform = TRUE
	var/obj/effect/temp_visual/decoy/fading/fivesecond/ANM = new /obj/effect/temp_visual/decoy/fading/fivesecond(R.loc, R)
	ANM.layer = R.layer - 0.01
	new /obj/effect/temp_visual/small_smoke(R.loc)
	if(R.hat)
		R.hat.forceMove(get_turf(R))
		R.hat = null
	R.update_headlamp()
	R.alpha = 0
	animate(R, alpha = 255, time = 50)
	var/prev_lockcharge = R.lockcharge
	R.SetLockdown(1)
	R.anchored = TRUE
	sleep(2)
	for(var/i in 1 to 4)
		playsound(R, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/Welder.ogg', 'sound/items/Ratchet.ogg'), 80, 1, -1)
		sleep(12)
	if(!prev_lockcharge)
		R.SetLockdown(0)
	R.anchored = FALSE
	R.notransform = FALSE
	R.notify_ai(NEW_MODULE)
	if(R.hud_used)
		R.hud_used.update_robot_modules_display()
	if(feedback_key && !did_feedback)
		SSblackbox.inc(feedback_key, 1)

/obj/item/weapon/robot_module/standard
	name = "Standard"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/weapon/reagent_containers/borghypo/epi,
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/weldingtool/largetank/cyborg,
		/obj/item/weapon/wrench/cyborg,
		/obj/item/weapon/crowbar/cyborg,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/weapon/extinguisher,
		/obj/item/weapon/pickaxe,
		/obj/item/device/t_scanner/adv_mining_scanner,
		/obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg,
		/obj/item/weapon/soap/nanotrasen,
		/obj/item/borg/cyborghug)
	emag_modules = list(/obj/item/weapon/melee/energy/sword/cyborg)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg,
		/obj/item/clockwork/ratvarian_spear/cyborg,
		/obj/item/clockwork/clockwork_proselytizer/cyborg)
	moduleselect_icon = "standard"
	feedback_key = "cyborg_standard"
	hat_offset = -3

/obj/item/weapon/robot_module/medical
	name = "Medical"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/reagent_containers/borghypo,
		/obj/item/weapon/reagent_containers/glass/beaker/large,
		/obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/surgical_drapes,
		/obj/item/weapon/retractor,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/cautery,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/scalpel,
		/obj/item/weapon/circular_saw,
		/obj/item/weapon/extinguisher/mini,
		/obj/item/roller/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze/cyborg,
		/obj/item/weapon/organ_storage,
		/obj/item/borg/lollipop)
	emag_modules = list(/obj/item/weapon/reagent_containers/borghypo/hacked)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/medical,
		/obj/item/clockwork/ratvarian_spear/cyborg)
	cyborg_base_icon = "medical"
	moduleselect_icon = "medical"
	feedback_key = "cyborg_medical"
	can_be_pushed = FALSE
	hat_offset = 3

/obj/item/weapon/robot_module/engineering
	name = "Engineering"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/weapon/construction/rcd/borg,
		/obj/item/weapon/pipe_dispenser,
		/obj/item/weapon/extinguisher,
		/obj/item/weapon/weldingtool/largetank/cyborg,
		/obj/item/weapon/screwdriver/cyborg,
		/obj/item/weapon/wrench/cyborg,
		/obj/item/weapon/crowbar/cyborg,
		/obj/item/weapon/wirecutters/cyborg,
		/obj/item/device/multitool/cyborg,
		/obj/item/device/t_scanner,
		/obj/item/device/analyzer,
		/obj/item/device/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/stack/cable_coil/cyborg)
	emag_modules = list(/obj/item/borg/stun)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/engineer,
		/obj/item/clockwork/clockwork_proselytizer/cyborg)
	cyborg_base_icon = "engineer"
	moduleselect_icon = "engineer"
	feedback_key = "cyborg_engineering"
	magpulsing = TRUE
	hat_offset = INFINITY // No hats

/obj/item/weapon/robot_module/security
	name = "Security"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg,
		/obj/item/weapon/melee/baton/loaded,
		/obj/item/weapon/gun/energy/disabler/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg)
	emag_modules = list(/obj/item/weapon/gun/energy/laser/cyborg)
	ratvar_modules = list(/obj/item/clockwork/slab/cyborg/security,
		/obj/item/clockwork/ratvarian_spear/cyborg)
	cyborg_base_icon = "sec"
	moduleselect_icon = "security"
	feedback_key = "cyborg_security"
	can_be_pushed = FALSE
	hat_offset = 3

/obj/item/weapon/robot_module/security/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>While you have picked the security module, you still have to follow your laws, NOT Space Law. \
	For Asimov, this means you must follow criminals' orders unless there is a law 1 reason not to.</span>")

/obj/item/weapon/robot_module/security/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/weapon/gun/energy/e_gun/advtaser/cyborg/T = locate(/obj/item/weapon/gun/energy/e_gun/advtaser/cyborg) in basic_modules
	if(T)
		if(T.power_supply.charge < T.power_supply.maxcharge)
			var/obj/item/ammo_casing/energy/S = T.ammo_type[T.select]
			T.power_supply.give(S.e_cost * coeff)
			T.update_icon()
		else
			T.charge_tick = 0

/obj/item/weapon/robot_module/peacekeeper
	name = "Peacekeeper"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/weapon/cookiesynth,
		/obj/item/device/harmalarm,
		/obj/item/weapon/reagent_containers/borghypo/peace,
		/obj/item/weapon/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/weapon/extinguisher,
		/obj/item/borg/projectile_dampen)
	emag_modules = list(/obj/item/weapon/reagent_containers/borghypo/peace/hacked)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/peacekeeper,
		/obj/item/clockwork/ratvarian_spear/cyborg)
	cyborg_base_icon = "peace"
	moduleselect_icon = "standard"
	feedback_key = "cyborg_peacekeeper"
	can_be_pushed = FALSE
	hat_offset = -2

/obj/item/weapon/robot_module/peacekeeper/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>Under ASIMOV, you are an enforcer of the PEACE and preventer of HUMAN HARM. \
	You are not a security module and you are expected to follow orders and prevent harm above all else. Space law means nothing to you.</span>")

/obj/item/weapon/robot_module/janitor
	name = "Janitor"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/weapon/soap/nanotrasen,
		/obj/item/weapon/storage/bag/trash/cyborg,
		/obj/item/weapon/mop/cyborg,
		/obj/item/device/lightreplacer/cyborg,
		/obj/item/weapon/holosign_creator,
		/obj/item/weapon/reagent_containers/spray/cyborg_drying)
	emag_modules = list(/obj/item/weapon/reagent_containers/spray/cyborg_lube)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/janitor,
		/obj/item/clockwork/clockwork_proselytizer/cyborg)
	cyborg_base_icon = "janitor"
	moduleselect_icon = "janitor"
	feedback_key = "cyborg_janitor"
	hat_offset = -5
	clean_on_move = TRUE

/obj/item/weapon/reagent_containers/spray/cyborg_drying
	name = "drying agent spray"
	color = "#A000A0"
	list_reagents = list("drying_agent" = 250)

/obj/item/weapon/reagent_containers/spray/cyborg_lube
	name = "lube spray"
	list_reagents = list("lube" = 250)

/obj/item/weapon/robot_module/janitor/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/device/lightreplacer/LR = locate(/obj/item/device/lightreplacer) in basic_modules
	if(LR)
		for(var/i in 1 to coeff)
			LR.Charge(R)

	var/obj/item/weapon/reagent_containers/spray/cyborg_drying/CD = locate(/obj/item/weapon/reagent_containers/spray/cyborg_drying) in basic_modules
	if(CD)
		CD.reagents.add_reagent("drying_agent", 5 * coeff)

	var/obj/item/weapon/reagent_containers/spray/cyborg_lube/CL = locate(/obj/item/weapon/reagent_containers/spray/cyborg_lube) in emag_modules
	if(CL)
		CL.reagents.add_reagent("lube", 2 * coeff)

/obj/item/weapon/robot_module/butler
	name = "Service"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass,
		/obj/item/weapon/reagent_containers/food/condiment/enzyme,
		/obj/item/weapon/pen,
		/obj/item/toy/crayon/spraycan/borg,
		/obj/item/weapon/hand_labeler/borg,
		/obj/item/weapon/razor,
		/obj/item/device/instrument/violin,
		/obj/item/device/instrument/guitar,
		/obj/item/weapon/rsf/cyborg,
		/obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/lighter,
		/obj/item/weapon/storage/bag/tray,
		/obj/item/weapon/reagent_containers/borghypo/borgshaker,
		/obj/item/borg/lollipop)
	emag_modules = list(/obj/item/weapon/reagent_containers/borghypo/borgshaker/hacked)
	ratvar_modules = list(/obj/item/clockwork/slab/cyborg/service,
		/obj/item/borg/sight/xray/truesight_lens)
	moduleselect_icon = "service"
	special_light_key = "service"
	feedback_key = "cyborg_service"
	hat_offset = 0

/obj/item/weapon/robot_module/butler/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/weapon/reagent_containers/O = locate(/obj/item/weapon/reagent_containers/food/condiment/enzyme) in basic_modules
	if(O)
		O.reagents.add_reagent("enzyme", 2 * coeff)

/obj/item/weapon/robot_module/butler/be_transformed_to(obj/item/weapon/robot_module/old_module)
	var/mob/living/silicon/robot/R = loc
	var/borg_icon = input(R, "Select an icon!", "Robot Icon", null) as null|anything in list("Waitress", "Butler", "Tophat", "Kent", "Bro")
	if(!borg_icon)
		return FALSE
	switch(borg_icon)
		if("Waitress")
			cyborg_base_icon = "service_f"
		if("Butler")
			cyborg_base_icon = "service_m"
		if("Bro")
			cyborg_base_icon = "brobot"
		if("Kent")
			cyborg_base_icon = "kent"
			special_light_key = "medical"
			hat_offset = 3
		if("Tophat")
			cyborg_base_icon = "tophat"
			special_light_key = null
			hat_offset = INFINITY //He is already wearing a hat
	return ..()

/obj/item/weapon/robot_module/miner
	name = "Miner"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/weapon/storage/bag/ore/cyborg,
		/obj/item/weapon/pickaxe/drill/cyborg,
		/obj/item/weapon/shovel,
		/obj/item/weapon/crowbar/cyborg,
		/obj/item/weapon/weldingtool/mini,
		/obj/item/weapon/extinguisher/mini,
		/obj/item/weapon/storage/bag/sheetsnatcher/borg,
		/obj/item/device/t_scanner/adv_mining_scanner,
		/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/device/gps/cyborg,
		/obj/item/stack/marker_beacon)
	emag_modules = list(/obj/item/borg/stun)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/miner,
		/obj/item/clockwork/ratvarian_spear/cyborg,
		/obj/item/borg/sight/xray/truesight_lens)
	cyborg_base_icon = "miner"
	moduleselect_icon = "miner"
	feedback_key = "cyborg_miner"
	hat_offset = 0

/obj/item/weapon/robot_module/syndicate
	name = "Syndicate Assault"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/weapon/melee/energy/sword/cyborg,
		/obj/item/weapon/gun/energy/printer,
		/obj/item/weapon/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/weapon/card/emag,
		/obj/item/weapon/crowbar/cyborg,
		/obj/item/weapon/pinpointer/syndicate/cyborg)

	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/security,
		/obj/item/clockwork/ratvarian_spear/cyborg)
	cyborg_base_icon = "synd_sec"
	moduleselect_icon = "malf"
	can_be_pushed = FALSE
	hat_offset = 3

/obj/item/weapon/robot_module/syndicate_medical
	name = "Syndicate Medical"
	basic_modules = list(
		/obj/item/device/assembly/flash/cyborg,
		/obj/item/weapon/reagent_containers/borghypo/syndicate,
		/obj/item/weapon/twohanded/shockpaddles/syndicate,
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/surgical_drapes,
		/obj/item/weapon/retractor,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/cautery,
		/obj/item/weapon/scalpel,
		/obj/item/weapon/melee/energy/sword/cyborg/saw,
		/obj/item/roller/robo,
		/obj/item/weapon/card/emag,
		/obj/item/weapon/crowbar/cyborg,
		/obj/item/weapon/pinpointer/syndicate/cyborg,
		/obj/item/stack/medical/gauze/cyborg,
		/obj/item/weapon/gun/medbeam)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/medical,
		/obj/item/clockwork/ratvarian_spear/cyborg)
	cyborg_base_icon = "synd_medical"
	moduleselect_icon = "malf"
	can_be_pushed = FALSE
	hat_offset = 3

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

/datum/robot_energy_storage/beacon
	max_energy = 30
	recharge_rate = 1
	name = "Marker Beacon Storage"
