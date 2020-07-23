/*
 * Photo album
 */
/obj/item/storage/photo_album
	name = "photo album"
	desc = "A big book used to store photos and mementos."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "album"
	inhand_icon_state = "album"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	var/persistence_id

/obj/item/storage/photo_album/Initialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.set_holdable(list(/obj/item/photo))
	STR.max_combined_w_class = 42
	STR.max_items = 21
	LAZYADD(SSpersistence.photo_albums, src)

/obj/item/storage/photo_album/Destroy()
	LAZYREMOVE(SSpersistence.photo_albums, src)
	return ..()

/obj/item/storage/photo_album/proc/get_picture_id_list()
	var/list/L = list()
	for(var/i in contents)
		if(istype(i, /obj/item/photo))
			L += i
	if(!L.len)
		return
	. = list()
	for(var/i in L)
		var/obj/item/photo/P = i
		if(!istype(P.picture))
			continue
		. |= P.picture.id

//Manual loading, DO NOT USE FOR HARDCODED/MAPPED IN ALBUMS. This is for if an album needs to be loaded mid-round from an ID.
/obj/item/storage/photo_album/proc/persistence_load()
	var/list/data = SSpersistence.GetPhotoAlbums()
	if(data[persistence_id])
		populate_from_id_list(data[persistence_id])

/obj/item/storage/photo_album/proc/populate_from_id_list(list/ids)
	var/list/current_ids = get_picture_id_list()
	for(var/i in ids)
		if(i in current_ids)
			continue
		var/obj/item/photo/old/P = load_photo_from_disk(i)
		if(istype(P))
			if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, P, null, TRUE, TRUE))
				qdel(P)

/obj/item/storage/photo_album/hos
	name = "photo album (Head of Security)"
	persistence_id = "HoS"

/obj/item/storage/photo_album/rd
	name = "photo album (Research Director)"
	persistence_id = "RD"

/obj/item/storage/photo_album/hop
	name = "photo album (Head of Personnel)"
	persistence_id = "HoP"

/obj/item/storage/photo_album/captain
	name = "photo album (Captain)"
	persistence_id = "Captain"

/obj/item/storage/photo_album/cmo
	name = "photo album (Chief Medical Officer)"
	persistence_id = "CMO"

/obj/item/storage/photo_album/qm
	name = "photo album (Quartermaster)"
	persistence_id = "QM"

/obj/item/storage/photo_album/ce
	name = "photo album (Chief Engineer)"
	persistence_id = "CE"

/obj/item/storage/photo_album/bar
	name = "photo album (Bar)"
	persistence_id = "bar"

/obj/item/storage/photo_album/syndicate
	name = "photo album (Syndicate)"
	persistence_id = "syndicate"

/obj/item/storage/photo_album/library
	name = "photo album (Library)"
	persistence_id = "library"

obj/item/storage/photo_album/chapel
	name = "photo album (Chapel)"
	persistence_id = "chapel"

obj/item/storage/photo_album/prison
	name = "photo album (Prison)"
	persistence_id = "prison"
