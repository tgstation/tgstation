/obj/item/pipe_painter
	name = "pipe painter"
	desc = "Used for coloring pipes, unsurprisingly."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "labeler1"
	inhand_icon_state = null
	item_flags = NOBLUDGEON
	var/paint_color = "grey"

	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT)

/obj/item/pipe_painter/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	//Make sure we only paint adjacent items
	if(!proximity_flag)
		return

	if(istype(target, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/target_pipe = target
		target_pipe.paint(paint_color)
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		balloon_alert(user, "painted in [GLOB.pipe_color_name[paint_color]] color")
	else if(istype(target, /obj/item/pipe))
		var/obj/item/pipe/target_pipe = target
		target_pipe.pipe_color = paint_color
		target.add_atom_colour(paint_color, FIXED_COLOUR_PRIORITY)
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		balloon_alert(user, "painted in [GLOB.pipe_color_name[paint_color]] color")

/obj/item/pipe_painter/attack_self(mob/user)
	paint_color = tgui_input_list(user, "Which colour do you want to use?", "Pipe painter", GLOB.pipe_paint_colors)

/obj/item/pipe_painter/examine(mob/user)
	. = ..()
	. += span_notice("It is set to [paint_color].")
