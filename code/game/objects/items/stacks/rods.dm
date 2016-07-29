<<<<<<< HEAD
var/global/list/datum/stack_recipe/rod_recipes = list ( \
	new/datum/stack_recipe("grille", /obj/structure/grille, 2, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("table frame", /obj/structure/table_frame, 2, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("scooter frame", /obj/item/scooter_frame, 10, time = 25, one_per_turf = 0), \
	)

/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	item_state = "rods"
	flags = CONDUCT
	w_class = 3
	force = 9
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=1000)
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'

/obj/item/stack/rods/New(var/loc, var/amount=null)
	..()

	recipes = rod_recipes
	update_icon()

/obj/item/stack/rods/update_icon()
	var/amount = get_amount()
	if((amount <= 5) && (amount > 0))
		icon_state = "rods-[amount]"
	else
		icon_state = "rods"

/obj/item/stack/rods/attackby(obj/item/W, mob/user, params)
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(get_amount() < 2)
			user << "<span class='warning'>You need at least two rods to do this!</span>"
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			user.visible_message("[user.name] shaped [src] into metal with the welding tool.", \
						 "<span class='notice'>You shape [src] into metal with the welding tool.</span>", \
						 "<span class='italics'>You hear welding.</span>")
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(new_item)

	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = W
		if(amount != 1)
			user << "<span class='warning'>You must use a single rod!</span>"
		else if(S.w_class > 2)
			user << "<span class='warning'>The ingredient is too big for [src]!</span>"
		else
			var/obj/item/weapon/reagent_containers/food/snacks/customizable/A = new/obj/item/weapon/reagent_containers/food/snacks/customizable/kebab(get_turf(src))
			A.initialize_custom_food(src, S, user)
	else
		return ..()

/obj/item/stack/rods/cyborg/
	materials = list()
	is_cyborg = 1
	cost = 250

/obj/item/stack/rods/cyborg/update_icon()
	return
=======
/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_MEDIUM
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	starting_materials = list(MAT_IRON = 1875)
	max_amount = 60
	attack_verb = list("hits", "bludgeons", "whacks")
	w_type=RECYK_METAL
	melt_temperature = MELTPOINT_STEEL

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
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal)
			M.amount = 1
			M.forceMove(get_turf(usr)) //This is because new() doesn't call forceMove, so we're forcemoving the new sheet to make it stack with other sheets on the ground.
			user.visible_message("<span class='warning'>[src] is shaped into metal by [user.name] with the welding tool.</span>", \
			"<span class='warning'>You shape the [src] into metal with the welding tool.</span>", \
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
				G.healthcheck()
				use(1)
			else
				return 1
	else
		if(amount < 2)
			to_chat(user, "<span class='notice'>You need at least two rods to do this.</span>")
			return

		to_chat(user, "<span class='notice'>Assembling grille...</span>")

		if(!do_after(user, get_turf(src), 10))
			return

		var/obj/structure/grille/Grille = getFromPool(/obj/structure/grille, user.loc)
		if(!Grille)
			Grille = new(user.loc)
		to_chat(user, "<span class='notice'>You assembled a grille!</span>")
		Grille.add_fingerprint(user)
		use(2)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
