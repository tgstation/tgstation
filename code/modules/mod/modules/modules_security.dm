//Security modules for MODsuits

///Magnetic Harness - Automatically puts guns in your suit storage when you drop them.
/obj/item/mod/module/magnetic_harness
	name = "MOD magnetic harness module"
	desc = "Based off old TerraGov harness kits, this magnetic harness automatically attaches dropped guns back to the wearer."
	icon_state = "mag_harness"
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/magnetic_harness)
	/// Time before we activate the magnet.
	var/magnet_delay = 0.8 SECONDS
	/// The typecache of all guns we allow.
	var/static/list/guns_typecache
	/// The guns already allowed by the modsuit chestplate.
	var/list/already_allowed_guns = list()

/obj/item/mod/module/magnetic_harness/Initialize(mapload)
	. = ..()
	if(!guns_typecache)
		guns_typecache = typecacheof(list(/obj/item/gun/ballistic, /obj/item/gun/energy, /obj/item/gun/grenadelauncher, /obj/item/gun/chem, /obj/item/gun/syringe))

/obj/item/mod/module/magnetic_harness/on_install()
	already_allowed_guns = guns_typecache & mod.chestplate.allowed
	mod.chestplate.allowed |= guns_typecache

/obj/item/mod/module/magnetic_harness/on_uninstall(deleting = FALSE)
	if(deleting)
		return
	mod.chestplate.allowed -= (guns_typecache - already_allowed_guns)

/obj/item/mod/module/magnetic_harness/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(check_dropped_item))

/obj/item/mod/module/magnetic_harness/on_suit_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_MOB_UNEQUIPPED_ITEM)

/obj/item/mod/module/magnetic_harness/proc/check_dropped_item(datum/source, obj/item/dropped_item, force, new_location)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(dropped_item, guns_typecache))
		return
	if(new_location != get_turf(src))
		return
	addtimer(CALLBACK(src, PROC_REF(pick_up_item), dropped_item), magnet_delay)

/obj/item/mod/module/magnetic_harness/proc/pick_up_item(obj/item/item)
	if(!isturf(item.loc) || !item.Adjacent(mod.wearer))
		return
	if(!mod.wearer.equip_to_slot_if_possible(item, ITEM_SLOT_SUITSTORE, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	playsound(src, 'sound/items/modsuit/magnetic_harness.ogg', 50, TRUE)
	balloon_alert(mod.wearer, "[item] reattached")
	drain_power(use_power_cost)

///Pepper Shoulders - When hit, reacts with a spray of pepper spray around the user.
/obj/item/mod/module/pepper_shoulders
	name = "MOD pepper shoulders module"
	desc = "A module that attaches two pepper sprayers on shoulders of a MODsuit, reacting to touch with a spray around the user."
	icon_state = "pepper_shoulder"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/pepper_shoulders)
	cooldown_time = 5 SECONDS
	overlay_state_inactive = "module_pepper"
	overlay_state_use = "module_pepper_used"

/obj/item/mod/module/pepper_shoulders/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_check_shields))

/obj/item/mod/module/pepper_shoulders/on_suit_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/mod/module/pepper_shoulders/on_use()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	var/datum/reagents/capsaicin_holder = new(10)
	capsaicin_holder.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 10)
	var/datum/effect_system/fluid_spread/smoke/chem/quick/smoke = new
	smoke.set_up(1, holder = src, location = get_turf(src), carry = capsaicin_holder)
	smoke.start(log = TRUE)
	QDEL_NULL(capsaicin_holder) // Reagents have a ref to their holder which has a ref to them. No leaks please.

/obj/item/mod/module/pepper_shoulders/proc/on_check_shields()
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return
	if(!check_power(use_power_cost))
		return
	mod.wearer.visible_message(span_warning("[src] reacts to the attack with a smoke of pepper spray!"), span_notice("Your [src] releases a cloud of pepper spray!"))
	on_use()

///Holster - Instantly holsters any not huge gun.
/obj/item/mod/module/holster
	name = "MOD holster module"
	desc = "Based off typical storage compartments, this system allows the suit to holster a \
		standard firearm across its surface and allow for extremely quick retrieval. \
		While some users prefer the chest, others the forearm for quick deployment, \
		some law enforcement prefer the holster to extend from the thigh."
	icon_state = "holster"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/holster)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// Gun we have holstered.
	var/obj/item/gun/holstered

/obj/item/mod/module/holster/on_use()
	. = ..()
	if(!.)
		return
	if(!holstered)
		var/obj/item/gun/holding = mod.wearer.get_active_held_item()
		if(!holding)
			balloon_alert(mod.wearer, "nothing to holster!")
			return
		if(!istype(holding) || holding.w_class > WEIGHT_CLASS_BULKY)
			balloon_alert(mod.wearer, "it doesn't fit!")
			return
		if(mod.wearer.transferItemToLoc(holding, src, force = FALSE, silent = TRUE))
			holstered = holding
			balloon_alert(mod.wearer, "weapon holstered")
			playsound(src, 'sound/weapons/gun/revolver/empty.ogg', 100, TRUE)
	else if(mod.wearer.put_in_active_hand(holstered, forced = FALSE, ignore_animation = TRUE))
		balloon_alert(mod.wearer, "weapon drawn")
		playsound(src, 'sound/weapons/gun/revolver/empty.ogg', 100, TRUE)
	else
		balloon_alert(mod.wearer, "holster full!")

/obj/item/mod/module/holster/on_uninstall(deleting = FALSE)
	if(holstered)
		holstered.forceMove(drop_location())

/obj/item/mod/module/holster/Exited(atom/movable/gone, direction)
	if(gone == holstered)
		holstered = null
	return ..()

/obj/item/mod/module/holster/Destroy()
	QDEL_NULL(holstered)
	return ..()

///Megaphone - Lets you speak loud.
/obj/item/mod/module/megaphone
	name = "MOD megaphone module"
	desc = "A microchip megaphone linked to a MODsuit, for very important purposes, like: loudness."
	icon_state = "megaphone"
	module_type = MODULE_TOGGLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/megaphone)
	cooldown_time = 0.5 SECONDS
	/// List of spans we add to the speaker.
	var/list/voicespan = list(SPAN_COMMAND)

/obj/item/mod/module/megaphone/on_activation()
	. = ..()
	if(!.)
		return
	RegisterSignal(mod.wearer, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/obj/item/mod/module/megaphone/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	UnregisterSignal(mod.wearer, COMSIG_MOB_SAY)

/obj/item/mod/module/megaphone/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	speech_args[SPEECH_SPANS] |= voicespan
	drain_power(use_power_cost)

///Criminal Capture - Generates hardlight bags you can put people in and sinch.
/obj/item/mod/module/criminalcapture
	name = "MOD criminal capture module"
	desc = "The private security that had orders to take in people dead were quite \
		happy with their space-proofed suit, but for those who wanted to bring back \
		whomever their targets were still breathing needed a way to \"share\" the \
		space-proofing. And thus: criminal capture! Creates a hardlight prisoner transport bag \
		around the apprehended that has breathable atmospheric conditions."
	icon_state = "criminal_capture"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/criminalcapture)
	cooldown_time = 0.5 SECONDS
	/// Time to capture a prisoner.
	var/capture_time = 2.5 SECONDS
	/// Time to dematerialize a bodybag.
	var/packup_time = 1 SECONDS
	/// Typepath of our bodybag
	var/bodybag_type = /obj/structure/closet/body_bag/environmental/prisoner/hardlight
	/// Our linked bodybag.
	var/obj/structure/closet/body_bag/linked_bodybag

/obj/item/mod/module/criminalcapture/on_process(seconds_per_tick)
	idle_power_cost = linked_bodybag ? (DEFAULT_CHARGE_DRAIN * 3) : 0
	return ..()

/obj/item/mod/module/criminalcapture/on_deactivation(display_message, deleting)
	. = ..()
	if(!.)
		return
	if(!linked_bodybag)
		return
	packup()

/obj/item/mod/module/criminalcapture/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(target == linked_bodybag)
		playsound(src, 'sound/machines/ding.ogg', 25, TRUE)
		if(!do_after(mod.wearer, packup_time, target = target))
			balloon_alert(mod.wearer, "interrupted!")
		packup()
		return
	if(linked_bodybag)
		return
	var/turf/target_turf = get_turf(target)
	if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
		return
	playsound(src, 'sound/machines/ding.ogg', 25, TRUE)
	if(!do_after(mod.wearer, capture_time, target = target))
		balloon_alert(mod.wearer, "interrupted!")
		return
	if(linked_bodybag)
		return
	linked_bodybag = new bodybag_type(target_turf)
	linked_bodybag.take_contents()
	playsound(linked_bodybag, 'sound/weapons/egloves.ogg', 80, TRUE)
	RegisterSignal(linked_bodybag, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))

/obj/item/mod/module/criminalcapture/proc/packup()
	if(!linked_bodybag)
		return
	playsound(linked_bodybag, 'sound/weapons/egloves.ogg', 80, TRUE)
	apply_wibbly_filters(linked_bodybag)
	animate(linked_bodybag, 0.5 SECONDS, alpha = 50, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, PROC_REF(delete_bag), linked_bodybag), 0.5 SECONDS)
	linked_bodybag = null

/obj/item/mod/module/criminalcapture/proc/check_range()
	SIGNAL_HANDLER

	if(get_dist(mod.wearer, linked_bodybag) <= 9)
		return
	packup()

/obj/item/mod/module/criminalcapture/proc/delete_bag(obj/structure/closet/body_bag/bag)
	if(mod?.wearer)
		UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
		balloon_alert(mod.wearer, "bag dissipated")
	bag.open(force = TRUE)
	qdel(bag)

///Mirage grenade dispenser - Dispenses grenades that copy the user's appearance.
/obj/item/mod/module/dispenser/mirage
	name = "MOD mirage grenade dispenser module"
	desc = "This module can create mirage grenades at the user's liking. These grenades create holographic copies of the user."
	icon_state = "mirage_grenade"
	cooldown_time = 20 SECONDS
	overlay_state_inactive = "module_mirage_grenade"
	dispense_type = /obj/item/grenade/mirage

/obj/item/mod/module/dispenser/mirage/on_use()
	. = ..()
	if(!.)
		return
	var/obj/item/grenade/mirage/grenade = .
	grenade.arm_grenade(mod.wearer)

/obj/item/grenade/mirage
	name = "mirage grenade"
	desc = "A special device that, when activated, produces a holographic copy of the user."
	icon_state = "mirage"
	inhand_icon_state = "flashbang"
	det_time = 3 SECONDS
	/// Mob that threw the grenade.
	var/mob/living/thrower

/obj/item/grenade/mirage/arm_grenade(mob/user, delayoverride, msg, volume)
	. = ..()
	thrower = user

/obj/item/grenade/mirage/detonate(mob/living/lanced_by)
	. = ..()
	do_sparks(rand(3, 6), FALSE, src)
	if(thrower)
		var/mob/living/simple_animal/hostile/illusion/mirage/mirage = new(get_turf(src))
		mirage.Copy_Parent(thrower, 15 SECONDS)
	qdel(src)

///Projectile Dampener - Weakens projectiles in range.
/obj/item/mod/module/projectile_dampener
	name = "MOD projectile dampener module"
	desc = "Using technology from peaceborgs, this module weakens all projectiles in nearby range."
	icon_state = "projectile_dampener"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/projectile_dampener)
	cooldown_time = 1.5 SECONDS
	/// Radius of the dampening field.
	var/field_radius = 2
	/// Damage multiplier on projectiles.
	var/damage_multiplier = 0.75
	/// Speed multiplier on projectiles, higher means slower.
	var/speed_multiplier = 2.5
	/// List of all tracked projectiles.
	var/list/tracked_projectiles = list()
	/// Effect image on projectiles.
	var/image/projectile_effect
	/// The dampening field
	var/datum/proximity_monitor/advanced/projectile_dampener/dampening_field

/obj/item/mod/module/projectile_dampener/Initialize(mapload)
	. = ..()
	projectile_effect = image('icons/effects/fields.dmi', "projectile_dampen_effect")

/obj/item/mod/module/projectile_dampener/on_activation()
	. = ..()
	if(!.)
		return
	if(istype(dampening_field))
		QDEL_NULL(dampening_field)
	dampening_field = new(mod.wearer, field_radius, TRUE, src)
	RegisterSignal(dampening_field, COMSIG_DAMPENER_CAPTURE, PROC_REF(dampen_projectile))
	RegisterSignal(dampening_field, COMSIG_DAMPENER_RELEASE, PROC_REF(release_projectile))

/obj/item/mod/module/projectile_dampener/on_deactivation(display_message, deleting = FALSE)
	. = ..()
	if(!.)
		return
	QDEL_NULL(dampening_field)

/obj/item/mod/module/projectile_dampener/proc/dampen_projectile(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	projectile.damage *= damage_multiplier
	projectile.speed *= speed_multiplier
	projectile.add_overlay(projectile_effect)

/obj/item/mod/module/projectile_dampener/proc/release_projectile(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	projectile.damage /= damage_multiplier
	projectile.speed /= speed_multiplier
	projectile.cut_overlay(projectile_effect)

///Active Sonar - Displays a hud circle on the turf of any living creatures in the given radius
/obj/item/mod/module/active_sonar
	name = "MOD active sonar"
	desc = "Ancient tech from the 20th century, this module uses sonic waves to detect living creatures within the user's radius. \
		Its loud ping is much harder to hide in an indoor station than in the outdoor operations it was designed for."
	icon_state = "active_sonar"
	module_type = MODULE_USABLE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 4
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/active_sonar)
	cooldown_time = 15 SECONDS

/obj/item/mod/module/active_sonar/on_use()
	. = ..()
	if(!.)
		return
	balloon_alert(mod.wearer, "readying sonar...")
	playsound(mod.wearer, 'sound/mecha/skyfall_power_up.ogg', vol = 20, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	if(!do_after(mod.wearer, 1.1 SECONDS, target = mod))
		return
	var/creatures_detected = 0
	for(var/mob/living/creature in range(9, mod.wearer))
		if(creature == mod.wearer || creature.stat == DEAD)
			continue
		new /obj/effect/temp_visual/sonar_ping(mod.wearer.loc, mod.wearer, creature)
		creatures_detected++
	playsound(mod.wearer, 'sound/effects/ping_hit.ogg', vol = 75, vary = TRUE, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE) // Should be audible for the radius of the sonar
	to_chat(mod.wearer, span_notice("You slam your fist into the ground, sending out a sonic wave that detects [creatures_detected] living beings nearby!"))

#define SHOOTING_ASSISTANT_OFF "Currently Off"
#define STORMTROOPER_MODE "Quick Fire Stormtrooper"
#define SHARPSHOOTER_MODE "Slow Ricochet Sharpshooter"

/**
 * A module that enhances the user's ability with firearms, with a couple drawbacks:
 * In 'Stormtrooper' mode, the user will be given faster firerate, but lower accuracy.
 * In 'Sharpshooter' mode, the user will have better accuracy and ricochet to his shots, but slower movement speed.
 * Both modes prevent the user from dual wielding guns.
 */
/obj/item/mod/module/shooting_assistant
	name = "MOD shooting assistant module"
	desc = "A botched prototype meant to boost the TGMC crayon eaters' ability with firearms. \
		It has only two modes available in its configurations: \
		'Quick Fire Stormtrooper' and 'Slow Ricochet Sharpshooter', \
		both incompatible with dual wielding firearms."
	icon_state = "shooting_assistant"
	module_type = MODULE_PASSIVE
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/shooting_assistant)
	var/selected_mode = SHOOTING_ASSISTANT_OFF
	///Association list, the assoc values are the balloon alerts shown to the user when the mode is set.
	var/static/list/available_modes = list(
		SHOOTING_ASSISTANT_OFF = "assistant off",
		STORMTROOPER_MODE = "stormtrooper mode",
		SHARPSHOOTER_MODE = "sharpshooter mode",
	)

/obj/item/mod/module/shooting_assistant/get_configuration()
	. = ..()
	.["shooting_mode"] = add_ui_configuration("Mode", "list", selected_mode, assoc_to_keys(available_modes))

/obj/item/mod/module/shooting_assistant/configure_edit(key, value)
	switch(key)
		if("shooting_mode")
			set_shooting_mode(value)

/obj/item/mod/module/shooting_assistant/proc/set_shooting_mode(new_mode)
	if(new_mode == selected_mode || !mod.active)
		return
	if(new_mode != SHOOTING_ASSISTANT_OFF && !mod.get_charge())
		balloon_alert(mod.wearer, "no charge!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return

	//Remove the effects of the previously selected mode
	if(mod.active)
		remove_mode_effects()

	balloon_alert(mod.wearer, available_modes[new_mode])
	selected_mode = new_mode

	//Apply the effects of the new mode
	if(mod.active)
		apply_mode_effects()

/obj/item/mod/module/shooting_assistant/proc/apply_mode_effects()
	switch(selected_mode)
		if(SHOOTING_ASSISTANT_OFF)
			idle_power_cost = 0
		if(STORMTROOPER_MODE)
			idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.4
			mod.wearer.add_traits(list(TRAIT_NO_GUN_AKIMBO, TRAIT_DOUBLE_TAP), MOD_TRAIT)
			RegisterSignal(mod.wearer, COMSIG_MOB_FIRED_GUN, PROC_REF(stormtrooper_fired_gun))
		if(SHARPSHOOTER_MODE)
			idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.6
			mod.wearer.add_traits(list(TRAIT_NO_GUN_AKIMBO, TRAIT_NICE_SHOT), MOD_TRAIT)
			RegisterSignal(mod.wearer, COMSIG_MOB_FIRED_GUN, PROC_REF(sharpshooter_fired_gun))
			RegisterSignal(mod.wearer, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE, PROC_REF(apply_ricochet))
			mod.wearer.add_movespeed_modifier(/datum/movespeed_modifier/shooting_assistant)

/obj/item/mod/module/shooting_assistant/proc/remove_mode_effects()
	switch(selected_mode)
		if(STORMTROOPER_MODE)
			UnregisterSignal(mod.wearer, COMSIG_MOB_FIRED_GUN)
			mod.wearer.remove_traits(list(TRAIT_NO_GUN_AKIMBO, TRAIT_DOUBLE_TAP), MOD_TRAIT)
		if(SHARPSHOOTER_MODE)
			UnregisterSignal(mod.wearer, list(COMSIG_MOB_FIRED_GUN, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE))
			mod.wearer.remove_traits(list(TRAIT_NO_GUN_AKIMBO, TRAIT_NICE_SHOT), MOD_TRAIT)
			mod.wearer.remove_movespeed_modifier(/datum/movespeed_modifier/shooting_assistant)

/obj/item/mod/module/shooting_assistant/drain_power(amount)
	. = ..()
	if(!.)
		set_shooting_mode(SHOOTING_ASSISTANT_OFF)

/obj/item/mod/module/shooting_assistant/on_suit_activation()
	apply_mode_effects()

/obj/item/mod/module/shooting_assistant/on_suit_deactivation(deleting = FALSE)
	remove_mode_effects()

/obj/item/mod/module/shooting_assistant/proc/stormtrooper_fired_gun(mob/user, obj/item/gun/gun_fired, target, params, zone_override, list/bonus_spread_values)
	SIGNAL_HANDLER
	bonus_spread_values[MIN_BONUS_SPREAD_INDEX] += 15
	bonus_spread_values[MAX_BONUS_SPREAD_INDEX] += 25

/obj/item/mod/module/shooting_assistant/proc/sharpshooter_fired_gun(mob/user, obj/item/gun/gun_fired, target, params, zone_override, list/bonus_spread_values)
	SIGNAL_HANDLER
	bonus_spread_values[MIN_BONUS_SPREAD_INDEX] -= 20
	bonus_spread_values[MAX_BONUS_SPREAD_INDEX] -= 10

/obj/item/mod/module/shooting_assistant/proc/apply_ricochet(mob/user, obj/projectile/projectile, datum/fired_from, atom/clicked_atom)
	SIGNAL_HANDLER
	projectile.ricochets_max += 1
	projectile.min_ricochets += 1
	projectile.ricochet_incidence_leeway = 0 //allows the projectile to bounce at any angle.
	ADD_TRAIT(projectile, TRAIT_ALWAYS_HIT_ZONE, MOD_TRAIT)

#undef SHOOTING_ASSISTANT_OFF
#undef STORMTROOPER_MODE
#undef SHARPSHOOTER_MODE
