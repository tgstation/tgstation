// Straps that, when used on suit items, will consume themselves and add their list of things to
// That suit item's suit storage allowed slot
/obj/item/job_equipment_strap
	name = "generic equipment strap"
	desc = "A special strap designed to allow you to attach critical equipment to any piece of outer clothing when connected."
	icon = 'modular_doppler/job_straps/icons/straps.dmi'
	icon_state = "strap_base"
	w_class = WEIGHT_CLASS_NORMAL
	icon_angle = 45
	force = 10
	demolition_mod = 1.5
	wound_bonus = 0
	bare_wound_bonus = 10
	attack_verb_continuous = list("flogs", "whips", "lashes", "disciplines")
	attack_verb_simple = list("flog", "whip", "lash", "discipline")
	hitsound = 'sound/items/weapons/whipgrab.ogg'
	/// Everything we add to clothing's allow list when used on the clothing item
	var/list/things_to_allow = list(
		/obj/item/flashlight,
		/obj/item/modular_computer,
		/obj/item/radio,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
	)

/obj/item/job_equipment_strap/Initialize(mapload)
	. = ..()
	register_item_context()

/obj/item/job_equipment_strap/examine(mob/user)
	. = ..()
	. += span_notice("Using this on a <b>suit slot</b> item will add this strap's job items to the things you can wear in it's suit storage.")
	return .

/obj/item/job_equipment_strap/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(!istype(target, /obj/item/clothing/suit))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Attach strap"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/job_equipment_strap/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/item/clothing/suit))
		return NONE
	if(!do_after(user, 3 SECONDS, target = interacting_with))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/clothing/suit/targeted_suit = interacting_with
	targeted_suit.allowed |= things_to_allow
	playsound(src, 'sound/items/equip/toolbelt_equip.ogg', 50, TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS


// Service
/obj/item/job_equipment_strap/service
	name = "service equipment strap"
	icon_state = "strap_serv"
	things_to_allow = list(
		// Default
		/obj/item/flashlight,
		/obj/item/modular_computer,
		/obj/item/radio,
		/obj/item/tank/internals,
		// Botanist
		/obj/item/cultivator,
		/obj/item/geneshears,
		/obj/item/graft,
		/obj/item/hatchet,
		/obj/item/plant_analyzer,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/secateurs,
		/obj/item/seeds,
		/obj/item/storage/bag/plants,
		// Chef
		/obj/item/kitchen,
		/obj/item/knife/kitchen,
		/obj/item/storage/bag/tray,
		// Janitor
		/obj/item/access_key,
		/obj/item/grenade/chem_grenade,
		/obj/item/holosign_creator,
		/obj/item/key/janitor,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/spray,
	)

// Medical
/obj/item/job_equipment_strap/medical
	name = "medical equipment strap"
	icon_state = "strap_med"
	things_to_allow = list(
		// Default
		/obj/item/flashlight,
		/obj/item/modular_computer,
		/obj/item/radio,
		/obj/item/tank/internals,
		// Medical
		/obj/item/gun/syringe,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/applicator/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/medkit,
		/obj/item/storage/backpack/duffelbag/deforest_medkit,
		/obj/item/storage/backpack/duffelbag/deforest_surgical,
		// Chemist
		/obj/item/storage/bag/chemistry,
		// Coroner
		/obj/item/autopsy_scanner,
		/obj/item/scythe,
		/obj/item/shovel,
		/obj/item/shovel/serrated,
		/obj/item/trench_tool,
		// Virology
		/obj/item/storage/bag/bio,
	)

// Science
/obj/item/job_equipment_strap/science
	name = "science equipment strap"
	icon_state = "strap_sci"
	things_to_allow = list(
		// Default
		/obj/item/flashlight,
		/obj/item/modular_computer,
		/obj/item/radio,
		/obj/item/tank/internals,
		// Science
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/applicator/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/bag/xeno,
		/obj/item/storage/pill_bottle,
		// Genetics
		/obj/item/sequence_scanner,
	)

// Engineering
/obj/item/job_equipment_strap/engineering
	name = "engineering equipment strap"
	icon_state = "strap_eng"
	things_to_allow = list(
		// Default
		/obj/item/flashlight,
		/obj/item/modular_computer,
		/obj/item/radio,
		/obj/item/tank/internals,
		// Engineering
		/obj/item/analyzer,
		/obj/item/construction/rcd,
		/obj/item/fireaxe/metal_h2_axe,
		/obj/item/pipe_dispenser,
		/obj/item/storage/bag/construction,
		/obj/item/t_scanner,
		/obj/item/construction/rld,
		/obj/item/construction/rtd,
		/obj/item/gun/ballistic/rifle/rebarxbow,
		/obj/item/storage/bag/rebar_quiver,
	)

// Supply
/obj/item/job_equipment_strap/supply
	name = "supply equipment strap"
	icon_state = "strap_sup"
	things_to_allow = list(
		// Default
		/obj/item/flashlight,
		/obj/item/modular_computer,
		/obj/item/radio,
		/obj/item/tank/internals,
		// Supply
		/obj/item/storage/bag/mail,
		/obj/item/stamp,
		/obj/item/universal_scanner,
		// Mining
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/storage/bag/ore,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/tank/internals,
		/obj/item/shovel,
		/obj/item/trench_tool,
	)

// Security
/obj/item/job_equipment_strap/security
	name = "security equipment strap"
	icon_state = "strap_sec"
	things_to_allow = list(
		// Default
		/obj/item/flashlight,
		/obj/item/modular_computer,
		/obj/item/radio,
		/obj/item/tank/internals,
		// Security
		/obj/item/flashlight,
		/obj/item/gun/ballistic,
		/obj/item/gun/energy,
		/obj/item/knife/combat,
		/obj/item/melee/baton,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/storage/belt/holster/detective,
		/obj/item/storage/belt/holster/nukie,
		/obj/item/storage/belt/holster/energy,
		/obj/item/gun/ballistic/shotgun/automatic/combat/compact,
		/obj/item/pen/red/security,
		/obj/item/storage/belt/secsword,
		/obj/item/storage/toolbox/guncase/modular,
	)
