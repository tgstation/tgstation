//Bot Construction

//Cleanbot assembly
/obj/item/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/created_name = "Cleanbot"

/obj/item/bucket_sensor/attackby(obj/item/W, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/bodypart/l_arm/robot) || istype(W, /obj/item/bodypart/r_arm/robot))
		if(!user.temporarilyRemoveItemFromInventory(W))
			return
		qdel(W)
		var/turf/T = get_turf(loc)
		var/mob/living/simple_animal/bot/cleanbot/A = new /mob/living/simple_animal/bot/cleanbot(T)
		A.name = created_name
		to_chat(user, "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>")
		qdel(src)

	else if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t

//Edbot Assembly

/obj/item/ed209_assembly
	name = "\improper ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = ""

/obj/item/ed209_assembly/attackby(obj/item/W, mob/user, params)
	..()

	if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
		return

	switch(build_step)
		if(0,1)
			if(istype(W, /obj/item/bodypart/l_leg/robot) || istype(W, /obj/item/bodypart/r_leg/robot))
				if(!user.temporarilyRemoveItemFromInventory(W))
					return
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the robot leg to [src].</span>")
				name = "legs/frame assembly"
				if(build_step == 1)
					item_state = "ed209_leg"
					icon_state = "ed209_leg"
				else
					item_state = "ed209_legs"
					icon_state = "ed209_legs"

		if(2)
			var/newcolor = ""
			if(istype(W, /obj/item/clothing/suit/redtag))
				newcolor = "r"
			else if(istype(W, /obj/item/clothing/suit/bluetag))
				newcolor = "b"
			if(newcolor || istype(W, /obj/item/clothing/suit/armor/vest))
				if(!user.temporarilyRemoveItemFromInventory(W))
					return
				lasercolor = newcolor
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the armor to [src].</span>")
				name = "vest/legs/frame assembly"
				item_state = "[lasercolor]ed209_shell"
				icon_state = "[lasercolor]ed209_shell"

		if(3)
			if(istype(W, /obj/item/weldingtool))
				var/obj/item/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					build_step++
					name = "shielded frame assembly"
					to_chat(user, "<span class='notice'>You weld the vest to [src].</span>")
		if(4)
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/clothing/head/helmet/bluetaghelm))
						return

				if("r")
					if(!istype(W, /obj/item/clothing/head/helmet/redtaghelm))
						return

				if("")
					if(!istype(W, /obj/item/clothing/head/helmet))
						return

			if(!user.temporarilyRemoveItemFromInventory(W))
				return
			qdel(W)
			build_step++
			to_chat(user, "<span class='notice'>You add the helmet to [src].</span>")
			name = "covered and shielded frame assembly"
			item_state = "[lasercolor]ed209_hat"
			icon_state = "[lasercolor]ed209_hat"

		if(5)
			if(isprox(W))
				if(!user.temporarilyRemoveItemFromInventory(W))
					return
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the prox sensor to [src].</span>")
				name = "covered, shielded and sensored frame assembly"
				item_state = "[lasercolor]ed209_prox"
				icon_state = "[lasercolor]ed209_prox"

		if(6)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.get_amount() < 1)
					to_chat(user, "<span class='warning'>You need one length of cable to wire the ED-209!</span>")
					return
				to_chat(user, "<span class='notice'>You start to wire [src]...</span>")
				if(do_after(user, 40, target = src))
					if(coil.get_amount() >= 1 && build_step == 6)
						coil.use(1)
						build_step = 7
						to_chat(user, "<span class='notice'>You wire the ED-209 assembly.</span>")
						name = "wired ED-209 assembly"

		if(7)
			var/newname = ""
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/gun/energy/laser/bluetag))
						return
					newname = "bluetag ED-209 assembly"
				if("r")
					if(!istype(W, /obj/item/gun/energy/laser/redtag))
						return
					newname = "redtag ED-209 assembly"
				if("")
					if(!istype(W, /obj/item/gun/energy/e_gun/advtaser))
						return
					newname = "taser ED-209 assembly"
				else
					return
			if(!user.temporarilyRemoveItemFromInventory(W))
				return
			name = newname
			build_step++
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			item_state = "[lasercolor]ed209_taser"
			icon_state = "[lasercolor]ed209_taser"
			qdel(W)

		if(8)
			if(istype(W, /obj/item/screwdriver))
				playsound(loc, W.usesound, 100, 1)
				to_chat(user, "<span class='notice'>You start attaching the gun to the frame...</span>")
				if(do_after(user, 40*W.toolspeed, 0, src, 1))
					build_step++
					name = "armed [name]"
					to_chat(user, "<span class='notice'>Taser gun attached.</span>")

		if(9)
			if(istype(W, /obj/item/stock_parts/cell))
				if(!user.temporarilyRemoveItemFromInventory(W))
					return
				build_step++
				to_chat(user, "<span class='notice'>You complete the ED-209.</span>")
				var/turf/T = get_turf(src)
				new /mob/living/simple_animal/bot/ed209(T,created_name,lasercolor)
				qdel(W)
				qdel(src)

//Floorbot assemblies
/obj/item/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3
	throwforce = 10
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/created_name = "Floorbot"

/obj/item/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3
	throwforce = 10
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/created_name = "Floorbot"

/obj/item/storage/toolbox/mechanical/attackby(obj/item/stack/tile/plasteel/T, mob/user, params)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		..()
		return
	if(contents.len >= 1)
		to_chat(user, "<span class='warning'>They won't fit in, as there is already stuff inside!</span>")
		return
	if(T.use(10))
		if(user.s_active)
			user.s_active.close(user)
		var/obj/item/toolbox_tiles/B = new /obj/item/toolbox_tiles
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>")
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You need 10 floor tiles to start building a floorbot!</span>")
		return

/obj/item/toolbox_tiles/attackby(obj/item/W, mob/user, params)
	..()
	if(isprox(W))
		qdel(W)
		var/obj/item/toolbox_tiles_sensor/B = new /obj/item/toolbox_tiles_sensor()
		B.created_name = created_name
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the sensor to the toolbox and tiles.</span>")
		qdel(src)

	else if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return

		created_name = t

/obj/item/toolbox_tiles_sensor/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/bodypart/l_arm/robot) || istype(W, /obj/item/bodypart/r_arm/robot))
		qdel(W)
		var/turf/T = get_turf(user.loc)
		var/mob/living/simple_animal/bot/floorbot/A = new /mob/living/simple_animal/bot/floorbot(T)
		A.name = created_name
		to_chat(user, "<span class='notice'>You add the robot arm to the odd looking toolbox assembly. Boop beep!</span>")
		qdel(src)
	else if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return

		created_name = t

//Medbot Assembly
/obj/item/firstaid_arm_assembly
	name = "incomplete medibot assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "firstaid_arm"
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	w_class = WEIGHT_CLASS_NORMAL

	/obj/item/firstaid_arm_assembly/New()
		..()
		spawn(5)
			if(skin)
				add_overlay("kit_skin_[skin]")

/obj/item/storage/firstaid/attackby(obj/item/bodypart/S, mob/user, params)

	if((!istype(S, /obj/item/bodypart/l_arm/robot)) && (!istype(S, /obj/item/bodypart/r_arm/robot)))
		return ..()

	//Making a medibot!
	if(contents.len >= 1)
		to_chat(user, "<span class='warning'>You need to empty [src] out first!</span>")
		return

	var/obj/item/firstaid_arm_assembly/A = new /obj/item/firstaid_arm_assembly
	if(istype(src, /obj/item/storage/firstaid/fire))
		A.skin = "ointment"
	else if(istype(src, /obj/item/storage/firstaid/toxin))
		A.skin = "tox"
	else if(istype(src, /obj/item/storage/firstaid/o2))
		A.skin = "o2"
	else if(istype(src, /obj/item/storage/firstaid/brute))
		A.skin = "brute"

	qdel(S)
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>You add the robot arm to the first aid kit.</span>")
	qdel(src)


/obj/item/firstaid_arm_assembly/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
	else
		switch(build_step)
			if(0)
				if(istype(W, /obj/item/device/healthanalyzer))
					if(!user.temporarilyRemoveItemFromInventory(W))
						return
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the health sensor to [src].</span>")
					name = "First aid/robot arm/health analyzer assembly"
					add_overlay("na_scanner")

			if(1)
				if(isprox(W))
					if(!user.temporarilyRemoveItemFromInventory(W))
						return
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You complete the Medibot. Beep boop!</span>")
					var/turf/T = get_turf(src)
					var/mob/living/simple_animal/bot/medbot/S = new /mob/living/simple_animal/bot/medbot(T, skin)
					S.name = created_name
					qdel(src)

//Secbot Assembly
/obj/item/secbot_assembly
	name = "incomplete securitron assembly"
	desc = "Some sort of bizarre assembly made from a proximity sensor, helmet, and signaler."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess

/obj/item/clothing/head/helmet/attackby(obj/item/device/assembly/signaler/S, mob/user, params)
	..()
	if(!issignaler(S))
		..()
		return

	if(type != /obj/item/clothing/head/helmet/sec) //Eh, but we don't want people making secbots out of space helmets.
		return

	if(F) //Has a flashlight. Player must remove it, else it will be lost forever.
		to_chat(user, "<span class='warning'>The mounted flashlight is in the way, remove it first!</span>")
		return

	if(S.secured)
		qdel(S)
		var/obj/item/secbot_assembly/A = new /obj/item/secbot_assembly
		user.put_in_hands(A)
		to_chat(user, "<span class='notice'>You add the signaler to the helmet.</span>")
		qdel(src)
	else
		return

/obj/item/secbot_assembly/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/weldingtool))
		if(!build_step)
			var/obj/item/weldingtool/WT = I
			if(WT.remove_fuel(0, user))
				build_step++
				add_overlay("hs_hole")
				to_chat(user, "<span class='notice'>You weld a hole in [src]!</span>")
		else if(build_step == 1)
			var/obj/item/weldingtool/WT = I
			if(WT.remove_fuel(0, user))
				build_step--
				cut_overlay("hs_hole")
				to_chat(user, "<span class='notice'>You weld the hole in [src] shut!</span>")

	else if(isprox(I) && (build_step == 1))
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You add the prox sensor to [src]!</span>")
		add_overlay("hs_eye")
		name = "helmet/signaler/prox sensor assembly"
		qdel(I)

	else if(((istype(I, /obj/item/bodypart/l_arm/robot)) || (istype(I, /obj/item/bodypart/r_arm/robot))) && (build_step == 2))
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You add the robot arm to [src]!</span>")
		name = "helmet/signaler/prox sensor/robot arm assembly"
		add_overlay("hs_arm")
		qdel(I)

	else if((istype(I, /obj/item/melee/baton)) && (build_step >= 3))
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You complete the Securitron! Beep boop.</span>")
		var/mob/living/simple_animal/bot/secbot/S = new /mob/living/simple_animal/bot/secbot(get_turf(src))
		S.name = created_name
		S.baton_type = I.type
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t

	else if(istype(I, /obj/item/screwdriver))
		if(!build_step)
			new /obj/item/device/assembly/signaler(get_turf(src))
			new /obj/item/clothing/head/helmet/sec(get_turf(src))
			to_chat(user, "<span class='notice'>You disconnect the signaler from the helmet.</span>")
			qdel(src)

		else if(build_step == 2)
			cut_overlay("hs_eye")
			new /obj/item/device/assembly/prox_sensor(get_turf(src))
			to_chat(user, "<span class='notice'>You detach the proximity sensor from [src].</span>")
			build_step--

		else if(build_step == 3)
			cut_overlay("hs_arm")
			new /obj/item/bodypart/l_arm/robot(get_turf(src))
			to_chat(user, "<span class='notice'>You remove the robot arm from [src].</span>")
			build_step--
