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
	starting_materials = list(MAT_IRON = 1875)
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")
	w_type=RECYK_METAL
	melt_temperature = MELTPOINT_STEEL

/obj/item/stack/rods/recycle(var/datum/materials/rec)
	rec.addAmount("iron",amount/2)
	return RECYK_METAL

/obj/item/stack/rods/afterattack(atom/Target, mob/user, adjacent, params)
	var/busy = 0
	if(adjacent)
		if(isturf(Target) || istype(Target, /obj/structure/lattice))
			var/turf/T = get_turf(Target)
			var/obj/item/stack/rods/R = src
			var/obj/structure/lattice/L = T.canBuildCatwalk(R)
			if(istype(L))
				if(R.amount < 2)
					to_chat(user, "<span class='warning'>You need atleast 2 rods to build a catwalk!</span>")
					return
				if(busy) //We are already building a catwalk, avoids stacking catwalks
					return
				to_chat(user, "<span class='notice'>You begin to build a catwalk.</span>")
				busy = 1
				if(do_after(user, Target, 30))
					busy = 0
					if(R.amount < 2)
						to_chat(user, "<span class='warning'>You ran out of rods!</span>")
						return
					if(!istype(L) || L.loc != T)
						to_chat(user, "<span class='warning'>You need a lattice first!</span>")
						return
					playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You build a catwalk!</span>")
					R.use(2)
					new /obj/structure/catwalk(T)
					qdel(L)
					return

			if(T.canBuildLattice(R))
				to_chat(user, "<span class='notice'>Constructing support lattice ...</span>")
				playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
				new /obj/structure/lattice(T)
				R.use(1)
				return

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W

		if(amount < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to do this.</span>")
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
			if(G.broken)
				G.health = initial(G.health)
				G.density = 1
				G.broken = 0
				G.icon_state = "[initial(G.icon_state)]"
				use(1)
			else
				return 1
	else
		if(amount < 2)
			to_chat(user, "<span class='notice'>You need at least two rods to do this.</span>")
			return

		to_chat(user, "<span class='notice'>Assembling grille...</span>")

		if(!do_after(user, src, 10))
			return

		var/obj/structure/grille/Grille = getFromPool(/obj/structure/grille, user.loc)
		if(!Grille)
			Grille = new(user.loc)
		to_chat(user, "<span class='notice'>You assembled a grille!</span>")
		Grille.add_fingerprint(user)
		use(2)
