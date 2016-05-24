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

/obj/machinery/power/emitter/energycannon/magical/update_icon()
	if(active)
		icon_state = icon_state_on
	else
		icon_state = initial(icon_state)

/obj/machinery/power/emitter/energycannon/magical/process()
	. = ..()
	var/changed = FALSE
	if(active_tables.len >= 2)
		if(!active)
			visible_message("<span class='revenboldnotice'>\
				[src] opens its eyes.</span>")
			changed = TRUE
		active = TRUE
	else
		if(active)
			visible_message("<span class='revenboldnotice'>\
				[src] closes its eyes.</span>")
			changed = TRUE
		active = FALSE

	if(changed)
		update_icon()

/obj/machinery/power/emitter/energycannon/magical/attack_hand(mob/user)
	return

/obj/machinery/power/emitter/energycannon/magical/attackby(obj/item/W, mob/user, params)
	return

/obj/machinery/power/emitter/energycannon/magical/ex_act(severity)
	return

/obj/machinery/power/emitter/energycannon/magical/emag_act(mob/user)
	return

/obj/structure/table/abductor/wabbajack
	name = "wabbajack altar"
	health = 1000
	verb_say = "chants"
	var/obj/machinery/power/emitter/energycannon/magical/our_statue
	var/list/mob/living/sleepers = list()
	var/never_spoken = TRUE
	flags = NODECONSTRUCT

/obj/structure/table/abductor/wabbajack/New()
	. = ..()
	SSobj.processing += src

/obj/structure/table/abductor/wabbajack/Destroy()
	SSobj.processing -= src
	. = ..()

/obj/structure/table/abductor/wabbajack/process()
	var/area = orange(4, src)
	if(!our_statue)
		for(var/obj/machinery/power/emitter/energycannon/magical/M in area)
			our_statue = M
			break

	var/turf/T = get_turf(src)
	var/list/found = list()
	for(var/mob/living/carbon/C in T)
		if(C.stat != DEAD)
			found += C

	// New sleepers
	for(var/i in found - sleepers)
		var/mob/living/L = i
		L.color = "#800080"
		L.visible_message("<span class='revennotice'>A strange purple glow \
			wraps itself around [L] as they suddenly fall unconcious.</span>",
			"<span class='revendanger'>[desc]</span>")


	// Existing sleepers
	for(var/i in found)
		var/mob/living/L = i
		L.SetSleeping(10)

	// Missing sleepers
	for(var/i in sleepers - found)
		var/mob/living/L = i
		L.color = initial(L.color)
		L.visible_message("<span class='revennotice'>The glow from [L] fades \
			away.</span>")

	sleepers = found

	if(sleepers.len)
		our_statue.active_tables |= src
		if(never_spoken || prob(5))
			say(desc)
			never_spoken = FALSE
	else
		our_statue.active_tables &= src

/obj/structure/table/abductor/wabbajack/left
	desc = "You sleep so it may wake."

/obj/structure/table/abductor/wabbajack/right
	desc = "It wakes so you may sleep."
