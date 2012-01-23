/*/obj/mecha/working/firefighter
	desc = "Standart APLU chassis was refitted with additional thermal protection and cistern."
	name = "Ripley-on-Fire"
	icon_state = "ripley"
	step_in = 6
	max_temperature = 6000
	health = 250
	internal_damage_threshold = 40
	wreckage = /obj/effect/decal/mecha_wreckage/ripley
	infra_luminosity = 5


/obj/mecha/working/firefighter/New()
	..()
//	tools += new /datum/mecha_tool/uni_interface(src)
	tools += new /datum/mecha_tool/extinguisher(src)
	tools += new /datum/mecha_tool/drill(src)

	for(var/g_type in typesof(/datum/mecha_tool/gimmick))
		if(g_type!=/datum/mecha_tool/gimmick)
			tools += new g_type(src)

	selected_tool = tools[1]
	return
*/