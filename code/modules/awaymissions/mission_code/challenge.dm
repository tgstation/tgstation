//Challenge Areas

/area/awaymission/challenge/start
	name = "Where Am I?"
	icon_state = "away"

/area/awaymission/challenge/main
	name = "Danger Room"
	icon_state = "away1"
	requires_power = 0

/area/awaymission/challenge/end
	name = "Administration"
	icon_state = "away2"
	requires_power = 0


/obj/machinery/power/emitter/energycannon
	name = "Energy Cannon"
	desc = "A heavy duty industrial laser"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 1
	density = 1

	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0

	active = 1
	locked = 1
	state = 2

/obj/machinery/power/emitter/energycannon/RefreshParts()
	return

/obj/machinery/power/emitter/energycannon/magical
	name = "wabbajack statue"
	desc = "Who am I? What is my purpose in life? What do I mean by who am I?"
	projectile_type = /obj/item/projectile/magic/change
	icon = 'icons/obj/machines/magic_emitter.dmi'
	icon_state = "wabbajack_statue"
	icon_state_on = "wabbajack_statue_on"
	var/list/active_tables = list()
	active = FALSE

/obj/machinery/power/emitter/energycannon/magical/New()
	. = ..()
	if(prob(50))
		desc = "Oh no, not again."
	update_icon()

/obj/machinery/power/emitter/energycannon/magical/process()
	. = ..()
	if(active_tables.len >= 2)
		active = TRUE
		update_icon()
	else
		active = FALSE
		update_icon()

/obj/machinery/power/emitter/energycannon/magical/attack_hand(mob/user)
	return

/obj/machinery/power/emitter/energycannon/magical/attackby(obj/item/W, mob/user, params)
	return

/obj/machinery/power/emitter/energycannon/magical/ex_act(severity)
	return

/obj/structure/table/abductor/wabbajack
	name = "wabbajack altar"
	health = 1000
	verb_say = "chants"
	var/mob/living/sleeper
	var/obj/machinery/power/emitter/energycannon/magical/our_statue

/obj/structure/table/abductor/wabbajack/New()
	. = ..()
	SSobj.processing += src

/obj/structure/table/abductor/wabbajack/Destroy()
	SSobj.processing -= src

/obj/structure/table/abductor/wabbajack/process()
	if(!our_statue)
		for(var/obj/machinery/power/emitter/energycannon/magical/M in orange(4,src))
			our_statue = M
			break
	if(!our_statue)
		say("It has left us.")
	return

	if(sleeper && (get_turf(sleeper) == get_turf(src)))
		sleeper.SetSleeping(10)
		sleeper.color = "#800080"
		our_statue.active_tables |= src
		if(prob(5))
			say(desc)
	else
		sleeper.color = initial(sleeper.color)
		our_statue.active_tables &= src
		sleeper = null

/obj/structure/table/abductor/wabbajack/Crossed(atom/AM)
	. = ..()
	if(isliving(AM))
		sleeper = AM
		say(desc)

/obj/structure/table/abductor/wabbajack/left
	desc = "You sleep so it may wake."

/obj/structure/table/abductor/wabbajack/right
	desc = "It wakes so you may sleep."