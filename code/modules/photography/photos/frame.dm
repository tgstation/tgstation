// Picture frames

/obj/item/wallframe/picture
	name = "picture frame"
	desc = "The perfect showcase for your favorite deathtrap memories."
	icon = 'icons/obj/signs.dmi'
	custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
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
		PF.set_and_save_framed(displayed)
	if(contents.len)
		var/obj/item/I = pick(contents)
		I.forceMove(PF)

/obj/structure/sign/picture_frame
	name = "picture frame"
	desc = "Every time you look it makes you laugh."
	icon = 'icons/obj/signs.dmi'
	icon_state = "frame-overlay"
	custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	var/obj/item/photo/framed
	var/persistence_id
	var/art_value = OK_ART
	var/can_decon = TRUE

/obj/structure/sign/picture_frame/Initialize(mapload, dir, building)
	. = ..()
	AddElement(/datum/element/art, art_value)
	if (!SSpersistence.initialized)
		LAZYADD(SSpersistence.queued_photo_frames, src)
	if(dir)
		setDir(dir)

/obj/structure/sign/picture_frame/Destroy()
	LAZYREMOVE(SSpersistence.queued_photo_frames, src)
	return ..()

/obj/structure/sign/picture_frame/proc/get_photo_id()
	if(istype(framed) && istype(framed.picture))
		return framed.picture.id

//Manual loading, DO NOT USE FOR HARDCODED/MAPPED IN ALBUMS. This is for if an album needs to be loaded mid-round from an ID.
/obj/structure/sign/picture_frame/proc/persistence_load()
	var/list/data = SSpersistence.photo_frames_database.get_key(persistence_id)
	if(!isnull(data))
		load_from_id(data)

/obj/structure/sign/picture_frame/proc/load_from_id(id)
	var/obj/item/photo/old/P = load_photo_from_disk(id)
	if(istype(P))
		if(istype(framed))
			framed.forceMove(drop_location())
		else
			qdel(framed)
		framed = P
		update_appearance()

/// Given a photo (or null), will change the contained picture, and queue a persistent save.
/obj/structure/sign/picture_frame/proc/set_and_save_framed(obj/item/photo/photo)
	framed = photo

	if (isnull(persistence_id))
		return

	SSpersistence.photo_frames_database.set_key(persistence_id, photo?.picture?.id)

/obj/structure/sign/picture_frame/examine(mob/user)
	. = ..()
	if(in_range(src, user))
		framed?.show(user)

/// Internal proc
/obj/structure/sign/picture_frame/proc/try_deconstruct(mob/living/user, obj/item/tool)
	if(!can_decon)
		return FALSE
	to_chat(user, span_notice("You start unsecuring [name]..."))
	if(tool.use_tool(src, user, 3 SECONDS, volume=50))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		to_chat(user, span_notice("You unsecure [name]."))
		deconstruct()
	return TRUE

/obj/structure/sign/picture_frame/screwdriver_act(mob/living/user, obj/item/tool)
	return try_deconstruct(user, tool)

/obj/structure/sign/picture_frame/wrench_act(mob/living/user, obj/item/tool)
	return try_deconstruct(user, tool)

/obj/structure/sign/picture_frame/wirecutter_act(mob/living/user, obj/item/tool)
	if (!framed)
		return FALSE
	tool.play_tool_sound(src)
	framed.forceMove(drop_location())
	user.visible_message(span_warning("[user] cuts away [framed] from [src]!"))
	set_and_save_framed(null)
	update_appearance()
	return ITEM_INTERACT_SUCCESS


/obj/structure/sign/picture_frame/attackby(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/photo))
		if(framed)
			to_chat(user, span_warning("\The [src] already contains a photo."))
			return TRUE
		var/obj/item/photo/P = I
		if(!user.transferItemToLoc(P, src))
			return
		set_and_save_framed(P)
		update_appearance()
		return TRUE
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

/obj/structure/sign/picture_frame/atom_deconstruct(disassembled = TRUE)
	var/obj/item/wallframe/picture/showcase = new /obj/item/wallframe/picture(loc)
	if(framed)
		showcase.displayed = framed
		set_and_save_framed(null)
	if(contents.len)
		var/obj/item/I = pick(contents)
		I.forceMove(showcase)
	showcase.update_appearance()

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

/obj/structure/sign/picture_frame/portrait/Initialize(mapload)
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

// for the hall of fame escape shuttle
/obj/structure/sign/picture_frame/hall_of_fame/one
	persistence_id = "frame_hall_of_fame_1"

/obj/structure/sign/picture_frame/hall_of_fame/two
	persistence_id = "frame_hall_of_fame_2"

/obj/structure/sign/picture_frame/hall_of_fame/three
	persistence_id = "frame_hall_of_fame_3"

/obj/structure/sign/picture_frame/hall_of_fame/four
	persistence_id = "frame_hall_of_fame_4"

/obj/structure/sign/picture_frame/portrait/bar
	persistence_id = "frame_bar"

///Generates a persistence id unique to the current map. Every bar should feel a little bit different after all.
/obj/structure/sign/picture_frame/portrait/bar/Initialize(mapload)
	if(SSmapping.current_map.map_path != CUSTOM_MAP_PATH) //skip adminloaded custom maps.
		persistence_id = "frame_bar_[SSmapping.current_map.map_name]"
	return ..()
