/obj/machinery/computer/shuttle
	name = "Shuttle"
	desc = "For shuttle control."
	icon_state = "shuttle"
	var/auth_need = 3.0
	var/list/authorized = list(  )


	attackby(var/obj/item/weapon/card/W as obj, var/mob/user as mob)
		if(stat & (BROKEN|NOPOWER))	return
		if ((!( istype(W, /obj/item/weapon/card) ) || !( ticker ) || emergency_shuttle.location != 1 || !( user )))	return
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

/*		else if (istype(W, /obj/item/weapon/card/emag))
			var/choice = alert(user, "Would you like to launch the shuttle?","Shuttle control", "Launch", "Cancel")
			switch(choice)
				if("Launch")
					world << "\blue <B>Alert: Shuttle launch time shortened to 10 seconds!</B>"
					emergency_shuttle.settimeleft( 10 )
				if("Cancel")
					return*/
		return
