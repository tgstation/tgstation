/obj/item/clothing/gloves
	var/wired = 0
	var/obj/item/weapon/stock_parts/cell/cell = null

/obj/item/clothing/gloves/attackby(var/obj/item/W as obj, mob/user as mob, params)
	if(istype(src, /obj/item/clothing/gloves/boxing))
		user << "<span class='notice'>That won't work.</span>"
		..()
		return

	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(!wired)
			if(C.amount >= 2)
				C.use(2)
				wired = 1
				user << "<span class='notice'>You wrap some wires around [src].</span>"
				update_icon()
				strip_delay -= 10
			else
				user << "<span class='notice'>There is not enough wire to cover [src].</span>"
		else
			user << "<span class='notice'>[src] are already wired.</span>"

	else if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(!wired)
			user << "<span class='notice'>[src] need to be wired first.</span>"
		else if(!cell)
			user.drop_item()
			W.loc = src
			cell = W
			user << "<span class='notice'>You attach a cell to [src].</span>"
			strip_delay -= 5
			update_icon()
		else
			user << "<span class='notice'>[src] already have a cell.</span>"

	else if(istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/weapon/scalpel))
		if(cell)
			cell.updateicon()
			cell.loc = get_turf(src.loc)
			cell = null
			user << "<span class='notice'>You cut the cell away from [src].</span>"
			strip_delay += 5
			update_icon()
			return
		if(wired)
			wired = 0
			user << "<span class='notice'>You cut the wires away from [src].</span>"
			new /obj/item/stack/cable_coil(get_turf(src), 2)
			strip_delay += 10
			update_icon()
	..()
	return

/obj/item/clothing/gloves/Touch(A, proximity, var/mob/living/carbon/user)
	if(!user)		return 0
	if(!proximity)	return 0
	if(!cell)		return 0
	if(ishuman(A) && user.a_intent == "harm")
		var/mob/living/carbon/human/M = A
		var/stun = 4

		var/use_charge = min(cell.charge, 5000)

		if(cell.use(use_charge))
			stun *= round(use_charge / 5000)
		else
			stun = 0

		if(stun)
			if((M != user) && M.check_shields(0, user.name))
				add_logs(M, user, "attempted to stunglove")
				user.visible_message("<span class='warning'>[user] attempted to touch [M]!</span>")
				return 1
			M.visible_message("<span class='warning'>[A] has been touched with the stun gloves by [user]!</span>",
				"<span class='userdanger'>[A] has been touched with the stun gloves by [user]!</span>")
			add_logs(M, user, "stungloved")
			M.apply_effects(stun,stun,0,0,0,0,0,M.run_armor_check(user.zone_sel.selecting, "energy"))
			if(siemens_coefficient)
				user.Stun(stun*siemens_coefficient)
				user.Weaken(stun*siemens_coefficient)
				user << "<span class='userdanger'>You are stunned by your own stun gloves!</span>"
		else
			user << "<span class='warning'>Not enough charge!</span>"

		return 1
	return 0



/obj/item/clothing/gloves/update_icon()
	..()
	overlays.Cut()
	if(wired)
		overlays += "gloves_wire"
	if(cell)
		overlays += "gloves_cell"