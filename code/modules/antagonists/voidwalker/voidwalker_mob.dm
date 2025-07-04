//Minimum strength to convert a wall into a void window.
#define WALL_CONVERT_STRENGTH 40

/// Voidwalker mob to void all over the place
/mob/living/basic/voidwalker
	name = "voidwalker"
	desc = "A glass-like entity from the void between stars. You probably shouldn't stare."
	icon = 'icons/mob/simple/voidwalker.dmi'
	icon_state = "voidwalker"

	mob_biotypes = MOB_SPECIAL
	maxHealth = 150
	health = 150
	damage_coeff = list(BRUTE = 1, BURN = 0.66, TOX = 1, STAMINA = 1, OXY = 0)

	pressure_resistance = 200
	combat_mode = TRUE

	obj_damage = 15

	melee_damage_lower = 12
	melee_damage_upper = 15
	melee_attack_cooldown = CLICK_CD_MELEE

	melee_damage_type = OXY

	attack_sound = 'sound/items/weapons/shrink_hit.ogg'
	attack_vis_effect = ATTACK_EFFECT_VOID

	faction = list(FACTION_CARP)

	habitable_atmos = null
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500

	basic_mob_flags = DEL_ON_DEATH
	speed = 0

	hud_type = /datum/hud/dextrous/voidwalker
	hud_possible = list(ANTAG_HUD)
	sight = SEE_TURFS | SEE_MOBS

	/// Color of our regen outline
	var/regenerate_colour = COLOR_GRAY

	/// How long does it take to kidnap them?
	var/kidnap_time = 6 SECONDS
	/// Are we kidnapping right now?
	var/kidnapping = FALSE

	/// Our stare/stun ability
	var/datum/action/cooldown/spell/pointed/unsettle/unsettle
	/// Our means of communicating with the world
	var/datum/action/cooldown/spell/list_target/telepathy/voidwalker/telepathy = /datum/action/cooldown/spell/list_target/telepathy/voidwalker
	/// Our cool charge ability
	var/datum/action/cooldown/mob_cooldown/charge/charge = /datum/action/cooldown/mob_cooldown/charge/voidwalker

	/// Alpha we have in space
	var/space_alpha = 0
	/// Alpha we have elsewhere
	var/non_space_alpha = 255

	/// Speed modifier given when in gravity
	var/datum/movespeed_modifier/speed_modifier = /datum/movespeed_modifier/grounded_voidwalker

	/// Cooldown for converting walls to void windows
	COOLDOWN_DECLARE(wall_conversion)
	/// How many wall conversions can we perform before we have to refresh?
	var/conversions_remaining = 2

	/// Damage type we do for rightclicks
	var/rclick_damage_type = BRUTE
	/// Can we speak?
	var/can_speak = FALSE
	/// Turf that our abilities rely on. VVing this automatically sets all the components and removes space dependency stuff if the new tile isnt space
	var/home_turf = /turf/open/space
	/// Decal that we can kidnap on
	var/kidnapping_decal = /obj/effect/decal/cleanable/vomit/nebula
	/// Toggle for abduction interactions, in-case we have non-kidnap subtypes ()
	var/can_do_abductions = TRUE

/mob/living/basic/voidwalker/Initialize(mapload, mob/tamer)
	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT) //Need to set before init cause if we init in hyperspace we get dragged before the trait can be added
	. = ..()

	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/glass_pacifist)

	AddComponent(/datum/component/regenerator, brute_per_second = 2, burn_per_second = 2, outline_colour = regenerate_colour, regen_check = CALLBACK(src, PROC_REF(can_regen)))
	AddComponent(/datum/component/glass_passer, deform_glass = 5 SECONDS)
	AddComponent(/datum/component/planet_allergy)

	AddElement(/datum/element/dextrous, hud_type = hud_type)
	AddComponent(/datum/component/basic_inhands, x_offset = -2)

	AddElement(/datum/element/pick_and_drop_only)

	AddComponent(/datum/component/debris_bleeder, \
		list(/obj/effect/spawner/random/glass_shards = 20, /obj/effect/spawner/random/glass_debris = 0), \
		BRUTE, SFX_SHATTER, sound_threshold = 20)

	charge = new charge(src)
	charge.Grant(src)

	// Glass passing is handled by the glass passer component
	passtable_on(src, type)

	// Voidwalker lore is that radio's actually attracted them, so they should be able to listen to it
	var/obj/item/radio/internal_radio = new /obj/item/radio(src)
	internal_radio.keyslot = /obj/item/encryptionkey/heads/captain
	internal_radio.subspace_transmission = TRUE
	internal_radio.canhear_range = 0 // anything higher and people in the area will hear it too
	internal_radio.recalculateChannels()

	telepathy =  new telepathy(src)
	telepathy.Grant(src)

	unique_setup()

/// Stuff you might want different on subtypes
/mob/living/basic/voidwalker/proc/unique_setup()
	AddComponent(/datum/component/space_camo, space_alpha, non_space_alpha, 255, 5 SECONDS, image(icon, icon_state + "_stealthed", ABOVE_LIGHTING_PLANE))
	AddComponent(/datum/component/space_dive, /obj/effect/dummy/phased_mob/space_dive/voidwalker)

	unsettle = new(src)
	unsettle.Grant(src)

	fully_replace_character_name(null, pick(GLOB.voidwalker_names))

/mob/living/basic/voidwalker/Destroy()
	QDEL_NULL(unsettle)
	QDEL_NULL(telepathy)
	QDEL_NULL(charge)

	return ..()

/// Called on COMSIG_LIVING_UNARMED_ATTACK
/mob/living/basic/voidwalker/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()

	if(!. || !can_do_abductions)
		return

	if(ishuman(target))
		var/mob/living/carbon/human/hewmon = target

		var/should_attack = try_kidnap(hewmon)

		if(!should_attack)
			return FALSE

		if(hewmon.stat == HARD_CRIT && !hewmon.has_trauma_type(/datum/brain_trauma/voided))
			hewmon.balloon_alert(src, "is in crit!")
			hewmon.Stun(5 SECONDS) // blocks some crit movement mechanics from a bunch of sources
			return FALSE

	// left click
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		melee_damage_type = ishuman(target) ? initial(melee_damage_type) : rclick_damage_type

	// Right click
	else
		melee_damage_type = rclick_damage_type

		if(!istype(target, /turf/closed/wall))
			return
		INVOKE_ASYNC(src, PROC_REF(try_convert_wall), target)
	return TRUE

/// Called by the regenerator component so we only regen in space
/mob/living/basic/voidwalker/proc/can_regen()
	if(istype(get_turf(src), home_turf))
		return TRUE
	return FALSE

/mob/living/basic/voidwalker/can_speak(allow_mimes)
	return can_speak && ..()

/mob/living/basic/voidwalker/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	if(!isturf(loc) || !speed_modifier)
		return

	var/turf/new_turf = loc

	//apply debufs for being in gravity
	var/area/local_area = get_area(new_turf)
	if(new_turf.has_gravity() && !is_area_nearby_station(local_area))
		add_movespeed_modifier(speed_modifier)
	//remove debufs for not being in gravity
	else
		remove_movespeed_modifier(speed_modifier)

/mob/living/basic/voidwalker/death()
	var/turf/spawn_loc = get_turf(src)
	new /obj/effect/spawner/random/glass_shards(spawn_loc)
	new /obj/item/clothing/head/helmet/skull/cosmic(spawn_loc)
	playsound(get_turf(src), SFX_SHATTER, 100)

	return ..()

///
/// Kidnapping
///

/// Start the kidnap interactions, including surprises for those who are already voided
/mob/living/basic/voidwalker/proc/try_kidnap(mob/living/carbon/human/victim)
	if(victim.has_trauma_type(/datum/brain_trauma/voided))
		victim.balloon_alert(src, "already voided!")
		new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(victim))
		victim.SetSleeping(30 SECONDS)
		return FALSE

	if(victim.stat == DEAD)
		victim.balloon_alert(src, "is dead!")
		return FALSE

	if(victim.stat == CONSCIOUS) //we're still beating them up!!
		return TRUE

	if(!istype(get_turf(victim), home_turf) && !(locate(kidnapping_decal) in get_turf(victim)))
		victim.balloon_alert(src, "not in space!")
		return FALSE

	if(!kidnapping)
		INVOKE_ASYNC(src, PROC_REF(kidnap), src, victim)
		return FALSE

/// Start kidnapping the victim
/mob/living/basic/voidwalker/proc/kidnap(mob/living/parent, mob/living/victim)
	victim.Paralyze(kidnap_time) //so they don't get up if we already got em

	var/static/list/wave_filter = list(type = "wave", x = 2, size = 4)
	victim.add_filter("wave_filter_kidnap", 3, wave_filter)
	animate(victim.get_filter("wave_filter_kidnap"), offset = 32, time = kidnap_time)

	kidnapping = TRUE

	if(do_after(parent, kidnap_time, victim, extra_checks = CALLBACK(src, PROC_REF(check_incapacitated), victim)))
		take_them(victim)

	victim.remove_filter("wave_filter_kidnap")

	kidnapping = FALSE

/// Woosh! You got takened
/mob/living/basic/voidwalker/proc/take_them(mob/living/victim)
	if(ishuman(victim))
		var/mob/living/carbon/human/hewmon = victim
		hewmon.gain_trauma(/datum/brain_trauma/voided)

	victim.flash_act(INFINITY, override_blindness_check = TRUE, visual = TRUE, type = /atom/movable/screen/fullscreen/flash/black)
	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(victim))

	if(!SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_VOIDWALKER_VOID) || !GLOB.voidwalker_void.len)
		victim.forceMove(get_random_station_turf())
		victim.heal_overall_damage(brute = 80, burn = 20)
		CRASH("[victim] was instantly dumped after being voidwalker kidnapped due to a missing landmark!")
	else
		victim.heal_and_revive(90)
		victim.adjustOxyLoss(-100, FALSE)

		conversions_remaining++

		var/obj/wisp = new /obj/effect/wisp_mobile (get_turf(pick(GLOB.voidwalker_void)))
		victim.forceMove(wisp)

/// Check if theyre still incapacitated for the kidnap do_after
/mob/living/basic/voidwalker/proc/check_incapacitated(mob/living/carbon/human/kidnappee)
	return kidnappee.incapacitated

/// Modding the voidwalker is funny, so setting the home_turf sets everything right for easy of modding
/mob/living/basic/voidwalker/vv_edit_var(vname, vval)
	. = ..()
	// This is all very snowflakey code but like, it's supposed to be. It's just for helping admins mod it
	if(vname == NAMEOF(src, home_turf))
		var/datum/component/space_camo/camo = GetComponent(/datum/component/space_camo)
		var/datum/component/space_dive/dive = GetComponent(/datum/component/space_dive)

		camo.camo_tile = vval
		dive.diveable_turf = vval
		if(istype(charge, /datum/action/cooldown/mob_cooldown/charge/voidwalker))
			var/datum/action/cooldown/mob_cooldown/charge/voidwalker/charge_voidwalker = charge
			charge_voidwalker.valid_target_turf = vval

		if(!isspaceturf(vval))
			qdel(GetComponent(/datum/component/planet_allergy))
			remove_movespeed_modifier(speed_modifier)
			speed_modifier = null

///
/// Wall Conversion
///

/// Attempt to convert a wall into passable voidwalker windows
/mob/living/basic/voidwalker/proc/try_convert_wall(turf/closed/wall/our_wall)
	if(!conversions_remaining)
		balloon_alert(src, "need more kidnaps!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!COOLDOWN_FINISHED(src, wall_conversion))
		balloon_alert(src, "must wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, wall_conversion))]!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!check_wall_validity(our_wall, src, silent = FALSE))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	playsound(our_wall, 'sound/effects/magic/blind.ogg', 100, TRUE)
	new /obj/effect/temp_visual/transmute_tile_flash(our_wall)

	var/obj/particles = new /obj/effect/abstract/particle_holder (our_wall, /particles/void_wall)

	balloon_alert(src, "opening window...")
	if(!do_after(src, 8 SECONDS, our_wall, hidden = TRUE))
		qdel(particles)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!conversions_remaining)
		qdel(particles)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	qdel(particles)

	var/list/target_walls = list()
	target_walls += our_wall
	for(var/turf/closed/wall/adjacent_wall in orange(1, our_wall))
		if(check_wall_validity(adjacent_wall))
			target_walls += adjacent_wall

	playsound(our_wall, 'sound/effects/magic/blind.ogg', 100, TRUE)

	for(var/turf/closed/wall/targeted_wall in target_walls)
		new /obj/effect/temp_visual/transmute_tile_flash(targeted_wall)
		targeted_wall.ScrapeAway()
		new /obj/structure/window/fulltile/voidwalker(targeted_wall)
		new /obj/structure/grille(targeted_wall)

	conversions_remaining--
	COOLDOWN_START(src, wall_conversion, 60 SECONDS)

/// Check if the wall is valid for conversion
/mob/living/basic/voidwalker/proc/check_wall_validity(turf/closed/wall/wall_to_check, silent = TRUE)
	if(wall_to_check.hardness < WALL_CONVERT_STRENGTH)
		if(!silent)
			balloon_alert(src, "too strong!")
		return FALSE
	return TRUE

#undef WALL_CONVERT_STRENGTH
