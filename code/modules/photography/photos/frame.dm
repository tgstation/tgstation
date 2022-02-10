// Picture frames

/obj/item/wallframe/picture
	name = "picture frame"
	desc = "The perfect showcase for your favorite deathtrap memories."
	icon = 'icons/obj/decals.dmi'
	custom_materials = list(/datum/material/wood = 2000)
	flags_1 = 0
	icon_state = "frame-overlay"
	result_path = /obj/structure/sign/picture_frame
	var/obj/item/photo/displayed
	pixel_shift = 30

/obj/item/wallframe/picture/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/photo))
		if(!displayed)
			if(!user.transferItemToLoc(I, src))
				return
			displayed = I
			update_appearance()
		else
			to_chat(user, span_warning("\The [src] already contains a photo."))
	..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/wallframe/picture/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() != src)
		..()
		return
	if(contents.len)
		var/obj/item/I = pick(contents)
		user.put_in_hands(I)
		to_chat(user, span_notice("You carefully remove the photo from \the [src]."))
		displayed = null
		update_appearance()
	return ..()

/obj/item/wallframe/picture/attack_self(mob/user)
	user.examinate(src)

/obj/item/wallframe/picture/examine(mob/user)
	if(user.is_holding(src) && displayed)
		displayed.show(user)
		return list()
	else
		return ..()

/obj/item/wallframe/picture/update_overlays()
	. = ..()
	if(displayed)
		. += displayed

/obj/item/wallframe/picture/after_attach(obj/O)
	..()
	var/obj/structure/sign/picture_frame/PF = O
	PF.copy_overlays(src)
	if(displayed)
		PF.framed = displayed
	if(contents.len)
		var/obj/item/I = pick(contents)
		I.forceMove(PF)

/obj/structure/sign/picture_frame
	name = "picture frame"
	desc = "Every time you look it makes you laugh."
	icon = 'icons/obj/decals.dmi'
	icon_state = "frame-overlay"
	custom_materials = list(/datum/material/wood = 2000)
	var/obj/item/photo/framed
	var/persistence_id
	var/del_id_on_destroy = FALSE
	var/art_value = OK_ART
	var/can_decon = TRUE

#define FRAME_DEFINE(id) /obj/structure/sign/picture_frame/##id/persistence_id = #id

//Put default persistent frame defines here!

#undef FRAME_DEFINE

/obj/structure/sign/picture_frame/Initialize(mapload, dir, building)
	. = ..()
	AddElement(/datum/element/art, art_value)
	LAZYADD(SSpersistence.photo_frames, src)
	if(dir)
		setDir(dir)

/obj/structure/sign/picture_frame/Destroy()
	LAZYREMOVE(SSpersistence.photo_frames, src)
	if(persistence_id && del_id_on_destroy)
		SSpersistence.RemovePhotoFrame(persistence_id)
	return ..()

/obj/structure/sign/picture_frame/proc/get_photo_id()
	if(istype(framed) && istype(framed.picture))
		return framed.picture.id

//Manual loading, DO NOT USE FOR HARDCODED/MAPPED IN ALBUMS. This is for if an album needs to be loaded mid-round from an ID.
/obj/structure/sign/picture_frame/proc/persistence_load()
	var/list/data = SSpersistence.GetPhotoFrames()
	if(data[persistence_id])
		load_from_id(data[persistence_id])

/obj/structure/sign/picture_frame/proc/load_from_id(id)
	var/obj/item/photo/old/P = load_photo_from_disk(id)
	if(istype(P))
		if(istype(framed))
			framed.forceMove(drop_location())
		else
			qdel(framed)
		framed = P
		update_appearance()

/obj/structure/sign/picture_frame/examine(mob/user)
	. = ..()
	if(in_range(src, user))
		framed?.show(user)

/obj/structure/sign/picture_frame/attackby(obj/item/I, mob/user, params)
	if(can_decon && (I.tool_behaviour == TOOL_SCREWDRIVER || I.tool_behaviour == TOOL_WRENCH))
		to_chat(user, span_notice("You start unsecuring [name]..."))
		if(I.use_tool(src, user, 30, volume=50))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			to_chat(user, span_notice("You unsecure [name]."))
			deconstruct()

	else if(I.tool_behaviour == TOOL_WIRECUTTER && framed)
		framed.forceMove(drop_location())
		user.visible_message(span_warning("[user] cuts away [framed] from [src]!"))
		framed = null
		update_appearance()
		return

	else if(istype(I, /obj/item/photo))
		if(!framed)
			var/obj/item/photo/P = I
			if(!user.transferItemToLoc(P, src))
				return
			framed = P
			update_appearance()
		else
			to_chat(user, span_warning("\The [src] already contains a photo."))

	..()

/obj/structure/sign/picture_frame/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(framed)
		framed.show(user)

/obj/structure/sign/picture_frame/update_overlays()
	. = ..()
	if(framed)
		. += framed

/obj/structure/sign/picture_frame/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/item/wallframe/picture/F = new /obj/item/wallframe/picture(loc)
		if(framed)
			F.displayed = framed
			framed = null
		if(contents.len)
			var/obj/item/I = pick(contents)
			I.forceMove(F)
		F.update_appearance()
	qdel(src)


/obj/structure/sign/picture_frame/showroom
	name = "distinguished crew display"
	desc = "A photo frame to commemorate crewmembers that distinguished themselves in the line of duty. WARNING: unauthorized tampering will be severely punished."
	can_decon = FALSE

/// This used to be a plaque portrait of a monkey. Now it's been revamped into something more.
/obj/structure/sign/picture_frame/portrait
	icon_state = "frame-monkey"
	can_decon = FALSE
	art_value = GOOD_ART
	var/portrait_name
	var/portrait_state
	var/portrait_desc

/obj/structure/sign/picture_frame/portrait/Initialize()
	. = ..()
	switch(rand(1,4))
		if(1) // Deempisi
			name = "\improper Mr. Deempisi portrait"
			icon_state = "frame-monkey"
			desc = "Under the portrait a plaque reads: 'While the meat grinder may not have spared you, fear not. Not one part of you has gone to waste... You were delicious.'"
		if(2) // A fruit
			name = "picture of a fruit"
			icon_state = "frame-fruit"
			desc = "<i>Ceci n'est pas une orange.</i>"
		if(3) // Rat
			name = "\improper Tom portrait"
			desc = "Jerry the cat is still not amused."
			icon_state = "frame-rat"
		if(4) // Ratvar
			name = "portrait of the imprisoned god"
			desc = "Under the portrait a plaque reads: 'In loving memory of Ratvar, ancient powerful entity and rival of Nar'Sie, \
				ultimately struck down by NT bluespace artillery at the hands of Outpost 17 crew. Rust in peace.'" // common core lore.
			icon_state = "frame-ratvar"
	portrait_name = name
	portrait_state = icon_state
	portrait_desc = desc

/obj/structure/sign/picture_frame/portrait/update_name(updates)
	if(framed)
		name = initial(name)
	else
		name = portrait_name
	return ..()

/obj/structure/sign/picture_frame/portrait/update_icon_state(updates)
	. = ..()
	if(framed)
		icon_state = "frame-overlay"
	else
		icon_state = portrait_state

/obj/structure/sign/picture_frame/portrait/update_desc(updates)
	. = ..()
	if(framed)
		desc = "Every time you look it makes you laugh."
	else
		desc = portrait_desc

/obj/structure/sign/picture_frame/portrait/examine_more(mob/user)
	. = ..()
	if(!framed)
		. += span_notice("The frame and the picture are glued together, but you guess you could slip a photo between the two.")

//persistent frames, make sure the same ID doesn't appear more than once per map
/obj/structure/sign/picture_frame/showroom/one
	persistence_id = "frame_showroom1"

/obj/structure/sign/picture_frame/showroom/two
	persistence_id = "frame_showroom2"

/obj/structure/sign/picture_frame/showroom/three
	persistence_id = "frame_showroom3"

/obj/structure/sign/picture_frame/showroom/four
	persistence_id = "frame_showroom4"

/obj/structure/sign/picture_frame/portrait/bar
	persistence_id = "frame_bar"
	del_id_on_destroy = TRUE

///Generates a persistence id unique to the current map. Every bar should feel a little bit different after all.
/obj/structure/sign/picture_frame/portrait/bar/Initialize()
	if(SSmapping.config.map_path != CUSTOM_MAP_PATH) //skip adminloaded custom maps.
		persistence_id = "frame_bar_[SSmapping.config.map_name]"
	return ..()
