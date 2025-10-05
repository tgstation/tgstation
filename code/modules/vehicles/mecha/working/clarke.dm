///Lavaproof, fireproof, fast mech with low armor and higher energy consumption and has an internal ore box.
/obj/vehicle/sealed/mecha/clarke
	desc = "Combining man and machine for a better, stronger miner. Can even resist lava! Due to its tracks it cannot strafe."
	name = "\improper Clarke"
	icon_state = "clarke"
	base_icon_state = "clarke"
	max_temperature = 65000
	max_integrity = 250
	movedelay = 1.25
	overclock_coeff = 1.25
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	step_energy_drain = 12 //slightly higher energy drain since you movin those wheels FAST
	armor_type = /datum/armor/mecha_clarke
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/orebox_manager, /obj/item/mecha_parts/mecha_equipment/sleeper/clarke),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 6,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	wreckage = /obj/structure/mecha_wreckage/clarke
	mech_type = EXOSUIT_MODULE_CLARKE
	enter_delay = 40
	mecha_flags = IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE | OMNIDIRECTIONAL_ATTACKS | BEACON_TRACKABLE | AI_COMPATIBLE | BEACON_CONTROLLABLE
	accesses = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	allow_diagonal_movement = FALSE
	pivot_step = TRUE

/datum/armor/mecha_clarke
	melee = 40
	bullet = 10
	laser = 20
	energy = 10
	bomb = 60
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/clarke/Initialize(mapload)
	. = ..()
	ore_box = new(src)

/obj/vehicle/sealed/mecha/clarke/atom_destruction()
	if(ore_box)
		INVOKE_ASYNC(ore_box, TYPE_PROC_REF(/obj/structure/ore_box, dump_box_contents))
	return ..()

/obj/vehicle/sealed/mecha/clarke/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_search_ruins)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/clarke_scoop_body)

//Ore Box Controls

///Special equipment for the Clarke mech, handles moving ore without giving the mech a hydraulic clamp and cargo compartment.
/obj/item/mecha_parts/mecha_equipment/orebox_manager
	name = "ore storage module"
	desc = "An automated ore box management device, complete with a built-in boulder processor."
	icon_state = "mecha_bin"
	equipment_slot = MECHA_UTILITY
	detachable = FALSE

/obj/item/mecha_parts/mecha_equipment/orebox_manager/attach(obj/vehicle/sealed/mecha/mecha, attach_right = FALSE)
	. = ..()
	ADD_TRAIT(chassis, TRAIT_OREBOX_FUNCTIONAL, TRAIT_MECH_EQUIPMENT(type))

/obj/item/mecha_parts/mecha_equipment/orebox_manager/detach(atom/moveto)
	REMOVE_TRAIT(chassis, TRAIT_OREBOX_FUNCTIONAL, TRAIT_MECH_EQUIPMENT(type))
	return ..()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/get_snowflake_data()
	var/list/contents = chassis.ore_box?.contents
	var/list/contents_grouped = list()
	for(var/atom/movable/item as anything in contents)
		var/amount = 1
		if(isstack(item))
			var/obj/item/stack/stack = item
			amount = stack.amount
		if(isnull(contents_grouped[item.icon_state]))
			var/ore_data = list()
			ore_data["name"] = item.name
			ore_data["icon"] = item.icon_state
			ore_data["amount"] = amount
			contents_grouped[item.icon_state] = ore_data
		else
			contents_grouped[item.icon_state]["amount"] += amount
	var/list/data = list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_OREBOX_MANAGER,
		"contents" = contents_grouped,
		)
	return data

/obj/item/mecha_parts/mecha_equipment/orebox_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE
	if(action == "dump")
		var/obj/structure/ore_box/cached_ore_box = chassis.ore_box
		if(isnull(cached_ore_box))
			return FALSE
		cached_ore_box.dump_box_contents()
		playsound(chassis, 'sound/items/weapons/tap.ogg', 50, TRUE)
		log_message("Dumped [cached_ore_box].", LOG_MECHA)
		return TRUE

/obj/item/mecha_parts/mecha_equipment/sleeper/clarke //The Clarke subtype of the sleeper is a built-in utility module
	equipment_slot = MECHA_UTILITY
	detachable = FALSE

/datum/action/vehicle/sealed/mecha/clarke_scoop_body
	name = "Pick up body"
	desc = "Activate to pick up a nearby body"
	button_icon = 'icons/obj/devices/mecha_equipment.dmi'
	button_icon_state = "mecha_sleeper_miner"

/datum/action/vehicle/sealed/mecha/clarke_scoop_body/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return
	var/obj/item/mecha_parts/mecha_equipment/sleeper/clarke/sleeper = locate() in chassis
	var/mob/living/carbon/human/human_target
	for(var/mob/living/carbon/human/body in range(1, chassis))
		if(chassis.is_driver(body) || !ishuman(body) || !chassis.Adjacent(body))
			continue
		human_target = body //Non-driver, human, and adjacent
		break
	sleeper.action(pick(chassis.return_drivers()), human_target) //This will probably break if anyone allows multiple drivers of the Clarke mech

#define SEARCH_COOLDOWN (1 MINUTES)

/datum/action/vehicle/sealed/mecha/mech_search_ruins
	name = "Search for Ruins"
	button_icon_state = "mech_search_ruins"
	COOLDOWN_DECLARE(search_cooldown)

/datum/action/vehicle/sealed/mecha/mech_search_ruins/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	if(!COOLDOWN_FINISHED(src, search_cooldown))
		chassis.balloon_alert(owner, "on cooldown!")
		return
	if(!isliving(owner))
		return
	var/mob/living/living_owner = owner
	button_icon_state = "mech_search_ruins_cooldown"
	build_all_button_icons()
	COOLDOWN_START(src, search_cooldown, SEARCH_COOLDOWN)
	addtimer(VARSET_CALLBACK(src, button_icon_state, "mech_search_ruins"), SEARCH_COOLDOWN)
	addtimer(CALLBACK(src, PROC_REF(build_all_button_icons)), SEARCH_COOLDOWN)
	var/obj/pinpointed_ruin
	for(var/obj/effect/landmark/ruin/ruin_landmark as anything in GLOB.ruin_landmarks)
		if(ruin_landmark.z != chassis.z)
			continue
		if(!pinpointed_ruin || get_dist(ruin_landmark, chassis) < get_dist(pinpointed_ruin, chassis))
			pinpointed_ruin = ruin_landmark
	if(!pinpointed_ruin)
		chassis.balloon_alert(living_owner, "no ruins!")
		return
	var/datum/status_effect/agent_pinpointer/ruin_pinpointer = living_owner.apply_status_effect(/datum/status_effect/agent_pinpointer/ruin)
	ruin_pinpointer.RegisterSignal(living_owner, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/status_effect/agent_pinpointer/ruin, cancel_self))
	ruin_pinpointer.scan_target = pinpointed_ruin
	chassis.balloon_alert(living_owner, "pinpointing nearest ruin")

/datum/status_effect/agent_pinpointer/ruin
	duration = SEARCH_COOLDOWN * 0.5
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/ruin
	tick_interval = 3 SECONDS
	range_fuzz_factor = 0
	minimum_range = 5
	range_mid = 20
	range_far = 50

/datum/status_effect/agent_pinpointer/ruin/scan_for_target()
	return

/datum/status_effect/agent_pinpointer/ruin/proc/cancel_self(datum/source, atom/old_loc)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/agent_pinpointer/ruin
	name = "Ruin Target"
	desc = "Searching for valuables..."

#undef SEARCH_COOLDOWN
