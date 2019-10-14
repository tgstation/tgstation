//Pressure sensor: Activates when stepped on.
/obj/structure/destructible/clockwork/trap/trigger/pressure_sensor
	name = "pressure sensor"
	desc = "A thin plate of brass, barely visible but clearly distinct."
	clockwork_desc = "A trigger that will activate when a non-servant runs across it."
	max_integrity = 5
	icon_state = "pressure_sensor"
	alpha = 50

/obj/structure/destructible/clockwork/trap/trigger/Initialize()
	. = ..()
	for(var/obj/structure/destructible/clockwork/trap/T in get_turf(src))
		if(!istype(T, /obj/structure/destructible/clockwork/trap/trigger))
			wired_to += T
			T.wired_to += src
			to_chat(usr, "<span class='alloy'>[src] automatically links with [T] beneath it.</span>")

/obj/structure/destructible/clockwork/trap/trigger/pressure_sensor/Crossed(atom/movable/AM)
	if(isliving(AM) && !is_servant_of_ratvar(AM))
		var/mob/living/L = AM
		if(L.stat || L.m_intent == MOVE_INTENT_WALK || !(L.mobility_flags & MOBILITY_STAND))
			return
		audible_message("<i>*click*</i>")
		playsound(src, 'sound/items/screwdriver2.ogg', 50, TRUE)
		activate()
