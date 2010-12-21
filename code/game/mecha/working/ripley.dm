/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit."
	name = "APLU \"Ripley\""
	icon_state = "ripley"
	step_in = 8
	max_temperature = 1000
	health = 200
	cargo_capacity = 15


/obj/mecha/working/ripley/New()
	..()
//	tools += new /datum/mecha_tool/uni_interface(src)
	tools += new /datum/mecha_tool/hydraulic_clamp(src)
	tools += new /datum/mecha_tool/drill(src)
/*
	for(var/g_type in typesof(/datum/mecha_tool/gimmick))
		if(g_type!=/datum/mecha_tool/gimmick)
			tools += new g_type(src)
*/
	selected_tool = tools[1]
	return