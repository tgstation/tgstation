/obj/machinery/computer/mechpad
	name = "mecha orbital pad console"
	desc = "Sends mechs through space to space. Why would you do that?"
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	ui_x = 475
	ui_y = 260

	var/selected_id
	var/obj/machinery/mechpad/connected_mechpad
	var/list/obj/machinery/mechpad/mechpads = list()
	var/maximum_pads = 3

/obj/machinery/computer/mechpad/Initialize(mapload)
	. = ..()
	if(mapload)
		connected_mechpad = connect_to_pad()
		for(var/obj/machinery/mechpad/pad in world)
			if(pad == connected_mechpad)
				continue
			mechpads |= pad
			if(LAZYLEN(mechpads) < maximum_pads)
				break



/obj/machinery/computer/mechpad/proc/connect_to_pad()
	if(connected_mechpad)
		return
	for(var/direction in GLOB.cardinals)
		connected_mechpad = locate(/obj/machinery/mechpad, get_step(src, direction))
		if(connected_mechpad)
			break
	return connected_mechpad

/obj/machinery/computer/mechpad/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/mechpad))
			if(LAZYLEN(mechpads) < maximum_pads)
				if(M.buffer == connected_mechpad)
					to_chat(user, "<span class='warning'>[src] cannot connect to its own mechpad!</span>")
				else if(!connected_mechpad && M.buffer == connect_to_pad())
					connected_mechpad = connect_to_pad()
					M.buffer = null
					to_chat(user, "<span class='notice'>You connect the console to the pad with data from the [W.name]'s buffer.</span>")
				else
					mechpads |= M.buffer
					M.buffer = null
					to_chat(user, "<span class='notice'>You upload the data from the [W.name]'s buffer.</span>")
			else
				to_chat(user, "<span class='warning'>[src] cannot handle any more connections!</span>")
	else
		return ..()

/obj/machinery/computer/mechpad/attack_hand(mob/living/user)
	. = ..()
	if(locate(/obj/mecha) in get_turf(connected_mechpad))
		connected_mechpad.launch(pick(mechpads))
