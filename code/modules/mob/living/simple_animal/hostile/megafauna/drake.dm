///used whenever the drake generates a hotspot
#define DRAKE_FIRE_TEMP 500
///used whenever the drake generates a hotspot
#define DRAKE_FIRE_EXPOSURE 50
///used to see if the drake is enraged or not
#define DRAKE_ENRAGED (health < maxHealth*0.5)

#define SWOOP_DAMAGEABLE 1
#define SWOOP_INVULNERABLE 2

/*£
 *
 *ASH DRAKE
 *
 *Ash drakes spawn randomly wherever a lavaland creature is able to spawn. They are the draconic guardians of the Necropolis.
 *
 *It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.
 *
 *Whenever possible, the drake will breathe fire directly at it's target, igniting and heavily damaging anything caught in the blast.
 *It also often causes lava to pool from the ground around you - many nearby turfs will temporarily turn into lava, dealing damage to anything on the turfs.
 *The drake also utilizes its wings to fly into the sky, flying after its target and attempting to slam down on them. Anything near when it slams down takes huge damage.
 *Sometimes it will chain these swooping attacks over and over, making swiftness a necessity.
 *Sometimes, it will encase its target in an arena of lava
 *
 *When an ash drake dies, it leaves behind a chest that can contain four things:
 *A. A spectral blade that allows its wielder to call ghosts to it, enhancing its power
 *B. A lava staff that allows its wielder to create lava
 *C. A spellbook and wand of fireballs
 *D. A bottle of dragon's blood with several effects, including turning its imbiber into a drake themselves.
 *
 *When butchered, they leave behind diamonds, sinew, bone, and ash drake hide. Ash drake hide can be used to create a hooded cloak that protects its wearer from ash storms.
 *
 *Intended Difficulty: Medium
 */

/mob/living/simple_animal/hostile/megafauna/dragon
	name = "ash drake"
	desc = "Guardians of the necropolis."
	health = 2500
	maxHealth = 2500
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "dragon"
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	health_doll_icon = "dragon"
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	pixel_x = -16
	base_pixel_x = -16
	maptext_height = 64
	maptext_width = 64
	crusher_loot = list(/obj/structure/closet/crate/necropolis/dragon/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/ashdrake = 10)
	var/swooping = NONE
	var/player_cooldown = 0
	gps_name = "Fiery Signal"
	achievement_type = /datum/award/achievement/boss/drake_kill
	crusher_achievement_type = /datum/award/achievement/boss/drake_crusher
	score_achievement_type = /datum/award/score/drake_score
	deathmessage = "collapses into a pile of bones, its flesh sloughing away."
	deathsound = 'sound/magic/demon_dies.ogg'
	footstep_type = FOOTSTEP_MOB_HEAVY
	small_sprite_type = /datum/action/small_sprite/megafauna/drake
	/// Fire cone ability
	var/datum/action/cooldown/mob_cooldown/fire_breath/cone/fire_cone
	/// Meteors ability
	var/datum/action/cooldown/mob_cooldown/meteors/meteors
	/// Mass fire ability
	var/datum/action/cooldown/mob_cooldown/fire_breath/mass_fire/mass_fire
	/// Lava swoop ability
	var/datum/action/cooldown/mob_cooldown/lava_swoop/lava_swoop

/mob/living/simple_animal/hostile/megafauna/dragon/Initialize()
	. = ..()
	fire_cone = new /datum/action/cooldown/mob_cooldown/fire_breath/cone()
	meteors = new /datum/action/cooldown/mob_cooldown/meteors()
	mass_fire = new /datum/action/cooldown/mob_cooldown/fire_breath/mass_fire()
	lava_swoop = new /datum/action/cooldown/mob_cooldown/lava_swoop()
	fire_cone.Grant(src)
	meteors.Grant(src)
	mass_fire.Grant(src)
	lava_swoop.Grant(src)
	RegisterSignal(src, COMSIG_MOB_ABILITY_STARTED, .proc/start_attack)
	RegisterSignal(src, COMSIG_MOB_ABILITY_FINISHED, .proc/finished_attack)
	RegisterSignal(src, COMSIG_SWOOP_INVULNERABILITY_STARTED, .proc/swoop_invulnerability_started)
	RegisterSignal(src, COMSIG_LAVA_ARENA_FAILED, .proc/on_arena_fail)

/mob/living/simple_animal/hostile/megafauna/dragon/Destroy()
	QDEL_NULL(fire_cone)
	QDEL_NULL(meteors)
	QDEL_NULL(mass_fire)
	QDEL_NULL(lava_swoop)
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(!.)
		return
	pull_force = MOVE_FORCE_OVERPOWERING

/mob/living/simple_animal/hostile/megafauna/dragon/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/OpenFire()
	if(swooping)
		return

	if(client)
		return

	if(prob(15 + anger_modifier))
		if(DRAKE_ENRAGED)
			// Lava Arena
			lava_swoop.Trigger(target = target)
			return
		// Lava Pools
		if(lava_swoop.Trigger(target = target))
			SLEEP_CHECK_DEATH(0, src)
			fire_cone.StartCooldown(0)
			fire_cone.Trigger(target = target)
			meteors.StartCooldown(0)
			INVOKE_ASYNC(meteors, /datum/action/proc/Trigger, target)
			return
	else if(prob(10+anger_modifier) && DRAKE_ENRAGED)
		mass_fire.Trigger(target = target)
		return
	if(fire_cone.Trigger(target = target))
		if(prob(50))
			meteors.StartCooldown(0)
			meteors.Trigger(target = target)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/start_attack(mob/living/owner, datum/action/cooldown/activated)
	SIGNAL_HANDLER
	if(activated == lava_swoop)
		icon_state = "shadow"
		swooping = SWOOP_DAMAGEABLE

/mob/living/simple_animal/hostile/megafauna/dragon/proc/swoop_invulnerability_started()
	SIGNAL_HANDLER
	swooping = SWOOP_INVULNERABLE

/mob/living/simple_animal/hostile/megafauna/dragon/proc/finished_attack(mob/living/owner, datum/action/cooldown/finished)
	SIGNAL_HANDLER
	if(finished == lava_swoop)
		icon_state = initial(icon_state)
		swooping = NONE

/mob/living/simple_animal/hostile/megafauna/dragon/proc/on_arena_fail()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/arena_escape_enrage)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/arena_escape_enrage() // you ran somehow / teleported away from my arena attack now i'm mad fucker
	SLEEP_CHECK_DEATH(0, src)
	visible_message(span_boldwarning("[src] starts to glow vibrantly as its wounds close up!"))
	adjustBruteLoss(-250) // yeah you're gonna pay for that, don't run nerd
	add_atom_colour(rgb(255, 255, 0), TEMPORARY_COLOUR_PRIORITY)
	move_to_delay = move_to_delay / 2
	set_light_range(10)
	SLEEP_CHECK_DEATH(5 SECONDS, src) // run.
	mass_fire.Activate(target)
	mass_fire.StartCooldown(8 SECONDS)
	move_to_delay = initial(move_to_delay)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	set_light_range(initial(light_range))

//fire line keeps going even if dragon is deleted
/proc/dragon_fire_line(atom/source, list/turfs, frozen = FALSE)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break
		var/obj/effect/hotspot/drake_fire_hotspot = new /obj/effect/hotspot(T)
		if(frozen)
			drake_fire_hotspot.add_atom_colour(COLOR_BLUE_LIGHT, FIXED_COLOUR_PRIORITY)
		T.hotspot_expose(DRAKE_FIRE_TEMP,DRAKE_FIRE_EXPOSURE,1)
		for(var/mob/living/L in T.contents)
			if(L in hit_list || istype(L, source.type))
				continue
			hit_list += L
			if(!frozen)
				L.adjustFireLoss(20)
				to_chat(L, span_userdanger("You're hit by [source]'s fire breath!"))
				continue
			L.adjustFireLoss(10)
			L.apply_status_effect(/datum/status_effect/ice_block_talisman, 20)
			to_chat(L, span_userdanger("You're hit by [source]'s freezing breath!"))

		// deals damage to mechs
		for(var/obj/vehicle/sealed/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BRUTE, MELEE, 1)
		sleep(1.5)

/mob/living/simple_animal/hostile/megafauna/dragon/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	anger_modifier = clamp(((maxHealth - health)/60),0,20)
	lava_swoop.enraged = DRAKE_ENRAGED
	if(!forced && (swooping & SWOOP_INVULNERABLE))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, visible_message_flags = NONE)
	if(swooping & SWOOP_INVULNERABLE) //to suppress attack messages without overriding every single proc that could send a message saying we got hit
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/AttackingTarget()
	if(!swooping)
		return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/DestroySurroundings()
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/megafauna/dragon/Move()
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/megafauna/dragon/Goto(target, delay, minimum_distance)
	if(!swooping)
		..()

/obj/effect/temp_visual/lava_warning
	icon_state = "lavastaff_warn"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	light_range = 2
	duration = 13
	var/mob/owner

/obj/effect/temp_visual/lava_warning/Initialize(mapload, reset_time = 10)
	. = ..()
	INVOKE_ASYNC(src, .proc/fall, reset_time)
	src.alpha = 63.75
	animate(src, alpha = 255, time = duration)

/obj/effect/temp_visual/lava_warning/proc/fall(reset_time)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, TRUE)
	sleep(duration)
	playsound(T,'sound/magic/fireball.ogg', 200, TRUE)

	for(var/mob/living/L in T.contents - owner)
		if(istype(L, /mob/living/simple_animal/hostile/megafauna/dragon))
			continue
		L.adjustFireLoss(10)
		to_chat(L, span_userdanger("You fall directly into the pool of lava!"))

	// deals damage to mechs
	for(var/obj/vehicle/sealed/mecha/M in T.contents)
		M.take_damage(45, BRUTE, MELEE, 1)

	// changes turf to lava temporarily
	if(!istype(T, /turf/closed) && !istype(T, /turf/open/lava))
		var/lava_turf = /turf/open/lava/smooth
		var/reset_turf = T.type
		T.ChangeTurf(lava_turf, flags = CHANGETURF_INHERIT_AIR)
		addtimer(CALLBACK(T, /turf.proc/ChangeTurf, reset_turf, null, CHANGETURF_INHERIT_AIR), reset_time, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/temp_visual/drakewall
	desc = "An ash drakes true flame."
	name = "Fire Barrier"
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	can_atmos_pass = ATMOS_PASS_DENSITY
	duration = 82
	color = COLOR_DARK_ORANGE

/obj/effect/temp_visual/lava_safe
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "trap-earth"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 13

/obj/effect/temp_visual/fireball
	icon = 'icons/obj/wizard.dmi'
	icon_state = "fireball"
	name = "fireball"
	desc = "Get out of the way!"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	randomdir = FALSE
	duration = 9
	pixel_z = 270

/obj/effect/temp_visual/fireball/Initialize(mapload)
	. = ..()
	animate(src, pixel_z = 0, time = duration)

/obj/effect/temp_visual/target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	light_range = 2
	duration = 9

/obj/effect/temp_visual/target/Initialize(mapload, list/flame_hit)
	. = ..()
	INVOKE_ASYNC(src, .proc/fall, flame_hit)

/obj/effect/temp_visual/target/proc/fall(list/flame_hit)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, TRUE)
	new /obj/effect/temp_visual/fireball(T)
	sleep(duration)
	if(ismineralturf(T))
		var/turf/closed/mineral/M = T
		M.gets_drilled()
	playsound(T, SFX_EXPLOSION, 80, TRUE)
	new /obj/effect/hotspot(T)
	T.hotspot_expose(DRAKE_FIRE_TEMP, DRAKE_FIRE_EXPOSURE, 1)
	for(var/mob/living/L in T.contents)
		if(istype(L, /mob/living/simple_animal/hostile/megafauna/dragon))
			continue
		if(islist(flame_hit) && !flame_hit[L])
			L.adjustFireLoss(40)
			to_chat(L, span_userdanger("You're hit by the drake's fire breath!"))
			flame_hit[L] = TRUE
		else
			L.adjustFireLoss(10) //if we've already hit them, do way less damage

/mob/living/simple_animal/hostile/megafauna/dragon/lesser
	name = "lesser ash drake"
	maxHealth = 200
	health = 200
	faction = list("neutral")
	obj_damage = 80
	melee_damage_upper = 30
	melee_damage_lower = 30
	mouse_opacity = MOUSE_OPACITY_ICON
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	loot = list()
	crusher_loot = list()
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	attack_action_types = list()

/mob/living/simple_animal/hostile/megafauna/dragon/lesser/Initialize()
	. = ..()
	fire_cone.Remove(src)
	meteors.Remove(src)
	mass_fire.Remove(src)
	lava_swoop.cooldown_time = 20 SECONDS

/mob/living/simple_animal/hostile/megafauna/dragon/lesser/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	lava_swoop.enraged = FALSE

/mob/living/simple_animal/hostile/megafauna/dragon/lesser/grant_achievement(medaltype,scoretype)
	return

#undef SWOOP_DAMAGEABLE
#undef SWOOP_INVULNERABLE
