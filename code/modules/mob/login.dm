/mob/Login()
	log_access("Login: [key_name(src)] from [src.client.address ? src.client.address : "localhost"]")
	src.lastKnownIP = src.client.address
	src.computer_id = src.client.computer_id
	if (config.log_access)
		for (var/mob/M in world)
			if(M == src)
				continue
			if(M.client && M.client.address == src.client.address)
				log_access("Notice: [key_name(src)] has same IP address as [key_name(M)]")
				message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same IP address as <A href='?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A></font>", 1)
			else if (M.lastKnownIP && M.lastKnownIP == src.client.address && M.ckey != src.ckey && M.key)
				log_access("Notice: [key_name(src)] has same IP address as [key_name(M)] did ([key_name(M)] is no longer logged in).")
				message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same IP address as [key_name_admin(M)] did ([key_name_admin(M)] is no longer logged in).</font>", 1)
			if(M.client && M.client.computer_id == src.client.computer_id)
				log_access("Notice: [key_name(src)] has same computer ID as [key_name(M)]")
				message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same <font color='red'><B>computer ID</B><font color='blue'> as <A href='?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A></font>", 1)
				spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
			else if (M.computer_id && M.computer_id == src.client.computer_id && M.ckey != src.ckey && M.key)
				log_access("Notice: [key_name(src)] has same computer ID as [key_name(M)] did ([key_name(M)] is no longer logged in).")
				message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same <font color='red'><B>computer ID</B><font color='blue'> as [key_name_admin(M)] did ([key_name_admin(M)] is no longer logged in).</font>", 1)
				spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
	if(!src.dna) src.dna = new /datum/dna(null)
	//src.client.screen -= main_hud1.contents
	world.update_status()
	//if (!src.hud_used)
	//	src.hud_used = main_hud1

	if (!src.hud_used)
		src.hud_used = new/obj/hud( src )
	else
		del(src.hud_used)
		src.hud_used = new/obj/hud( src )

	src.next_move = 1
	src.sight |= SEE_SELF
	src.logged_in = 1

	if(istype (src, /mob/living))
		if(ticker)
			if(ticker.mode)
				if(ticker.mode.name == "revolution")
					if ((src.mind in ticker.mode:revolutionaries) || (src.mind in ticker.mode:head_revolutionaries))
						ticker.mode:update_rev_icons_added(src.mind)
				if(ticker.mode.name == "cult")
					if (src.mind in ticker.mode:cult)
						ticker.mode:update_cult_icons_added(src.mind)
		if(isAI(src))
			for(var/obj/effect/rune/rune in world)
				var/image/blood = image('blood.dmi', loc = rune, icon_state = "floor[rand(1,7)]")
				blood.override = 1
				client.images += blood
		..()
