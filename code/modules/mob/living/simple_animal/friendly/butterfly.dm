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
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
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

/mob/living/simple_animal/hostile/fly
	name = "fly"
	desc = "We went to space to escape flies, but they always seem to find us."
	icon_state = "fly"
	icon_living = "fly"
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
	maxHealth = 1
	health = 1
	move_to_delay = 0
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	movement_type = FLYING
	search_objects = 1 //have to find those plant trays!

/mob/living/simple_animal/hostile/fly/Initialize()
	. = ..()
	AddComponent(/datum/component/swarming)

/mob/living/simple_animal/hostile/fly/time
	name = "time fly"
	desc = "it's just a jump to the left..."
	attacktext = "zaps"
	icon_state = "timefly"
	icon_living = "timefly"
	icon_dead = "timefly_dead"
	var/obj/effect/proc_holder/spell/targeted/timewarp/twarp
	var/datum/action/innate/timewarp/twarpself

/mob/living/simple_animal/hostile/fly/time/Initialize()
	. = ..()
	twarp = new
	twarpself = new
	twarpself.Grant(src)

/mob/living/simple_animal/hostile/fly/time/AttackingTarget()
	if(. && isliving(target))
		var/mob/living/L = target
		if(twarp)
			twarp.cast(L, src)

/datum/action/innate/timewarp/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/fly/time))
		return
	var/mob/living/simple_animal/hostile/fly/time/TF = owner
	if(TF.twarp)
		TF.twarp.cast(TF, TF)

/obj/effect/proc_holder/spell/targeted/timewarp //this spell exists (probably in nullspace) but is not granted to any character, it is triggered by the time fly's actions. good god old armhulen you were SO ahead of your time
	name = "Time Warp!"
	desc = "I REMEMBERRRRRR DOIN THE TIIIME WARRRRRP DRINKING THOSE MOMENTS WHEEEEEEEEEN THE BLACKNESS WOULD HIT MEEEEEE AND THE VOID WOULD BE CAAAAAAAALLING"
	charge_max = 0
	clothes_req = FALSE
	selection_type = "range"
	range = -1
	include_user = TRUE
	cooldown_min = 0
	overlay = null
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"
	action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/spell/targeted/timewarp/cast(mob/living/target, mob/living/user = usr)
	playsound(get_turf(user), 'sound/magic/ethereal_enter.ogg', 50, 1, -1)
	visible_message("<span class='boldwarning'>[target] blinks out of existence!</span>")
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
