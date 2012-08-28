/obj/item/weapon/handcuffs/attack(mob/M as mob, mob/user as mob)
	if(istype(src, /obj/item/weapon/handcuffs/cyborg) && isrobot(user))
		if(!M.handcuffed)
			var/turf/p_loc = user.loc
			var/turf/p_loc_m = M.loc
			playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
			for(var/mob/O in viewers(user, null))
				O.show_message("\red <B>[user] is trying to put handcuffs on [M]!</B>", 1)
			spawn(30)
				if(!M)	return
				if(p_loc == user.loc && p_loc_m == M.loc)
					M.handcuffed = new /obj/item/weapon/handcuffs(M)
					M.update_inv_handcuffed()

	else
		if ((CLUMSY in usr.mutations) && prob(50))
			usr << "\red Uh ... how do those things work?!"
			if (istype(M, /mob/living/carbon/human))
				if(!M.handcuffed)
					var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
					O.source = user
					O.target = user
					O.item = user.get_active_hand()
					O.s_loc = user.loc
					O.t_loc = user.loc
					O.place = "handcuff"
					M.requests += O
					spawn( 0 )
						O.process()
				return
			return
		if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
			usr << "\red You don't have the dexterity to do this!"
			return
		if (istype(M, /mob/living/carbon/human))
			if(!M.handcuffed)
				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been handcuffed (attempt) by [user.name] ([user.ckey])</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to handcuff [M.name] ([M.ckey])</font>")

				log_attack("<font color='red'>[user.name] ([user.ckey]) Attempted to handcuff [M.name] ([M.ckey])</font>")

				var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
				O.source = user
				O.target = M
				O.item = user.get_active_hand()
				O.s_loc = user.loc
				O.t_loc = M.loc
				O.place = "handcuff"
				M.requests += O
				spawn( 0 )
					if(istype(src, /obj/item/weapon/handcuffs/cable))
						feedback_add_details("handcuffs","C")
						playsound(src.loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
					else
						feedback_add_details("handcuffs","H")
						playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
					O.process()
			return
		else
			if(!M.handcuffed)
				var/obj/effect/equip_e/monkey/O = new /obj/effect/equip_e/monkey(  )
				O.source = user
				O.target = M
				O.item = user.get_active_hand()
				O.s_loc = user.loc
				O.t_loc = M.loc
				O.place = "handcuff"
				M.requests += O
				spawn( 0 )
					if(istype(src, /obj/item/weapon/handcuffs/cable))
						playsound(src.loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
					else
						playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
					O.process()
			return
	return