/obj/machinery/soulbencher
	name = "soulbencher"
	desc = "I gave up trying to go back a long time ago. \
		Maybe you should just sit this one out."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator-red"

	var/list/damned_ckeys = list()
	var/list/died_ckeys = list()
	var/the_deal = "<span class='warning'>The deal has been made and cannot \
		be undone.</span>"

/obj/machinery/soulbencher/New()
	. = ..()
	soulbenchers_list += src

/obj/machinery/soulbencher/Destroy()
	soulbenchers_list -= src
	. = ..()

/obj/machinery/soulbencher/process()
	// In case they somehow manage to live again.
	for(var/mob/M in player_list)
		if(M.ckey in died_ckeys && (!(isobserver(M))) && M.stat != DEAD)
			M << the_deal
			M.death()
	. = ..()

	for(var/mob/M in living_mob_list)
		if(M.stat == DEAD && M.ckey in damned_ckeys)
			M << the_deal
			died_ckeys += M.ckey

/obj/machinery/soulbencher/proc/bench(ckey, kill=FALSE)
	damned_ckeys |= ckey
	if(kill)
		died_ckeys |= ckey

/mob/proc/is_ineligible_for_ghost_roles()
	. = FALSE
	for(var/x in soulbenchers_list)
		var/obj/machinery/soulbencher/sb = x
		if(src.ckey in sb.damned_ckeys)
			. = TRUE
			break
