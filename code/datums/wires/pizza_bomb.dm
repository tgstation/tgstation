
/datum/wires/pizza_bomb
	random = 1
	holder_type = /obj/item/device/pizza_bomb
	wire_count = 4

var/const/PIZZA_WIRE_DISARM = 1		// No boom


/datum/wires/pizza_bomb/UpdatePulsed(index)
	var/obj/item/device/pizza_bomb/P = holder
	switch(index)
		if(PIZZA_WIRE_DISARM)
			var/was_primed = P.primed
			P.disarm()
			if(was_primed)
				spawn(100) //Rearm after a short time
					if(P)
						P.arm()
		else
			if(!P.disarmed)
				message_admins("a pizza bomb at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[P.loc.x];Y=[P.loc.y];Z=[P.loc.z]'>(JMP)</a> armed by [key_name_admin(P.armer)] has exploded via wire pulsing.")
				log_game("a pizza bomb ([P.loc.x],[P.loc.y],[P.loc.z]) armed by [key_name(P.armer)] has exploded via wire pulsing.")
				P.go_boom()


/datum/wires/pizza_bomb/UpdateCut(index,mended)
	var/obj/item/device/pizza_bomb/P = holder
	switch(index)
		if(PIZZA_WIRE_DISARM)
			if(mended)
				P.disarmed = 0
			else
				P.disarm()
		else
			if(!mended && !P.disarmed)
				message_admins("a pizza bomb at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[P.loc.x];Y=[P.loc.y];Z=[P.loc.z]'>(JMP)</a> armed by [key_name_admin(P.armer)] has exploded via wire pulsing.")
				log_game("a pizza bomb ([P.loc.x],[P.loc.y],[P.loc.z]) armed by [key_name(P.armer)] has exploded via wire pulsing.")
				P.go_boom()


/datum/wires/pizza_bomb/GetInteractWindow()
	. = ..()
	var/obj/item/device/pizza_bomb/P = holder
	. += text("<br>The red light is [P.primed ? "on" : "off"].<br>")
	. += text("The green light is [P.disarmed ? "on": "off"].<br>")
