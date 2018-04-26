/mob/living/simple_animal/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach"
	health = 1
	maxHealth = 1
	turns_per_move = 5
	loot = list(/obj/effect/decal/cleanable/deadcockroach)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	response_help  = "pokes"
	response_disarm = "shoos"
	response_harm   = "splats"
	speak_emote = list("chitters")
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters loudly"
	verb_yell = "chitters loudly"
	var/squish_chance = 50
	del_on_death = 1

/mob/living/simple_animal/cockroach/death(gibbed)
	if(SSticker.mode && SSticker.mode.station_was_nuked) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	..()

/mob/living/simple_animal/cockroach/Crossed(var/atom/movable/AM)
	if(ismob(AM))
		if(isliving(AM))
			var/mob/living/A = AM
			if(A.mob_size > MOB_SIZE_SMALL && !(A.movement_type & FLYING))
				if(prob(squish_chance))
					A.visible_message("<span class='notice'>[A] squashed [src].</span>", "<span class='notice'>You squashed [src].</span>")
					adjustBruteLoss(1) //kills a normal cockroach
				else
					visible_message("<span class='notice'>[src] avoids getting crushed.</span>")
	else
		if(isstructure(AM))
			if(prob(squish_chance))
				AM.visible_message("<span class='notice'>[src] was crushed under [AM].</span>")
				adjustBruteLoss(1)
			else
				visible_message("<span class='notice'>[src] avoids getting crushed.</span>")

/mob/living/simple_animal/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return

/obj/effect/decal/cleanable/deadcockroach
	name = "cockroach guts"
	desc = "One bug squashed. Four more will rise in its place."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")
	beauty = -300

/mob/living/simple_animal/hostile/fly
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

/mob/living/simple_animal/hostile/fly/Initialize()
	. = ..()
	AddComponent(/datum/component/swarming)

/mob/living/simple_animal/hostile/fly/time
	name = "time fly"
	desc = "Radiation seems to have given this swarm of flies a jump to the left and a step to the.... oh you get the idea!"
	icon_state = "timefly-10"
	icon_living = "timefly-10"
	icon_dead = "timefly_dead"
	var/obj/effect/proc_holder/spell/targeted/timewarp/twarp
	var/datum/action/innate/timewarp/twarpself

/mob/living/simple_animal/hostile/fly/time/Initialize()
	twarp = new

/mob/living/simple_animal/hostile/fly/time/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(twarp)
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
	visible_message("<span class='boldwarning'>[targets] is warped 10 seconds into the future!</span>")
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
		visible_message("<span class='boldwarning'>[jaunter] arrives from the past!</span>")
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
