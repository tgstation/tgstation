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
				if (M != user)
					O.show_message(text("\red <B>[] is trying to implant [] with [src.name]!</B>", user, M), 1)
				else
					O.show_message("\red <B>[user] is trying to inject themselves with [src.name]!</B>", 1)
			if(!do_mob(user, M,60))
				return
			if(istype(M, /mob/living/carbon/human))
				var/picked = 0
				var/mob/living/carbon/human/T = M
				var/list/datum/organ/external/E = T.GetOrgans()
				while(picked == 0 && E.len > 0)
					var/datum/organ/external/O = pick(E)
					E -= O
					if(!E.implant)
						O.implant = src.imp
						picked = 1
				if(picked == 0)
					for (var/mob/O in viewers(M, null))
						O.show_message(text("[user.name] can't find anywhere to implant [M.name]"), 1)
					return
			for (var/mob/O in viewers(M, null))
				if (M != user)
					O.show_message(text("\red [] implants [] with [src.name]!", user, M), 1)
				else
					O.show_message("\red [user] implants themself with [src.name]!", 1)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'> Implanted with [src.name] ([src.imp.name])  by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] ([src.imp.name]) to implant [M.name] ([M.ckey])</font>")
			log_admin("ATTACK: [user] ([user.ckey]) implanted [M] ([M.ckey]) with [src].")
			message_admins("ATTACK: [user] ([user.ckey]) implanted [M] ([M.ckey]) with [src].")
			src.imp.loc = M
			src.imp.imp_in = M
			src.imp.implanted = 1
			src.imp.implanted(M)
			src.imp = null
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

/obj/item/weapon/implanter/compressed
	name = "implanter-compressed"
	icon_state = "cimplanter0"

	New()
		src.imp = new /obj/item/weapon/implant/compressed( src )
		..()
		update()
		return

	update()
		if (src.imp)
			var/obj/item/weapon/implant/compressed/c = src.imp
			if(!c.scanned)
				src.icon_state = "cimplanter0"
			else
				src.icon_state = "cimplanter1"
		else
			src.icon_state = "cimplanter2"
		return

	attack(mob/M as mob, mob/user as mob)
		var/obj/item/weapon/implant/compressed/c = src.imp
		if (c.scanned == null)
			user << "Please scan an object with the implanter first."
			return
		..()

	afterattack(atom/A, mob/user as mob)
		if(istype(A,/obj/item))
			var/obj/item/weapon/implant/compressed/c = src.imp
			c.scanned = A
			A.loc.contents.Remove(A)
			src.update()