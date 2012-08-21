/**********************Gas extractor**************************/

/obj/machinery/mineral/gasextractor
	name = "Gas extractor"
	desc = "A machine which extracts gasses from ores"
	icon = 'icons/obj/computer.dmi'
	icon_state = "aiupload"
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/message = "";
	var/processing = 0
	var/newtoxins = 0
	density = 1
	anchored = 1.0

/obj/machinery/mineral/gasextractor/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		return
	return

/obj/machinery/mineral/gasextractor/attack_hand(user as mob)

	if(processing == 1)
		user << "The machine is processing"
		return

	var/dat
	dat = text("input connection status: ")
	if (input)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")
	dat += text("<br>output connection status: ")
	if (output)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")

	dat += text("<br><br><A href='?src=\ref[src];extract=[input]'>Extract gas</A>")

	dat += text("<br><br>Message: [message]")

	user << browse("[dat]", "window=purifier")

/obj/machinery/mineral/gasextractor/Topic(href, href_list)
	if(..())
		return

	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["extract"])
		if (src.output)
			if (locate(/obj/machinery/portable_atmospherics/canister,output.loc))
				newtoxins = 0
				processing = 1
				var/obj/item/weapon/ore/O
				while(locate(/obj/item/weapon/ore/plasma, input.loc) && locate(/obj/machinery/portable_atmospherics/canister,output.loc))
					O = locate(/obj/item/weapon/ore/plasma, input.loc)
					if (istype(O,/obj/item/weapon/ore/plasma))
						var/obj/machinery/portable_atmospherics/canister/C
						C = locate(/obj/machinery/portable_atmospherics/canister,output.loc)
						C.air_contents.toxins += 100
						newtoxins += 100
						del(O)
					sleep(5);
				processing = 0;
				message = "Canister filled with [newtoxins] units of toxins"
			else
				message = "No canister found"
	src.updateUsrDialog()
	return
