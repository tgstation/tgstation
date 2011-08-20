/obj/machinery/computer/shuttle/attackby(var/obj/item/weapon/card/W as obj, var/mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	if ((!( istype(W, /obj/item/weapon/card) ) || !( ticker ) || emergency_shuttle.location != 1 || !( user )))
		return


	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (istype(W, /obj/item/device/pda))
			var/obj/item/device/pda/pda = W
			W = pda.id
		if (!W:access) //no access
			user << "The access level of [W:registered]\'s card is not high enough. "
			return

		var/list/cardaccess = W:access
		if(!istype(cardaccess, /list) || !cardaccess.len) //no access
			user << "The access level of [W:registered]\'s card is not high enough. "
			return

		if(!(access_heads in W:access)) //doesn't have this access
			user << "The access level of [W:registered]\'s card is not high enough. "
			return 0

		var/choice = alert(user, text("Would you like to (un)authorize a shortened launch time? [] authorization\s are still needed. Use abort to cancel all authorizations.", src.auth_need - src.authorized.len), "Shuttle Launch", "Authorize", "Repeal", "Abort")
		switch(choice)
			if("Authorize")
				src.authorized -= W:registered
				src.authorized += W:registered
				if (src.auth_need - src.authorized.len > 0)
					message_admins("[key_name_admin(user)] has authorized early shuttle launch")
					log_game("[user.ckey] has authorized early shuttle launch")
					world << text("\blue <B>Alert: [] authorizations needed until shuttle is launched early</B>", src.auth_need - src.authorized.len)
				else
					message_admins("[key_name_admin(user)] has launched the shuttle")
					log_game("[user.ckey] has launched the shuttle early")
					world << "\blue <B>Alert: Shuttle launch time shortened to 10 seconds!</B>"
					emergency_shuttle.settimeleft(10)
					//src.authorized = null
					del(src.authorized)
					src.authorized = list(  )

			if("Repeal")
				src.authorized -= W:registered
				world << text("\blue <B>Alert: [] authorizations needed until shuttle is launched early</B>", src.auth_need - src.authorized.len)

			if("Abort")
				world << "\blue <B>All authorizations to shorting time for shuttle launch have been revoked!</B>"
				src.authorized.len = 0
				src.authorized = list(  )

	else if (istype(W, /obj/item/weapon/card/emag))
		var/choice = alert(user, "Would you like to launch the shuttle?","Shuttle control", "Launch", "Cancel")
		switch(choice)
			if("Launch")
				world << "\blue <B>Alert: Shuttle launch time shortened to 10 seconds!</B>"
				emergency_shuttle.settimeleft( 10 )
			if("Cancel")
				return

	return

/*
/obj/shut_controller/proc/rotate(direct)

	var/SE_X = 1
	var/SE_Y = 1
	var/SW_X = 1
	var/SW_Y = 1
	var/NE_X = 1
	var/NE_Y = 1
	var/NW_X = 1
	var/NW_Y = 1
	for(var/obj/move/M in src.parts)
		if (M.x < SW_X)
			SW_X = M.x
		if (M.x > SE_X)
			SE_X = M.x
		if (M.y < SW_Y)
			SW_Y = M.y
		if (M.y > NW_Y)
			NW_Y = M.y
		if (M.y > NE_Y)
			NE_Y = M.y
		if (M.y < SE_Y)
			SE_Y = M.y
		if (M.x > NE_X)
			NE_X = M.x
		if (M.x < NW_X)
			NW_X = M.y
	var/length = abs(NE_X - NW_X)
	var/width = abs(NE_Y - SE_Y)
	var/obj/random = pick(src.parts)
	var/s_direct = null
	switch(s_direct)
		if(1.0)
			switch(direct)
				if(90.0)
					var/tx = SE_X
					var/ty = SE_Y
					var/t_z = random.z
					for(var/obj/move/M in src.parts)
						M.ty =  -M.x - tx
						M.tx =  -M.y - ty
						var/T = locate(M.x, M.y, 11)
						M.relocate(T)
						M.ty =  -M.ty
						M.tx += length
						//Foreach goto(374)
					for(var/obj/move/M in src.parts)
						M.tx += tx
						M.ty += ty
						var/T = locate(M.tx, M.ty, t_z)
						M.relocate(T, 90)
						//Foreach goto(468)
				if(-90.0)
					var/tx = SE_X
					var/ty = SE_Y
					var/t_z = random.z
					for(var/obj/move/M in src.parts)
						M.ty = M.x - tx
						M.tx = M.y - ty
						var/T = locate(M.x, M.y, 11)
						M.relocate(T)
						M.ty =  -M.ty
						M.ty += width
						//Foreach goto(571)
					for(var/obj/move/M in src.parts)
						M.tx += tx
						M.ty += ty
						var/T = locate(M.tx, M.ty, t_z)
						M.relocate(T, -90.0)
						//Foreach goto(663)
				else
		else
	return
*/

/obj/machinery/computer/prison_shuttle/verb/take_off()
	set category = "Object"
	set name = "Launch Prison Shuttle"
	set src in oview(1)

	if (usr.stat || usr.restrained())
		return

	src.add_fingerprint(usr)
	if(!src.allowedtocall)
		usr << "\red The console seems irreparably damaged!"
		return
	if(src.z == 3)
		usr << "\red Already in transit! Please wait!"
		return

	var/A = locate(/area/shuttle/prison/)
	for(var/mob/M in A)
		M.show_message("\red Launch sequence initiated!")
		spawn(0)	shake_camera(M, 10, 1)
	sleep(10)

	if(src.z == 2)	//This is the laziest proc ever
		for(var/atom/movable/AM as mob|obj in A)
			AM.z = 3
			AM.Move()
		sleep(rand(600,1800))
		for(var/atom/movable/AM as mob|obj in A)
			AM.z = 1
			AM.Move()
	else
		for(var/atom/movable/AM as mob|obj in A)
			AM.z = 3
			AM.Move()
		sleep(rand(600,1800))
		for(var/atom/movable/AM as mob|obj in A)
			AM.z = 2
			AM.Move()
	for(var/mob/M in A)
		M.show_message("\red Prison shuttle has arrived at destination!")
		spawn(0)	shake_camera(M, 2, 1)
	return

/obj/machinery/computer/prison_shuttle/verb/restabalize()
	set category = "Object"
	set name = "Restabilize Prison Shuttle"
	set src in oview(1)

	src.add_fingerprint(usr)

	var/A = locate(/area/shuttle/prison/)
	for(var/mob/M in A)
		M.show_message("\red <B>Restabilizing prison shuttle atmosphere!</B>")