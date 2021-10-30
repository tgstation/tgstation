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
	loot = list(/obj/effect/gibspawner/human/bodypartless, /obj/effect/gibspawner/robot, /obj/item/food/baguette)
	var/steroid = 0 //Checks if you can use the expand steroid ability
	var/steroid_cooldown = 0 //The cooldown of the steroid ability gets assigned to this variable
	var/datum/action/innate/horror_mime/expand/expand_mime //Creates a variable to put in the steroid ability for the mime
	var/obj/effect/proc_holder/spell/self/disappear/disappear = null //Creates a variable to put in the dissapear ability for the mime

/mob/living/simple_animal/hostile/horror_mime/Initialize(mapload)
	. = ..()
	expand_mime = new
	expand_mime.Grant(src)
	disappear = new /obj/effect/proc_holder/spell/self/disappear
	AddSpell(disappear)

/mob/living/simple_animal/hostile/horror_mime/Destroy()
	QDEL_NULL(expand_mime)
	return ..()

/mob/living/simple_animal/hostile/horror_mime/Life(delta_time = SSMOBS_DT, times_fired)
	if(!steroid)
		steroid_cooldown = max((steroid_cooldown - (0.5 * delta_time)), 0)
	if(target && AIStatus == AI_ON)
		expand_mime.Activate()
	..()

/mob/living/simple_animal/hostile/horror_mime/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && steroid)
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/horror_mime/Aggro()
	..()
	expand_mime.Activate()

/datum/action/innate/horror_mime
	icon_icon = 'icons/mob/actions/actions_mime.dmi'
	background_icon_state = "bg_mime"

/datum/action/innate/horror_mime/expand
	name = "Steroid Rush"
	desc = "Makes you stronger for a short moment!"
	button_icon_state = "mime_horror"

/datum/action/innate/horror_mime/expand/Activate()
	var/mob/living/simple_animal/hostile/horror_mime/currect_user = owner
	if(currect_user.steroid)
		balloon_alert(currect_user, span_warning("You cannot handle more steroids!"))
		return
	if(currect_user.steroid_cooldown)
		balloon_alert(currect_user, span_warning("You have no steroids!"))
		return
	currect_user.steroid = 1
	currect_user.icon_state = "mime_st"
	currect_user.move_resist = INFINITY
	currect_user.harm_intent_damage += 6
	currect_user.melee_damage_upper += 12
	currect_user.obj_damage += 80
	currect_user.environment_smash += 1
	currect_user.rapid_melee += 2
	currect_user.speed -= 1
	currect_user.move_to_delay -= 3
	addtimer(CALLBACK(currect_user, /mob/living/simple_animal/hostile/horror_mime/proc/Deflate), 10 SECONDS)

/mob/living/simple_animal/hostile/horror_mime/proc/Deflate()
	if(steroid)
		walk(src, 0)
		steroid = 0
		icon_state = "mime"
		move_resist = 1000
		steroid_cooldown = 15
		harm_intent_damage -= 6
		melee_damage_upper -= 12
		obj_damage -= 80
		environment_smash -= 1
		rapid_melee -= 2
		speed += 1
		move_to_delay += 3

/mob/living/simple_animal/hostile/horror_mime/death(gibbed)
	Deflate()
	..(gibbed)
