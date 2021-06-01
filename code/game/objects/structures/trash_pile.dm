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
	
/// Characters that have searched this trashpile, with values of searched time.
	var/list/searchedby	= list()

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
///Releases stored item or produces maint loot if user hasn't already searched it.
/obj/structure/trash_pile/proc/do_search(mob/user)
	//We can only find one item at a time, so we prioritize things that were already hidden in the pile.
	if(contents.len) //There's something hidden
		var/atom/stash = contents[contents.len] //Get the most recent hidden thing
		if (istype(stash, /obj/item))
			var/obj/item/item = stash
			to_chat(user,"<span class='notice'>You found something!</span>")
			item.forceMove(src.loc)
	else
		//Each pile only generates an item once per user, so we return.
		if(user.ckey in searchedby)
			to_chat(user,"<span class='warning'>There's nothing else for you in \the [src]!</span>")
			return ..()
	//Nothing else was in the pile, so we generate a new maintloot and blacklist the user from this pile.
	else
		produce_item()
		to_chat(user,"<span class='notice'>You found something!</span>")
		searchedby += user.ckey

/obj/structure/trash_pile/attack_hand(mob/user)
	//Human mobs only, no borgs allowed.
	if(!ishuman(user))
		return ..()
	else
		var/mob/living/carbon/human/mob = user
		mob.visible_message("[user] searches through \the [src].","<span class='notice'>You search through \the [src].</span>")
		//Do the searching
		if(do_after(user,rand(4 SECONDS,6 SECONDS),target=src))
			if(src.loc) //Let's check if the pile still exists
				do_search(user)

///When a user finds a random item, we pick from maint loot lists and spawn something.
/obj/structure/trash_pile/proc/produce_item()
	var/lootspawn = pickweight(GLOB.maintenance_loot)
	while(islist(lootspawn))
		lootspawn = pickweight(lootspawn)
	var/obj/item/item = new lootspawn(get_turf(src))
	return item

///You can't hide more than 10 items in a trash pile.
/obj/structure/trash_pile/proc/can_hide_item(obj/item/item)
	if(contents.len > 10)
		return FALSE
	return TRUE
	
///Hitting the trash pile with an item in combat mode bashes it, otherwise hide the item.
/obj/structure/trash_pile/attackby(obj/item/item, mob/living/user, params)
	if(!user.combat_mode)
		if(!can_hide_item(item))
			to_chat(user,"<span class='warning'>The [src] is way too full to fit [item].</span>")
			return
		else
			to_chat(user,"<span class='notice'>You begin to stealthily hide [item] in the [src].</span>")
			if(do_mob(user, user, hide_item_time))
				if(src.loc)
					if(user.transferItemToLoc(item, src))
						to_chat(user,"<span class='notice'>You hide [item] in the trash.</span>")
					else
						to_chat(user, "<span class='warning'>\The [item] is stuck to your hand, you cannot put it in the trash!</span>")

	. = ..()

/obj/structure/trash_pile/Destroy()
	for(var/atom/movable/atom in src)
		atom.forceMove(src.loc)
	return ..()

/obj/structure/trash_pile/container_resist_act(mob/user)
	user.forceMove(src.loc)

/obj/structure/trash_pile/relaymove(mob/user)
	container_resist_act(user)
