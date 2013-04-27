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
	flags = FPRINT | TABLEPASS

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/weapon/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag0"
	item_state = "trashbag"

	w_class = 4
	max_w_class = 2
	storage_slots = 21
	can_hold = list() // any
	cant_hold = list("/obj/item/weapon/disk/nuclear")


/obj/item/weapon/storage/bag/trash/update_icon()
	if(contents.len == 0)
		icon_state = "trashbag0"
	else if(contents.len < 12)
		icon_state = "trashbag1"
	else if(contents.len < 21)
		icon_state = "trashbag2"
	else icon_state = "trashbag3"

// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/weapon/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	slot_flags = SLOT_BELT | SLOT_POCKET
	w_class = 3
	storage_slots = 50
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	max_w_class = 3
	can_hold = list("/obj/item/weapon/ore")


// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/weapon/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "plantbag"
	storage_slots = 50; //the number of plant pieces it can carry.
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	max_w_class = 3
	w_class = 1
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/grown","/obj/item/seeds","/obj/item/weapon/grown")

////////

/obj/item/weapon/storage/bag/plants/portaseeder
	name = "portable seed extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	icon_state = "portaseeder"

	verb/dissolve_contents()
		set name = "Activate Seed Extraction"
		set category = "Object"
		set desc = "Activate to convert your plants into plantable seeds."
		for(var/obj/item/O in contents)
			seedify(O, 1)
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)


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
	w_class = 3

	allow_quick_empty = 1 // this function is superceded
	New()
		..()
		//verbs -= /obj/item/weapon/storage/verb/quick_empty
		//verbs += /obj/item/weapon/storage/bag/sheetsnatcher/quick_empty

	can_be_inserted(obj/item/W as obj, stop_messages = 0)
		if(!istype(W,/obj/item/stack/sheet) || istype(W,/obj/item/stack/sheet/mineral/sandstone) || istype(W,/obj/item/stack/sheet/wood))
			if(!stop_messages)
				usr << "The snatcher does not accept [W]."
			return 0 //I don't care, but the existing code rejects them for not being "sheets" *shrug* -Sayu
		var/current = 0
		for(var/obj/item/stack/sheet/S in contents)
			current += S.amount
		if(capacity == current)//If it's full, you're done
			if(!stop_messages)
				usr << "\red The snatcher is full."
			return 0
		return 1


// Modified handle_item_insertion.  Would prefer not to, but...
	handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
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
			usr.u_equip(S)
			if (usr.client && usr.s_active != src)
				usr.client.screen -= S
			S.dropped(usr)
			if(!S.amount)
				del S
			else
				S.loc = src

		orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)
		update_icon()
		return 1


// Sets up numbered display to show the stack size of each stored mineral
// NOTE: numbered display is turned off currently because it's broken
	orient2hud(mob/user as mob)
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
	quick_empty()
		var/location = get_turf(src)
		for(var/obj/item/stack/sheet/S in contents)
			while(S.amount)
				var/obj/item/stack/sheet/N = new S.type(location)
				var/stacksize = min(S.amount,N.max_amount)
				N.amount = stacksize
				S.amount -= stacksize
			if(!S.amount)
				del S // todo: there's probably something missing here
		orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)
		update_icon()

// Instead of removing
	remove_from_storage(obj/item/W as obj, atom/new_location)
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