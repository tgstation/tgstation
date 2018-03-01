/mob/living/simple_animal/butterfly
	name = "butterfly"
	desc = "A colorful butterfly, how'd it get up here?"
	icon_state = "butterfly"
	icon_living = "butterfly"
	icon_dead = "butterfly_dead"
	turns_per_move = 1
	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	speak_emote = list("flutters")
	maxHealth = 2
	health = 2
	harm_intent_damage = 1
	friendly = "nudges"
	density = FALSE
	movement_type = FLYING
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "flutters"
	verb_ask = "flutters inquisitively"
	verb_exclaim = "flutters intensely"
	verb_yell = "flutters intensely"

/mob/living/simple_animal/butterfly/Initialize()
	. = ..()
	var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/butterfly/bee_friendly()
	return TRUE //treaty signed at the Beeneeva convention

/mob/living/simple_animal/fly
	name = "swarm of flies"
	desc = "[health = 1 ? "A single brave little fly, ready to take what the world throws at it." : "A swarm of flies, because the Janitor just isn't doing a good enough job."]"
	icon_state = "fly-10"
	icon_living = "fly-10"
	icon_dead = "fly_dead"
	turns_per_move = 1
	response_help = "shoos"
	response_disarm = "shoos"
	response_harm = "splats"
	speak_emote = list("buzzes")
	maxHealth = 10 //it's a swarm!!
	health = 10
	harm_intent_damage = 3 //you can only kill one of the flies in the swarm at a time
	friendly = "nudges"
	density = FALSE
	movement_type = FLYING
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "buzzes"
	verb_ask = "buzzes inquisitively"
	verb_exclaim = "buzzes intensely"
	verb_yell = "buzzes intensely"

/mob/living/simple_animal/fly/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	src.health --
	visible_message("the fly stops moving...")
	if(stat)
		icon_state = "fly-[health]"
		maxHealth = health

/mob/living/simple_animal/fly/time
	name = "swarm of time flies"
	desc = "Radiation seems to have given this [health = 1 ? "fly" : "swarm of flies"] time bending powers."
	icon_state = "timefly-10"
	icon_living = "timefly-10"
	icon_dead = "timefly_dead"

/mob/living/simple_animal/fly/time/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	src.health --
	visible_message("the time fly stops moving...")
	if(stat)
		icon_state = "timefly-[health]"
		maxHealth = health

/mob/living/simple_animal/fly/time/AttackingTarget()
	. = ..()
	if(. && isliving(target)
	var/mob/living/L = target





/obj/effect/proc_holder/spell/targeted/shadowwalk
	name = "Shadow Walk"
	desc = "Grants unlimited movement in darkness."
	charge_max = 0
	clothes_req = 0
	phase_allowed = 1
	selection_type = "range"
	range = -1
	include_user = 1
	cooldown_min = 0
	overlay = null
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"
	action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/spell/targeted/shadowwalk/cast(list/targets,mob/living/user = usr)
	var/L = user.loc
	if(istype(user.loc, /obj/effect/dummy/shadow))
		var/obj/effect/dummy/shadow/S = L
		S.end_jaunt(FALSE)
		return
	else
		var/turf/T = get_turf(user)
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			playsound(get_turf(user), 'sound/magic/ethereal_enter.ogg', 50, 1, -1)
			visible_message("<span class='boldwarning'>[user] melts into the shadows!</span>")
			user.SetStun(0, FALSE)
			user.SetKnockdown(0, FALSE)
			user.setStaminaLoss(0, 0)
			var/obj/effect/dummy/shadow/S2 = new(get_turf(user.loc))
			user.forceMove(S2)
			S2.jaunter = user
		else
			to_chat(user, "<span class='warning'>It isn't dark enough here!</span>")

/obj/effect/dummy/timewarp
	name = "distortion in spacetime"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	var/mob/living/jaunter
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/timewarp/relaymove(mob/user, direction)
	var/turf/newLoc = get_step(src,direction)
	if(isspaceturf(newLoc))
		to_chat(user, "<span class='warning'>It really would not be wise to go into space.</span>")
		return
	forceMove(newLoc)
	check_light_level()

/obj/effect/dummy/timewarp/proc/check_light_level()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(light_amount > 0.2) // jaunt ends
		end_jaunt(TRUE)
	else if (light_amount < 0.2 && (!QDELETED(jaunter))) //heal in the dark
		jaunter.heal_overall_damage(1,1)

/obj/effect/dummy/timewarp/proc/end_jaunt(forced = FALSE)
	if(jaunter)
		if(forced)
			visible_message("<span class='boldwarning'>[jaunter] is revealed by the light!</span>")
		else
			visible_message("<span class='boldwarning'>[jaunter] emerges from the darkness!</span>")
		jaunter.forceMove(get_turf(src))
		playsound(get_turf(jaunter), 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
		jaunter = null
	qdel(src)

/obj/effect/dummy/timewarp/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/shadow/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/dummy/shadow/process()
	if(!jaunter)
		qdel(src)
	if(jaunter.loc != src)
		qdel(src)
	check_light_level()

/obj/effect/dummy/shadow/ex_act()
	return

/obj/effect/dummy/shadow/bullet_act()
	return

/obj/effect/dummy/shadow/singularity_act()
	return
