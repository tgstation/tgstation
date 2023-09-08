#define SEEDLING_STATE_NEUTRAL 0
#define SEEDLING_STATE_WARMUP 1
#define SEEDLING_STATE_ACTIVE 2
#define SEEDLING_STATE_RECOVERY 3

//A plant rooted in the ground that forfeits its melee attack in favor of ranged barrages.
//It will fire flurries of solar energy, and occasionally charge up a powerful blast that makes it vulnerable to attack.
/mob/living/simple_animal/hostile/jungle/seedling
	name = "seedling"
	desc = "This oversized, predatory flower conceals what can only be described as an organic energy cannon, and it will not die until its hidden vital organs are sliced out. \
		The concentrated streams of energy it sometimes produces require its full attention, attacking it during this time will prevent it from finishing its attack."
	icon = 'icons/mob/simple/jungle/seedling.dmi'
	icon_state = "seedling"
	icon_living = "seedling"
	icon_dead = "seedling_dead"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	maxHealth = 100
	health = 100
	melee_damage_lower = 30
	melee_damage_upper = 30
	SET_BASE_PIXEL(-16, -14)

	minimum_distance = 3
	move_to_delay = 20
	vision_range = 9
	aggro_vision_range = 15
	ranged = TRUE
	ranged_cooldown_time = 10
	projectiletype = /obj/projectile/seedling
	projectilesound = 'sound/weapons/pierce.ogg'
	robust_searching = TRUE
	stat_attack = HARD_CRIT
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	var/combatant_state = SEEDLING_STATE_NEUTRAL
	var/mob/living/beam_debuff_target
	var/solar_beam_identifier = 0

/mob/living/basic/seedling
	name = "seedling"
	desc = "This oversized, predatory flower conceals what can only be described as an organic energy cannon, and it will not die until its hidden vital organs are sliced out. \
		The concentrated streams of energy it sometimes produces require its full attention, attacking it during this time will prevent it from finishing its attack."
	icon = 'icons/mob/simple/jungle/seedling.dmi'
	icon_state = "seedling"
	icon_living = "seedling"
	icon_dead = "seedling_dead"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	maxHealth = 100
	health = 100
	pixel_x = -16
	pixel_y = -14
	melee_damage_lower = 30
	melee_damage_upper = 30
	var/combatant_state = SEEDLING_STATE_NEUTRAL

/mob/living/basic/seedling/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/seed_attack = new(src)
	seed_attack.Grant(src)

/mob/living/basic/seedling/proc/change_combatant_state(state)
	combatant_state = state
	update_appearance(UPDATE_ICON)

/mob/living/basic/seedling/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	switch(combatant_state)
		if(SEEDLING_STATE_NEUTRAL)
			icon_state = "seedling"
		if(SEEDLING_STATE_WARMUP)
			icon_state = "seedling_charging"
		if(SEEDLING_STATE_ACTIVE)
			icon_state = "seedling_fire"

/obj/projectile/seedling
	name = "solar energy"
	icon_state = "seedling"
	damage = 10
	damage_type = BURN
	light_range = 2
	armor_flag = ENERGY
	light_color = LIGHT_COLOR_DIM_YELLOW
	speed = 1.6
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	nondirectional_sprite = TRUE

/obj/projectile/seedling/on_hit(atom/target)
	if(!isliving(target))
		return ..()

	var/mob/living/living_target = target
	if(FACTION_JUNGLE in living_target.faction)
		return

	return ..()

/obj/effect/temp_visual/solarbeam_killsat
	name = "beam of solar energy"
	icon_state = "solar_beam"
	icon = 'icons/effects/beam.dmi'
	plane = LIGHTING_PLANE
	layer = LIGHTING_PRIMARY_LAYER
	duration = 5 SECONDS
	randomdir = FALSE


/mob/living/simple_animal/hostile/jungle/seedling/proc/SolarBeamStartup(mob/living/living_target)//It's more like requiem than final spark
	if(combatant_state == SEEDLING_STATE_WARMUP && target)
		combatant_state = SEEDLING_STATE_ACTIVE
//		living_target.apply_status_effect(/datum/status_effect/seedling_beam_indicator, src)
		beam_debuff_target = living_target
		playsound(src,'sound/effects/seedling_chargeup.ogg', 100, FALSE)
		if(get_dist(src,living_target) > 7)
			playsound(living_target,'sound/effects/seedling_chargeup.ogg', 100, FALSE)
		solar_beam_identifier = world.time
		addtimer(CALLBACK(src, PROC_REF(Beamu), living_target, solar_beam_identifier), 35)

/mob/living/simple_animal/hostile/jungle/seedling/proc/Beamu(mob/living/living_target, beam_id = 0)
	if(combatant_state == SEEDLING_STATE_ACTIVE && living_target && beam_id == solar_beam_identifier)
		if(living_target.z == z)
			update_icons()
			var/obj/effect/temp_visual/solarbeam_killsat/S = new (get_turf(src))
			var/matrix/starting = matrix()
			starting.Scale(1,32)
			starting.Translate(0,520)
			S.transform = starting
			var/obj/effect/temp_visual/solarbeam_killsat/K = new (get_turf(living_target))
			var/matrix/final = matrix()
			final.Scale(1,32)
			final.Translate(0,512)
			K.transform = final
			living_target.adjustFireLoss(30)
			living_target.adjust_fire_stacks(0.2)//Just here for the showmanship
			living_target.ignite_mob()
			playsound(living_target,'sound/weapons/sear.ogg', 50, TRUE)
			addtimer(CALLBACK(src, PROC_REF(AttackRecovery)), 5)
			return
	AttackRecovery()

/mob/living/simple_animal/hostile/jungle/seedling/proc/AttackRecovery()
	if(combatant_state == SEEDLING_STATE_ACTIVE)
		combatant_state = SEEDLING_STATE_RECOVERY
		update_icons()
		ranged_cooldown = world.time + ranged_cooldown_time
		if(target)
			face_atom(target)
		addtimer(CALLBACK(src, PROC_REF(ResetNeutral)), 10)

/mob/living/simple_animal/hostile/jungle/seedling/proc/ResetNeutral()
	combatant_state = SEEDLING_STATE_NEUTRAL
	if(target && !stat)
		update_icons()
		Goto(target, move_to_delay, minimum_distance)

/mob/living/simple_animal/hostile/jungle/seedling/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(combatant_state == SEEDLING_STATE_ACTIVE && beam_debuff_target)
//		beam_debuff_target.remove_status_effect(/datum/status_effect/seedling_beam_indicator)
		beam_debuff_target = null
		solar_beam_identifier = 0
		AttackRecovery()

/mob/living/simple_animal/hostile/jungle/seedling/update_icons()
	. = ..()
	if(!stat)
		switch(combatant_state)
			if(SEEDLING_STATE_NEUTRAL)
				icon_state = "seedling"
			if(SEEDLING_STATE_WARMUP)
				icon_state = "seedling_charging"
			if(SEEDLING_STATE_ACTIVE)
				icon_state = "seedling_fire"



/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling
	name = "Solar Energy"
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "seedling"
	desc = "Fire small beams of solar energy."
	cooldown_time = 10 SECONDS
	projectile_type = /obj/projectile/seedling
	default_projectile_spread = 10
	shot_count = 10
	shot_delay = 0.2 SECONDS
	///how long we must charge up before firing off
	var/charge_up_timer = 3 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/seedling/seed_owner = owner
	if(seed_owner.combatant_state != SEEDLING_STATE_NEUTRAL)
		if(feedback)
			seed_owner.balloon_alert(seed_owner, "charging!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/Activate(atom/target)
	var/mob/living/basic/seedling/seed_owner = owner
	seed_owner.change_combatant_state(state = SEEDLING_STATE_WARMUP)
	addtimer(CALLBACK(src, PROC_REF(attack_sequence), owner, target), charge_up_timer)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/attack_sequence(mob/living/firer, atom/target)
	var/mob/living/basic/seedling/seed_owner = owner
	seed_owner.change_combatant_state(state = SEEDLING_STATE_ACTIVE)
	. = ..()
	addtimer(CALLBACK(seed_owner, TYPE_PROC_REF(/mob/living/basic/seedling, change_combatant_state), SEEDLING_STATE_NEUTRAL), charge_up_timer)

#undef SEEDLING_STATE_NEUTRAL
#undef SEEDLING_STATE_WARMUP
#undef SEEDLING_STATE_ACTIVE
#undef SEEDLING_STATE_RECOVERY
