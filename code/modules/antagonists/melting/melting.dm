

/mob/living/simple_animal/hostile/melting
	name = "melting"
	real_name = "melting"
	desc = "While seemingly nice in appearance, this creature is completely evil."
	icon = 'icons/mob/melting.dmi'
	icon_state = ""
	icon_living = ""
	bubble_icon = "melting"
	pixel_x = -16
	pixel_y = -4
	speed = 2
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	maxHealth = 150
	health = 150
	healable = 0
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	see_in_dark = 8
	gender = NEUTER
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	del_on_death = TRUE
	var/slimebody_color
	var/obj/effect/proc_holder/spell/targeted/mark/mark
	var/datum/action/innate/colorchange/colors
	var/datum/action/innate/communicate/talk
	var/obj/effect/proc_holder/spell/aimed/slime/slimeball
	var/static/mutable_appearance/slimebody_overlay

/mob/living/simple_animal/hostile/melting/Initialize()
	. = ..()
	name = "[pick(GLOB.melting_first_names)] [pick(GLOB.melting_last_names)]"
	setup_icons()
	mark = new
	AddSpell(mark)
	colors = new
	colors.Grant(src)
	addtimer(CALLBACK(src, .proc/remove_colorpick), 1 MINUTES)
	slimeball = new
	AddSpell(slimeball)
	talk = new
	talk.Grant(src)

/mob/living/simple_animal/hostile/melting/proc/setup_icons(decided_color)
	cut_overlays()
	if(decided_color)
		slimebody_color = decided_color
	else
		slimebody_color = rgb(rand(100, 255), rand(100, 255), rand(100, 255))
	slimebody_overlay = slimebody_overlay || mutable_appearance('icons/mob/melting.dmi')
	slimebody_overlay.icon_state = "melting_base"
	slimebody_overlay.color = slimebody_color
	slimebody_overlay.alpha = 200
	add_overlay(slimebody_overlay)
	add_overlay("melting_shine")

/mob/living/simple_animal/hostile/melting/proc/test_alpha(new_alphas = 255)
	slimebody_overlay.alpha = new_alphas
	to_chat(world, "alpha set to [new_alphas]!")

/mob/living/simple_animal/hostile/melting/proc/remove_colorpick()
	if(colors)
		QDEL_NULL(colors)

/mob/living/simple_animal/hostile/melting/Destroy()
	if(mark)
		RemoveSpell(mark)
	if(colors)
		QDEL_NULL(colors)
	QDEL_NULL(slimeball)
	QDEL_NULL(talk)

	for(var/datum/disease/transformation/melting/ourdisease in SSdisease.active_diseases)//on death, it globally cures the melting disease.
		ourdisease.cure(FALSE)

	return ..()

/mob/living/simple_animal/hostile/melting/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/disease/transformation/melting/disease = new()
		disease.creator = src
		disease.try_infect(H, make_copy = FALSE)

/mob/living/simple_animal/hostile/melted
	name = "melted"
	desc = "A sizzling, oozing monster."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/melting.dmi'
	icon_state = "melted_base"
	icon_living = "melted_base"
	speed = 2
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 100
	health = 100
	healable = 0
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	see_in_dark = 8
	gender = NEUTER
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	del_on_death = TRUE
	var/static/creatorname
	var/mob/living/simple_animal/hostile/melting/creator

/mob/living/simple_animal/hostile/melted/Initialize()
	. = ..()
	add_overlay("melted_shine")
	if(!creatorname)
		name = generate_creatorname()
	name = creatorname

/mob/living/simple_animal/hostile/melted/proc/generate_creatorname()
	var/present_tense = pick(GLOB.melting_first_names)
	if(creator)
		present_tense = splittext(creator.name, " ")[1]//Ceaseless Zeal >> Ceaseless
	var/static/regex/meltword_endings = new("ing$|eless$|ful$|y$")
	var/newmeltword = lowertext(meltword_endings.Replace(present_tense, ""))//Ceaseless >> cease
	if(copytext(newmeltword, -1) == "e")
		newmeltword = copytext(newmeltword, length(newmeltword)-1)//cease >> ceas //needed to prevent things like "ceaseed"
	newmeltword = "the [newmeltword]ed"//ceas >> ceased
	return newmeltword

/mob/living/simple_animal/hostile/melted/Login()
	. = ..()
	GLOB.meltedmobs[src] = TRUE

/mob/living/simple_animal/hostile/melted/Destroy()
	GLOB.meltedmobs -= src
	return ..()

/mob/living/simple_animal/hostile/melted/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/disease/transformation/melting/disease = new()
		disease.creator = creator
		disease.try_infect(H, make_copy = FALSE)
