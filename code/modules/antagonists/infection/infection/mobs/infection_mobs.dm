
/*
	Base slime type not meant to be spawned
*/

/mob/living/simple_animal/hostile/infection
	icon = 'icons/mob/infection/slime_mob.dmi'
	pass_flags = PASSBLOB
	faction = list(ROLE_INFECTION)
	bubble_icon = "blob"
	speak_emote = null //so we use verb_yell/verb_say/etc
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 360
	unique_name = 1
	light_range = 6
	a_intent = INTENT_HARM
	stat_attack = DEAD
	// if the spore can cross beacons
	var/can_cross_beacons = FALSE
	// the overmind of the spore
	var/mob/camera/commander/overmind = null
	// the factory the spore spawned from
	var/obj/structure/infection/factory/factory = null

/mob/living/simple_animal/hostile/infection/Initialize(mapload, owner_overmind)
	. = ..()
	verbs -= /mob/living/verb/pulled
	if(!can_cross_beacons)
		AddComponent(/datum/component/no_beacon_crossing)

/mob/living/simple_animal/hostile/infection/update_icons()
	if(overmind)
		add_atom_colour(overmind.infection_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/hostile/infection/Destroy()
	if(overmind)
		overmind.infection_mobs -= src
	return ..()

/mob/living/simple_animal/hostile/infection/blob_act(obj/structure/infection/I)
	if(stat != DEAD && health < maxHealth)
		for(var/i in 1 to 2)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				H.color = overmind.color
			else
				H.color = "#000000"
		adjustHealth(-maxHealth*0.0125)

/mob/living/simple_animal/hostile/infection/fire_act(exposed_temperature, exposed_volume)
	..()
	if(istype(src, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		return
	if(exposed_temperature)
		adjustFireLoss(CLAMP(0.01 * exposed_temperature, 1, 5))
	else
		adjustFireLoss(5)

/mob/living/simple_animal/hostile/infection/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/structure/infection) || istype(mover, /obj/item/projectile/bullet/infection))
		return 1
	return ..()

/mob/living/simple_animal/hostile/infection/Process_Spacemove(movement_dir = 0)
	for(var/obj/structure/infection/I in range(1, src))
		return 1
	return ..()

/mob/living/simple_animal/hostile/infection/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	infection_chat(message)

/*
	Attempts to talk using the message
*/
/mob/living/simple_animal/hostile/infection/proc/infection_chat(msg)
	var/rendered = "<font color=\"#EE4000\"><b>\[Infection Telepathy\] [real_name]</b> [msg]</font>"
	for(var/M in GLOB.mob_list)
		if(iscommander(M) || isinfectionmonster(M))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/*
	A normal infection slime created from factories
*/

/mob/living/simple_animal/hostile/infection/infectionspore
	name = "infection slime"
	desc = "A floating, fragile slime."
	icon_state = "infest-slime-core"
	icon_living = "infest-slime-core"
	health = 70
	maxHealth = 70
	verb_say = "psychically pulses"
	verb_ask = "psychically probes"
	verb_exclaim = "psychically yells"
	verb_yell = "psychically screams"
	melee_damage_lower = 10
	melee_damage_upper = 10
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attacktext = "hits"
	attack_sound = 'sound/weapons/genhit1.ogg'
	movement_type = FLYING
	del_on_death = 1
	deathmessage = "dissapates in the atmosphere!"
	// color of the crystal on top of the infection slime
	var/crystal_color = "#ffffff"
	var/crystal_icon_state = "infest-slime-layer"

/mob/living/simple_animal/hostile/infection/infectionspore/Initialize(mapload, var/obj/structure/infection/factory/linked_node, commander)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
	if(commander)
		overmind = commander
	update_icons()
	. = ..()

/mob/living/simple_animal/hostile/infection/infectionspore/Life()
	update_icons()
	if(factory && z != factory.z)
		death()
	..()

/mob/living/simple_animal/hostile/infection/infectionspore/death(gibbed)
	if(factory)
		factory.spore_delay = world.time + factory.spore_cooldown //put the factory on cooldown
	..()

/mob/living/simple_animal/hostile/infection/infectionspore/Destroy()
	if(factory)
		factory.spores -= src
	factory = null
	return ..()

/mob/living/simple_animal/hostile/infection/infectionspore/update_icons()
	cut_overlays()
	color = null
	var/mutable_appearance/slime_crystal = mutable_appearance('icons/mob/infection/slime_mob.dmi', crystal_icon_state)
	if(crystal_color)
		slime_crystal.color = crystal_color
	add_overlay(slime_crystal)

/mob/living/simple_animal/hostile/infection/infectionspore/weak
	name = "fragile infection slime"
	health = 15
	maxHealth = 15
	melee_damage_lower = 1
	melee_damage_upper = 2