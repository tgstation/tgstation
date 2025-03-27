//Engineering modules for MODsuits

///Welding Protection - Makes the helmet protect from flashes and welding.
/obj/item/mod/module/welding
	name = "MOD welding protection module"
	desc = "A module installed into the visor of the suit, this projects a \
		polarized, holographic overlay in front of the user's eyes. It's rated high enough for \
		immunity against extremities such as spot and arc welding, solar eclipses, and handheld flashlights."
	icon_state = "welding"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/welding, /obj/item/mod/module/armor_booster)
	overlay_state_inactive = "module_welding"
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/welding/on_part_activation()
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		//this is a screen that displays an image, so flash sensitives can use this to protect against flashes.
		head_cover.flash_protect = FLASH_PROTECTION_WELDER_HYPER_SENSITIVE

/obj/item/mod/module/welding/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.flash_protect = initial(head_cover.flash_protect)

///T-Ray Scan - Scans the terrain for undertile objects.
/obj/item/mod/module/t_ray
	name = "MOD t-ray scan module"
	desc = "A module installed into the visor of the suit, allowing the user to use a pulse of terahertz radiation \
		to essentially echolocate things beneath the floor, mostly cables and pipes. \
		A staple of atmospherics work, and counter-smuggling work."
	icon_state = "tray"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/t_ray)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)
	/// T-ray scan range.
	var/range = 4

/obj/item/mod/module/t_ray/on_active_process(seconds_per_tick)
	t_ray_scan(mod.wearer, 0.8 SECONDS, range)

///Magnetic Stability - Gives the user a slowdown but makes them negate gravity and be immune to slips.
/obj/item/mod/module/magboot
	name = "MOD magnetic stability module"
	desc = "These are powerful electromagnets fitted into the suit's boots, allowing users both \
		excellent traction no matter the condition indoors, and to essentially hitch a ride on the exterior of a hull. \
		However, these basic models do not feature computerized systems to automatically toggle them on and off, \
		so numerous users report a certain stickiness to their steps."
	icon_state = "magnet"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/magboot, /obj/item/mod/module/atrocinator)
	required_slots = list(ITEM_SLOT_FEET)
	/// Slowdown added onto the suit.
	var/slowdown_active = 0.5
	/// A list of traits to add to the wearer when we're active (see: Magboots)
	var/list/active_traits = list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE, TRAIT_NEGATES_GRAVITY)

/obj/item/mod/module/magboot/on_install()
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))

/obj/item/mod/module/magboot/on_uninstall(deleting)
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)

/obj/item/mod/module/magboot/on_activation()
	mod.wearer.add_traits(active_traits, REF(src))
	mod.update_speed()

/obj/item/mod/module/magboot/on_deactivation(display_message = TRUE, deleting = FALSE)
	mod.wearer.remove_traits(active_traits, REF(src))
	mod.update_speed()

/obj/item/mod/module/magboot/proc/on_update_speed(datum/source, list/module_slowdowns, prevent_slowdown)
	SIGNAL_HANDLER
	if (!prevent_slowdown && active)
		module_slowdowns += slowdown_active

/obj/item/mod/module/magboot/advanced
	name = "MOD advanced magnetic stability module"
	removable = FALSE
	complexity = 0
	slowdown_active = 0

///Emergency Tether - Shoots a grappling hook projectile in 0g that throws the user towards it.
/obj/item/mod/module/tether
	name = "MOD emergency tether module"
	desc = "A custom-built grappling-hook powered by a winch capable of hauling the user. \
		While some older models of cargo-oriented grapples have capacities of a few tons, \
		these are only capable of working in zero-gravity environments, a blessing to some Engineers."
	icon_state = "tether"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/tether)
	cooldown_time = 1.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/tether/used()
	if(HAS_TRAIT_FROM(mod.wearer, TRAIT_TETHER_ATTACHED, REF(src)))
		balloon_alert(mod.wearer, "already tethered!")
		playsound(src, 'sound/items/weapons/gun/general/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/tether/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/tether = new /obj/projectile/tether(mod.wearer.loc, src)
	tether.aim_projectile(target, mod.wearer)
	tether.firer = mod.wearer
	playsound(src, 'sound/items/weapons/batonextend.ogg', 25, TRUE)
	INVOKE_ASYNC(tether, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

/obj/item/mod/module/tether/get_configuration()
	. = ..()
	.["cut_tethers"] = add_ui_configuration("Cut Tethers", "button", "scissors")

/obj/item/mod/module/tether/configure_edit(key, value)
	if (key == "cut_tethers")
		SEND_SIGNAL(src, COMSIG_MOD_TETHER_SNAP)

/obj/item/mod/module/tether/on_deactivation(display_message, deleting)
	SEND_SIGNAL(src, COMSIG_MOD_TETHER_SNAP)

/obj/projectile/tether
	name = "tether"
	icon_state = "tether_projectile"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	range = 10
	hitsound = 'sound/items/weapons/batonextend.ogg'
	hitsound_wall = 'sound/items/weapons/batonextend.ogg'
	suppressed = SUPPRESSED_VERY
	hit_threshhold = ABOVE_NORMAL_TURF_LAYER
	embed_type = /datum/embedding/tether_projectile
	shrapnel_type = /obj/item/tether_anchor
	/// Reference to the beam following the projectile.
	var/line
	/// Last turf that we passed before impact
	var/turf/open/last_turf
	/// MODsuit tether module that fired us
	var/obj/item/mod/module/tether/parent_module

/obj/projectile/tether/Initialize(mapload, module)
	. = ..()
	RegisterSignal(src, COMSIG_PROJECTILE_ON_EMBEDDED, PROC_REF(on_embedded))
	if (!isnull(module))
		parent_module = module

/obj/projectile/tether/proc/on_embedded(datum/source, obj/item/payload, atom/hit)
	SIGNAL_HANDLER

	if (HAS_TRAIT_FROM(hit, TRAIT_TETHER_ATTACHED, REF(parent_module)))
		return

	firer.AddComponent(/datum/component/tether, hit, 7, "MODtether", payload, parent_module = parent_module, tether_trait_source = REF(parent_module))

/obj/projectile/tether/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if (isopenturf(loc))
		last_turf = loc

/obj/projectile/tether/fire(setAngle)
	if(firer)
		line = firer.Beam(src, "line", 'icons/obj/clothing/modsuit/mod_modules.dmi', emissive = FALSE)
	return ..()

/obj/projectile/tether/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (!firer)
		return

	// Funni is handled separately
	if (ismob(target))
		return

	if (istype(target, /obj/item/tether_anchor) || isstructure(target) || ismachinery(target))
		if(HAS_TRAIT_FROM(target, TRAIT_TETHER_ATTACHED, REF(parent_module)))
			return
		var/avoid_target_trait = FALSE
		if (istype(target, /obj/item/tether_anchor))
			avoid_target_trait = TRUE
		firer.AddComponent(/datum/component/tether, target, 7, "MODtether", parent_module = parent_module, tether_trait_source = REF(parent_module), no_target_trait = avoid_target_trait)
		return

	var/hitx = impact_x
	var/hity = impact_y

	if (!isnull(last_turf) && last_turf != target && last_turf != target.loc)
		var/turf_dir = get_dir(last_turf, get_turf(target))
		if (turf_dir & NORTH)
			hity += 32
		if (turf_dir & SOUTH)
			hity -= 32
		if (turf_dir & EAST)
			hitx += 32
		if (turf_dir & WEST)
			hitx -= 32

	var/obj/item/tether_anchor/anchor = new(last_turf || get_turf(target))
	anchor.pixel_x = hitx
	anchor.pixel_y = hity
	anchor.anchored = TRUE
	anchor.parent_module = parent_module
	firer.AddComponent(/datum/component/tether, anchor, 7, "MODtether", parent_module = parent_module, tether_trait_source = REF(parent_module))

/obj/projectile/tether/Destroy()
	QDEL_NULL(line)
	return ..()

/obj/item/tether_anchor
	name = "tether anchor"
	desc = "A reinforced anchor with a tether attachment point. A centuries old EVA tool which saved countless engineers' lives."
	icon_state = "tether_latched"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	max_integrity = 60
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT
	/// MODsuit tether module that created our projectile
	var/obj/item/mod/module/tether/parent_module

/obj/item/tether_anchor/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_TETHER_SNAPPED, PROC_REF(tether_snapped))

/obj/item/tether_anchor/Destroy(force)
	// We don't need to worry about hanging refs in case our parent gets destroyed because then it snaps all tethers, which in turn destroys us
	parent_module = null
	return ..()

/obj/item/tether_anchor/examine(mob/user)
	. = ..()
	. += span_info("It can be secured by using a wrench on it. Use right-click to tether yourself to [src].")
	. += span_info("LMB shortens the tether while RMB lengthens it. Ctrl-click to cut the tether.")

/obj/item/tether_anchor/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/item/tether_anchor/attack_hand_secondary(mob/user, list/modifiers)
	if (!can_interact(user) || !user.CanReach(src) || !isturf(loc))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(HAS_TRAIT_FROM(user, TRAIT_TETHER_ATTACHED, REF(src)))
		balloon_alert(user, "already tethered!")
		return

	if (parent_module && HAS_TRAIT_FROM(user, TRAIT_TETHER_ATTACHED, REF(parent_module)))
		balloon_alert(user, "already tethered!")
		return

	balloon_alert(user, "attached tether")
	user.AddComponent(/datum/component/tether, src, 7, "tether", tether_trait_source = REF(src))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/tether_anchor/mouse_drop_receive(atom/target, mob/user, params)
	if (!can_interact(user) || !user.CanReach(src) || !isturf(loc))
		return

	if (!isliving(target) || !target.CanReach(src))
		return

	if(HAS_TRAIT_FROM(target, TRAIT_TETHER_ATTACHED, REF(src)))
		balloon_alert(user, "already tethered!")
		return

	if (parent_module && HAS_TRAIT_FROM(user, TRAIT_TETHER_ATTACHED, REF(parent_module)))
		balloon_alert(user, "already tethered!")
		return

	if (target == user)
		balloon_alert(user, "attached tether")
		user.AddComponent(/datum/component/tether, src, 7, "tether", tether_trait_source = REF(src), no_target_trait = TRUE)
		return

	balloon_alert(user, "attaching tether...")
	to_chat(target, span_userdanger("[user] is trying to attach a tether to you!"))
	if (!do_after(user, 5 SECONDS, target))
		return

	if(HAS_TRAIT_FROM(target, TRAIT_TETHER_ATTACHED, REF(src)))
		balloon_alert(user, "already tethered!")
		return

	if (parent_module && HAS_TRAIT_FROM(user, TRAIT_TETHER_ATTACHED, REF(parent_module)))
		balloon_alert(user, "already tethered!")
		return

	balloon_alert(user, "attached tether")
	to_chat(target, span_userdanger("[user] attaches a tether to you!"))
	target.AddComponent(/datum/component/tether, src, 7, "tether", tether_trait_source = REF(src), no_target_trait = TRUE)

/obj/item/tether_anchor/proc/tether_snapped(datum/component/tether/tether, tether_source)
	SIGNAL_HANDLER

	if (!parent_module || tether_source != REF(parent_module))
		return

	// Destroy self if we've been created by a tether module
	do_sparks(3, TRUE, src)
	qdel(src)

/datum/embedding/tether_projectile
	embed_chance = 65 //spiky
	fall_chance = 2
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.4
	pain_mult = 3
	jostle_pain_mult = 2
	rip_time = 1 SECONDS

///Radiation Protection - Protects the user from radiation, gives them a geiger counter and rad info in the panel.
/obj/item/mod/module/rad_protection
	name = "MOD radiation protection module"
	desc = "A module utilizing polymers and reflective shielding to protect the user against ionizing radiation; \
		a common danger in space. This comes with software to notify the wearer that they're even in a radioactive area, \
		giving a voice to an otherwise silent killer."
	icon_state = "radshield"
	complexity = 2
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/rad_protection)
	tgui_id = "rad_counter"
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// Radiation threat level being perceived.
	var/perceived_threat_level

/obj/item/mod/module/rad_protection/on_part_activation()
	AddComponent(/datum/component/geiger_sound)
	ADD_TRAIT(mod.wearer, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, REF(src))
	RegisterSignal(mod.wearer, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation))
	for(var/obj/item/part in mod.get_parts(all = TRUE))
		ADD_TRAIT(part, TRAIT_RADIATION_PROTECTED_CLOTHING, MOD_TRAIT)

/obj/item/mod/module/rad_protection/on_part_deactivation(deleting = FALSE)
	qdel(GetComponent(/datum/component/geiger_sound))
	REMOVE_TRAIT(mod.wearer, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, REF(src))
	UnregisterSignal(mod.wearer, COMSIG_IN_RANGE_OF_IRRADIATION)
	for(var/obj/item/part in mod.get_parts(all = TRUE))
		REMOVE_TRAIT(part, TRAIT_RADIATION_PROTECTED_CLOTHING, MOD_TRAIT)

/obj/item/mod/module/rad_protection/add_ui_data()
	. = ..()
	.["is_user_irradiated"] = mod.wearer ? HAS_TRAIT(mod.wearer, TRAIT_IRRADIATED) : FALSE
	.["background_radiation_level"] = perceived_threat_level
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	.["loss_tox"] = mod.wearer?.getToxLoss() || 0

/obj/item/mod/module/rad_protection/proc/on_pre_potential_irradiation(datum/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER

	perceived_threat_level = get_perceived_radiation_danger(pulse_information, insulation_to_target)
	addtimer(VARSET_CALLBACK(src, perceived_threat_level, null), TIME_WITHOUT_RADIATION_BEFORE_RESET, TIMER_UNIQUE | TIMER_OVERRIDE)

///Constructor - Lets you build quicker and create RCD holograms.
/obj/item/mod/module/constructor
	name = "MOD constructor module"
	desc = "This module entirely occupies the wearer's forearm, notably causing conflict with \
		advanced arm servos meant to carry crewmembers. However, it functions as an \
		extremely advanced construction hologram scanner, as well as containing the \
		latest engineering schematics combined with inbuilt memory to help the user build walls."
	icon_state = "constructor"
	module_type = MODULE_USABLE
	complexity = 2
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/constructor, /obj/item/mod/module/quick_carry)
	cooldown_time = 11 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/constructor/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, REF(src))

/obj/item/mod/module/constructor/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, REF(src))

/obj/item/mod/module/constructor/on_use()
	rcd_scan(src, fade_time = 10 SECONDS)
	drain_power(use_energy_cost)

///Safety-First Head Protection - Protects your brain matter from sudden impacts.
/obj/item/mod/module/headprotector
	name = "MOD safety-first head protection module"
	desc = "A series of dampening plates are installed along the back and upper areas of \
		the helmet. These plates absorb abrupt kinetic shocks delivered to the skull. \
		The bulk of this module prevents it from being installed in any suit that is capable \
		of combat armor adjustments. However, the rudimentry nature of the module makes it \
		relatively easy to install into most other suits."
	icon_state = "welding"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/armor_booster, /obj/item/mod/module/infiltrator)
	required_slots = list(ITEM_SLOT_HEAD)

/obj/item/mod/module/headprotector/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_HEAD_INJURY_BLOCKED, REF(src))

/obj/item/mod/module/headprotector/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_HEAD_INJURY_BLOCKED, REF(src))

///Mister - Sprays water over an area.
/obj/item/mod/module/mister
	name = "MOD water mister module"
	desc = "A module containing a mister, able to spray it over areas."
	icon_state = "mister"
	module_type = MODULE_ACTIVE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/reagent_containers/spray/mister
	incompatible_modules = list(/obj/item/mod/module/mister)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_BACK)
	/// Volume of our reagent holder.
	var/volume = 500

/obj/item/mod/module/mister/Initialize(mapload)
	create_reagents(volume, OPENCONTAINER)
	return ..()

///Resin Mister - Sprays resin over an area.
/obj/item/mod/module/mister/atmos
	name = "MOD resin mister module"
	desc = "An atmospheric resin mister, able to fix up areas quickly."
	device = /obj/item/extinguisher/mini/nozzle/mod
	volume = 250

/obj/item/mod/module/mister/atmos/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/water, volume)

/obj/item/extinguisher/mini/nozzle/mod
	name = "MOD atmospheric mister"
	desc = "An atmospheric resin mister with three modes, mounted as a module."
