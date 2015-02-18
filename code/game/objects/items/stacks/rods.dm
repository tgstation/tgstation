/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags = FPRINT
	siemens_coefficient = 1
	w_class = 3.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	m_amt = 1875
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")
	w_type=RECYK_METAL
	melt_temperature = MELTPOINT_STEEL

/obj/item/stack/rods/recycle(var/datum/materials/rec)
	rec.addAmount("iron",amount/2)
	return RECYK_METAL

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W

		if(amount < 2)
			user << "<span class='warning'>You need at least two rods to do this.</span>"
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
			M.amount = 1
			M.add_to_stacks(usr)
			user.visible_message("<span class='warning'>[src] is shaped into metal by [user.name] with the weldingtool.</span>", \
			"<span class='warning'>You shape the [src] into metal with the weldingtool.</span>", \
			"<span class='warning'>You hear welding.</span>")
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(M)
		return 1
	return ..()


/obj/item/stack/rods/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!istype(user.loc, /turf)) return 0

	if(locate(/obj/structure/grille, user.loc))
		for(var/obj/structure/grille/G in user.loc)
			if(G.destroyed)
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
				use(1)
			else
				return 1
	else
		if(amount < 2)
			user << "<span class='notice'>You need at least two rods to do this.</span>"
			return

		user << "<span class='notice'>Assembling grille...</span>"

		if(!do_after(user, 10))
			return

		var/obj/structure/grille/Grille = getFromPool(/obj/structure/grille, user.loc)
		user << "<span class='notice'>You assembled a grille!</span>"
		if(!Grille)
			Grille = new(user.loc)
		Grille.add_fingerprint(user)
		use(2)
