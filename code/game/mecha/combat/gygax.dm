/obj/mecha/combat/gygax
	desc = "Security exosuit."
	name = "Gygax"
	icon_state = "gygax"
	step_in = 6
	health = 300
	deflect_chance = 10
	max_temperature = 3500
	infra_luminosity = 6
	var/overload = 0
	operation_req_access = list(access_security)
	wreckage = "/obj/decal/mecha_wreckage/gygax"

/obj/mecha/combat/gygax/New()
	..()
	weapons += new /datum/mecha_weapon/taser(src)
	weapons += new /datum/mecha_weapon/laser(src)
	weapons += new /datum/mecha_weapon/missile_rack/flashbang(src)
	selected_weapon = weapons[1]
	return

/obj/mecha/combat/gygax/verb/overload()
	set category = "Exosuit Interface"
	set name = "Toggle leg actuators overload"
	set src in view(0)
	if(usr!=src.occupant)
		return
	if(overload)
		overload = 0
		step_in = initial(step_in)
		src.occupant_message("<font color='blue'>You disable leg actuators overload.</font>")
	else
		overload = 1
		step_in = min(1, round(step_in/2))
		src.occupant_message("<font color='red'> You enable leg actuators overload.</font>")
	return



/obj/mecha/combat/gygax/relaymove(mob/user,direction)
	if(!..()) return
	if(overload)
		cell.use(step_energy_drain)
		health--
		if(health < initial(health) - initial(health)/3)
			overload = 0
			step_in = initial(step_in)
			src.occupant_message("<font color='red'>Leg actuators damage threshold exceded. Disabling overload.</font>")
	return


/obj/mecha/combat/gygax/get_stats_part()
	var/output = ..()
	output += "<b>Leg actuators overload: [overload?"on":"off"]</b>"
	return output

/obj/mecha/combat/gygax/get_commands()
	var/output = {"<a href='?src=\ref[src];toggle_leg_overload=1'>Toggle leg actuators overload</a><br>
				"}
	output += ..()
	return output

/obj/mecha/combat/gygax/Topic(href, href_list)
	..()
	if (href_list["toggle_leg_overload"])
		src.overload()
	return