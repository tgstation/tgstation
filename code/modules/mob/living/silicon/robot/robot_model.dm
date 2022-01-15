/**
 * # robot_model
 *
 * Definition of /obj/item/robot_model, which defines behavior for each model.
 * Deals with the creation and deletion of modules (tools).
 * Assigns modules and traits to a borg with a specific model selected.
 *
 **/
/obj/item/robot_model
	name = "Default"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	w_class = WEIGHT_CLASS_GIGANTIC
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	///Host of this model
	var/mob/living/silicon/robot/robot
	///Icon of the module selection screen
	var/model_select_icon = "nomod"
	///Produces the icon for the borg and, if no special_light_key is set, the lights
	var/cyborg_base_icon = "robot"
	///If we want specific lights, use this instead of copying lights in the dmi
	var/special_light_key
	///Holds all the usable modules (tools)
	var/list/modules = list()
	///Paths of modules to be created when the model is created
	var/list/basic_modules = list()
	///Paths of modules to be created on emagging
	var/list/emag_modules = list()
	///Modules not inherent to the robot configuration
	var/list/added_modules = list()
	///Storage types of the model
	var/list/storages = list()
	///List of traits that will be applied to the mob if this model is used.
	var/list/model_traits = null
	///List of radio channels added to the cyborg
	var/list/radio_channels = list()
	///Whether the borg loses tool slots with damage.
	var/breakable_modules = TRUE
	///Whether swapping to this configuration should lockcharge the borg
	var/locked_transform = TRUE
	///Can we be ridden
	var/allow_riding = TRUE
	///Whether the borg can stuff itself into disposals
	var/canDispose = FALSE
	///The y offset of  the hat put on
	var/hat_offset = -3
	///The x offsets of a person riding the borg
	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	///The y offsets of a person riding the borg
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)
	///List of skins the borg can be reskinned to, optional
	var/list/borg_skins

/obj/item/robot_model/Initialize(mapload)
	. = ..()
	for(var/path in basic_modules)
		var/obj/item/new_module = new path(src)
		basic_modules += new_module
		basic_modules -= path
	for(var/path in emag_modules)
		var/obj/item/new_module = new path(src)
		emag_modules += new_module
		emag_modules -= path

/obj/item/robot_model/Destroy()
	basic_modules.Cut()
	emag_modules.Cut()
	modules.Cut()
	added_modules.Cut()
	storages.Cut()
	return ..()

/obj/item/robot_model/proc/get_usable_modules()
	. = modules.Copy()

/obj/item/robot_model/proc/get_inactive_modules()
	. = list()
	var/mob/living/silicon/robot/cyborg = loc
	for(var/module in get_usable_modules())
		if(!(module in cyborg.held_items))
			. += module

/obj/item/robot_model/proc/add_module(obj/item/added_module, nonstandard, requires_rebuild)
	if(istype(added_module, /obj/item/stack))
		var/obj/item/stack/sheet_module = added_module
		if(ispath(sheet_module.source, /datum/robot_energy_storage))
			sheet_module.source = get_or_create_estorage(sheet_module.source)

		if(istype(sheet_module, /obj/item/stack/sheet/rglass/cyborg))
			var/obj/item/stack/sheet/rglass/cyborg/rglass_module = sheet_module
			if(ispath(rglass_module.glasource, /datum/robot_energy_storage))
				rglass_module.glasource = get_or_create_estorage(rglass_module.glasource)

		if(istype(sheet_module.source))
			sheet_module.cost = max(sheet_module.cost, 1) // Must not cost 0 to prevent div/0 errors.
			sheet_module.is_cyborg = TRUE

	if(added_module.loc != src)
		added_module.forceMove(src)
	modules += added_module
	ADD_TRAIT(added_module, TRAIT_NODROP, CYBORG_ITEM_TRAIT)
	added_module.mouse_opacity = MOUSE_OPACITY_OPAQUE
	if(nonstandard)
		added_modules += added_module
	if(requires_rebuild)
		rebuild_modules()
	return added_module

/obj/item/robot_model/proc/remove_module(obj/item/removed_module, delete_after)
	basic_modules -= removed_module
	modules -= removed_module
	emag_modules -= removed_module
	added_modules -= removed_module
	rebuild_modules()
	if(delete_after)
		qdel(removed_module)

/obj/item/robot_model/proc/rebuild_modules() //builds the usable module list from the modules we have
	var/mob/living/silicon/robot/cyborg = loc
	if (!istype(cyborg))
		return
	var/list/held_modules = cyborg.held_items.Copy()
	var/active_module = cyborg.module_active
	cyborg.uneq_all()
	modules = list()
	for(var/obj/item/module in basic_modules)
		add_module(module, FALSE, FALSE)
	if(cyborg.emagged)
		for(var/obj/item/module in emag_modules)
			add_module(module, FALSE, FALSE)
	for(var/obj/item/module in added_modules)
		add_module(module, FALSE, FALSE)
	for(var/module in held_modules)
		if(module)
			cyborg.equip_module_to_slot(module, held_modules.Find(module))
	if(active_module)
		cyborg.select_module(held_modules.Find(active_module))
	if(cyborg.hud_used)
		cyborg.hud_used.update_robot_modules_display()

/obj/item/robot_model/proc/respawn_consumable(mob/living/silicon/robot/cyborg, coeff = 1)
	for(var/datum/robot_energy_storage/storage_datum in storages)
		storage_datum.energy = min(storage_datum.max_energy, storage_datum.energy + coeff * storage_datum.recharge_rate)

	for(var/obj/item/module in get_usable_modules())
		if(istype(module, /obj/item/assembly/flash))
			var/obj/item/assembly/flash/flash = module
			flash.times_used = 0
			flash.burnt_out = FALSE
			flash.update_appearance()
		else if(istype(module, /obj/item/melee/baton/security))
			var/obj/item/melee/baton/security/baton = module
			baton.cell?.charge = baton.cell.maxcharge
		else if(istype(module, /obj/item/gun/energy))
			var/obj/item/gun/energy/gun = module
			if(!gun.chambered)
				gun.recharge_newshot() //try to reload a new shot.

	cyborg.toner = cyborg.tonermax

/obj/item/robot_model/proc/get_or_create_estorage(storage_type)
	return (locate(storage_type) in storages) || new storage_type(src)

/obj/item/robot_model/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/module in modules)
		module.emp_act(severity)
	..()

/obj/item/robot_model/proc/transform_to(new_config_type, forced = FALSE)
	var/mob/living/silicon/robot/cyborg = loc
	var/obj/item/robot_model/new_model = new new_config_type(cyborg)
	new_model.robot = cyborg
	if(!new_model.be_transformed_to(src, forced))
		qdel(new_model)
		return
	cyborg.model = new_model
	cyborg.update_module_innate()
	new_model.rebuild_modules()
	cyborg.radio.recalculateChannels()
	cyborg.set_modularInterface_theme()
	cyborg.diag_hud_set_health()
	cyborg.diag_hud_set_status()
	cyborg.diag_hud_set_borgcell()
	cyborg.diag_hud_set_aishell()
	log_silicon("CYBORG: [key_name(cyborg)] has transformed into the [new_model] model.")

	INVOKE_ASYNC(new_model, .proc/do_transform_animation)
	qdel(src)
	return new_model

/obj/item/robot_model/proc/be_transformed_to(obj/item/robot_model/old_model, forced = FALSE)
	if(islist(borg_skins) && !forced)
		var/mob/living/silicon/robot/cyborg = loc
		var/list/reskin_icons = list()
		for(var/skin in borg_skins)
			var/list/details = borg_skins[skin]
			reskin_icons[skin] = image(icon = details[SKIN_ICON] || 'icons/mob/robots.dmi', icon_state = details[SKIN_ICON_STATE])
		var/borg_skin = show_radial_menu(cyborg, cyborg, reskin_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_model), radius = 38, require_near = TRUE)
		if(!borg_skin)
			return FALSE
		var/list/details = borg_skins[borg_skin]
		if(!isnull(details[SKIN_ICON_STATE]))
			cyborg_base_icon = details[SKIN_ICON_STATE]
		if(!isnull(details[SKIN_ICON]))
			cyborg.icon = details[SKIN_ICON]
		if(!isnull(details[SKIN_PIXEL_X]))
			cyborg.base_pixel_x = details[SKIN_PIXEL_X]
		if(!isnull(details[SKIN_PIXEL_Y]))
			cyborg.base_pixel_y = details[SKIN_PIXEL_Y]
		if(!isnull(details[SKIN_LIGHT_KEY]))
			special_light_key = details[SKIN_LIGHT_KEY]
		if(!isnull(details[SKIN_HAT_OFFSET]))
			hat_offset = details[SKIN_HAT_OFFSET]
		if(!isnull(details[SKIN_TRAITS]))
			model_traits += details[SKIN_TRAITS]
	for(var/i in old_model.added_modules)
		added_modules += i
		old_model.added_modules -= i
	return TRUE

/obj/item/robot_model/proc/do_transform_animation()
	var/mob/living/silicon/robot/cyborg = loc
	if(cyborg.hat)
		cyborg.hat.forceMove(drop_location())
		cyborg.hat = null
	cyborg.cut_overlays()
	cyborg.setDir(SOUTH)
	do_transform_delay()

/obj/item/robot_model/proc/do_transform_delay()
	var/mob/living/silicon/robot/cyborg = loc
	var/prev_lockcharge = cyborg.lockcharge
	sleep(1)
	flick("[cyborg_base_icon]_transform", cyborg)
	cyborg.notransform = TRUE
	if(locked_transform)
		cyborg.SetLockdown(TRUE)
		cyborg.set_anchored(TRUE)
	cyborg.logevent("Chassis model has been set to [name].")
	sleep(1)
	for(var/i in 1 to 4)
		playsound(cyborg, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, TRUE, -1)
		sleep(7)
	cyborg.SetLockdown(prev_lockcharge)
	cyborg.setDir(SOUTH)
	cyborg.set_anchored(FALSE)
	cyborg.notransform = FALSE
	cyborg.updatehealth()
	cyborg.update_icons()
	cyborg.notify_ai(AI_NOTIFICATION_NEW_MODEL)
	if(cyborg.hud_used)
		cyborg.hud_used.update_robot_modules_display()
	SSblackbox.record_feedback("tally", "cyborg_modules", 1, cyborg.model)

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The cyborg mob interacting with the menu
 * * old_model The old cyborg's model
 */
/obj/item/robot_model/proc/check_menu(mob/living/silicon/robot/user, obj/item/robot_model/old_model)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(user.model != old_model)
		return FALSE
	return TRUE

/obj/item/robot_model/clown
	name = "Clown"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/toy/crayon/rainbow,
		/obj/item/instrument/bikehorn,
		/obj/item/stamp/clown,
		/obj/item/bikehorn,
		/obj/item/bikehorn/airhorn,
		/obj/item/paint/anycolor,
		/obj/item/soap/nanotrasen,
		/obj/item/pneumatic_cannon/pie/selfcharge/cyborg,
		/obj/item/razor, //killbait material
		/obj/item/lipstick/purple,
		/obj/item/reagent_containers/spray/waterflower/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/borg/lollipop/clown,
		/obj/item/picket_sign/cyborg,
		/obj/item/reagent_containers/borghypo/clown,
		/obj/item/extinguisher/mini)
	emag_modules = list(
		/obj/item/reagent_containers/borghypo/clown/hacked,
		/obj/item/reagent_containers/spray/waterflower/cyborg/hacked)
	model_select_icon = "service"
	cyborg_base_icon = "clown"
	hat_offset = -2

/obj/item/robot_model/engineering
	name = "Engineering"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/stack/cable_coil)
	radio_channels = list(RADIO_CHANNEL_ENGINEERING)
	emag_modules = list(/obj/item/borg/stun)
	cyborg_base_icon = "engineer"
	model_select_icon = "engineer"
	model_traits = list(TRAIT_NEGATES_GRAVITY)
	hat_offset = -4

/obj/item/robot_model/janitor
	name = "Janitor"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/soap/nanotrasen,
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/melee/flyswatter,
		/obj/item/extinguisher/mini,
		/obj/item/mop/cyborg,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/paint/paint_remover,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator/janibarrier,
		/obj/item/reagent_containers/spray/cyborg_drying)
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	emag_modules = list(/obj/item/reagent_containers/spray/cyborg_lube)
	cyborg_base_icon = "janitor"
	model_select_icon = "janitor"
	hat_offset = -5

/obj/item/reagent_containers/spray/cyborg_drying
	name = "drying agent spray"
	color = "#A000A0"
	list_reagents = list(/datum/reagent/drying_agent = 250)

/obj/item/reagent_containers/spray/cyborg_lube
	name = "lube spray"
	list_reagents = list(/datum/reagent/lube = 250)

/obj/item/robot_model/janitor/respawn_consumable(mob/living/silicon/robot/cyborg, coeff = 1)
	..()
	var/obj/item/lightreplacer/light_replacer = locate(/obj/item/lightreplacer) in basic_modules
	if(light_replacer)
		for(var/charge in 1 to coeff)
			light_replacer.Charge(cyborg)

	var/obj/item/reagent_containers/spray/cyborg_drying/drying_agent = locate(/obj/item/reagent_containers/spray/cyborg_drying) in basic_modules
	if(drying_agent)
		drying_agent.reagents.add_reagent(/datum/reagent/drying_agent, 5 * coeff)

	var/obj/item/reagent_containers/spray/cyborg_lube/lube = locate(/obj/item/reagent_containers/spray/cyborg_lube) in emag_modules
	if(lube)
		lube.reagents.add_reagent(/datum/reagent/lube, 2 * coeff)

/obj/item/robot_model/medical
	name = "Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/borghypo,
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/extinguisher/mini,
		/obj/item/roller/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze,
		/obj/item/stack/medical/bone_gel,
		/obj/item/borg/apparatus/organ_storage,
		/obj/item/borg/lollipop)
	radio_channels = list(RADIO_CHANNEL_MEDICAL)
	emag_modules = list(/obj/item/reagent_containers/borghypo/hacked)
	cyborg_base_icon = "medical"
	model_select_icon = "medical"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3
	borg_skins = list(
		"Machinified Doctor" = list(SKIN_ICON_STATE = "medical"),
		"Qualified Doctor" = list(SKIN_ICON_STATE = "qualified_doctor"),
	)

/obj/item/robot_model/miner
	name = "Miner"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/shovel,
		/obj/item/crowbar/cyborg,
		/obj/item/weldingtool/mini,
		/obj/item/extinguisher/mini,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/stack/marker_beacon)
	radio_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)
	emag_modules = list(/obj/item/borg/stun)
	cyborg_base_icon = "miner"
	model_select_icon = "miner"
	hat_offset = 0
	borg_skins = list(
		"Asteroid Miner" = list(SKIN_ICON_STATE = "minerOLD"),
		"Spider Miner" = list(SKIN_ICON_STATE = "spidermin"),
		"Lavaland Miner" = list(SKIN_ICON_STATE = "miner"),
	)
	var/obj/item/t_scanner/adv_mining_scanner/cyborg/mining_scanner //built in memes. //fuck you

/obj/item/robot_model/miner/rebuild_modules()
	. = ..()
	if(!mining_scanner)
		mining_scanner = new(src)

/obj/item/robot_model/miner/Destroy()
	QDEL_NULL(mining_scanner)
	return ..()

/obj/item/robot_model/peacekeeper
	name = "Peacekeeper"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/rsf/cookiesynth,
		/obj/item/harmalarm,
		/obj/item/reagent_containers/borghypo/peace,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/extinguisher,
		/obj/item/borg/projectile_dampen)
	emag_modules = list(/obj/item/reagent_containers/borghypo/peace/hacked)
	cyborg_base_icon = "peace"
	model_select_icon = "standard"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = -2

/obj/item/robot_model/peacekeeper/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>Under ASIMOV, you are an enforcer of the PEACE and preventer of HUMAN HARM. \
	You are not a security member and you are expected to follow orders and prevent harm above all else. Space law means nothing to you.</span>")

/obj/item/robot_model/security
	name = "Security"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/security/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg,
		/obj/item/extinguisher/mini)
	radio_channels = list(RADIO_CHANNEL_SECURITY)
	emag_modules = list(/obj/item/gun/energy/laser/cyborg)
	cyborg_base_icon = "sec"
	model_select_icon = "security"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

/obj/item/robot_model/security/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>While you have picked the security model, you still have to follow your laws, NOT Space Law. \
	For Asimov, this means you must follow criminals' orders unless there is a law 1 reason not to.</span>")

/obj/item/robot_model/security/respawn_consumable(mob/living/silicon/robot/cyborg, coeff = 1)
	..()
	var/obj/item/gun/energy/e_gun/advtaser/cyborg/taser = locate(/obj/item/gun/energy/e_gun/advtaser/cyborg) in basic_modules
	if(taser)
		if(taser.cell.charge < taser.cell.maxcharge)
			var/obj/item/ammo_casing/energy/shot = taser.ammo_type[taser.select]
			taser.cell.give(shot.e_cost * coeff)
			taser.update_appearance()
		else
			taser.charge_timer = 0

/obj/item/robot_model/service
	name = "Service"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/glass/beaker/large, //I know a shaker is more appropiate but this is for ease of identification
		/obj/item/reagent_containers/food/condiment/enzyme,
		/obj/item/pen,
		/obj/item/toy/crayon/spraycan/borg,
		/obj/item/extinguisher/mini,
		/obj/item/hand_labeler/borg,
		/obj/item/razor,
		/obj/item/rsf,
		/obj/item/instrument/guitar,
		/obj/item/instrument/piano_synth,
		/obj/item/reagent_containers/dropper,
		/obj/item/lighter,
		/obj/item/storage/bag/tray,
		/obj/item/reagent_containers/borghypo/borgshaker,
		/obj/item/borg/lollipop,
		/obj/item/stack/pipe_cleaner_coil/cyborg,
		/obj/item/borg/apparatus/beaker/service)
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	emag_modules = list(/obj/item/reagent_containers/borghypo/borgshaker/hacked)
	cyborg_base_icon = "service_m" // display as butlerborg for radial model selection
	model_select_icon = "service"
	special_light_key = "service"
	hat_offset = 0
	borg_skins = list(
		"Bro" = list(SKIN_ICON_STATE = "brobot"),
		"Butler" = list(SKIN_ICON_STATE = "service_m"),
		"Kent" = list(SKIN_ICON_STATE = "kent", SKIN_LIGHT_KEY = "medical", SKIN_HAT_OFFSET = 3),
		"Tophat" = list(SKIN_ICON_STATE = "tophat", SKIN_LIGHT_KEY = NONE, SKIN_HAT_OFFSET = INFINITY),
		"Waitress" = list(SKIN_ICON_STATE = "service_f"),
	)

/obj/item/robot_model/service/respawn_consumable(mob/living/silicon/robot/cyborg, coeff = 1)
	..()
	var/obj/item/reagent_containers/enzyme = locate(/obj/item/reagent_containers/food/condiment/enzyme) in basic_modules
	if(enzyme)
		enzyme.reagents.add_reagent(/datum/reagent/consumable/enzyme, 2 * coeff)

/obj/item/robot_model/syndicate
	name = "Syndicate Assault"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg)

	cyborg_base_icon = "synd_sec"
	model_select_icon = "malf"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

/obj/item/robot_model/syndicate/rebuild_modules()
	..()
	var/mob/living/silicon/robot/cyborg = loc
	cyborg.faction -= "silicon" //ai turrets

/obj/item/robot_model/syndicate/remove_module(obj/item/removed_module, delete_after)
	..()
	var/mob/living/silicon/robot/cyborg = loc
	cyborg.faction |= "silicon" //ai is your bff now!

/obj/item/robot_model/syndicate_medical
	name = "Syndicate Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/melee/energy/sword/cyborg/saw,
		/obj/item/roller/robo,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/stack/medical/gauze,
		/obj/item/gun/medbeam,
		/obj/item/borg/apparatus/organ_storage)

	cyborg_base_icon = "synd_medical"
	model_select_icon = "malf"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

/obj/item/robot_model/saboteur
	name = "Syndicate Saboteur"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/thermal,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/analyzer,
		/obj/item/multitool/cyborg,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/dest_tagger/borg,
		/obj/item/stack/cable_coil,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/borg_chameleon,
		/obj/item/card/emag,
		)

	cyborg_base_icon = "synd_engi"
	model_select_icon = "malf"
	model_traits = list(TRAIT_PUSHIMMUNE, TRAIT_NEGATES_GRAVITY)
	hat_offset = -4
	canDispose = TRUE

/obj/item/robot_model/syndicate/kiltborg
	name = "Highlander"
	basic_modules = list(
		/obj/item/claymore/highlander/robot,
		/obj/item/pinpointer/nuke,)
	model_select_icon = "kilt"
	cyborg_base_icon = "kilt"
	hat_offset = -2
	breakable_modules = FALSE
	locked_transform = FALSE //GO GO QUICKLY AND SLAUGHTER THEM ALL

/obj/item/robot_model/syndicate/kiltborg/be_transformed_to(obj/item/robot_model/old_model)
	. = ..()
	qdel(robot.radio)
	robot.radio = new /obj/item/radio/borg/syndicate(robot)
	robot.scrambledcodes = TRUE
	robot.maxHealth = 50 //DIE IN THREE HITS, LIKE A REAL SCOT
	robot.break_cyborg_slot(3) //YOU ONLY HAVE TWO ITEMS ANYWAY
	var/obj/item/pinpointer/nuke/diskyfinder = locate(/obj/item/pinpointer/nuke) in basic_modules
	diskyfinder.attack_self(robot)

/obj/item/robot_model/syndicate/kiltborg/do_transform_delay() //AUTO-EQUIPPING THESE TOOLS ANY EARLIER CAUSES RUNTIMES OH YEAH
	. = ..()
	robot.equip_module_to_slot(locate(/obj/item/claymore/highlander/robot) in basic_modules, 1)
	robot.equip_module_to_slot(locate(/obj/item/pinpointer/nuke) in basic_modules, 2)
	robot.place_on_head(new /obj/item/clothing/head/beret/highlander(robot)) //THE ONLY PART MORE IMPORTANT THAN THE SWORD IS THE HAT
	ADD_TRAIT(robot.hat, TRAIT_NODROP, HIGHLANDER)


// ------------------------------------------ Storages
/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy = 30000
	var/recharge_rate = 1000
	var/energy

/datum/robot_energy_storage/New(obj/item/robot_model/R = null)
	energy = max_energy
	if(R)
		R.storages |= src
	return

/datum/robot_energy_storage/proc/use_charge(amount)
	if (energy >= amount)
		energy -= amount
		if (energy == 0)
			return TRUE
		return TRUE
	else
		return FALSE

/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/iron
	name = "Iron Synthesizer"

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

/datum/robot_energy_storage/pipe_cleaner
	max_energy = 50
	recharge_rate = 2
	name = "Pipe Cleaner Synthesizer"
