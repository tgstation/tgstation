// fire leaper bubble ability
/datum/action/cooldown/mob_cooldown/projectile_attack/leaper_bubble
	name = "Fire Leaper Bubble"
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "leaper"
	desc = "Fires a poisonous leaper bubble towards the victim!"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	cooldown_time = 7 SECONDS
	projectile_type = /obj/projectile/leaper
	projectile_sound = 'sound/effects/snap.ogg'
	shared_cooldown = NONE

// bubble ability objects and effects
/obj/projectile/leaper
	name = "leaper bubble"
	icon_state = "leaper"
	paralyze = 5 SECONDS
	damage = 0
	range = 7
	hitsound = 'sound/effects/snap.ogg'
	nondirectional_sprite = TRUE
	impact_effect_type = /obj/effect/temp_visual/leaper_projectile_impact

/obj/projectile/leaper/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (!isliving(target))
		return
	var/mob/living/bubbled = target
	if(iscarbon(target))
		bubbled.reagents.add_reagent(/datum/reagent/toxin/leaper_venom, 5)
		return
	bubbled.apply_damage(30)

/obj/projectile/leaper/on_range()
	new /obj/structure/leaper_bubble(get_turf(src))
	return ..()

/obj/effect/temp_visual/leaper_projectile_impact
	name = "leaper bubble"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "leaper_bubble_pop"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 3 SECONDS

/obj/effect/temp_visual/leaper_projectile_impact/Initialize(mapload)
	. = ..()
	new /obj/effect/decal/cleanable/leaper_sludge(get_turf(src))

/obj/effect/decal/cleanable/leaper_sludge
	name = "leaper sludge"
	desc = "A small pool of sludge, containing trace amounts of leaper venom."
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "tomato_floor1"

// bubble ability reagent
/datum/reagent/toxin/leaper_venom
	name = "Leaper venom"
	description = "A toxin spat out by leapers that, while harmless in small doses, quickly creates a toxic reaction if too much is in the body."
	color = "#801E28" // rgb: 128, 30, 40
	toxpwr = 0
	taste_description = "french cuisine"
	taste_mult = 1.3

/datum/reagent/toxin/leaper_venom/on_mob_life(mob/living/carbon/poisoned_mob, seconds_per_tick, times_fired)
	. = ..()
	if(volume <= 5)
		return
	if(poisoned_mob.adjustToxLoss(2.5 * REM * seconds_per_tick, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

// bubble ability structure
/obj/structure/leaper_bubble
	name = "leaper bubble"
	desc = "A floating bubble containing leaper venom. The contents are under a surprising amount of pressure."
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "leaper"
	max_integrity = 10
	density = FALSE

/obj/structure/leaper_bubble/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(src, TRAIT_MOVE_FLOATING, LEAPER_BUBBLE_TRAIT)
	QDEL_IN(src, 10 SECONDS)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/leaper_bubble/Destroy()
	new /obj/effect/temp_visual/leaper_projectile_impact(get_turf(src))
	playsound(src,'sound/effects/snap.ogg', 50, TRUE)
	return ..()

/obj/structure/leaper_bubble/proc/on_entered(datum/source, atom/movable/bubbled)
	SIGNAL_HANDLER
	if(!isliving(bubbled) || istype(bubbled, /mob/living/basic/leaper))
		return
	var/mob/living/bubbled_mob = bubbled

	playsound(src, 'sound/effects/snap.ogg',50, TRUE)
	bubbled_mob.Paralyze(5 SECONDS)
	if(iscarbon(bubbled_mob))
		bubbled_mob.reagents.add_reagent(/datum/reagent/toxin/leaper_venom, 5)
	else
		bubbled_mob.apply_damage(30)
	qdel(src)

// blood rain ability
/datum/action/cooldown/mob_cooldown/blood_rain
	name = "Blood Rain"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "blood_effect_falling"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Rain down poisonous droplets of blood!"
	cooldown_time = 10 SECONDS
	click_to_activate = FALSE
	shared_cooldown = NONE
	/// how many droplets we will fire
	var/volley_count = 8
	/// time between each droplet launched
	var/fire_interval = 0.1 SECONDS

/datum/action/cooldown/mob_cooldown/blood_rain/Activate(mob/living/firer, atom/target)
	var/list/possible_turfs = list()
	for(var/turf/possible_turf in oview(5, owner))
		if(possible_turf.is_blocked_turf() || isopenspaceturf(possible_turf) || isspaceturf(possible_turf))
			continue
		if(locate(/obj/structure/leaper_bubble) in possible_turf)
			continue
		possible_turfs += possible_turf

	if(!length(possible_turfs))
		return FALSE

	playsound(owner, 'sound/effects/magic/fireball.ogg', 70, TRUE)
	new /obj/effect/temp_visual/blood_drop_rising(get_turf(owner))
	addtimer(CALLBACK(src, PROC_REF(fire_droplets), possible_turfs), 1.5 SECONDS)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_rain/proc/fire_droplets(list/possible_turfs)
	var/fire_count = min(volley_count, possible_turfs.len)
	for(var/i in 1 to fire_count)
		addtimer(CALLBACK(src, PROC_REF(fall_effect), pick_n_take(possible_turfs)), i * fire_interval)

/datum/action/cooldown/mob_cooldown/blood_rain/proc/fall_effect(turf/selected_turf)
	new /obj/effect/temp_visual/blood_drop_falling(selected_turf)
	var/obj/effect/temp_visual/falling_shadow = new /obj/effect/temp_visual/shadow_telegraph(selected_turf)
	animate(falling_shadow, transform = matrix().Scale(0.1, 0.1), time = falling_shadow.duration)

// blood rain effects
/obj/effect/temp_visual/blood_drop_rising
	name = "leaper bubble"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "leaper"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 1 SECONDS

/obj/effect/temp_visual/blood_drop_rising/Initialize(mapload)
	. = ..()
	animate(src, pixel_y = base_pixel_y + 150, time = duration)

/obj/effect/temp_visual/blood_drop_falling
	name = "leaper bubble"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blood_effect_falling"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 0.7 SECONDS
	pixel_y = 60

/obj/effect/temp_visual/blood_drop_falling/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(create_blood_structure)), duration)
	animate(src, pixel_y = 0, time = duration)

/obj/effect/temp_visual/blood_drop_falling/proc/create_blood_structure()
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	new /obj/structure/leaper_bubble(get_turf(src))

/obj/effect/temp_visual/shadow_telegraph
	name = "shadow"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shadow_telegraph"
	duration = 1.5 SECONDS


// flop ability
/datum/action/cooldown/mob_cooldown/belly_flop
	name = "Belly Flop"
	desc = "Belly flop your enemy!"
	cooldown_time = 14 SECONDS
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/belly_flop/Activate(atom/target)
	var/turf/target_turf = get_turf(target)
	if(isclosedturf(target_turf) || isspaceturf(target_turf))
		owner.balloon_alert(owner, "base not suitable!")
		return FALSE
	new /obj/effect/temp_visual/leaper_crush(target_turf)
	owner.throw_at(target = target_turf, range = 7, speed = 1, spin = FALSE, callback = CALLBACK(src, PROC_REF(flop_on_turf), target_turf))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/belly_flop/proc/flop_on_turf(turf/target, original_pixel_y)
	playsound(get_turf(owner), 'sound/effects/meteorimpact.ogg', 200, TRUE)
	for(var/mob/living/victim in oview(1, owner))
		if(victim in owner.buckled_mobs)
			continue
		victim.apply_damage(35)
		if(QDELETED(victim)) // Some mobs are deleted on death
			continue
		var/throw_dir = victim.loc == owner.loc ? get_dir(owner, victim) : pick(GLOB.alldirs)
		var/throwtarget = get_edge_target_turf(victim, throw_dir)
		victim.throw_at(target = throwtarget, range = 3, speed = 1)
		victim.visible_message(span_warning("[victim] is thrown clear of [owner]!"))

// flop ability effects
/obj/effect/temp_visual/leaper_crush
	name = "grim tidings"
	desc = "Incoming leaper!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "lily_pad"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	SET_BASE_PIXEL(-32, -32)
	duration = 3 SECONDS

// summon toads ability
/datum/action/cooldown/spell/conjure/limit_summons/create_suicide_toads
	name = "Summon Suicide Toads"
	button_icon = 'icons/mob/simple/animal.dmi'
	button_icon_state = "frog_trash"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	summon_type = list(/mob/living/basic/frog/frog_suicide)
	summon_radius = 2
	summon_amount = 2
	max_summons = 2

/datum/action/cooldown/spell/conjure/limit_summons/create_suicide_toads/post_summon(atom/summoned_object, atom/cast_on)
	. = ..()
	var/mob/living/summoned_toad = summoned_object
	summoned_toad.faction = owner.faction ///so they dont attack the leaper or the wizard master
