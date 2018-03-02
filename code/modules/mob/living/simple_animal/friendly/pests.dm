/mob/living/simple_animal/fly
	name = "swarm of flies"
	desc = "A swarm of flies, because the Janitor just isn't doing a good enough job."
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
	health --
	visible_message("the fly stops moving...")
	if(stat)
		icon_state = "fly-[health]"
		health = maxHealth

/mob/living/simple_animal/fly/time
	name = "swarm of time flies"
	desc = "Radiation seems to have given this swarm of flies time bending powers."
	icon_state = "timefly-10"
	icon_living = "timefly-10"
	icon_dead = "timefly_dead"

/mob/living/simple_animal/fly/time/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	health --
	visible_message("the time fly stops moving...")
	if(stat)
		icon_state = "timefly-[health]"
		maxHealth = health

///mob/living/simple_animal/fly/time/AttackingTarget()
//	. = ..()
//	if(. && isliving(target)
//	var/mob/living/L = target





/obj/effect/proc_holder/spell/targeted/timewarp
	name = "Time Warp!"
	desc = "Warps you 10 seconds into the future! If, for some reason, you wanted to travel yourself 10 seconds into the future."
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

/obj/effect/proc_holder/spell/targeted/timewarp/cast(list/targets,mob/living/user = usr)
	playsound(get_turf(user), 'sound/magic/ethereal_enter.ogg', 50, 1, -1)
	visible_message("<span class='boldwarning'>[user] melts into the shadows!</span>")
	user.SetStun(0, FALSE)
	user.SetKnockdown(0, FALSE)
	user.setStaminaLoss(0, 0)
	var/obj/effect/dummy/timewarp/T2 = new(get_turf(user.loc))
	user.forceMove(T2)
	T2.jaunter = user
	addtimer(CALLBACK(T2, /obj/effect/dummy/timewarp.proc/end_jaunt), 100)

/obj/effect/dummy/timewarp
	name = "distortion in spacetime"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 0
	var/mob/living/jaunter
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/timewarp/proc/end_jaunt()
	if(jaunter)
		visible_message("<span class='boldwarning'>[jaunter] pops into existence!</span>")
		jaunter.forceMove(get_turf(src))
		playsound(get_turf(jaunter), 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
		jaunter = null
	qdel(src)

/obj/effect/dummy/timewarp/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/timewarp/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/dummy/timewarp/process()
	if(!jaunter)
		qdel(src)
	if(jaunter.loc != src)
		qdel(src)

/obj/effect/dummy/timewarp/ex_act()
	return

/obj/effect/dummy/timewarp/bullet_act()
	return

/obj/effect/dummy/timewarp/singularity_act()
	return

//	desc = "[health == 1 ? "A single brave little fly, ready to take what the world throws at it." : "A swarm of flies, because the Janitor just isn't doing a good enough job."]"
//	desc = "Radiation seems to have given this [health = 1 ? "fly" : "swarm of flies"] time bending powers."