/obj/item/weapon/implanter
	name = "implanter"
	icon = 'items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	var
		obj/item/weapon/implant/imp = null
	proc
		update()


	update()
		if (src.imp)
			src.icon_state = "implanter1"
		else
			src.icon_state = "implanter0"
		return


	attack(mob/M as mob, mob/user as mob)
		if (!istype(M, /mob/living/carbon))
			return
		if (user && src.imp)
			for (var/mob/O in viewers(M, null))
				O.show_message("\red [M] has been implanted by [user].", 1)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'> Implanted with [src.name] ([src.imp.name])  by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] ([src.imp.name]) to implant [M.name] ([M.ckey])</font>")
			log_attack("<font color='red'>[user.name] ([user.ckey]) implanted [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

			src.imp.loc = M
			src.imp.imp_in = M
			src.imp.implanted = 1
			src.imp.implanted(M)
			src.imp = null
			user.show_message("\red You implanted the implant into [M].")
			src.icon_state = "implanter0"
		return



/obj/item/weapon/implanter/loyalty
	name = "implanter-loyalty"

	New()
		src.imp = new /obj/item/weapon/implant/loyalty( src )
		..()
		update()
		return



/obj/item/weapon/implanter/explosive
	name = "implanter-explosive"

	New()
		src.imp = new /obj/item/weapon/implant/explosive( src )
		..()
		update()
		return