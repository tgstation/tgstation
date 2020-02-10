/obj/machinery/dwarven_sarcophagus_recharge
	name = "Ancient Sarcophagus"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "sarcophagus_open"
	density = TRUE

	var/recharge = TRUE
	var/recharge_points = 0
	var/recharge_points_max = 500

/obj/machinery/dwarven_sarcophagus_recharge/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It requires [recharge_points_max-recharge_points] points to reactivate </span>"

/obj/machinery/dwarven_sarcophagus_recharge/attackby(obj/item/stack/ore/I, mob/living/user, params)
	recharge_points += I.amount * I.points
	qdel(I)
	check_requirements()
	return

/obj/machinery/dwarven_sarcophagus_recharge/proc/check_requirements()
	if(recharge_points_max <= recharge_points)
		for(var/mob/M in viewers(src,5))
			to_chat(M, "<span class='notice'>The sarcophagus reignites with ancient fire, ready to birth another dwarf!</span>")
			new  /obj/effect/mob_spawn/human/dwarven_sarcophagus(get_turf(src))
			qdel(src)
	else
		for(var/mob/M in viewers(src,5))
			to_chat(M, "<span class='notice'>The sarcophagus is set ablaze for a second, but ancient powers die down. It requires more minerals!</span>")
