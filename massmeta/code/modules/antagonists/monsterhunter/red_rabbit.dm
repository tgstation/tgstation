/mob/living/simple_animal/hostile/red_rabbit
	name = "jabberwocky"
	desc = "Servant of the moon."
	faction = list("rabbit")
	health = 500
	maxHealth = 500
	icon = 'massmeta/icons/monster_hunter/red_rabbit.dmi'
	icon_state = "red_rabbit"
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	obj_damage = 400
	melee_damage_upper = 40
	vision_range = 9
	minbodytemp = 0
	maxbodytemp = 1500
	pressure_resistance = 200
	aggro_vision_range = 18
	speed = 5
	environment_smash = ENVIRONMENT_SMASH_WALLS
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	rapid_melee = 3
	melee_queue_distance = 18
	ranged = TRUE
	pixel_x = -16
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	base_pixel_x = -16
	del_on_death = TRUE
	butcher_results = list()
	wander = FALSE
	blood_volume = BLOOD_VOLUME_NORMAL
	death_message = "succumbs to the moonlight."
	death_sound = 'sound/effects/gravhit.ogg'
	footstep_type = FOOTSTEP_MOB_HEAVY



/mob/living/simple_animal/hostile/red_rabbit/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/red_rabbit/cards = new
	var/datum/action/cooldown/spell/pointed/red_rabbit_hole/hole = new
	var/datum/action/cooldown/spell/rabbit_spawn/rabbit = new
	var/datum/action/cooldown/mob_cooldown/charge/rabbit/spear = new
	cards.Grant(src)
	hole.Grant(src)
	rabbit.Grant(src)
	spear.Grant(src)

/datum/action/cooldown/mob_cooldown/charge/rabbit
	destroy_objects = FALSE
	charge_past = 5
	cooldown_time = 3 SECONDS


/datum/action/cooldown/spell/rabbit_spawn
	name = "Create Offspring"
	button_icon_state = "killer_rabbit"
	desc = "Give birth to a bunch of cute bunnies eager to suicide bomb the nearest enemy!"
	cooldown_time = 3 SECONDS
	button_icon = 'massmeta/icons/monster_hunter/rabbit.dmi'
	button_icon_state = "killer_rabbit"
	spell_requirements = NONE


/datum/action/cooldown/spell/rabbit_spawn/cast(atom/cast_on)
	. = ..()
	StartCooldown(360 SECONDS, 360 SECONDS)
	for(var/i in 1 to 3 )
		var/mob/living/simple_animal/hostile/killer_rabbit/rabbit = new /mob/living/simple_animal/hostile/killer_rabbit(owner.loc)
		rabbit.GiveTarget(target)
		rabbit.faction = owner.faction.Copy()
	StartCooldown()



/mob/living/simple_animal/hostile/killer_rabbit
	name = "killer baby rabbit"
	desc = "A cute little rabbit, surely its harmless... right?"
	icon = 'massmeta/icons/monster_hunter/rabbit.dmi'
	icon_state = "killer_rabbit"
	faction = list("rabbit")
	maxHealth = 5
	melee_damage_lower = 5
	melee_damage_upper = 5

/mob/living/simple_animal/hostile/killer_rabbit/AttackingTarget()
	var/mob/living/carbon/human
	if(!iscarbon(target))
		return
	human = target
	if(human)
		explosion(src,heavy_impact_range = 1, light_impact_range = 1, flame_range = 2)




/datum/action/cooldown/spell/pointed/red_rabbit_hole
	name = "Create Rabbit Hole"
	button_icon_state = "hole_effect_button"
	cooldown_time = 3 SECONDS
	desc = "Trip down enemies through the rabbit holes!"
	button_icon = 'massmeta/icons/monster_hunter/rabbit.dmi'
	button_icon_state = "hole_effect_button"
	spell_requirements = NONE


/obj/effect/rabbit_hole
	name = "Rabbit Hole"
	icon = 'massmeta/icons/monster_hunter/rabbit.dmi'
	icon_state = "hole_effect"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE

/obj/effect/rabbit_hole/first

/obj/effect/rabbit_hole/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(fell)), 1 SECONDS)
	QDEL_IN(src, 4 SECONDS)

/obj/effect/rabbit_hole/proc/fell()
	for(var/mob/living/carbon/human/man in loc)
		if(man.stat == DEAD)
			continue
		visible_message(span_danger("[man] falls into the rabbit hole!"))
		man.Knockdown(5 SECONDS)
		man.adjustBruteLoss(20)


/obj/effect/rabbit_hole/first/Initialize(mapload, new_spawner)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(generate_holes)), 0.5 SECONDS)


/obj/effect/rabbit_hole/first/proc/generate_holes()
	var/list/directions = GLOB.cardinals.Copy()
	for(var/i in 1 to 4)
		var/spawndir = pick_n_take(directions)
		var/turf/hole = get_step(src, spawndir)
		if(hole)
			new /obj/effect/rabbit_hole(hole)


/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/red_rabbit
	cooldown_time = 3 SECONDS
	projectile_type = /obj/projectile/red_rabbit

/obj/projectile/red_rabbit
	name = "Red Queen"
	icon = 'massmeta/icons/monster_hunter/weapons.dmi'
	icon_state = "locator"
	damage = 20
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE
	plane = GAME_PLANE


/datum/action/cooldown/spell/pointed/red_rabbit_hole/is_valid_target(atom/target_atom)
	if(!isfloorturf(target_atom))
		to_chat(owner, span_warning("Holes can only be opened up on floors!"))
		return
	StartCooldown(360 SECONDS, 360 SECONDS)
	new /obj/effect/rabbit_hole/first(target_atom)
	StartCooldown()
