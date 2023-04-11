/obj/item/mcobject/thermal_printer
	name = "Thermal Printer"
	desc = ""
	icon_state = "comp_tprint"
	base_icon_state = "comp_tprint"

	COOLDOWN_DECLARE(print_cooldown)
	var/paper_name = "thermal paper"

/obj/item/mcobject/thermal_printer/Initialize(mapload)
	. = ..()
	MC_ADD_CONFIG("Set Paper Name", set_paper_name)
	MC_ADD_INPUT("print", print_paper)

/obj/item/mcobject/thermal_printer/proc/print_paper(datum/mcmessage/input)
	if(!COOLDOWN_FINISHED(src, print_cooldown))
		return
	var/stringified_input = input.cmd
	if(!stringified_input)
		return
	flick("comp_tprint1", src)
	var/obj/item/paper/thermal_paper = new(src.loc)

	thermal_paper.name = paper_name
	thermal_paper.add_raw_text("<br>[stringified_input]</br>")
	thermal_paper.thermal_paper = TRUE
	COOLDOWN_START(src, print_cooldown, 5 SECONDS)

/obj/item/mcobject/thermal_printer/proc/set_paper_name(mob/user, obj/item/tool)
	var/new_paper_name = tgui_input_text(user, "Set the new name for the paper", "Thermal Printer", paper_name)
	if(!new_paper_name)
		return
	paper_name = new_paper_name
	return TRUE
