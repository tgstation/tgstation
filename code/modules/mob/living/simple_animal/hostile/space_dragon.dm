/// The carp rift is currently charging.
#define CHARGE_ONGOING 0
/// The carp rift is currently charging and has output a final warning.
#define CHARGE_FINALWARNING 1
/// The carp rift is now fully charged.
#define CHARGE_COMPLETED 2
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
	desc = "A vile, leviathan-esque creature that flies in the most unnatural way.  Looks slightly similar to a space carp."
	maxHealth = 320
	health = 320
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0.5, OXY = 1)
	combat_mode = TRUE
	speed = 0
	movement_type = FLYING
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	deathsound = 'sound/creatures/space_dragon_roar.ogg'
	icon = 'icons/mob/spacedragon.dmi'
	icon_state = "spacedragon"
	icon_living = "spacedragon"
	icon_dead = "spacedragon_dead"
	health_doll_icon = "spacedragon"
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_NONE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	melee_damage_upper = 35
	melee_damage_lower = 35
	atom_size = MOB_SIZE_LARGE
	armour_penetration = 30
	pixel_x = -16
	base_pixel_x = -16
	maptext_height = 64
	maptext_width = 64
	turns_per_move = 5
	ranged = TRUE
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	deathmessage = "screeches as its wings turn to dust and it collapses on the floor, its life extinguished."
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("carp")
	pressure_resistance = 200
	/// Current time since the the last rift was activated.  If set to -1, does not increment.
	var/riftTimer = 0
	/// Maximum amount of time which can pass without a rift before Space Dragon despawns.
	var/maxRiftTimer = 300
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
	/// A list of all of the rifts created by Space Dragon.  Used for setting them all to infinite carp spawn when Space Dragon wins, and removing them when Space Dragon dies.
	var/list/obj/structure/carp_rift/rift_list = list()
	/// How many rifts have been successfully charged
	var/rifts_charged = 0
	/// Whether or not Space Dragon has completed their objective, and thus triggered the ending sequence.
	var/objective_complete = FALSE
	/// The innate ability to summon rifts
	var/datum/action/innate/summon_rift/rift
	/// The color of the space dragon.
	var/chosen_color
	/// Minimum devastation damage dealt coefficient based on max health
	var/devastation_damage_min_percentage = 0.4
	/// Maximum devastation damage dealt coefficient based on max health
	var/devastation_damage_max_percentage = 0.75

/mob/living/simple_animal/hostile/space_dragon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_HEALS_FROM_CARP_RIFTS, INNATE_TRAIT)
	rift = new
	rift.Grant(src)

/mob/living/simple_animal/hostile/space_dragon/Login()
	. = ..()
	if(!chosen_color)
		dragon_name()
		color_selection()

/mob/living/simple_animal/hostile/space_dragon/ex_act_devastate()
	var/damage_coefficient = rand(devastation_damage_min_percentage, devastation_damage_max_percentage)
	adjustBruteLoss(initial(maxHealth)*damage_coefficient)

/mob/living/simple_animal/hostile/space_dragon/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	tiredness = max(tiredness - (0.5 * delta_time), 0)
	for(var/mob/living/consumed_mob in src)
		if(consumed_mob.stat == DEAD)
			continue
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
		visible_message(span_danger("[src] vomits up [consumed_mob]!"))
		consumed_mob.forceMove(loc)
		consumed_mob.Paralyze(50)
	if((rifts_charged == 3 || (SSshuttle.emergency.mode == SHUTTLE_DOCKED && rifts_charged > 0)) && !objective_complete)
		victory()
	if(riftTimer == -1)
		return
	riftTimer = min(riftTimer + 1, maxRiftTimer + 1)
	if(riftTimer == (maxRiftTimer - 60))
		to_chat(src, span_boldwarning("You have a minute left to summon the rift!  Get to it!"))
		return
	if(riftTimer >= maxRiftTimer)
		to_chat(src, span_boldwarning("You've failed to summon the rift in a timely manner!  You're being pulled back from whence you came!"))
		destroy_rifts()
		playsound(src, 'sound/magic/demon_dies.ogg', 100, TRUE)
		QDEL_NULL(src)

/mob/living/simple_animal/hostile/space_dragon/AttackingTarget()
	if(using_special)
		return
	if(target == src)
		to_chat(src, span_warning("You almost bite yourself, but then decide against it."))
		return
	if(istype(target, /turf/closed/wall))
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
			if(istype(thewall, /turf/open))
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
	if(istype(target, /obj/vehicle/sealed/mecha))
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
	empty_contents()
	if(!objective_complete)
		destroy_rifts()
	..()
	add_dragon_overlay()

/mob/living/simple_animal/hostile/space_dragon/revive(full_heal, admin_revive)
	. = ..()
	add_dragon_overlay()

/mob/living/simple_animal/hostile/space_dragon/wabbajack_act(mob/living/new_mob)
	empty_contents()
	. = ..()

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
	turfs = line_target(0, range, at)
	var/delayFire = -1.0
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			return
		for(var/obj/structure/window/W in T.contents)
			return
		for(var/obj/machinery/door/D in T.contents)
			if(D.density)
				return
		delayFire += 1.5
		addtimer(CALLBACK(src, .proc/dragon_fire_line, T), delayFire)

/**
 * What occurs on each tile to actually create the fire.
 *
 * Creates a fire on the given turf.
 * It creates a hotspot on the given turf, damages any living mob with 30 burn damage, and damages mechs by 50.
 * It can only hit any given target once.
 * Arguments:
 * * turf/T - The turf to trigger the effects on.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/dragon_fire_line(turf/T)
	var/list/hit_list = list()
	hit_list += src
	new /obj/effect/hotspot(T)
	T.hotspot_expose(700,50,1)
	for(var/mob/living/L in T.contents)
		if(L in hit_list)
			continue
		hit_list += L
		L.adjustFireLoss(30)
		to_chat(L, span_userdanger("You're hit by [src]'s fire breath!"))
	// deals damage to mechs
	for(var/obj/vehicle/sealed/mecha/M in T.contents)
		if(M in hit_list)
			continue
		hit_list += M
		M.take_damage(50, BRUTE, MELEE, 1)

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
		playsound(src, 'sound/magic/demon_attack1.ogg', 100, TRUE)
		visible_message(span_warning("[src] swallows [A] whole!"))
		A.forceMove(src)
		return TRUE
	return FALSE

/**
 * Disperses the contents of the mob on the surrounding tiles.
 *
 * Randomly places the contents of the mob onto surrounding tiles.
 * Has a 10% chance to place on the same tile as the mob.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/empty_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

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
 * Handles Space Dragon's temporary empowerment after boosting a rift.
 *
 * Empowers and depowers Space Dragon after a successful rift charge.
 * Empowered, Space Dragon regains all his health and becomes temporarily faster for 30 seconds, along with being tinted red.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/rift_empower(is_permanent)
	fully_heal()
	add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)
	addtimer(CALLBACK(src, .proc/rift_depower), 30 SECONDS)

/**
 * Gives Space Dragon their the rift speed buff permanantly.
 *
 * Gives Space Dragon the enraged speed buff from charging rifts permanantly.
 * Only happens in circumstances where Space Dragon completes their objective.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/permanant_empower()
	fully_heal()
	add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)

/**
 * Removes Space Dragon's rift speed buff.
 *
 * Removes Space Dragon's speed buff from charging a rift.  This is only called
 * in rift_empower, which uses a timer to call this after 30 seconds.  Also
 * removes the red glow from Space Dragon which is synonymous with the speed buff.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/rift_depower()
	remove_filter("anger_glow")
	remove_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)

/**
 * Destroys all of Space Dragon's current rifts.
 *
 * QDeletes all the current rifts after removing their references to other objects.
 * Currently, the only reference they have is to the Dragon which created them, so we clear that before deleting them.
 * Currently used when Space Dragon dies or one of his rifts is destroyed.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/destroy_rifts()
	rifts_charged = 0
	add_movespeed_modifier(/datum/movespeed_modifier/dragon_depression)
	riftTimer = -1
	tiredness_mult = 5
	playsound(src, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
	for(var/obj/structure/carp_rift/rift in rift_list)
		rift.dragon = null
		rift_list -= rift
		if(!QDELETED(rift))
			QDEL_NULL(rift)

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
		addtimer(CALLBACK(src, .proc/useGust, timer + 1), 1.5)
		return
	pixel_y = 0
	icon_state = "spacedragon_gust_2"
	cut_overlays()
	var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_gust_2")
	overlay.appearance_flags = RESET_COLOR
	add_overlay(overlay)
	playsound(src, 'sound/effects/gravhit.ogg', 100, TRUE)
	var/gust_locs = spiral_range_turfs(gust_distance, get_turf(src))
	var/list/hit_things = list()
	for(var/turf/T in gust_locs)
		for(var/mob/living/L in T.contents)
			if(L == src)
				continue
			hit_things += L
			visible_message(span_boldwarning("[L] is knocked back by the gust!"))
			to_chat(L, span_userdanger("You're knocked back by the gust!"))
			var/dir_to_target = get_dir(get_turf(src), get_turf(L))
			var/throwtarget = get_edge_target_turf(target, dir_to_target)
			L.safe_throw_at(throwtarget, 10, 1, src)
			L.Paralyze(50)
	addtimer(CALLBACK(src, .proc/reset_status), 4 + ((tiredness * tiredness_mult) / 10))
	tiredness = tiredness + (gust_tiredness * tiredness_mult)

/**
 * Sets up Space Dragon's victory for completing the objectives.
 *
 * Triggers when Space Dragon completes his objective.
 * Calls the shuttle with a coefficient of 3, making it impossible to recall.
 * Sets all of his rifts to allow for infinite sentient carp spawns
 * Also plays appropiate sounds and CENTCOM messages.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/victory()
	objective_complete = TRUE
	permanant_empower()
	var/datum/antagonist/space_dragon/S = mind.has_antag_datum(/datum/antagonist/space_dragon)
	if(S)
		var/datum/objective/summon_carp/main_objective = locate() in S.objectives
		if(main_objective)
			main_objective.completed = TRUE
	priority_announce("A large amount of lifeforms have been detected approaching [station_name()] at extreme speeds. Remaining crew are advised to evacuate as soon as possible.", "Central Command Wildlife Observations")
	sound_to_playing_players('sound/creatures/space_dragon_roar.ogg')
	for(var/obj/structure/carp_rift/rift in rift_list)
		rift.carp_stored = 999999
		rift.time_charged = rift.max_charge

/datum/action/innate/summon_rift
	name = "Summon Rift"
	desc = "Summon a rift to bring forth a horde of space carp."
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_space_dragon.dmi'
	button_icon_state = "carp_rift"

/datum/action/innate/summon_rift/Activate()
	var/mob/living/simple_animal/hostile/space_dragon/S = owner
	if(S.using_special)
		return
	if(S.riftTimer == -1)
		to_chat(S, span_warning("Your death has left you unable to summon rifts!"))
		return
	var/area/A = get_area(S)
	if(!(A.area_flags & VALID_TERRITORY))
		to_chat(S, span_warning("You can't summon a rift here!  Try summoning somewhere secure within the station!"))
		return
	for(var/obj/structure/carp_rift/rift in S.rift_list)
		var/area/RA = get_area(rift)
		if(RA == A)
			to_chat(S, span_warning("You've already summoned a rift in this area!  You have to summon again somewhere else!"))
			return
	to_chat(S, span_warning("You begin to open a rift..."))
	if(do_after(S, 100, target = S))
		for(var/obj/structure/carp_rift/c in S.loc.contents)
			return
		var/obj/structure/carp_rift/CR = new /obj/structure/carp_rift(S.loc)
		playsound(S, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
		S.riftTimer = -1
		CR.dragon = S
		S.rift_list += CR
		to_chat(S, span_boldwarning("The rift has been summoned.  Prevent the crew from destroying it at all costs!"))
		notify_ghosts("The Space Dragon has opened a rift!", source = CR, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Carp Rift Opened")
		qdel(src)

/**
 * # Carp Rift
 *
 * The portals Space Dragon summons to bring carp onto the station.
 *
 * The portals Space Dragon summons to bring carp onto the station.  His main objective is to summon 3 of them and protect them from being destroyed.
 * The portals can summon sentient space carp in limited amounts.  The portal also changes color based on whether or not a carp spawn is available.
 * Once it is fully charged, it becomes indestructible, and intermitently spawns non-sentient carp.  It is still destroyed if Space Dragon dies.
 */
/obj/structure/carp_rift
	name = "carp rift"
	desc = "A rift akin to the ones space carp use to travel long distances."
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 50, BIO = 100, FIRE = 100, ACID = 100)
	max_integrity = 300
	icon = 'icons/obj/carp_rift.dmi'
	icon_state = "carp_rift_carpspawn"
	light_color = LIGHT_COLOR_PURPLE
	light_range = 10
	anchored = TRUE
	density = FALSE
	plane = MASSIVE_OBJ_PLANE
	/// The amount of time the rift has charged for.
	var/time_charged = 0
	/// The maximum charge the rift can have.
	var/max_charge = 300
	/// How many carp spawns it has available.
	var/carp_stored = 1
	/// A reference to the Space Dragon that created it.
	var/mob/living/simple_animal/hostile/space_dragon/dragon
	/// Current charge state of the rift.
	var/charge_state = CHARGE_ONGOING
	/// The interval for adding additional space carp spawns to the rift.
	var/carp_interval = 60
	/// The time since an extra carp was added to the ghost role spawning pool.
	var/last_carp_inc = 0
	/// A list of all the ckeys which have used this carp rift to spawn in as carps.
	var/list/ckey_list = list()

/obj/structure/carp_rift/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/aura_healing, \
		range = 0, \
		simple_heal = 5, \
		limit_to_trait = TRAIT_HEALS_FROM_CARP_RIFTS, \
		healing_color = COLOR_BLUE, \
	)

	START_PROCESSING(SSobj, src)

// Carp rifts always take heavy explosion damage. Discourages the use of maxcaps
// and favours more weaker explosives to destroy the portal
// as they have the same effect on the portal.
/obj/structure/carp_rift/ex_act(severity, target)
	return ..(min(EXPLODE_HEAVY, severity))

/obj/structure/carp_rift/examine(mob/user)
	. = ..()
	if(time_charged < max_charge)
		. += span_notice("It seems to be [(time_charged / max_charge) * 100]% charged.")
	else
		. += span_warning("This one is fully charged.  In this state, it is poised to transport a much larger amount of carp than normal.")

	if(isobserver(user))
		. += span_notice("It has [carp_stored] carp available to spawn as.")

/obj/structure/carp_rift/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/magic/lightningshock.ogg', 50, TRUE)

/obj/structure/carp_rift/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(time_charged != max_charge + 1)
		dragon?.destroy_rifts()
		if(dragon)
			to_chat(dragon, span_boldwarning("A rift has been destroyed! You have failed, and find yourself weakened."))
	return ..()

/obj/structure/carp_rift/process(delta_time)
	// If we're fully charged, just start mass spawning carp and move around.
	if(charge_state == CHARGE_COMPLETED)
		if(DT_PROB(1.25, delta_time))
			new /mob/living/simple_animal/hostile/carp(loc)
		if(DT_PROB(1.5, delta_time))
			var/rand_dir = pick(GLOB.cardinals)
			Move(get_step(src, rand_dir), rand_dir)
		return

	// Increase time trackers and check for any updated states.
	time_charged = min(time_charged + delta_time, max_charge)
	last_carp_inc += delta_time
	update_check()

/obj/structure/carp_rift/attack_ghost(mob/user)
	. = ..()
	summon_carp(user)

/**
 * Does a series of checks based on the portal's status.
 *
 * Performs a number of checks based on the current charge of the portal, and triggers various effects accordingly.
 * If the current charge is a multiple of carp_interval, add an extra carp spawn.
 * If we're halfway charged, announce to the crew our location in a CENTCOM announcement.
 * If we're fully charged, tell the crew we are, change our color to yellow, become invulnerable, and give Space Dragon the ability to make another rift, if he hasn't summoned 3 total.
 */
/obj/structure/carp_rift/proc/update_check()
	// If the rift is fully charged, there's nothing to do here anymore.
	if(charge_state == CHARGE_COMPLETED)
		return

	// Can we increase the carp spawn pool size?
	if(last_carp_inc >= carp_interval)
		carp_stored++
		icon_state = "carp_rift_carpspawn"
		if(light_color != LIGHT_COLOR_PURPLE)
			set_light_color(LIGHT_COLOR_PURPLE)
			update_light()
		notify_ghosts("The carp rift can summon an additional carp!", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Carp Spawn Available")
		last_carp_inc -= carp_interval

	// Is the rift now fully charged?
	if(time_charged >= max_charge)
		charge_state = CHARGE_COMPLETED
		var/area/A = get_area(src)
		priority_announce("Spatial object has reached peak energy charge in [initial(A.name)], please stand-by.", "Central Command Wildlife Observations")
		atom_integrity = INFINITY
		icon_state = "carp_rift_charged"
		set_light_color(LIGHT_COLOR_YELLOW)
		update_light()
		armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
		resistance_flags = INDESTRUCTIBLE
		dragon.rifts_charged += 1
		if(dragon.rifts_charged != 3 && !dragon.objective_complete)
			dragon.rift = new
			dragon.rift.Grant(dragon)
			dragon.riftTimer = 0
			dragon.rift_empower()
		// Early return, nothing to do after this point.
		return

	// Do we need to give a final warning to the station at the halfway mark?
	if(charge_state < CHARGE_FINALWARNING && time_charged >= (max_charge * 0.5))
		charge_state = CHARGE_FINALWARNING
		var/area/A = get_area(src)
		priority_announce("A rift is causing an unnaturally large energy flux in [initial(A.name)].  Stop it at all costs!", "Central Command Wildlife Observations", ANNOUNCER_SPANOMALIES)

/**
 * Used to create carp controlled by ghosts when the option is available.
 *
 * Creates a carp for the ghost to control if we have a carp spawn available.
 * Gives them prompt to control a carp, and if our circumstances still allow if when they hit yes, spawn them in as a carp.
 * Also add them to the list of carps in Space Dragon's antgonist datum, so they'll be displayed as having assisted him on round end.
 * Arguments:
 * * mob/user - The ghost which will take control of the carp.
 */
/obj/structure/carp_rift/proc/summon_carp(mob/user)
	if(carp_stored <= 0)//Not enough carp points
		return FALSE
	var/is_listed = FALSE
	if (user.ckey in ckey_list)
		if(carp_stored == 1)
			to_chat(user, span_warning("You've already become a carp using this rift!  Either wait for a backlog of carp spawns or until the next rift!"))
			return FALSE
		is_listed = TRUE
	var/carp_ask = tgui_alert(usr,"Become a carp?", "Help bring forth the horde?", list("Yes", "No"))
	if(carp_ask == "No" || !src || QDELETED(src) || QDELETED(user))
		return FALSE
	if(carp_stored <= 0)
		to_chat(user, span_warning("The rift already summoned enough carp!"))
		return FALSE

	var/mob/living/simple_animal/hostile/carp/newcarp = new /mob/living/simple_animal/hostile/carp(loc)
	newcarp.AddElement(/datum/element/nerfed_pulling, GLOB.typecache_general_bad_things_to_easily_move)
	newcarp.AddElement(/datum/element/prevent_attacking_of_types, GLOB.typecache_general_bad_hostile_attack_targets, "this tastes awful!")

	if(!is_listed)
		ckey_list += user.ckey
	newcarp.key = user.key
	newcarp.set_name()
	var/datum/antagonist/space_dragon/S = dragon?.mind?.has_antag_datum(/datum/antagonist/space_dragon)
	if(S)
		S.carp += newcarp.mind
	to_chat(newcarp, span_boldwarning("You have arrived in order to assist the space dragon with securing the rifts.  Do not jeopardize the mission, and protect the rifts at all costs!"))
	carp_stored--
	if(carp_stored <= 0 && charge_state < CHARGE_COMPLETED)
		icon_state = "carp_rift"
		set_light_color(LIGHT_COLOR_BLUE)
		update_light()
	return TRUE

#undef CHARGE_ONGOING
#undef CHARGE_FINALWARNING
#undef CHARGE_COMPLETED
#undef DARKNESS_THRESHOLD
