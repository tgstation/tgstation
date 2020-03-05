/datum/component/storage/concrete/bluespace/bag_of_holding/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/A = parent
	if(A == W)		//don't put yourself into yourself.
		return
	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(W.GetAllContents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= A
	if(istype(W, /obj/item/storage/backpack/holding) || matching.len)
		var/safety = alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [A.name]?", "Proceed", "Abort")
		if(safety != "Proceed" || QDELETED(A) || QDELETED(W) || QDELETED(user) || !user.canUseTopic(A, BE_CLOSE, iscarbon(user)))
			return
		var/turf/loccheck = get_turf(A)
		to_chat(user, "<span class='danger'>The Bluespace interfaces of the two devices catastrophically malfunction!</span>")
		qdel(W)
		playsound(loccheck,'sound/effects/supermatter.ogg', 200, TRUE)

		message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(loccheck)].")
		log_game("[key_name(user)] detonated a bag of holding at [loc_name(loccheck)].")

		qdel(user)
		new/obj/boh_tear(loccheck)
		qdel(A)
		return
	. = ..()

///////////////////////
//Bag Of Holding Tear//
///////////////////////

/obj/boh_tear ///The result of combining two bags of holding
	name = "tear in the fabric of reality"
	desc = "Your own comprehension of reality starts bending as you stare this."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	pixel_x = -32
	pixel_y = -32
	move_resist = INFINITY

/obj/boh_tear/Initialize()
	QDEL_IN(src, 8 SECONDS) // vanishes after 8 seconds
	START_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/boh_tear/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/boh_tear/process()
	var/turf/T = get_turf(src)
	for(var/atom/A in range(T, 4))
		if(istype(A, /turf/open/floor/) && prob(70 - (get_dist(A, src) * 15)))
			var/turf/open/floor/F = A
			if(!F.floor_tile)
				continue
			var/floor_tile = F.floor_tile
			if(!F.make_plating()) //reinforced tiles are about as anchored as a tile could be
				continue
			A = new floor_tile(F)

		if(istype(A, /atom/movable))
			var/atom/movable/move = A
			if(move == src || move.anchored)
				continue
			if(ismob(move))
				var/mob/M = A
				if(M.mob_negates_gravity())
					continue
			move.safe_throw_at(T, 5, 1, force = MOVE_FORCE_EXTREMELY_STRONG)

	for(var/atom/movable/target in T.contents)
		if(target == src || target.anchored || istype(target, /mob/dead/observer))
			continue
		if(ismob(target))
			message_admins("[ADMIN_LOOKUPFLW(target)] has been consumed by the bag of holding tear at [ADMIN_VERBOSEJMP(T)].")
		qdel(target) //Hope you like the Astral plane
