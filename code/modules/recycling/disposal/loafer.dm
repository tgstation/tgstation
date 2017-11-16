/obj/item/reagent_containers/food/snacks/prison_loaf
	name = "prison loaf"
	desc = "A rather slapdash loaf designed to feed prisoners.  Technically nutritionally complete and edible in the same sense that potted meat product is edible."
	icon = 'goon/icons/obj/loafing_it_up.dmi'
	icon_state = "ploaf0"
	force = 0
	throwforce = 0
	volume = 1000
	list_reagents = list("nutriment" = 3, "flour" = 2, "corn_starch" = 10, "mayonnaise" = 10, "mushroomhallucinogen" = 3, "synthflesh" = 10)
	var/loaf_factor = 1
	var/loaf_recursion = 1

/obj/item/reagent_containers/food/snacks/prison_loaf/proc/loafing_it_up()
	var/orderOfLoafitude = max( 0, min( round( log(8, loaf_factor)), 10 ) )
	w_class = min(orderOfLoafitude+1, 4)
	switch(orderOfLoafitude)
		if (1)
			name = "prison loaf"
			desc = "A rather slapdash loaf designed to feed prisoners.  Technically nutritionally complete and edible in the same sense that potted meat product is edible."
			icon_state = "ploaf0"
			force = 0
			throwforce = 0

		if (2)
			name = "dense prison loaf"
			desc = "The chef must be really packing a lot of junk into these things today."
			icon_state = "ploaf0"
			force = 3
			throwforce = 3
			reagents.add_reagent("vitamin",25)

		if (3)
			name = "extra dense prison loaf"
			desc = "Good lord, this thing feels almost like a brick. A brick made of kitchen scraps and god knows what else."
			icon_state = "ploaf0"
			force = 6
			throwforce = 6
			reagents.add_reagent("liquidgibs",25)

		if (4)
			name = "super-compressed prison loaf"
			desc = "Hard enough to scratch a diamond, yet still somehow edible, this loaf seems to be emitting decay heat. Dear god."
			icon_state = "ploaf1"
			force = 11
			throwforce = 11
			throw_range = 6
			reagents.add_reagent("clf3",25)

		if (5)
			name = "fissile loaf"
			desc = "There's so much junk packed into this loaf, the flavor atoms are starting to go fissile. This might make a decent engine fuel, but it definitely wouldn't be good for you to eat."
			icon_state = "ploaf2"
			force = 22
			throwforce = 22
			throw_range = 5
			reagents.add_reagent("uranium",25)

		if (6)
			name = "fusion loaf"
			desc = "Forget fission, the flavor atoms in this loaf are so densely packed now that they are undergoing atomic fusion. What terrifying new flavor atoms might lurk within?"
			icon_state = "ploaf3"
			force = 44
			throwforce = 44
			throw_range = 4
			reagents.add_reagent("radium",25)

		if (7)
			name = "neutron loaf"
			desc = "Oh good, the flavor atoms in this prison loaf have collapsed down to a a solid lump of neutrons."
			icon_state = "ploaf4"
			force = 66
			throwforce = 66
			throw_range = 3
			reagents.add_reagent("polonium",25)

		if(8)
			name = "quark loaf"
			desc = "This nutritional loaf is collapsing into subatomic flavor particles. It is unfathmomably heavy."
			icon_state = "ploaf5"
			force = 88
			throwforce = 88
			throw_range = 2
			reagents.add_reagent("bluespace",25)

		if(9)
			name = "degenerate loaf"
			desc = "You should probably call a physicist."
			icon_state = "ploaf6"
			force = 110
			throwforce = 110
			throw_range = 1
			reagents.add_reagent("bluespace",50)

		if(10)
			name = "strangelet loaf"
			desc = "You should probably call a priest."
			icon_state = "ploaf7"
			force = 220
			throwforce = 220
			throw_range = 0
			reagents.add_reagent("bluespace",100)
			START_PROCESSING(SSobj, src) // good job, pro loaf science

/obj/item/reagent_containers/food/snacks/prison_loaf/process()
	..()
	if(get_turf(loc))
		var/edge = get_edge_target_turf(src, pick(GLOB.diagonals))
		throw_at(edge, 100, 1)

/obj/item/reagent_containers/food/snacks/prison_loaf/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/disposalpipe/loafer
	name = "disciplinary loaf processor"
	desc = "A pipe segment designed to convert detritus into a nutritionally-complete meal for inmates."
	icon = 'goon/icons/obj/loafing_around_town.dmi'
	icon_state = "pipe-loaf0"

/obj/structure/disposalpipe/loafer/transfer_to_dir(obj/structure/disposalholder/H, nextdir)
	icon_state = "pipe-loaf1"
	playsound(src.loc, "sound/machines/juicer.ogg", 50, 1)
	var/obj/item/reagent_containers/food/snacks/prison_loaf/newLoaf = new(src)
	for(var/atom/movable/A in H)
		if(A.reagents)
			A.reagents.trans_to(newLoaf, 1000)
		if(istype(A, /obj/item/reagent_containers/food/snacks/prison_loaf))
			var/obj/item/reagent_containers/food/snacks/prison_loaf/otherLoaf = A
			newLoaf.loaf_factor += otherLoaf.loaf_factor * 1.2
			newLoaf.loaf_recursion = otherLoaf.loaf_recursion + 1
		if(istype(A, /mob/living))
			var/mob/living/poorSoul = A
			if (issilicon(poorSoul))
				newLoaf.reagents.add_reagent("oil",10)
				newLoaf.reagents.add_reagent("silicon",10)
				newLoaf.reagents.add_reagent("iron",10)
			else
				newLoaf.reagents.add_reagent("blood",10)
				newLoaf.reagents.add_reagent("liquidgibs",10)

			if(ishuman(poorSoul))
				newLoaf.loaf_factor += (newLoaf.loaf_factor / 5) + 50
			else
				newLoaf.loaf_factor += (newLoaf.loaf_factor / 10) + 50
			poorSoul.emote("scream")
		if(istype(A, /obj/item))
			var/obj/item/I = A
			newLoaf.loaf_factor += I.w_class * 5
		else
			newLoaf.loaf_factor++
		qdel(A)
	newLoaf.forceMove(H)
	newLoaf.loafing_it_up()
	sleep(30)
	icon_state = "pipe-loaf0"
	. = ..()