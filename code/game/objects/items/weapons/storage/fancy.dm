/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Crayon Box
 *		Cigarette Box
 *		Food Box
 *		Chicken Bucket
 *		Slider Box
 */

/obj/item/weapon/storage/fancy/
	icon = 'icons/obj/food.dmi'
	icon_state = "donutbox6"
	name = "donut box"
	var/icon_type = "donut"

	//Note : Fancy storages generally collect one specific type of objects only due to their properties
	//As such, it would make sense that one click on a stack of the corresponding objects should shove everything in here

	allow_quick_gather = 1
	use_to_pickup = 1
	allow_quick_empty = 1

/obj/item/weapon/storage/fancy/update_icon(var/itemremoved = 0)
	var/total_contents = src.contents.len - itemremoved
	src.icon_state = "[src.icon_type]box[total_contents]"
	return

/obj/item/weapon/storage/fancy/examine(mob/user)
	..()
	if(contents.len <= 0)
		user << "<span class='info'>There are no [src.icon_type]s left in the box.</span>"
	else if(contents.len == 1)
		user << "<span class='info'>There is one [src.icon_type] left in the box.</span>"
	else
		user << "<span class='info'>There are [src.contents.len] [src.icon_type]s in the box.</span>"


/*
 * Donut Box
 */

/obj/item/weapon/storage/fancy/donut_box
	icon = 'icons/obj/food.dmi'
	icon_state = "donutbox6"
	icon_type = "donut"
	name = "donut box"
	storage_slots = 6
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/donut")

	foldable = /obj/item/stack/sheet/cardboard

/obj/item/weapon/storage/fancy/donut_box/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/weapon/reagent_containers/food/snacks/donut/normal(src)
	return

/*
 * Egg Box
 */

/obj/item/weapon/storage/fancy/egg_box
	icon = 'icons/obj/food.dmi'
	icon_state = "eggbox"
	icon_type = "egg"
	name = "egg box"
	storage_slots = 12
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/egg")

	foldable = /obj/item/stack/sheet/cardboard

/obj/item/weapon/storage/fancy/egg_box/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/weapon/reagent_containers/food/snacks/egg(src)
	return

/*
 * Candle Box
 */

/obj/item/weapon/storage/fancy/candle_box
	name = "Candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	icon_type = "candle"
	item_state = "candlebox5"
	foldable = /obj/item/stack/sheet/cardboard
	storage_slots = 5
	throwforce = 2
	flags = 0
	slot_flags = SLOT_BELT
	var/empty = 0

/obj/item/weapon/storage/fancy/candle_box/empty
	empty = 1
	icon_state = "candlebox0"
	item_state = "candlebox0" //i don't know what this does but it seems like this should go here

/obj/item/weapon/storage/fancy/candle_box/New()
	..()
	if (empty) return
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/candle(src)
	return

/*
 * Crayon Box
 */

/obj/item/weapon/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	foldable = /obj/item/stack/sheet/cardboard
	w_class = 2.0
	storage_slots = 6
	icon_type = "crayon"
	var/empty = 0
	can_hold = list(
		"/obj/item/toy/crayon"
	)

/obj/item/weapon/storage/fancy/crayons/empty
	empty = 1

/obj/item/weapon/storage/fancy/crayons/New()
	..()
	if (empty) return
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	update_icon()

/obj/item/weapon/storage/fancy/crayons/update_icon()
	overlays = list() //resets list
	overlays += image('icons/obj/crayons.dmi',"crayonbox")
	for(var/obj/item/toy/crayon/crayon in contents)
		overlays += image('icons/obj/crayons.dmi',crayon.colourName)

/obj/item/weapon/storage/fancy/crayons/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/toy/crayon))
		switch(W:colourName)
			if("mime")
				usr << "This crayon is too sad to be contained in this box."
				return
			if("rainbow")
				usr << "This crayon is too powerful to be contained in this box."
				return
	..()

////////////
//CIG PACK//
////////////
/obj/item/weapon/storage/fancy/cigarettes
	name = "cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	w_class = 1
	throwforce = 2
	flags = 0
	slot_flags = SLOT_BELT
	storage_slots = 6
	can_hold = list("=/obj/item/clothing/mask/cigarette", "/obj/item/weapon/lighter", "/obj/item/weapon/storage/box/matches") // Strict type check.
	icon_type = "cigarette"

/obj/item/weapon/storage/fancy/cigarettes/New()
	..()
	flags |= NOREACT
	for(var/i = 1 to storage_slots)
		new /obj/item/clothing/mask/cigarette(src)
	create_reagents(15 * storage_slots)//so people can inject cigarettes without opening a packet, now with being able to inject the whole one

/obj/item/weapon/storage/fancy/cigarettes/Destroy()
	del(reagents)
	..()


/obj/item/weapon/storage/fancy/cigarettes/update_icon()
	icon_state = "[initial(icon_state)][contents.len]"
	desc = "There are [contents.len] cig\s left!"
	return

/obj/item/weapon/storage/fancy/cigarettes/remove_from_storage(obj/item/W as obj, atom/new_location)
	var/obj/item/clothing/mask/cigarette/C = W
	if(!istype(C)) return // what
	reagents.trans_to(C, (reagents.total_volume/contents.len))
	..()

/obj/item/weapon/storage/fancy/cigarettes/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if(M == user && user.zone_sel.selecting == "mouth" && contents.len > 0 && !user.wear_mask)
		var/obj/item/clothing/mask/cigarette/W = new /obj/item/clothing/mask/cigarette(user)
		reagents.trans_to(W, (reagents.total_volume/contents.len))
		user.equip_to_slot_if_possible(W, slot_wear_mask)
		reagents.maximum_volume = 15 * contents.len
		contents.len--
		user << "<span class='notice'>You take a cigarette out of the pack.</span>"
		update_icon()
	else
		..()

/obj/item/weapon/storage/fancy/cigarettes/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "Dpacket"
	item_state = "Dpacket"


/*
 * Vial Box
 */

/obj/item/weapon/storage/fancy/vials
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox6"
	icon_type = "vial"
	name = "vial storage box"
	storage_slots = 6
	can_hold = list("/obj/item/weapon/reagent_containers/glass/beaker/vial")


/obj/item/weapon/storage/fancy/vials/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/weapon/reagent_containers/glass/beaker/vial(src)
	return

//I know vial storage is just above, but it really shouldn't be there
//Furthermore, this can lead to confusion with fancy items now having quick gather and quick empty
/obj/item/weapon/storage/lockbox/vials
	name = "secure vial storage box"
	desc = "A locked box for keeping things away from children."
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox0"
	item_state = "syringe_kit"
	max_w_class = 3
	can_hold = list("/obj/item/weapon/reagent_containers/glass/beaker/vial")
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 6
	req_access = list(access_virology)

/obj/item/weapon/storage/lockbox/vials/New()
	..()
	update_icon()

/obj/item/weapon/storage/lockbox/vials/update_icon(var/itemremoved = 0)
	var/total_contents = src.contents.len - itemremoved
	src.icon_state = "vialbox[total_contents]"
	src.overlays.len = 0
	if (!broken)
		overlays += image(icon, src, "led[locked]")
		if(locked)
			overlays += image(icon, src, "cover")
	else
		overlays += image(icon, src, "ledb")
	return

/obj/item/weapon/storage/lockbox/vials/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	update_icon()

//FLARE BOX
//Useful for lots of things, this box has 6 flares in it. Only takes unused and unlight flares.
//Great for emergency crates/closets etc.

/obj/item/weapon/storage/fancy/flares
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flarebox6"
	icon_type = "flare"
	name = "box of flares"
	storage_slots = 6
	m_amt = 15000
	can_hold = list("/obj/item/device/flashlight/flare")

	foldable = /obj/item/stack/sheet/cardboard

/obj/item/weapon/storage/fancy/flares/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/device/flashlight/flare(src)
	return

/obj/item/weapon/storage/fancy/flares/attackby(var/obj/item/device/flashlight/flare/F, var/user as mob) //if it's on or empty, we don't want it
	if(!istype(F))
		return
	if(F.on)
		user <<"You can't put a lit flare in the box!"
		return
	if(!F.fuel)
		user <<"This flare is empty!"
		return
	..()

/obj/item/weapon/storage/fancy/flares/update_icon()
	..()
	m_amt = contents.len * 2500

/obj/item/weapon/storage/fancy/food_box/chicken_bucket
	name = "chicken bucket"
	desc = "Now we're doing it!"
	icon_state = "kfc_drumsticks"
	item_state = "kfc_bucket"
	icon_type = "drumsticks"
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/chicken_drumstick")

/obj/item/weapon/storage/fancy/food_box/chicken_bucket/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chicken_drumstick(src)
	return

/obj/item/weapon/storage/fancy/food_box/chicken_bucket/remove_from_storage(obj/item/W as obj, atom/new_location)
	..()
	if(!contents.len)
		new/obj/item/trash/chicken_bucket(get_turf(src.loc))
		if(istype(src.loc,/mob/living/carbon))
			var/mob/living/carbon/C = src.loc
			C.u_equip(src)
		qdel(src)

/obj/item/weapon/storage/fancy/food_box/chicken_bucket/update_icon(var/itemremoved = 0)
	return

/obj/item/weapon/storage/fancy/food_box
	name = "food box"
	desc = "Holds food."
	icon = 'icons/obj/food.dmi'
	icon_state = "slider_box"
	storage_slots = 6
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks")

/obj/item/weapon/storage/fancy/food_box/update_icon(var/itemremoved = 0) //this is so that your box doesn't turn into a donut box, see line 29
	return

//SLIDER BOXES

/obj/item/weapon/storage/fancy/food_box/slider_box
	name = "slider box"
	desc = "I wonder what's inside."
	icon_type = "slider"
	storage_slots = 4
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/slider")
	var/slider_type = /obj/item/weapon/reagent_containers/food/snacks/slider//set this as the spawn path of your slider

/obj/item/weapon/storage/fancy/food_box/slider_box/New()
	..()
	for(var/i=1, i <= storage_slots; i++)
		new slider_type(src)

/obj/item/weapon/storage/fancy/food_box/slider_box/synth
	name = "synth slider box"
	slider_type = /obj/item/weapon/reagent_containers/food/snacks/slider/synth

/obj/item/weapon/storage/fancy/food_box/slider_box/xeno
	name = "xeno slider box"
	slider_type = /obj/item/weapon/reagent_containers/food/snacks/slider/xeno

/obj/item/weapon/storage/fancy/food_box/slider_box/chicken
	name = "chicken slider box"
	slider_type = /obj/item/weapon/reagent_containers/food/snacks/slider/chicken

/obj/item/weapon/storage/fancy/food_box/slider_box/carp
	name = "carp slider box"
	slider_type = /obj/item/weapon/reagent_containers/food/snacks/slider/carp

/obj/item/weapon/storage/fancy/food_box/slider_box/spider
	name = "spidey slidey box"
	slider_type = /obj/item/weapon/reagent_containers/food/snacks/slider/carp/spider

/obj/item/weapon/storage/fancy/food_box/slider_box/clown
	name = "honky slider box"
	slider_type = /obj/item/weapon/reagent_containers/food/snacks/slider/clown

/obj/item/weapon/storage/fancy/food_box/slider_box/mime
	name = "quiet slider box"
	slider_type = /obj/item/weapon/reagent_containers/food/snacks/slider/mime

/obj/item/weapon/storage/fancy/food_box/slider_box/slippery
	name = "slippery slider box"
	slider_type = /obj/item/weapon/reagent_containers/food/snacks/slider/slippery
	storage_slots = 2

//SLIDER BOXES END