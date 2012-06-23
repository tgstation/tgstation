//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/implantcase
	name = "Glass Case"
	desc = "A case containing an implant."
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/obj/item/weapon/implant/imp = null
	proc
		update()


	update()
		if (src.imp)
			src.icon_state = text("implantcase-[]", src.imp.color)
		else
			src.icon_state = "implantcase-0"
		return


	attackby(obj/item/weapon/I as obj, mob/user as mob)
		..()
		if (istype(I, /obj/item/weapon/pen))
			var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
			if (user.get_active_hand() != I)
				return
			if((!in_range(src, usr) && src.loc != user))
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if(t)
				src.name = text("Glass Case- '[]'", t)
			else
				src.name = "Glass Case"
		else if(istype(I, /obj/item/weapon/reagent_containers/syringe))
			if(!src.imp)	return
			if(!src.imp.allow_reagents)	return
			if(src.imp.reagents.total_volume >= 10)
				user << "\red [src] is full."
			else
				spawn(5)
					I.reagents.trans_to(src.imp, 5)
					user << "\blue You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units."
		else if (istype(I, /obj/item/weapon/implanter))
			if (I:imp)
				if ((src.imp || I:imp.implanted))
					return
				I:imp.loc = src
				src.imp = I:imp
				I:imp = null
				src.update()
				I:update()
			else
				if (src.imp)
					if (I:imp)
						return
					src.imp.loc = I
					I:imp = src.imp
					src.imp = null
					update()
				I:update()
		return



/obj/item/weapon/implantcase/tracking
	name = "Glass Case- 'Tracking'"
	desc = "A case containing a tracking implant."
	icon = 'items.dmi'
	icon_state = "implantcase-b"


	New()
		src.imp = new /obj/item/weapon/implant/tracking( src )
		..()
		return



/obj/item/weapon/implantcase/explosive
	name = "Glass Case- 'Explosive'"
	desc = "A case containing an explosive implant."
	icon = 'items.dmi'
	icon_state = "implantcase-r"


	New()
		src.imp = new /obj/item/weapon/implant/explosive( src )
		..()
		return



/obj/item/weapon/implantcase/chem
	name = "Glass Case- 'Chem'"
	desc = "A case containing a chemical implant."
	icon = 'items.dmi'
	icon_state = "implantcase-b"
/obj/item/weapon/implantcase/chem/New()

	src.imp = new /obj/item/weapon/implant/chem( src )
	..()
	return


/obj/item/weapon/implantcase/loyalty
	name = "Glass Case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	icon = 'items.dmi'
	icon_state = "implantcase-r"


	New()
		src.imp = new /obj/item/weapon/implant/loyalty( src )
		..()
		return
