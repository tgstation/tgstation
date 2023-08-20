/// The darkness threshold for space dragon when choosing a color
#define DARKNESS_THRESHOLD 50

/**
 * # Space Dragon
 *
 * A space-faring leviathan-esque monster which breathes fire and summons carp.  Spawned during its respective midround antagonist event.
 *
 * A space-faring monstrosity who has the ability to breathe dangerous fire breath and uses its powerful wings to knock foes away.
 * Normally spawned as an antagonist during the Space Dragon event, Space Dragon's main goal is to open three rifts from which to pull a great tide of carp onto the station.
 * Space Dragon can summon only one rift at a time, and can do so anywhere a blob is allowed to spawn.  In order to trigger his victory condition, Space Dragon must summon and defend three rifts while they charge.
 * Space Dragon, when spawned, has five minutes to summon the first rift.  Failing to do so will cause Space Dragon to return from whence he came.
 * When the rift spawns, ghosts can interact with it to spawn in as space carp to help complete the mission.  One carp is granted when the rift is first summoned, with an extra one every 30 seconds.
 * Once the victory condition is met, all current rifts become invulnerable to damage, are allowed to spawn infinite sentient space carp, and Space Dragon gets unlimited rage.
 * Alternatively, if the shuttle arrives while Space Dragon is still active, their victory condition will automatically be met and all the rifts will immediately become fully charged.
 * If a charging rift is destroyed, Space Dragon will be incredibly slowed, and the endlag on his gust attack is greatly increased on each use.
 * Space Dragon has the following abilities to assist him with his objective:
 * - Can shoot fire in straight line, dealing 30 burn damage and setting those suseptible on fire.
 * - Can use his wings to temporarily stun and knock back any nearby mobs.  This attack has no cooldown, but instead has endlag after the attack where Space Dragon cannot act.  This endlag's time decreases over time, but is added to every time he uses the move.
 * - Can swallow mob corpses to heal for half their max health.  Any corpses swallowed are stored within him, and will be regurgitated on death.
 * - Can tear through any type of wall.  This takes 4 seconds for most walls, and 12 seconds for reinforced walls.
 */
/mob/living/simple_animal/hostile/space_dragon
	name = "Space Dragon"
	desc = "A vile, leviathan-esque creature that flies in the most unnatural way. Looks slightly similar to a space carp."
	gender = NEUTER
	maxHealth = 400
	health = 400
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0.5, OXY = 1)
	combat_mode = TRUE
	speed = 0
	movement_type = FLYING
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	death_sound = 'sound/creatures/space_dragon_roar.ogg'
	icon = 'icons/mob/nonhuman-player/spacedragon.dmi'
	icon_state = "spacedragon"
	icon_living = "spacedragon"
	icon_dead = "spacedragon_dead"
	health_doll_icon = "spacedragon"
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_NONE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	melee_damage_upper = 35
	melee_damage_lower = 35
	mob_size = MOB_SIZE_LARGE
	armour_penetration = 30
	pixel_x = -16
	base_pixel_x = -16
	maptext_height = 64
	maptext_width = 64
	turns_per_move = 5
	ranged = TRUE
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	death_message = "screeches as its wings turn to dust and it collapses on the floor, its life extinguished."
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list(FACTION_CARP)
	pressure_resistance = 200
	/// How much endlag using Wing Gust should apply.  Each use of wing gust increments this, and it decreases over time.
	var/tiredness = 0
	/// A multiplier to how much each use of wing gust should add to the tiredness variable.  Set to 5 if the current rift is destroyed.
	var/tiredness_mult = 1
	/// The distance Space Dragon's gust reaches
	var/gust_distance = 4
	/// The amount of tiredness to add to Space Dragon per use of gust
	var/gust_tiredness = 30
	/// Determines whether or not Space Dragon is in the middle of using wing gust.  If set to true, prevents him from moving and doing certain actions.
	var/using_special = FALSE
	/// Determines whether or not Space Dragon is currently tearing through a wall.
	var/tearing_wall = FALSE
	/// The color of the space dragon.
	var/chosen_color
	/// Minimum devastation damage dealt coefficient based on max health
	var/devastation_damage_min_percentage = 0.4
	/// Maximum devastation damage dealt coefficient based on max health
	var/devastation_damage_max_percentage = 0.75

/mob/living/simple_animal/hostile/space_dragon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/simple_flying)
	add_traits(list(TRAIT_SPACEWALK, TRAIT_FREE_HYPERSPACE_MOVEMENT, TRAIT_NO_FLOATING_ANIM, TRAIT_HEALS_FROM_CARP_RIFTS), INNATE_TRAIT)
	AddElement(/datum/element/content_barfer)

/mob/living/simple_animal/hostile/space_dragon/Login()
	. = ..()
	if(!chosen_color)
		dragon_name()
		color_selection()

/mob/living/simple_animal/hostile/space_dragon/ex_act_devastate()
	var/damage_coefficient = rand(devastation_damage_min_percentage, devastation_damage_max_percentage)
	adjustBruteLoss(initial(maxHealth)*damage_coefficient)

/mob/living/simple_animal/hostile/space_dragon/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	tiredness = max(tiredness - (0.5 * seconds_per_tick), 0)

/mob/living/simple_animal/hostile/space_dragon/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if (isliving(arrived))
		RegisterSignal(arrived, COMSIG_MOB_STATCHANGE, PROC_REF(eaten_stat_changed))

/mob/living/simple_animal/hostile/space_dragon/Exited(atom/movable/gone, direction)
	. = ..()
	if (isliving(gone))
		UnregisterSignal(gone, COMSIG_MOB_STATCHANGE)

/// Release consumed mobs if they transition from dead to alive
/mob/living/simple_animal/hostile/space_dragon/proc/eaten_stat_changed(mob/living/eaten)
	SIGNAL_HANDLER
	if (eaten.stat == DEAD)
		return
	playsound(src, 'sound/effects/splat.ogg', vol = 50, vary = TRUE)
	visible_message(span_danger("[src] vomits up [eaten]!"))
	eaten.forceMove(loc)
	eaten.Paralyze(5 SECONDS)

/mob/living/simple_animal/hostile/space_dragon/AttackingTarget()
	if(using_special)
		return
	if(target == src)
		to_chat(src, span_warning("You almost bite yourself, but then decide against it."))
		return
	if(iswallturf(target))
		if(tearing_wall)
			return
		tearing_wall = TRUE
		var/turf/closed/wall/thewall = target
		to_chat(src, span_warning("You begin tearing through the wall..."))
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		var/timetotear = 40
		if(istype(target, /turf/closed/wall/r_wall))
			timetotear = 120
		if(do_after(src, timetotear, target = thewall))
			if(isopenturf(thewall))
				return
			thewall.dismantle_wall(1)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		tearing_wall = FALSE
		return
	if(isliving(target)) //Swallows corpses like a snake to regain health.
		var/mob/living/L = target
		if(L.stat == DEAD)
			to_chat(src, span_warning("You begin to swallow [L] whole..."))
			if(do_after(src, 30, target = L))
				if(eat(L))
					adjustHealth(-L.maxHealth * 0.25)
			return
	. = ..()
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		M.take_damage(50, BRUTE, MELEE, 1)

/mob/living/simple_animal/hostile/space_dragon/ranged_secondary_attack(atom/target, modifiers)
	if(using_special)
		return
	using_special = TRUE
	icon_state = "spacedragon_gust"
	add_dragon_overlay()
	useGust(0)

/mob/living/simple_animal/hostile/space_dragon/Move()
	if(!using_special)
		..()

/mob/living/simple_animal/hostile/space_dragon/OpenFire()
	if(using_special)
		return
	ranged_cooldown = world.time + ranged_cooldown_time
	fire_stream()

/mob/living/simple_animal/hostile/space_dragon/death(gibbed)
	. = ..()
	add_dragon_overlay()

/mob/living/simple_animal/hostile/space_dragon/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	add_dragon_overlay()

/**
 * Allows space dragon to choose its own name.
 *
 * Prompts the space dragon to choose a name, which it will then apply to itself.
 * If the name is invalid, will re-prompt the dragon until a proper name is chosen.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/dragon_name()
	var/chosen_name = sanitize_name(reject_bad_text(tgui_input_text(src, "What would you like your name to be?", "Choose Your Name", real_name, MAX_NAME_LEN)))
	if(!chosen_name)
		to_chat(src, span_warning("Not a valid name, please try again."))
		dragon_name()
		return
	to_chat(src, span_notice("Your name is now [span_name("[chosen_name]")], the feared Space Dragon."))
	fully_replace_character_name(null, chosen_name)

/**
 * Allows space dragon to choose a color for itself.
 *
 * Prompts the space dragon to choose a color, from which it will then apply to itself.
 * If an invalid color is given, will re-prompt the dragon until a proper color is chosen.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/color_selection()
	chosen_color = input(src,"What would you like your color to be?","Choose Your Color", COLOR_WHITE) as color|null
	if(!chosen_color) //redo proc until we get a color
		to_chat(src, span_warning("Not a valid color, please try again."))
		color_selection()
		return
	var/temp_hsv = RGBtoHSV(chosen_color)
	if(ReadHSV(temp_hsv)[3] < DARKNESS_THRESHOLD)
		to_chat(src, span_danger("Invalid color. Your color is not bright enough."))
		color_selection()
		return
	add_atom_colour(chosen_color, FIXED_COLOUR_PRIORITY)
	add_dragon_overlay()

/**
 * Adds the proper overlay to the space dragon.
 *
 * Clears the current overlay on space dragon and adds a proper one for whatever animation he's in.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/add_dragon_overlay()
	cut_overlays()
	if(stat == DEAD)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_dead")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)
		return
	if(!using_special)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_base")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)
		return
	if(using_special)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_gust")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)

/**
 * Determines a line of turfs from sources's position to the target with length range.
 *
 * Determines a line of turfs from the source's position to the target with length range.
 * The line will extend on past the target if the range is large enough, and not reach the target if range is small enough.
 * Arguments:
 * * offset - whether or not to aim slightly to the left or right of the target
 * * range - how many turfs should we go out for
 * * atom/at - The target
 */
/mob/living/simple_animal/hostile/space_dragon/proc/line_target(offset, range, atom/at = target)
	if(!at)
		return
	var/angle = ATAN2(at.x - src.x, at.y - src.y) + offset
	var/turf/T = get_turf(src)
	for(var/i in 1 to range)
		var/turf/check = locate(src.x + cos(angle) * i, src.y + sin(angle) * i, src.z)
		if(!check)
			break
		T = check
	return (get_line(src, T) - get_turf(src))

/**
 * Spawns fire at each position in a line from the source to the target.
 *
 * Spawns fire at each position in a line from the source to the target.
 * Stops if it comes into contact with a solid wall, a window, or a door.
 * Delays the spawning of each fire by 1.5 deciseconds.
 * Arguments:
 * * atom/at - The target
 */
/mob/living/simple_animal/hostile/space_dragon/proc/fire_stream(atom/at = target)
	playsound(get_turf(src),'sound/magic/fireball.ogg', 200, TRUE)
	var/range = 20
	var/list/turfs = list()
	var/list/hit_list_parameter = list(src)
	turfs = line_target(0, range, at)
	var/delayFire = -1.0
	for(var/turf/T in turfs)
		if(isclosedturf(T))
			return
		for(var/obj/structure/window/W in T.contents)
			return
		for(var/obj/machinery/door/D in T.contents)
			if(D.density)
				return
		delayFire += 1.0
		addtimer(CALLBACK(src, PROC_REF(dragon_fire_line), T, hit_list_parameter), delayFire)

/**
 * What occurs on each tile to actually create the fire.
 *
 * Creates a fire on the given turf.
 * It creates a hotspot on the given turf, damages any living mob with 30 burn damage, and damages mechs by 50.
 * It can only hit any given target once.
 * Arguments:
 * * turf/T - The turf to trigger the effects on.
 * * list/hit_list - The list of targets that have already been hit in the fire_stream.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/dragon_fire_line(turf/fire_turf, list/hit_list)
	new /obj/effect/hotspot(fire_turf)
	fire_turf.hotspot_expose(700,50,1)
	for(var/mob/living/living_target in fire_turf.contents)
		if(living_target.faction_check_mob(src) && living_target != src)
			hit_list += living_target
			start_carp_speedboost(living_target)
		if(living_target in hit_list)
			continue
		if(living_target.mind?.has_antag_datum(/datum/antagonist/space_carp))
			continue
		hit_list += living_target
		living_target.adjustFireLoss(30)
		to_chat(living_target, span_userdanger("You're hit by [src]'s fire breath!"))
	// deals damage to mechs
	for(var/obj/vehicle/sealed/mecha/mech_target in fire_turf.contents)
		if(mech_target in hit_list)
			continue
		hit_list += mech_target
		mech_target.take_damage(50, BRUTE, MELEE, 1)

/**
 * Applies the speed boost to carps when hit by space dragon's flame breath
 *
 * Applies the dragon rage effect to carps temporarily, giving them a glow and a speed boost.
 * This lasts for 8 seconds.
 * Arguments:
 * * mob/living/target - The carp being affected.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/start_carp_speedboost(mob/living/target)
	target.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 2))
	target.add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)
	addtimer(CALLBACK(src, PROC_REF(end_carp_speedboost), target), 8 SECONDS)

/**
 * Remove the speed boost from carps when hit by space dragon's flame breath
 *
 * Removes the dragon rage effect from carps, removing their glow and speed boost.
 * Arguments:
 * * mob/living/target - The carp being affected.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/end_carp_speedboost(mob/living/target)
	target.remove_filter("anger_glow")
	target.remove_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)

/**
 * Handles consuming and storing consumed things inside Space Dragon
 *
 * Plays a sound and then stores the consumed thing inside Space Dragon.
 * Used in AttackingTarget(), paired with a heal should it succeed.
 * Arguments:
 * * atom/movable/A - The thing being consumed
 */
/mob/living/simple_animal/hostile/space_dragon/proc/eat(atom/movable/A)
	if(A && A.loc != src)
		playsound(src, 'sound/magic/demon_attack1.ogg', 60, TRUE)
		visible_message(span_warning("[src] swallows [A] whole!"))
		to_chat(src, span_notice("Your acids cleanse the flames off [A] on the way down. Delicious!"))
		A.extinguish()
		A.forceMove(src)
		return TRUE
	return FALSE

/**
 * Resets Space Dragon's status after using wing gust.
 *
 * Resets Space Dragon's status after using wing gust.
 * If it isn't dead by the time it calls this method, reset the sprite back to the normal living sprite.
 * Also sets the using_special variable to FALSE, allowing Space Dragon to move and attack freely again.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/reset_status()
	if(stat != DEAD)
		icon_state = "spacedragon"
	using_special = FALSE
	add_dragon_overlay()

/**
 * Handles wing gust from the windup all the way to the endlag at the end.
 *
 * Handles the wing gust attack from start to finish, based on the timer.
 * When intially triggered, starts at 0.  Until the timer reaches 10, increase Space Dragon's y position by 2 and call back to the function in 1.5 deciseconds.
 * When the timer is at 10, trigger the attack.  Change Space Dragon's sprite. reset his y position, and push all living creatures back in a 3 tile radius and stun them for 5 seconds.
 * Stay in the ending state for how much our tiredness dictates and add to our tiredness.
 * Arguments:
 * * timer - The timer used for the windup.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/useGust(timer)
	if(timer != 10)
		pixel_y = pixel_y + 2;
		addtimer(CALLBACK(src, PROC_REF(useGust), timer + 1), 1.2)
		return
	pixel_y = 0
	icon_state = "spacedragon_gust_2"
	cut_overlays()
	var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_gust_2")
	overlay.appearance_flags = RESET_COLOR
	add_overlay(overlay)
	playsound(src, 'sound/effects/gravhit.ogg', 100, TRUE)
	for (var/mob/living/candidate in view(gust_distance, src))
		if(candidate == src || candidate.faction_check_mob(src))
			continue
		visible_message(span_boldwarning("[candidate] is knocked back by the gust!"))
		to_chat(candidate, span_userdanger("You're knocked back by the gust!"))
		var/dir_to_target = get_dir(get_turf(src), get_turf(candidate))
		var/throwtarget = get_edge_target_turf(target, dir_to_target)
		candidate.safe_throw_at(throwtarget, 10, 1, src)
		candidate.Paralyze(50)
	addtimer(CALLBACK(src, PROC_REF(reset_status)), 4 + ((tiredness * tiredness_mult) / 10))
	tiredness = tiredness + (gust_tiredness * tiredness_mult)

/mob/living/simple_animal/hostile/space_dragon/spawn_with_antag

/mob/living/simple_animal/hostile/space_dragon/spawn_with_antag/mind_initialize()
	. = ..()
	mind.add_antag_datum(/datum/antagonist/space_dragon)

#undef DARKNESS_THRESHOLD
