/obj/mecha/combat/durand
	desc = "Combat exosuit."
	name = "Durand"
	icon_state = "durand"
	step_in = 6
	health = 350
	deflect_chance = 12
	max_temperature = 3000
	infra_luminosity = 8
	operation_req_access = list(access_security)
	force = 35
	var/defence = 0
	var/defence_deflect = 30
	wreckage = "/obj/decal/mecha_wreckage/durand"


/obj/mecha/combat/durand/New()
	..()
	weapons += new /datum/mecha_weapon/ballistic/lmg(src)
	weapons += new /datum/mecha_weapon/ballistic/scattershot(src)
	selected_weapon = weapons[1]
	return

/obj/mecha/combat/durand/relaymove(mob/user,direction)
	if(defence)
		src.occupant_message("<font color='red'>Unable to move while in defence mode</font>")
		return 0
	. = ..()
	return


/obj/mecha/combat/durand/verb/defence_mode()
	set category = "Exosuit Interface"
	set name = "Toggle defence mode"
	set src in view(0)
	if(usr!=src.occupant)
		return
	defence = !defence
	if(defence)
		deflect_chance = defence_deflect
		src.occupant_message("<font color='blue'>You enable [src] defence mode.</font>")
	else
		deflect_chance = initial(deflect_chance)
		src.occupant_message("<font color='red'>You disable [src] defence mode.</font>")
	return


/obj/mecha/combat/durand/get_stats_part()
	var/output = ..()
	output += "<b>Defence mode: [defence?"on":"off"]</b>"
	return output

/obj/mecha/combat/durand/get_commands()
	var/output = {"<a href='?src=\ref[src];toggle_defence_mode=1'>Toggle defence mode</a><br>
				"}
	output += ..()
	return output

/obj/mecha/combat/durand/Topic(href, href_list)
	..()
	if (href_list["toggle_defence_mode"])
		src.defence_mode()
	return