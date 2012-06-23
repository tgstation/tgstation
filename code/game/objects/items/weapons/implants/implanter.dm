/obj/item/weapon/implanter
	name = "implanter"
	icon = 'items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	var/obj/item/weapon/implant/imp = null

/obj/item/weapon/implanter/proc/update()


/obj/item/weapon/implanter/update()
	if (imp)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"
	return


/obj/item/weapon/implanter/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob/living/carbon))
		return
	if (user && imp)
		if (M != user)
			user.visible_message("\red \The [user] tries to implant \the [M] with \the [src]!","\red You try to implant \the [M] with \the [src]!")
		else
			user.visible_message("\red \The [user] tries to implant [user.get_gender_form("itself")] with \the [src]!","\red You try to implant yourself with \the [src]!")
		if(!do_mob(user, M,60))
			return
		if(hasorgans(M))
			var/datum/organ/external/target = M:get_organ(check_zone(user.zone_sel.selecting))
			if(target.destroyed)
				user << "What [target.display_name]?"
				return
			target.implant += imp
			imp.loc = target
			if (M != user)
				user.visible_message("\red \The [user] implants \the [M]'s [target.display_name] with \the [src]!","\red You implant \the [M]'s [target.display_name] with \the [src]!")
			else
				user.visible_message("\red \The [user] implants [user.get_gender_form("its")] own [target.display_name] with \the [src]!","\red You implant your [target.display_name] with \the [src]!")
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'> Implanted with [src] ([imp])  by [user] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src] ([imp]) to implant [M] ([M.ckey])</font>")
		log_admin("ATTACK: [user] ([user.ckey]) implanted [M] ([M.ckey]) with [src].")
		message_admins("ATTACK: [user] ([user.ckey]) implanted [M] ([M.ckey]) with [src].")
		log_attack("<font color='red'>[user.name] ([user.ckey]) implanted [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
		imp.imp_in = M
		imp.implanted = 1
		imp.implanted(M)
		imp = null
		icon_state = "implanter0"
	return



/obj/item/weapon/implanter/loyalty
	name = "implanter-loyalty"

/obj/item/weapon/implanter/loyalty/New()
	imp = new /obj/item/weapon/implant/loyalty( src )
	..()
	update()
	return



/obj/item/weapon/implanter/explosive
	name = "implanter (E)"

/obj/item/weapon/implanter/explosive/New()
	imp = new /obj/item/weapon/implant/explosive( src )
	..()
	update()
	return

/obj/item/weapon/implanter/adrenalin
	name = "implanter-adrenalin"

/obj/item/weapon/implanter/adrenalin/New()
	src.imp = new /obj/item/weapon/implant/adrenalin(src)
	..()
	update()
	return

/obj/item/weapon/implanter/compressed
	name = "implanter (C)"
	icon_state = "cimplanter0"

/obj/item/weapon/implanter/compressed/New()
	imp = new /obj/item/weapon/implant/compressed( src )
	..()
	update()
	return

/obj/item/weapon/implanter/compressed/update()
	if (imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if(!c.scanned)
			icon_state = "cimplanter0"
		else
			icon_state = "cimplanter1"
	else
		icon_state = "cimplanter2"
	return

/obj/item/weapon/implanter/compressed/attack(mob/M as mob, mob/user as mob)
	var/obj/item/weapon/implant/compressed/c = imp
	if (c.scanned == null)
		user << "Please scan an object with the implanter first."
		return
	..()

/obj/item/weapon/implanter/compressed/afterattack(atom/A, mob/user as mob)
	if(istype(A,/obj/item))
		var/obj/item/weapon/implant/compressed/c = imp
		c.scanned = A
		A.loc.contents.Remove(A)
		update()
