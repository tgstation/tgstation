/obj/mecha/combat/honker
	desc = "Produced by \"Tyranny of Honk, INC\", this exosuit is designed as heavy clown-support. Used to spread the fun and joy of life. HONK!"
	name = "H.O.N.K"
	icon_state = "honker"
	step_in = 4
	health = 140
	deflect_chance = 60
	internal_damage_threshold = 60
	max_temperature = 3500
	infra_luminosity = 5
	operation_req_access = list(access_clown)

/obj/mecha/combat/honker/New()
	..()
/*
	weapons += new /datum/mecha_weapon/honker(src)
	weapons += new /datum/mecha_weapon/missile_rack/banana_mortar(src)
	weapons += new /datum/mecha_weapon/missile_rack/mousetrap_mortar(src)
	selected_weapon = weapons[1]
	return
*/


/obj/mecha/combat/honker/melee_action(target)
	if(!melee_can_hit || !istype(target, /atom))
		return
	if(istype(selected, /obj/item/mecha_parts/mecha_equipment/weapon/honker))
		selected.action(target)
	else if(istype(target, /mob))
		step_away(target,src,15)
	return

/obj/mecha/combat/honker/get_stats_part()
	var/cell_charge = get_charge()
	var/output = {"[internal_damage&MECHA_INT_FIRE?"<font color='red'><b>INTERNAL FIRE</b></font><br>":null]
						[internal_damage&MECHA_INT_TEMP_CONTROL?"<font color='red'><b>CLOWN SUPPORT SYSTEM MALFUNCTION</b></font><br>":null]
						[internal_damage&MECHA_INT_TANK_BREACH?"<font color='red'><b>GAS TANK HONK</b></font><br>":null]
						[internal_damage&MECHA_INT_CONTROL_LOST?"<font color='red'><b>HONK-A-DOODLE</b></font> - <a href='?src=\ref[src];repair_int_control_lost=1'>Recalibrate</a><br>":null]
						<b>IntegriHONK: </b> [health/initial(health)*100] %) <br>
						<b>PowerHONK charge: </b>[isnull(cell_charge)?"Someone HONKed powerHonk!!!":"[cell.percent()]%"])<br>
						<b>AirHONK pressure: </b>[src.return_pressure()]HoNKs<br>
						<b>Internal HONKature: </b> [src.air_contents.temperature]&deg;honK|[src.air_contents.temperature - T0C]&deg;honCk<br>
						<b>Lights: </b>[lights?"on":"off"]<br>
					"}
	output += "<b>HONKon systems:</b><div style=\"margin-left: 15px;\">"
	if(equipment.len)
		for(var/obj/item/mecha_parts/mecha_equipment/W in equipment)
			output += "[selected==W?"<b>":"<a href='?src=\ref[src];select_equip=\ref[W]'>"][W.get_equip_info()][selected==W?"</b>":"</a>"]<br>"
	else
		output += "None. HONK!"
	output += "</div>"
	output += {"<b>Sounds of HONK:</b><div style=\"margin-left: 15px;\">
					<a href='?src=\ref[src];play_sound=sadtrombone'>Sad Trombone</a>
					</div>"}
	return output


/obj/mecha/combat/honker/get_stats_html()
	var/output = {"<html>
						<head><title>[src.name] data</title></head>
						<body style="color: #[rand_hex_color()]; background: #[rand_hex_color()]; font: 14px 'Courier', monospace;">
						[src.get_stats_part()]
						<hr>
						[src.get_commands()]
						</body>
						</html>
					 "}
	return output


/obj/mecha/combat/honker/relaymove(mob/user,direction)
	var/result = ..(user,direction)
	if(result)
		playsound(src, "clownstep", 70, 1)
	return result


obj/mecha/combat/honker/Topic(href, href_list)
	..()
	if (href_list["play_sound"])
		switch(href_list["play_sound"])
			if("sadtrombone")
				playsound(src, 'sadtrombone.ogg', 50)
	return

proc/rand_hex_color()
	var/list/colors = list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
	var/color=""
	for (var/i=0;i<6;i++)
		color = color+pick(colors)
	return color


