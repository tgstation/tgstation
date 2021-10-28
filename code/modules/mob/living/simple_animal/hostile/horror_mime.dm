/mob/living/simple_animal/hostile/horror_mime
	name = "Horror Mime"
	desc = "A strange looking and weirdly scary mime."
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "mime"
	icon_living = "mime"
	icon_dead = "mime"
	robust_searching = 1
	aggro_vision_range = 12
	vision_range = 5
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 0
	turns_per_move = 20
	rapid_melee = 1
	speed = 1
	move_to_delay = 4
	move_resist = 1000
	maxHealth = 120
	health = 120
	pixel_x = -16
	base_pixel_x = -16
	see_in_dark = 3
	charger = TRUE
	charge_distance = 10
	charge_frequency = 120
	knockdown_time = 20
	response_help_continuous = "pricks"
	response_help_simple = "prick"
	response_harm_continuous = "pummels"
	response_harm_simple = "pummel"
	harm_intent_damage = 10
	melee_damage_lower = 8
	melee_damage_upper = 16
	obj_damage = 20
	attack_verb_continuous = "slaps"
	attack_verb_simple = "slap"
	attack_sound = "sound/creatures/mime_swing.ogg"
	del_on_death = 1

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 150
	maxbodytemp = 500
	var/steroid = 0
	var/steroid_cooldown = 0
	var/datum/action/innate/horror_mime/expand/E
	loot = list(/obj/effect/gibspawner/human/bodypartless, /obj/effect/gibspawner/robot, /obj/item/food/baguette)
	var/obj/effect/proc_holder/spell/self/disappear/disappear = null

/mob/living/simple_animal/hostile/horror_mime/Initialize(mapload)
	. = ..()
	E = new
	E.Grant(src)
	disappear = new /obj/effect/proc_holder/spell/self/disappear
	AddSpell(disappear)

/mob/living/simple_animal/hostile/horror_mime/Destroy()
	QDEL_NULL(E)
	return ..()

/mob/living/simple_animal/hostile/horror_mime/Life(delta_time = SSMOBS_DT, times_fired)
	if(!steroid)
		steroid_cooldown = max((steroid_cooldown - (0.5 * delta_time)), 0)
	if(target && AIStatus == AI_ON)
		E.Activate()
	..()

/mob/living/simple_animal/hostile/horror_mime/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && steroid)
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/horror_mime/Aggro()
	..()
	E.Activate()

/datum/action/innate/horror_mime
	icon_icon = 'icons/mob/actions/actions_mime.dmi'
	background_icon_state = "bg_mime"

/datum/action/innate/horror_mime/expand
	name = "Steroid Rush"
	desc = "Makes you stronger for a short moment!"
	button_icon_state = "mime_horror"

/datum/action/innate/horror_mime/expand/Activate()
	var/mob/living/simple_animal/hostile/horror_mime/F = owner
	if(F.steroid)
		to_chat(F, span_warning("You cannot pump more steroids in your body."))
		return
	if(F.steroid_cooldown)
		to_chat(F, span_warning("You need more time to gather another steroid rush!"))
		return
	F.steroid = 1
	F.icon_state = "mime_st"
	F.harm_intent_damage = 16
	F.melee_damage_upper = 24
	F.obj_damage = 100
	F.environment_smash = 2
	F.rapid_melee = 3
	F.speed = -1
	F.move_to_delay = 1
	F.move_resist = INFINITY
	addtimer(CALLBACK(F, /mob/living/simple_animal/hostile/horror_mime/proc/Deflate), 100)

/mob/living/simple_animal/hostile/horror_mime/proc/Deflate()
	if(steroid)
		walk(src, 0)
		steroid = 0
		icon_state = "mime"
		harm_intent_damage = 10
		melee_damage_upper = 12
		obj_damage = 20
		steroid_cooldown = 15
		environment_smash = 1
		rapid_melee = 1
		speed = 1
		move_to_delay = 4
		move_resist = 1000

/mob/living/simple_animal/hostile/horror_mime/death(gibbed)
	Deflate()
	..(gibbed)
