#define COLOSSUS_ENRAGED (health <= maxHealth / 3)

/**
 * COLOSSUS
 *
 *The colossus spawns randomly wherever a lavaland creature is able to spawn. It is powerful, ancient, and extremely deadly.
 *The colossus has a degree of sentience, proving this in speech during its attacks.
 *
 *It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.
 *
 *The colossus' true danger lies in its ranged capabilities. It fires immensely damaging death bolts that penetrate all armor in a variety of ways:
 *A. The colossus fires death bolts in alternating patterns: the cardinal directions and the diagonal directions.
 *B. The colossus fires death bolts in a shotgun-like pattern, instantly downing anything unfortunate enough to be hit by all of them.
 *C. The colossus fires a spiral of death bolts.
 *At 33% health, the colossus gains an additional attack:
 *D. The colossus fires two spirals of death bolts, spinning in opposite directions.
 *
 *When a colossus dies, it leaves behind a chunk of glowing crystal known as a black box. Anything placed inside will carry over into future rounds.
 *For instance, you could place a bag of holding into the black box, and then kill another colossus next round and retrieve the bag of holding from inside.
 *
 * Intended Difficulty: Very Hard
 */
/mob/living/simple_animal/hostile/megafauna/colossus
	name = "colossus"
	desc = "A monstrous creature protected by heavy shielding."
	health = 2500
	maxHealth = 2500
	attack_verb_continuous = "judges"
	attack_verb_simple = "judge"
	attack_sound = 'sound/effects/magic/clockwork/ratvar_attack.ogg'
	icon_state = "eva"
	icon_living = "eva"
	icon_dead = ""
	health_doll_icon = "eva"
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	icon = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 10
	move_to_delay = 10
	ranged = TRUE
	pixel_x = -32
	base_pixel_x = -32
	maptext_height = 96
	maptext_width = 96
	del_on_death = TRUE
	gps_name = "Angelic Signal"
	achievement_type = /datum/award/achievement/boss/colossus_kill
	crusher_achievement_type = /datum/award/achievement/boss/colossus_crusher
	score_achievement_type = /datum/award/score/colussus_score
	loot = list(/obj/structure/closet/crate/necropolis/colossus)
	crusher_loot = /obj/structure/closet/crate/necropolis/colossus/crusher
	replace_crusher_drop = TRUE
	death_message = "disintegrates, leaving a glowing core in its wake."
	death_sound = 'sound/effects/magic/demon_dies.ogg'
	summon_line = "Your trial begins now."
	/// Spiral shots ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/colossus/spiral_shots
	/// Random shots ablity
	var/datum/action/cooldown/mob_cooldown/projectile_attack/random_aoe/colossus/random_shots
	/// Shotgun blast ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/colossus/shotgun_blast
	/// Directional shots ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/alternating/colossus/dir_shots
	/// Final attack ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/colossus_final/colossus_final
	/// Have we used DIE yet?
	var/final_available = TRUE

/mob/living/simple_animal/hostile/megafauna/colossus/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT) //we don't want this guy to float, messes up his animations.
	spiral_shots = new(src)
	random_shots = new(src)
	shotgun_blast = new(src)
	dir_shots = new(src)
	colossus_final = new(src)
	spiral_shots.Grant(src)
	random_shots.Grant(src)
	shotgun_blast.Grant(src)
	dir_shots.Grant(src)
	colossus_final.Grant(src)
	RegisterSignal(src, COMSIG_MOB_ABILITY_STARTED, PROC_REF(start_attack))
	RegisterSignal(src, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(finished_attack))
	AddElement(/datum/element/projectile_shield)

/mob/living/simple_animal/hostile/megafauna/colossus/Destroy()
	RemoveElement(/datum/element/projectile_shield)
	spiral_shots = null
	random_shots = null
	shotgun_blast = null
	dir_shots = null
	colossus_final = null
	return ..()

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	anger_modifier = clamp(((maxHealth - health) / 40), 0, 20)

	if(client)
		return

	if(enrage(target))
		if(move_to_delay == initial(move_to_delay))
			visible_message(span_colossus("\"<b>You can't dodge.</b>\""))
		ranged_cooldown = world.time + 3 SECONDS
		telegraph()
		dir_shots.fire_in_directions(src, target, GLOB.alldirs)
		move_to_delay = 3
		return
	else
		move_to_delay = initial(move_to_delay)

	if(health <= maxHealth / 10 && final_available)
		final_available = FALSE
		colossus_final.Trigger(target = target)
	else if(prob(20 + anger_modifier)) //Major attack
		spiral_shots.Trigger(target = target)
	else if(prob(20))
		random_shots.Trigger(target = target)
	else
		if(prob(60 + anger_modifier))
			shotgun_blast.Trigger(target = target)
		else
			dir_shots.Trigger(target = target)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/telegraph()
	for(var/mob/viewer as anything in viewers(10, src))
		if(viewer.client)
			flash_color(viewer.client, "#C80000", 1)
			shake_camera(viewer, 4, 3)
	playsound(src, 'sound/effects/magic/clockwork/narsie_attack.ogg', 200, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/start_attack(mob/living/owner, datum/action/cooldown/activated)
	SIGNAL_HANDLER
	if(activated == spiral_shots)
		spiral_shots.enraged = COLOSSUS_ENRAGED
		telegraph()
		icon_state = "eva_attack"
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), "Judgement.", null, list("colossus", "yell"))
	else if(activated == random_shots)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), "Wrath.", null, list("colossus", "yell"))
	else if(activated == shotgun_blast)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), "Retribution.", null, list("colossus", "yell"))
	else if(activated == dir_shots)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), "Lament.", null, list("colossus", "yell"))

/mob/living/simple_animal/hostile/megafauna/colossus/proc/finished_attack(mob/living/owner, datum/action/cooldown/finished)
	SIGNAL_HANDLER
	if(finished == spiral_shots)
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/enrage(mob/living/victim)
	if(!ishuman(victim))
		return FALSE
	if(isgolem(victim) && victim.has_status_effect(/datum/status_effect/golem/gold))
		return TRUE

	return istype(GET_ACTIVE_MARTIAL_ART(victim), /datum/martial_art/the_sleeping_carp)

/obj/effect/temp_visual/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	light_system = OVERLAY_LIGHT
	light_range = 2.5
	light_power = 1.2
	light_color = "#ffff66"
	duration = 8
	var/target

/obj/effect/temp_visual/at_shield/Initialize(mapload, new_target)
	. = ..()
	target = new_target
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, orbit), target, 0, FALSE, 0, 0, FALSE, TRUE)

/obj/projectile/colossus
	name = "death bolt"
	icon_state = "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 0.5
	damage_type = BRUTE
	pass_flags = PASSTABLE
	plane = GAME_PLANE
	var/explode_hit_objects = TRUE

/obj/projectile/colossus/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parriable_projectile)

/obj/projectile/colossus/can_hit_target(atom/target, direct_target = FALSE, ignore_loc = FALSE, cross_failed = FALSE)
	if(isliving(target) && target != firer)
		direct_target = TRUE
	return ..(target, direct_target, ignore_loc, cross_failed)

/obj/projectile/colossus/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/dust_mob = target
		if(dust_mob.stat == DEAD)
			dust_mob.investigate_log("has been dusted by a death bolt (colossus).", INVESTIGATE_DEATHS)
			dust_mob.dust()
		return
	if(!explode_hit_objects || istype(target, /obj/vehicle/sealed))
		return
	if(isturf(target) || isobj(target))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target

#undef COLOSSUS_ENRAGED
