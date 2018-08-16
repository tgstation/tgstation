//Please make sure to:
//return FALSE: You are not going away, stop asking me to digest.
//return non-negative integer: Amount of nutrition/charge gained (scaled to nutrition, other end can multiply for charge scale).

// Ye default implementation.
/obj/item/proc/digest_act(var/atom/movable/item_storage = null)
	for(var/obj/item/O in contents)
		if(istype(O,/obj/item/storage)) //Dump contents from dummy pockets.
			for(var/obj/item/SO in O)
				if(item_storage)
					SO.forceMove(item_storage)
				qdel(O)
		else if(item_storage)
			O.forceMove(item_storage)

	qdel(src)
	return w_class

/////////////
// Some indigestible stuff
/////////////
/obj/item/hand_tele/digest_act(...)
	return FALSE
/obj/item/card/id/digest_act(...)
	return FALSE
/obj/item/aicard/digest_act(...)
	return FALSE
/obj/item/paicard/digest_act(...)
	return FALSE
/obj/item/pinpointer/digest_act(...)
	return FALSE
/obj/item/disk/nuclear/digest_act(...)
	return FALSE
/obj/item/perfect_tele_beacon/digest_act(...)
	return FALSE //Sorta important to not digest your own beacons.
/obj/item/pda/digest_act(...)
	return FALSE
/obj/item/gun/digest_act(...)
	return FALSE
/obj/item/clothing/shoes/magboots/digest_act(...)
	return FALSE
/obj/item/clothing/head/helmet/space/digest_act(...)
	return FALSE
/obj/item/clothing/suit/space/digest_act(...)
	return FALSE
/obj/item/reagent_containers/hypospray/CMO/digest_act(...)
	return FALSE
/obj/item/tank/jetpack/oxygen/captain/digest_act(...)
	return FALSE
/obj/item/clothing/accessory/medal/gold/captain/digest_act(...)
	return FALSE
/obj/item/clothing/suit/armor/digest_act(...)
	return FALSE
/obj/item/documents/digest_act(...)
	return FALSE
/obj/item/nuke_core/digest_act(...)
	return FALSE
/obj/item/nuke_core_container/digest_act(...)
	return FALSE
/obj/item/areaeditor/blueprints/digest_act(...)
	return FALSE
/obj/item/documents/syndicate/digest_act(...)
	return FALSE
/obj/item/bombcore/digest_act(...)
	return FALSE
/obj/item/grenade/digest_act(...)
	return FALSE
/obj/item/storage/digest_act(...)
	return FALSE

/////////////
// Some special treatment
/////////////
/*
//PDAs need to lose their ID to not take it with them, so we can get a digested ID
/obj/item/pda/digest_act(var/atom/movable/item_storage = null)
	if(id)
		id = null

	. = ..()
*/

/obj/item/reagent_containers/food/digest_act(var/atom/movable/item_storage = null)
	if(isbelly(item_storage))
		var/obj/belly/B = item_storage
		if(ishuman(B.owner))
			var/mob/living/carbon/human/H = B.owner
			reagents.trans_to(H, (reagents.total_volume * 0.3), 1, 0)
		else if(iscyborg(B.owner))
			var/mob/living/silicon/robot/R = B.owner
			R.cell.charge += 150

	. = ..()

/*
/obj/item/holder/digest_act(var/atom/movable/item_storage = null)
	for(var/mob/living/M in contents)
		if(item_storage)
			M.forceMove(item_storage)
	held_mob = null

	. = ..() */

/obj/item/organ/digest_act(var/atom/movable/item_storage = null)
	if((. = ..()))
		. += 70 //Organs give a little more

/obj/item/storage/digest_act(var/atom/movable/item_storage = null)
	for(var/obj/item/I in contents)
		I.screen_loc = null

	. = ..()

/////////////
// Some more complicated stuff
/////////////
/obj/item/mmi/digital/posibrain/digest_act(var/atom/movable/item_storage = null)
	//Replace this with a VORE setting so all types of posibrains can/can't be digested on a whim
	return FALSE
