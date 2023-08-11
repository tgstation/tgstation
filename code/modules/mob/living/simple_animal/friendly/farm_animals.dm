//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays.")
	emote_see = list("shakes their head.", "stamps a foot.", "glares around.")
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/food/meat/slab = 4)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	faction = list(FACTION_NEUTRAL)
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	attack_same = 1
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 40
	maxHealth = 40
	minbodytemp = 180
	melee_damage_lower = 1
	melee_damage_upper = 2
	environment_smash = ENVIRONMENT_SMASH_NONE
	stop_automated_movement_when_pulled = 1
	blood_volume = BLOOD_VOLUME_NORMAL

	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/retaliate/goat/Initialize(mapload)
	AddComponent(/datum/component/udder)
	AddElement(/datum/element/cliff_walking) //we walk the cliff
	. = ..()

/mob/living/simple_animal/hostile/retaliate/goat/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!enemies.len && SPT_PROB(0.5, seconds_per_tick))
			Retaliate()

		if(enemies.len && SPT_PROB(5, seconds_per_tick))
			enemies.Cut()
			LoseTarget()
			src.visible_message(span_notice("[src] calms down."))
	if(stat != CONSCIOUS)
		return

	eat_plants()
	if(pulledby)
		return

	for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
		var/turf/step = get_step(src, direction)

		if(!istype(step))
			return

		var/vine = locate(/obj/structure/spacevine) in step
		var/mushroom = locate(/obj/structure/glowshroom) in step
		var/flower = locate(/obj/structure/alien/resin/flower_bud) in step

		if(vine || mushroom || flower)
			Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	src.visible_message(span_danger("[src] gets an evil-looking gleam in [p_their()] eye."))

/mob/living/simple_animal/hostile/retaliate/goat/Move()
	. = ..()
	if(!stat)
		eat_plants()

/mob/living/simple_animal/hostile/retaliate/goat/proc/eat_plants()
	var/obj/structure/spacevine/vine = locate(/obj/structure/spacevine) in loc
	if(vine)
		vine.eat(src)

	var/obj/structure/alien/resin/flower_bud/flower = locate(/obj/structure/alien/resin/flower_bud) in loc
	if(flower)
		flower.take_damage(rand(30, 50), BRUTE, 0)

	var/obj/structure/glowshroom/mushroom = locate(/obj/structure/glowshroom) in loc
	if(mushroom)
		qdel(mushroom)

	if((vine || flower || mushroom) && prob(10))
		say("Nom") // bon appetit
		playsound(src, 'sound/items/eatfood.ogg', rand(30, 50), TRUE)

/mob/living/simple_animal/hostile/retaliate/goat/AttackingTarget()
	. = ..()

	if(!. || !isliving(target))
		return

	var/mob/living/plant_target = target
	if(!(plant_target.mob_biotypes & MOB_PLANT))
		return

	plant_target.adjustBruteLoss(20)
	playsound(src, 'sound/items/eatfood.ogg', rand(30, 50), TRUE)
	var/obj/item/bodypart/edible_bodypart

	if(ishuman(plant_target))
		var/mob/living/carbon/human/plant_man = target
		edible_bodypart = pick(plant_man.bodyparts)
		edible_bodypart.dismember()

	plant_target.visible_message(span_warning("[src] takes a big chomp out of [plant_target]!"), \
							span_userdanger("[src] takes a big chomp out of your [edible_bodypart || "body"]!"))
