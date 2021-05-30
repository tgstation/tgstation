/obj/structure/trash_pile
	name = "trash pile"
	desc = "A heap of garbage, but maybe there's something interesting inside?"
	icon = 'icons/obj/trash_piles.dmi'
	icon_state = "randompile"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	obj_flags = CAN_BE_HIT
	pass_flags = LETPASSTHROW

	max_integrity = 50

	var/hide_item_time = 15

	var/list/searchedby	= list()// Characters that have searched this trashpile, with values of searched time.

/obj/structure/trash_pile/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	icon_state = pick(
		"pile1",
		"pile2",
		"pilechair",
		"piletable",
		"pilevending",
		"brtrashpile",
		"microwavepile",
		"rackpile",
		"boxfort",
		"trashbag",
		"brokecomp",
	)

/obj/structure/trash_pile/proc/do_search(mob/user)
	if(contents.len) //There's something hidden
		var/atom/A = contents[contents.len] //Get the most recent hidden thing
		if (istype(A, /obj/item))
			var/obj/item/I = A
			to_chat(user,"<span class='notice'>You found something!</span>")
			I.forceMove(src.loc)
	else
		//You already searched this one bruh
		if(user.ckey in searchedby)
			to_chat(user,"<span class='warning'>There's nothing else for you in \the [src]!</span>")
		//You found an item!
		else
			produce_item()
			to_chat(user,"<span class='notice'>You found something!</span>")
			searchedby += user.ckey

/obj/structure/trash_pile/attack_hand(mob/user)
	//Human mob
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.visible_message("[user] searches through \the [src].","<span class='notice'>You search through \the [src].</span>")
		//Do the searching
		if(do_after(user,rand(4 SECONDS,6 SECONDS),target=src))
			if(src.loc) //Let's check if the pile still exists
				do_search(user)
	else
		return ..()

//Random lists
/obj/structure/trash_pile/proc/produce_item()
	var/lootspawn = pickweight(GLOB.maintenance_loot)
	while(islist(lootspawn))
		lootspawn = pickweight(lootspawn)
	var/obj/item/I = new lootspawn(get_turf(src))
	return I

/obj/structure/trash_pile/proc/can_hide_item(obj/item/I)
	if(contents.len > 10)
		return FALSE
	return TRUE

/obj/structure/trash_pile/attackby(obj/item/I, mob/living/user, params)
	if(!user.combat_mode)
		if(can_hide_item(I))
			to_chat(user,"<span class='notice'>You begin to stealthily hide [I] in the [src].</span>")
			if(do_mob(user, user, hide_item_time))
				if(src.loc)
					if(user.transferItemToLoc(I, src))
						to_chat(user,"<span class='notice'>You hide [I] in the trash.</span>")
					else
						to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in the trash!</span>")
		else
			to_chat(user,"<span class='warning'>The [src] is way too full to fit [I].</span>")
		return

	. = ..()

/obj/structure/trash_pile/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(src.loc)
	return ..()

/obj/structure/trash_pile/container_resist_act(mob/user)
	user.forceMove(src.loc)

/obj/structure/trash_pile/relaymove(mob/user)
	container_resist_act(user)
