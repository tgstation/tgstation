/obj/item/stack/rods
	name = "iron rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "iron rod"
	icon_state = "rods"
	flags = CONDUCT
	w_class = 3.0
	force = 9.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	m_amt = 1000
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(get_amount() < 2)
			user << "<span class='danger'>You need at least two rods to do this.</span>"
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			new_item.add_to_stacks(usr)
			for (var/mob/M in viewers(src))
				M.show_message("<span class='danger'>[src] is shaped into iron by [user.name] with the weldingtool.</span>", 3, "<span class='danger'>You hear welding.</span>", 2)
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(new_item)
		return
	..()


/obj/item/stack/rods/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if (locate(/obj/structure/grille, usr.loc))
		for(var/obj/structure/grille/G in usr.loc)
			if (G.destroyed)
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
				use(1)
			else
				return 1
	else
		if(get_amount() < 2)
			user << "<span class='notice'>You need at least two rods to do this.</span>"
			return
		usr << "<span class='notice'>Assembling grille...</span>"
		if (!do_after(usr, 10))
			return
		var/obj/structure/grille/F = new /obj/structure/grille/ ( usr.loc )
		usr << "<span class='notice'>You assemble a grille.</span>"
		F.add_fingerprint(usr)
		use(2)
	return

/obj/item/stack/rods/cyborg/
	m_amt = 0
	is_cyborg = 1
	cost = 250