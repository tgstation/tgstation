/*
 * Photo album
 */
/obj/item/storage/photo_album
	name = "photo album"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "album"
	item_state = "briefcase"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	resistance_flags = FLAMMABLE
	var/persistence_id

/obj/item/storage/photo_album/Initialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.can_hold = typecacheof(list(/obj/item/photo))
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

/obj/item/storage/photo_album/proc/populate_from_id_list(list/ids)
	var/list/current_ids = get_picture_id_list()
	for(var/i in ids)
		if(i in current_ids)
			continue
		var/obj/item/photo/P = load_photo_from_disk(i)
		if(istype(P))
			if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, P, null, TRUE, TRUE))
				qdel(P)

#define ALBUM_DEFINE(id) /obj/item/storage/photo_album/##id/persistence_id = #id

ALBUM_DEFINE(HoS)
ALBUM_DEFINE(RD)
ALBUM_DEFINE(HoP)
ALBUM_DEFINE(Captain)
ALBUM_DEFINE(CMO)
ALBUM_DEFINE(QM)
ALBUM_DEFINE(CE)

#undef ALBUM_DEFINE
