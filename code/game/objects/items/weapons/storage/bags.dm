/*
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	Contains:
 *		Trash Bag
 *		Mining Satchel
 *		Plant Bag
 *		Sheet Snatcher
 *		Book Bag
 *      Biowaste Bag
 *
 *	-Sayu
 */

//  Generic non-item
/obj/item/weapon/storage/bag
	allow_quick_gather = 1
	allow_quick_empty = 1
	display_contents_with_number = 1 // should work fine now
	use_to_pickup = 1
	slot_flags = SLOT_BELT

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/weapon/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag"
	item_state = "trashbag"

	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 30
	storage_slots = 30
	can_hold = list() // any
	cant_hold = list(/obj/item/weapon/disk/nuclear)

/obj/item/weapon/storage/bag/trash/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] puts [src] over [user.p_their()] head and starts chomping at the insides! Disgusting!</span>")
	playsound(loc, 'sound/items/eatfood.ogg', 50, 1, -1)
	return (TOXLOSS)

/obj/item/weapon/storage/bag/trash/update_icon()
	if(contents.len == 0)
		icon_state = "[initial(icon_state)]"
	else if(contents.len < 12)
		icon_state = "[initial(icon_state)]1"
	else if(contents.len < 21)
		icon_state = "[initial(icon_state)]2"
	else icon_state = "[initial(icon_state)]3"

/obj/item/weapon/storage/bag/trash/cyborg

/obj/item/weapon/storage/bag/trash/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	J.put_in_cart(src, user)
	J.mybag=src
	J.update_icon()

/obj/item/weapon/storage/bag/trash/cyborg/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	return

/obj/item/weapon/storage/bag/trash/bluespace
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	origin_tech = "materials=4;bluespace=4;engineering=4;plasmatech=3"
	max_combined_w_class = 60
	storage_slots = 60

// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/weapon/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	origin_tech = "engineering=2"
	slot_flags = SLOT_BELT | SLOT_POCKET
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 50
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/weapon/ore)

/obj/item/weapon/storage/bag/ore/cyborg
	name = "cyborg mining satchel"

/obj/item/weapon/storage/bag/ore/holding //miners, your messiah has arrived
	name = "mining satchel of holding"
	desc = "A revolution in convenience, this satchel allows for huge amounts of ore storage. It's been outfitted with anti-malfunction safety measures."
	storage_slots = INFINITY
	max_combined_w_class = INFINITY
	origin_tech = "bluespace=4;materials=3;engineering=3"
	icon_state = "satchel_bspace"

// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/weapon/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	storage_slots = 100; //the number of plant pieces it can carry.
	max_combined_w_class = 100 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/grown, /obj/item/seeds, /obj/item/weapon/grown, /obj/item/weapon/reagent_containers/honeycomb)
	resistance_flags = FLAMMABLE

////////

/obj/item/weapon/storage/bag/plants/portaseeder
	name = "portable seed extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	icon_state = "portaseeder"
	origin_tech = "biotech=3;engineering=2"

/obj/item/weapon/storage/bag/plants/portaseeder/verb/dissolve_contents()
	set name = "Activate Seed Extraction"
	set category = "Object"
	set desc = "Activate to convert your plants into plantable seeds."
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	for(var/obj/item/O in contents)
		seedify(O, 1)
	close_all()


// -----------------------------
//        Sheet Snatcher
// -----------------------------
// Because it stacks stacks, this doesn't operate normally.
// However, making it a storage/bag allows us to reuse existing code in some places. -Sayu

/obj/item/weapon/storage/bag/sheetsnatcher
	name = "sheet snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"

	var/capacity = 300; //the number of sheets it can carry.
	w_class = WEIGHT_CLASS_NORMAL

	allow_quick_empty = 1 // this function is superceded

/obj/item/weapon/storage/bag/sheetsnatcher/can_be_inserted(obj/item/W, stop_messages = 0)
	if(!istype(W, /obj/item/stack/sheet) || istype(W, /obj/item/stack/sheet/mineral/sandstone) || istype(W, /obj/item/stack/sheet/mineral/wood))
		if(!stop_messages)
			to_chat(usr, "The snatcher does not accept [W].")
		return 0 //I don't care, but the existing code rejects them for not being "sheets" *shrug* -Sayu
	var/current = 0
	for(var/obj/item/stack/sheet/S in contents)
		current += S.amount
	if(capacity == current)//If it's full, you're done
		if(!stop_messages)
			to_chat(usr, "<span class='danger'>The snatcher is full.</span>")
		return 0
	return 1


// Modified handle_item_insertion.  Would prefer not to, but...
/obj/item/weapon/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/W, prevent_warning = 0)
	var/obj/item/stack/sheet/S = W
	if(!istype(S)) return 0

	var/amount
	var/inserted = 0
	var/current = 0
	for(var/obj/item/stack/sheet/S2 in contents)
		current += S2.amount
	if(capacity < current + S.amount)//If the stack will fill it up
		amount = capacity - current
	else
		amount = S.amount

	for(var/obj/item/stack/sheet/sheet in contents)
		if(S.type == sheet.type) // we are violating the amount limitation because these are not sane objects
			sheet.amount += amount	// they should only be removed through procs in this file, which split them up.
			S.amount -= amount
			inserted = 1
			break

	if(!inserted || !S.amount)
		usr.dropItemToGround(S)
		if (usr.client && usr.s_active != src)
			usr.client.screen -= S
		S.dropped(usr)
		if(!S.amount)
			qdel(S)
		else
			if(S.pulledby)
				S.pulledby.stop_pulling()
			S.loc = src

	orient2hud(usr)
	if(usr.s_active)
		usr.s_active.show_to(usr)
	update_icon()
	return 1


// Sets up numbered display to show the stack size of each stored mineral
// NOTE: numbered display is turned off currently because it's broken
/obj/item/weapon/storage/bag/sheetsnatcher/orient2hud(mob/user)
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/stack/sheet/I in contents)
			adjusted_contents++
			var/datum/numbered_display/D = new/datum/numbered_display(I)
			D.number = I.amount
			numbered_contents.Add( D )

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	src.standard_orient_objs(row_num, col_count, numbered_contents)
	return


// Modified quick_empty verb drops appropriate sized stacks
/obj/item/weapon/storage/bag/sheetsnatcher/quick_empty()
	var/location = get_turf(src)
	for(var/obj/item/stack/sheet/S in contents)
		while(S.amount)
			var/obj/item/stack/sheet/N = new S.type(location)
			var/stacksize = min(S.amount,N.max_amount)
			N.amount = stacksize
			S.amount -= stacksize
		if(!S.amount)
			qdel(S)// todo: there's probably something missing here
	orient2hud(usr)
	if(usr.s_active)
		usr.s_active.show_to(usr)
	update_icon()

// Instead of removing
/obj/item/weapon/storage/bag/sheetsnatcher/remove_from_storage(obj/item/W, atom/new_location)
	var/obj/item/stack/sheet/S = W
	if(!istype(S)) return 0

	//I would prefer to drop a new stack, but the item/attack_hand code
	// that calls this can't recieve a different object than you clicked on.
	//Therefore, make a new stack internally that has the remainder.
	// -Sayu

	if(S.amount > S.max_amount)
		var/obj/item/stack/sheet/temp = new S.type(src)
		temp.amount = S.amount - S.max_amount
		S.amount = S.max_amount

	return ..(S,new_location)

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/weapon/storage/bag/sheetsnatcher/borg
	name = "sheet snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization


// -----------------------------
//           Book bag
// -----------------------------

/obj/item/weapon/storage/bag/books
	name = "book bag"
	desc = "A bag for books."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	display_contents_with_number = 0 //This would look really stupid otherwise
	storage_slots = 7
	max_combined_w_class = 21
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_BULKY //Bigger than a book because physics
	can_hold = list(/obj/item/weapon/book, /obj/item/weapon/storage/book, /obj/item/weapon/spellbook)
	resistance_flags = FLAMMABLE

/*
 * Trays - Agouri
 */
/obj/item/weapon/storage/bag/tray
	name = "tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	force = 5
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	materials = list(MAT_METAL=3000)
	preposition = "on"

/obj/item/weapon/storage/bag/tray/attack(mob/living/M, mob/living/user)
	..()
	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	quick_empty()

	// Make each item scatter a bit
	for(var/obj/item/I in oldContents)
		spawn()
			for(var/i = 1, i <= rand(1,2), i++)
				if(I)
					step(I, pick(NORTH,SOUTH,EAST,WEST))
					sleep(rand(2,4))

	if(prob(50))
		playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
	else
		playsound(M, 'sound/items/trayhit2.ogg', 50, 1)

	if(ishuman(M) || ismonkey(M))
		if(prob(10))
			M.Knockdown(40)

/obj/item/weapon/storage/bag/tray/proc/rebuild_overlays()
	cut_overlays()
	for(var/obj/item/I in contents)
		add_overlay(mutable_appearance(I.icon, I.icon_state))

/obj/item/weapon/storage/bag/tray/remove_from_storage(obj/item/W as obj, atom/new_location)
	..()
	rebuild_overlays()

/obj/item/weapon/storage/bag/tray/handle_item_insertion(obj/item/I, prevent_warning = 0)
	add_overlay(mutable_appearance(I.icon, I.icon_state))
	. = ..()


/*
 *	Chemistry bag
 */

/obj/item/weapon/storage/bag/chemistry
	name = "chemistry bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bag"
	desc = "A bag for storing pills, patches, and bottles."
	storage_slots = 50
	max_combined_w_class = 200
	w_class = WEIGHT_CLASS_TINY
	preposition = "in"
	can_hold = list(/obj/item/weapon/reagent_containers/pill, /obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle)
	resistance_flags = FLAMMABLE

/*
 *  Biowaste bag (mostly for xenobiologists)
 */

/obj/item/weapon/storage/bag/bio
	name = "bio bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "biobag"
	desc = "A bag for the safe transportation and disposal of biowaste and other biological materials."
	storage_slots = 25
	max_combined_w_class = 200
	w_class = WEIGHT_CLASS_TINY
	preposition = "in"
	can_hold = list(/obj/item/slime_extract, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle, /obj/item/weapon/reagent_containers/blood, /obj/item/weapon/reagent_containers/hypospray/medipen, /obj/item/trash/deadmouse, /obj/item/weapon/reagent_containers/food/snacks/monkeycube)
	resistance_flags = FLAMMABLE
