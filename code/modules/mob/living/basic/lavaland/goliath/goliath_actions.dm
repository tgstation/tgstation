/// Place some grappling tentacles underfoot
/datum/action/cooldown/mob_cooldown/goliath_tentacles
	name = "Unleash Tentacles"
	desc = "Unleash burrowed tentacles at a targeted location, grappling targets after a delay."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 12 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// Furthest range we can activate ability at
	var/max_range = 7

/datum/action/cooldown/mob_cooldown/goliath_tentacles/PreActivate(atom/target)
	target = get_turf(target)
	if (get_dist(owner, target) > max_range)
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/goliath_tentacles/Activate(atom/target)
	new /obj/effect/goliath_tentacle(target, owner)
	for(var/spawndir in GLOB.cardinals)
		var/turf/adjacent_target = get_step(target, spawndir)
		if(isgroundlessturf(adjacent_target) && !islava(adjacent_target))
			continue
		if(isopenturf(adjacent_target) || ismineralturf(adjacent_target))
			new /obj/effect/goliath_tentacle(adjacent_target)

	if (isliving(target))
		owner.visible_message(span_warning("[owner] digs its tentacles under [target]!"))
	StartCooldown()
	return TRUE

/// Place grappling tentacles around you to grab attackers
/datum/action/cooldown/mob_cooldown/tentacle_burst
	name = "Tentacle Burst"
	desc = "Unleash burrowed tentacles in an area around you, grappling targets after a delay."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	cooldown_time = 24 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/tentacle_burst/Activate(atom/target)
	var/list/directions = GLOB.alldirs.Copy()
	for (var/dir in directions)
		var/turf/adjacent_target = get_step(target, dir)
		if(adjacent_target)
			new /obj/effect/goliath_tentacle/drag(adjacent_target, owner)
	owner.visible_message(span_warning("[owner] unleashes tentacles from the ground around it!"))
	StartCooldown()
	return TRUE

/// Summon a line of tentacles towards the target
/datum/action/cooldown/mob_cooldown/tentacle_grasp
	name = "Tentacle Grasp"
	desc = "Unleash burrowed tentacles in a line towards a targeted location, grappling targets after a delay."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 12 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/tentacle_grasp/Activate(atom/target)
	new /obj/effect/temp_visual/effect_trail/burrowed_tentacle(owner.loc, target, owner)
	if (isliving(target))
		owner.visible_message(span_warning("[owner] reaches for [target] with its tentacles!"))
	StartCooldown()
	return TRUE

/// An invisible effect which chases a target, spawning tentacles every so often.
/obj/effect/temp_visual/effect_trail/burrowed_tentacle
	name = "burrowed_tentacle"
	duration = 2 SECONDS
	move_speed = 2
	homing = FALSE
	spawn_interval = 0.1 SECONDS
	spawned_effect = /obj/effect/goliath_tentacle/drag
	/// Mob who fired us
	var/mob/living/owner = null

/obj/effect/temp_visual/effect_trail/burrowed_tentacle/Initialize(mapload, atom/target, mob/living/owner)
	. = ..()
	src.owner = owner

/obj/effect/temp_visual/effect_trail/burrowed_tentacle/Destroy()
	. = ..()
	owner = null

/obj/effect/temp_visual/effect_trail/burrowed_tentacle/add_spawner()
	AddComponent(/datum/component/spawner, spawn_types = list(spawned_effect), max_spawned = max_spawned, spawn_time = spawn_interval, spawn_callback = CALLBACK(src, PROC_REF(on_tentacle_spawned)))

/obj/effect/temp_visual/effect_trail/burrowed_tentacle/proc/on_tentacle_spawned(obj/effect/goliath_tentacle/tentacle)
	tentacle.set_owner(owner)
