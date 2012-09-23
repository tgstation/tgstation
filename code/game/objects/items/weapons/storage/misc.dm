/*
 * Contains:
 *		Monkey Cube Box
 *		Candle Packs
 *		Snap Pop Box
 *		Crayon Box
 *		Beaker Box
 */

/*
 * Monkey Cube Box
 */

/obj/item/weapon/storage/monkeycube_box
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube")


/obj/item/weapon/storage/monkeycube_box/New()
	..()
	new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src)
	new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src)
	return

/*
 * Snap Pop Box
 */

/obj/item/weapon/storage/snappopbox
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_hold = list("/obj/item/toy/snappop")

/obj/item/weapon/storage/snappopbox/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/toy/snappop(src)

/*
 * Match Box
 */

/obj/item/weapon/storage/matchbox
	name = "Matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	storage_slots = 10
	w_class = 1
	flags = TABLEPASS
	slot_flags = SLOT_BELT


/obj/item/weapon/storage/matchbox/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/weapon/match(src)
	return

/obj/item/weapon/storage/matchbox/attackby(obj/item/weapon/match/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match) && W.lit == 0)
		W.lit = 1
		W.icon_state = "match_lit"
		processing_objects.Add(W)
	W.update_icon()
	return

/*
 * Crayon Box
 */

/obj/item/weapon/storage/crayonbox/New()
	..()
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	update_icon()

/obj/item/weapon/storage/crayonbox/update_icon()
	overlays = list() //resets list
	overlays += image('icons/obj/crayons.dmi',"crayonbox")
	for(var/obj/item/toy/crayon/crayon in contents)
		overlays += image('icons/obj/crayons.dmi',crayon.colourName)

/obj/item/weapon/storage/crayonbox/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/toy/crayon))
		switch(W:colourName)
			if("mime")
				usr << "This crayon is too sad to be contained in this box."
				return
			if("rainbow")
				usr << "This crayon is too powerful to be contained in this box."
				return
	..()

/*
 * Beaker Box
 */
/obj/item/weapon/storage/beakerbox
	name = "Beaker Box"
	icon_state = "beaker"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/beakerbox/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )