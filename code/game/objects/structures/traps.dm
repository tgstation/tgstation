/obj/structure/trap
	name = "IT'S A TARP"
	desc = "stepping on me is a guaranteed bad day"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "trap"
	density = 0
	anchored = TRUE
	alpha = 30 //initially quite hidden when not "recharging"
	var/last_trigger = 0
	var/time_between_triggers = 600 //takes a minute to recharge

	var/datum/effect_system/spark_spread/spark_system

/obj/structure/trap/Initialize(mapload)
	..()
	spark_system = new
	spark_system.set_up(4,1,src)
	spark_system.attach(src)

/obj/structure/trap/Destroy()
	qdel(spark_system)
	spark_system = null
	. = ..()

/obj/structure/trap/Crossed(atom/movable/AM)
	if(last_trigger + time_between_triggers > world.time)
		return
	alpha = initial(alpha)
	if(isliving(AM))
		var/mob/living/L = AM
		last_trigger = world.time
		alpha = 200
		trap_effect(L)
		animate(src, alpha = initial(alpha), time = time_between_triggers)

/obj/structure/trap/proc/trap_effect(mob/living/L)
	return

/obj/structure/trap/stun
	name = "shock trap"
	desc = "A trap that will shock you and it will render you immobile. You'd better avoid it."
	icon_state = "trap-shock"

/obj/structure/trap/stun/trap_effect(mob/living/L)
	L.electrocute_act(30, src, safety=1) // electrocute act does a message.
	L.Weaken(5)
	spark_system.start()


/obj/structure/trap/fire
	name = "flame trap"
	desc = "A trap that will set you ablaze. You'd better avoid it."
	icon_state = "trap-fire"

/obj/structure/trap/fire/trap_effect(mob/living/L)
	L << "<span class='danger'><B>Spontaneous combustion!</B></span>"
	L.Weaken(1)
	var/turf/Lturf = get_turf(L)
	new /obj/effect/hotspot(Lturf)
	spark_system.start()


/obj/structure/trap/chill
	name = "frost trap"
	desc = "A trap that will chill you to the bone. You'd better avoid it."
	icon_state = "trap-frost"

/obj/structure/trap/chill/trap_effect(mob/living/L)
	L << "<span class='danger'><B>You're frozen solid!</B></span>"
	L.Weaken(1)
	L.bodytemperature -= 300
	spark_system.start()


/obj/structure/trap/damage
	name = "earth trap"
	desc = "A trap that will summon a small earthquake, just for you. You'd better avoid it."
	icon_state = "trap-earth"


/obj/structure/trap/damage/trap_effect(mob/living/L)
	L << "<span class='danger'><B>The ground quakes beneath your feet!</B></span>"
	L.Weaken(5)
	L.adjustBruteLoss(35)
	var/turf/Lturf = get_turf(L)
	spark_system.start()
	var/obj/structure/flora/rock/giant_rock = new(Lturf)
	QDEL_IN(giant_rock, 50) // short lived earthquake.


/obj/structure/trap/ward
	name = "divine ward"
	desc = "A divine barrier, It looks like you could destroy it with enough effort, or wait for it to dissipate..."
	icon_state = "ward"
	density = 1
	time_between_triggers = 1200 //Exists for 2 minutes


/obj/structure/trap/ward/New()
	..()
	QDEL_IN(src, time_between_triggers)
