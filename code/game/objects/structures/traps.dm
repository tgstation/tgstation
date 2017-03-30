/obj/structure/trap
	name = "IT'S A TRAP"
	desc = "stepping on me is a guaranteed bad day"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "trap"
	density = 0
	anchored = TRUE
	alpha = 30 //initially quite hidden when not "recharging"
	var/last_trigger = 0
	var/time_between_triggers = 600 //takes a minute to recharge

	var/list/static/ignore_typecache

	var/datum/effect_system/spark_spread/spark_system

/obj/structure/trap/Initialize(mapload)
	..()
	spark_system = new
	spark_system.set_up(4,1,src)
	spark_system.attach(src)

	if(!ignore_typecache)
		ignore_typecache = typecacheof(list(
			/obj/effect,
			/mob/dead))

/obj/structure/trap/Destroy()
	qdel(spark_system)
	spark_system = null
	. = ..()

/obj/structure/trap/examine(mob/user)
	..()
	if(!isliving(user))
		return
	if(get_dist(user, src) <= 1)
		to_chat(user, "<span class='notice'>You reveal [src]!</span>")
		flare()

/obj/structure/trap/proc/flare()
	// Makes the trap visible, and starts the cooldown until it's
	// able to be triggered again.
	visible_message("<span class='warning'>[src] flares brightly!</span>")
	alpha = 200
	animate(src, alpha = initial(alpha), time = time_between_triggers)
	last_trigger = world.time
	spark_system.start()

/obj/structure/trap/Crossed(atom/movable/AM)
	if(last_trigger + time_between_triggers > world.time)
		return
	// Don't want the traps triggered by sparks, ghosts or projectiles.
	if(is_type_in_typecache(AM, ignore_typecache))
		return
	flare()
	if(isliving(AM))
		trap_effect(AM)

/obj/structure/trap/proc/trap_effect(mob/living/L)
	return

/obj/structure/trap/stun
	name = "shock trap"
	desc = "A trap that will shock and render you immobile. You'd better avoid it."
	icon_state = "trap-shock"

/obj/structure/trap/stun/trap_effect(mob/living/L)
	L.electrocute_act(30, src, safety=1) // electrocute act does a message.
	L.Weaken(5)

/obj/structure/trap/fire
	name = "flame trap"
	desc = "A trap that will set you ablaze. You'd better avoid it."
	icon_state = "trap-fire"

/obj/structure/trap/fire/trap_effect(mob/living/L)
	to_chat(L, "<span class='danger'><B>Spontaneous combustion!</B></span>")
	L.Weaken(1)

/obj/structure/trap/fire/flare()
	..()
	new /obj/effect/hotspot(get_turf(src))


/obj/structure/trap/chill
	name = "frost trap"
	desc = "A trap that will chill you to the bone. You'd better avoid it."
	icon_state = "trap-frost"

/obj/structure/trap/chill/trap_effect(mob/living/L)
	to_chat(L, "<span class='danger'><B>You're frozen solid!</B></span>")
	L.Weaken(1)
	L.bodytemperature -= 300
	L.apply_status_effect(/datum/status_effect/freon)


/obj/structure/trap/damage
	name = "earth trap"
	desc = "A trap that will summon a small earthquake, just for you. You'd better avoid it."
	icon_state = "trap-earth"


/obj/structure/trap/damage/trap_effect(mob/living/L)
	to_chat(L, "<span class='danger'><B>The ground quakes beneath your feet!</B></span>")
	L.Weaken(5)
	L.adjustBruteLoss(35)

/obj/structure/trap/damage/flare()
	..()
	var/obj/structure/flora/rock/giant_rock = new(get_turf(src))
	QDEL_IN(giant_rock, 200)


/obj/structure/trap/ward
	name = "divine ward"
	desc = "A divine barrier, It looks like you could destroy it with enough effort, or wait for it to dissipate..."
	icon_state = "ward"
	density = 1
	time_between_triggers = 1200 //Exists for 2 minutes


/obj/structure/trap/ward/New()
	..()
	QDEL_IN(src, time_between_triggers)
