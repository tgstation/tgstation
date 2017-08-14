
/obj/item/device/pipe_painter
	name = "pipe painter"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler1"
	item_state = "flight"
	flags = NOBLUDGEON
	var/list/modes = list(
		"grey"		= rgb(255,255,255),
		"red"			= rgb(255,0,0),
		"blue"		= rgb(0,0,255),
		"cyan"		= rgb(0,256,249),
		"green"		= rgb(30,255,0),
		"yellow"	= rgb(255,198,0),
		"purple"	= rgb(130,43,255)
	)
	var/mode = "grey"

	materials = list(MAT_METAL=5000, MAT_GLASS=2000)

/obj/item/device/pipe_painter/afterattack(atom/A, mob/user, proximity_flag)
	//Make sure we only paint adjacent items
	if(!proximity_flag)
		return

	if(!istype(A, /obj/machinery/atmospherics/pipe))
		return

	var/obj/machinery/atmospherics/pipe/P = A
	P.add_atom_colour(modes[mode], FIXED_COLOUR_PRIORITY)
	P.pipe_color = modes[mode]
	user.visible_message("<span class='notice'>[user] paints \the [P] [mode].</span>","<span class='notice'>You paint \the [P] [mode].</span>")
	P.update_node_icon() //updates the neighbors

/obj/item/device/pipe_painter/attack_self(mob/user)
	mode = input("Which colour do you want to use?","Pipe painter") in modes

/obj/item/device/pipe_painter/examine()
	..()
	to_chat(usr, "It is set to [mode].")
