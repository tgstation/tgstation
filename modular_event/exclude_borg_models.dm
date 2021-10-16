/mob/living/silicon/robot/pick_model()
	if(model.type != /obj/item/robot_model)
		return

	if(wires.is_cut(WIRE_RESET_MODEL))
		to_chat(src,span_userdanger("ERROR: Model installer reply timeout. Please check internal connections."))
		return

	// Event divergence: no engiborg, no miner borg
	var/list/model_list = list(
	"Medical" = /obj/item/robot_model/medical, \
	"Janitor" = /obj/item/robot_model/janitor, \
	"Service" = /obj/item/robot_model/service)
	if(!CONFIG_GET(flag/disable_peaceborg))
		model_list["Peacekeeper"] = /obj/item/robot_model/peacekeeper
	if(!CONFIG_GET(flag/disable_secborg))
		model_list["Security"] = /obj/item/robot_model/security

	// Create radial menu for choosing borg model
	var/list/model_icons = list()
	for(var/option in model_list)
		var/obj/item/robot_model/model = model_list[option]
		var/model_icon = initial(model.cyborg_base_icon)
		model_icons[option] = image(icon = 'icons/mob/robots.dmi', icon_state = model_icon)

	var/input_model = show_radial_menu(src, src, model_icons, radius = 42)
	if(!input_model || model.type != /obj/item/robot_model)
		return

	model.transform_to(model_list[input_model])
