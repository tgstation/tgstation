/mob/living/simple_animal/fly
	name = "fly"
	desc = "We went to space to escape flies, but they always seem to find us."
	icon_state = "fly-10"
	icon_living = "fly-10"
	icon_dead = "fly_dead"
	icon = 'icons/mob/bees.dmi'
	gender = NEUTER
	speak_emote = list("buzzes")
	emote_hear = list("buzzes")
	turns_per_move = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	retreat_distance = 2
	minimum_distance = 2
	friendly = "annoys"
	attacktext = "seriously annoys"
	response_help  = "shoos"
	response_disarm = "swats away"
	response_harm   = "squashes"
	maxHealth = 10
	health = 10
	spacewalk = TRUE
	faction = list("hostile")
	move_to_delay = 0
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	movement_type = FLYING
	gold_core_spawnable = HOSTILE_SPAWN
	search_objects = 1 //have to find those plant trays!

/mob/living/simple_animal/fly/Initialize()
	. = ..()
	AddComponent(/datum/component/swarming)

/mob/living/simple_animal/fly/time
	name = "time fly"
	desc = "Radiation seems to have given this swarm of flies a jump to the left and a step to the.... oh you get the idea!"
	icon_state = "timefly-10"
	icon_living = "timefly-10"
	icon_dead = "timefly_dead"
	var/obj/effect/proc_holder/spell/targeted/timewarp/twarp

/mob/living/simple_animal/fly/time/AttackingTarget()
	. = ..()
	if(. && isliving(target))
	var/mob/living/L = target
	twarp = new
	twarp.cast(L, src)

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