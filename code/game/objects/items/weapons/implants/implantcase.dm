<<<<<<< HEAD
/obj/item/weapon/implantcase
	name = "implant case"
	desc = "A glass case containing an implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 2
	throw_range = 5
	w_class = 1
	origin_tech = "materials=1;biotech=2"
	materials = list(MAT_GLASS=500)
	var/obj/item/weapon/implant/imp = null


/obj/item/weapon/implantcase/update_icon()
	if(imp)
		icon_state = "implantcase-[imp.item_color]"
		origin_tech = imp.origin_tech
		reagents = imp.reagents
	else
		icon_state = "implantcase-0"
		origin_tech = initial(origin_tech)
		reagents = null


/obj/item/weapon/implantcase/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "What would you like the label to be?", name, null)
		if(user.get_active_hand() != W)
			return
		if(!in_range(src, user) && loc != user)
			return
		if(t)
			name = "implant case - '[t]'"
		else
			name = "implant case"
	else if(istype(W, /obj/item/weapon/implanter))
		var/obj/item/weapon/implanter/I = W
		if(I.imp)
			if(imp || I.imp.implanted)
				return
			I.imp.loc = src
			imp = I.imp
			I.imp = null
			update_icon()
			I.update_icon()
		else
			if(imp)
				if(I.imp)
					return
				imp.loc = I
				I.imp = imp
				imp = null
				update_icon()
			I.update_icon()

	else
		return ..()

/obj/item/weapon/implantcase/New()
	..()
	update_icon()


/obj/item/weapon/implantcase/tracking
	name = "implant case - 'Tracking'"
	desc = "A glass case containing a tracking implant."

/obj/item/weapon/implantcase/tracking/New()
	imp = new /obj/item/weapon/implant/tracking(src)
	..()


/obj/item/weapon/implantcase/weapons_auth
	name = "implant case - 'Firearms Authentication'"
	desc = "A glass case containing a firearms authentication implant."

/obj/item/weapon/implantcase/weapons_auth/New()
	imp = new /obj/item/weapon/implant/weapons_auth(src)
	..()

/obj/item/weapon/implantcase/adrenaline
	name = "implant case - 'Adrenaline'"
	desc = "A glass case containing an adrenaline implant."

/obj/item/weapon/implantcase/adrenaline/New()
	imp = new /obj/item/weapon/implant/adrenalin(src)
	..()
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/implantcase
	name = "Glass Case"
	desc = "A case containing an implant."
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/obj/item/weapon/implant/imp = null
	proc
		update()


	update()
		if (src.imp)
			src.icon_state = text("implantcase-[]", src.imp._color)
		else
			src.icon_state = "implantcase-0"
		return


	attackby(obj/item/weapon/I as obj, mob/user as mob)
		..()
		if (istype(I, /obj/item/weapon/pen))
			var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
			if (user.get_active_hand() != I)
				return
			if (!Adjacent(user) || user.stat)
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if(t)
				src.name = text("Glass Case- '[]'", t)
			else
				src.name = "Glass Case"
		else if(istype(I, /obj/item/weapon/reagent_containers/syringe))
			if(!src.imp)	return
			if(!src.imp.allow_reagents)	return
			if(src.imp.reagents.total_volume >= src.imp.reagents.maximum_volume)
				to_chat(user, "<span class='warning'>[src] is full.</span>")
			else
				spawn(5)
					I.reagents.trans_to(src.imp, 5)
					to_chat(user, "<span class='notice'>You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units.</span>")
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
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"


	New()
		src.imp = new /obj/item/weapon/implant/tracking( src )
		..()
		return



/obj/item/weapon/implantcase/explosive
	name = "Glass Case- 'Explosive'"
	desc = "A case containing an explosive implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"


	New()
		src.imp = new /obj/item/weapon/implant/explosive( src )
		..()
		return



/obj/item/weapon/implantcase/chem
	name = "Glass Case- 'Chem'"
	desc = "A case containing a chemical implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"
/obj/item/weapon/implantcase/chem/New()

	src.imp = new /obj/item/weapon/implant/chem( src )
	..()
	return


/obj/item/weapon/implantcase/loyalty
	name = "Glass Case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"


	New()
		src.imp = new /obj/item/weapon/implant/loyalty( src )
		..()
		return


/obj/item/weapon/implantcase/death_alarm
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

	New()
		src.imp = new /obj/item/weapon/implant/death_alarm( src )
		..()
		return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
