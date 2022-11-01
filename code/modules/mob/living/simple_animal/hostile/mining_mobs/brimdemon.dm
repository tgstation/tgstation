#define BRIMBEAM_RANGE 10

/mob/living/simple_animal/hostile/asteroid/brimdemon
	name = "brimdemon"
	desc = "A misshapen demon with big, red eyes and a hinged mouth. Not much is known about the creatures \
		due to their response to any unexpected stimulus being \"brimbeam\", a deadly blood-laser barrage."
	icon = 'icons/mob/simple/lavaland/brimdemon.dmi'
	icon_state = "brimdemon"
	icon_living = "brimdemon"
	icon_dead = "brimdemon_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("cackles")
	emote_taunt = list("screeches")
	emote_hear = list("cackles","screeches")
	combat_mode = TRUE
	stat_attack = HARD_CRIT
	ranged_cooldown_time = 5 SECONDS
	vision_range = 9
	retreat_distance = 2
	speed = 3
	move_to_delay = 5
	maxHealth = 250
	health = 250
	obj_damage = 15
	melee_damage_lower = 7.5
	melee_damage_upper = 7.5
	rapid_melee = 2 // every second attack
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	butcher_results = list(
		/obj/item/food/meat/slab = 2,
		/obj/effect/decal/cleanable/brimdust = 1,
		/obj/item/organ/internal/monster_core/brimdust_sac = 1,
	)
	loot = list()
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW
	death_message = "wails as infernal energy escapes from its wounds, leaving it an empty husk."
	death_sound = 'sound/magic/demon_dies.ogg'
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 5
	light_range = 1.4
	crusher_loot = /obj/item/crusher_trophy/brimdemon_fang
	/// Are we charging/firing? If yes stops our movement.
	var/firing = FALSE
	/// A list of all the beam parts.
	var/list/beamparts = list()

/mob/living/simple_animal/hostile/asteroid/brimdemon/Destroy()
	QDEL_LIST(beamparts)
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/Login()
	ranged = TRUE
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/Logout()
	ranged = FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/death()
	firing = FALSE
	cut_overlay("brimdemon_telegraph_dir")
	move_resist = initial(move_resist)
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/Goto(target, delay, minimum_distance)
	if(firing)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/MoveToTarget(list/possible_targets)
	if(firing)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/AttackingTarget(atom/attacked_target)
	if(firing)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/Move(atom/newloc, dir, step_x , step_y)
	if(firing)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/brimdemon/OpenFire()
	if(firing)
		balloon_alert(src, "already firing!")
		return
	if(!COOLDOWN_FINISHED(src, ranged_cooldown))
		balloon_alert(src, "on cooldown!")
		return
	firing = TRUE
	set_dir_on_move = FALSE
	icon_state = "brimdemon_firing"
	move_resist = MOVE_FORCE_VERY_STRONG
	add_overlay("brimdemon_telegraph_dir")
	visible_message(span_danger("[src] starts charging!"))
	balloon_alert(src, "charging...")
	addtimer(CALLBACK(src, PROC_REF(fire_laser)), 1 SECONDS)
	COOLDOWN_START(src, ranged_cooldown, ranged_cooldown_time)

/mob/living/simple_animal/hostile/asteroid/brimdemon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	check_fire()

/mob/living/simple_animal/hostile/asteroid/brimdemon/proc/check_fire()
	if(key || QDELETED(target) || get_dist(src, target) > BRIMBEAM_RANGE || !(get_dir(src, target) in GLOB.cardinals))
		return
	face_atom(target)
	OpenFire()

/// Fires a brimbeam, getting a line of turfs between it and the direction to the target and creating a brimbeam effect on every one of them.
/mob/living/simple_animal/hostile/asteroid/brimdemon/proc/fire_laser()
	if(stat == DEAD)
		return
	visible_message(span_danger("[src] fires a brimbeam!"))
	balloon_alert(src, "brimbeam fired")
	playsound(src, 'sound/creatures/brimdemon.ogg', 150, FALSE, 0, 3)
	cut_overlay("brimdemon_telegraph_dir")
	var/turf/target_turf = get_ranged_target_turf(src, dir, BRIMBEAM_RANGE)
	var/turf/origin_turf = get_turf(src)
	var/list/affected_turfs = get_line(origin_turf, target_turf) - origin_turf
	for(var/turf/affected_turf in affected_turfs)
		var/blocked = FALSE
		if(affected_turf.opacity)
			blocked = TRUE
		for(var/obj/potential_block in affected_turf.contents)
			if(potential_block.opacity)
				blocked = TRUE
				break
		if(blocked)
			break
		var/atom/new_brimbeam = new /obj/effect/brimbeam(affected_turf)
		new_brimbeam.dir = dir
		beamparts += new_brimbeam
		for(var/mob/living/hit_mob in affected_turf.contents)
			hit_mob.adjustFireLoss(25)
			to_chat(hit_mob, span_userdanger("You're hit by [src]'s brimbeam!"))
	if(length(beamparts))
		var/atom/last_brimbeam = beamparts[length(beamparts)]
		last_brimbeam.icon_state = "brimbeam_end"
		var/atom/first_brimbeam = beamparts[1]
		first_brimbeam.icon_state = "brimbeam_start"
	addtimer(CALLBACK(src, PROC_REF(end_laser)), 2 SECONDS)

/// Deletes all the brimbeam parts and sets variables back to their initial ones.
/mob/living/simple_animal/hostile/asteroid/brimdemon/proc/end_laser()
	if(stat != DEAD)
		icon_state = initial(icon_state)
	move_resist = initial(move_resist)
	set_dir_on_move = initial(set_dir_on_move)
	firing = FALSE
	for(var/obj/effect/brimbeam/beam in beamparts)
		animate(beam, time = 0.5 SECONDS, alpha = 0)
		QDEL_IN(beam, 0.5 SECONDS)
		beamparts -= beam

/obj/effect/brimbeam
	name = "brimbeam"
	icon = 'icons/mob/simple/lavaland/brimdemon.dmi'
	icon_state = "brimbeam_mid"
	layer = ABOVE_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 3
	light_range = 2

/obj/effect/brimbeam/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/brimbeam/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/brimbeam/process()
	for(var/mob/living/hit_mob in get_turf(src))
		damage(hit_mob)

/obj/effect/brimbeam/proc/damage(mob/living/hit_mob)
	hit_mob.adjustFireLoss(5)
	to_chat(hit_mob, span_danger("You're damaged by [src]!"))

/obj/item/crusher_trophy/brimdemon_fang
	name = "brimdemon's fang"
	icon_state = "brimdemon_fang"
	desc = "A fang from a brimdemon's corpse."
	denied_type = /obj/item/crusher_trophy/brimdemon_fang
	var/static/list/comic_phrases = list("BOOM", "BANG", "KABLOW", "KAPOW", "OUCH", "BAM", "KAPOW", "WHAM", "POW", "KABOOM")

/obj/item/crusher_trophy/brimdemon_fang/effect_desc()
	return "mark detonation creates visual and audiosensory effects on the target"

/obj/item/crusher_trophy/brimdemon_fang/on_mark_detonation(mob/living/target, mob/living/user)
	target.balloon_alert_to_viewers("[pick(comic_phrases)]!")
	playsound(target, 'sound/lavaland/brimdemon_crush.ogg', 100)

/obj/effect/decal/cleanable/brimdust
	name = "brimdust"
	desc = "Dust from a brimdemon. It is considered valuable for its' botanical abilities."
	icon_state = "brimdust"
	icon = 'icons/obj/mining.dmi'
	layer = FLOOR_CLEAN_LAYER
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/brimdust/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/brimdust, 15)

/obj/item/ore_sensor
	name = "ore sensor"
	desc = "Using demonic frequencies, this ear-mounted tool detects ores in the nearby terrain."
	icon_state = "oresensor"
	icon = 'icons/obj/mining.dmi'
	slot_flags = ITEM_SLOT_EARS
	var/range = 5
	var/cooldown = 4 SECONDS //between the standard and the advanced ore scanner in strength
	COOLDOWN_DECLARE(ore_sensing_cooldown)

/obj/item/ore_sensor/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & ITEM_SLOT_EARS)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/ore_sensor/dropped(mob/user, silent)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/ore_sensor/process(delta_time)
	if(!COOLDOWN_FINISHED(src, ore_sensing_cooldown))
		return
	COOLDOWN_START(src, ore_sensing_cooldown, cooldown)
	mineral_scan_pulse(get_turf(src), range)
