/obj/item/disk/holodisk/immortus_one
	name = "Welcome"
	preset_image_type = /datum/preset_holoimage/fuzzy
	preset_record_text = {"
	NAME Sentry
	DELAY 10
	SAY Welcome to Immortus Clinics
	DELAY 20
	SAY We understand that for our distinguished clients in their final days...
	DELAY 20
	SAY small-minded regulations and medical ethics can only offer to hasten your end.
	DELAY 20
	SAY Here at Immortus, we offer hope instead.
	DELAY 20
	SAY That is why we established this clinic in an unregistered sector...
	DELAY 20
	SAY to offer you the latest and most cutting-edge of treatments.
	DELAY 200;"}

/obj/item/disk/holodisk/immortus_two
	name = "Welcome"
	preset_image_type = /datum/preset_holoimage/fuzzy
	preset_record_text = {"
	NAME Sentry
	DELAY 10
	SAY Welcome to Immortus Clinics
	DELAY 20
	SAY We understand that for our distinguished clients in their final days...
	DELAY 20
	SAY small-minded regulations and medical ethics can only offer to hasten your end.
	DELAY 20
	SAY Here at Immortus, we offer hope instead.
	DELAY 20
	SAY That is why we established this clinic in an unregistered sector...
	DELAY 20
	SAY to offer you the latest and most cutting-edge of treatments.
	DELAY 200;"}

/obj/machinery/light/spooky
	brightness = 6
	var/default_on = FALSE
	var/frequency = 900 // Max time between flickering in deciseconds

/obj/machinery/light/spooky/on
	default_on = TRUE
	frequency = 3000

/obj/machinery/light/spooky/Initialize()
	GLOB.machines += src
	flicker_loop()

/obj/machinery/light/spooky/proc/flicker_loop()
	addtimer(CALLBACK(src, .proc/flicker_loop), rand(200, frequency))
	if(default_on)
		flicker(20)
	else
		flicker(20, FALSE)


/obj/machinery/light/sequence
	brightness = 4
	on = FALSE
	var/static/list/lights = list(list(),list(),list(),list(),list(),list(),list(),list(),list(),list()) //Max of 9 groups
	var/group = 1
	var/static/sequencing

/obj/machinery/light/sequence/Initialize()
	GLOB.machines += src
	if(!sequencing)
		sequencing = TRUE
		light_sequence(1)
	lights[group] += src

/obj/machinery/light/sequence/Destroy()
	lights[group] -= src
	. = ..()

/obj/machinery/light/sequence/proc/light_sequence(groupnum, backwards = FALSE)
	var/obj/machinery/light/sequence/chosen
	for(var/i in 1 to 4)
		chosen = pick(lights[groupnum])
		if(chosen.status == LIGHT_OK)
			break
	if(chosen)
		to_chat(world, "Flickering [chosen] at loc: [chosen.x], [chosen.y] in group #[chosen.group]")
		chosen.flicker(20)
	var/next = groupnum
	if(backwards)
		next--
		if(LAZYLEN(lights[next]))
			addtimer(CALLBACK(chosen, .proc/light_sequence, next, TRUE), 75)
		else
			next = 1
			if(LAZYLEN(lights[next]))
				addtimer(CALLBACK(chosen, .proc/light_sequence, next, FALSE), 75)
	else
		next++
		if(LAZYLEN(lights[next]))
			addtimer(CALLBACK(chosen, .proc/light_sequence, next, FALSE), 75)
		else
			next -= 2
			addtimer(CALLBACK(chosen, .proc/light_sequence, next, TRUE), 75)
	sleep(100)
	chosen.flicker(20, FALSE)

/mob/living/simple_animal/hostile/zombie
	name = "undead"
	desc = "An experiment - gone tragically wrong."
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	icon_dead = "zombie_dead"
	turns_per_move = 5
	move_to_delay = 5
	speak_emote = list("groans")
	emote_see = list("groans")
	a_intent = "harm"
	maxHealth = 60
	health = 60
	speed = 2.5
	obj_damage = 40
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 350
	environment_smash = 1
	robust_searching = 1
	stat_attack = UNCONSCIOUS
	gold_core_spawnable = 0
	faction = list("zombie")
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie = 3)
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8

/mob/living/simple_animal/hostile/zombie/death()
	..()
	addtimer(CALLBACK(src, .proc/arise), rand(400,600))

/mob/living/simple_animal/hostile/zombie/proc/arise()
	if(stat == DEAD)
		visible_message("<span class='danger'>[src] staggers to their feet!</span>")
		playsound(src, 'sound/hallucinations/growl1.ogg', 100, 1)
		revive(full_heal = 1)