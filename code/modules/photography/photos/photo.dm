/*
 * Photo
 */
/obj/item/photo
	name = "photo"
	icon = 'icons/obj/art/camera.dmi'
	icon_state = "photo"
	inhand_icon_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	grind_results = list(/datum/reagent/iodine = 4)
	var/datum/picture/picture
	var/scribble //Scribble on the back.

/obj/item/photo/Initialize(mapload, datum/picture/P, datum_name = TRUE, datum_desc = TRUE)
	set_picture(P, datum_name, datum_desc, TRUE)
	//Photos are quite rarer than papers, so they're more likely to be added to the queue to make things even.
	if(!mapload && prob(MESSAGE_BOTTLE_CHANCE * 5) && picture?.id)
		LAZYADD(SSpersistence.queued_message_bottles, src)
	return ..()

/obj/item/photo/Destroy()
	LAZYREMOVE(SSpersistence.queued_message_bottles, src)
	return ..()

/obj/item/photo/proc/set_picture(datum/picture/P, setname, setdesc, name_override = FALSE)
	if(!istype(P))
		return
	picture = P
	update_appearance()
	if(P.caption)
		scribble = P.caption
	if(setname && P.picture_name)
		if(name_override)
			name = P.picture_name
		else
			name = "photo - [P.picture_name]"
	if(setdesc && P.picture_desc)
		desc = P.picture_desc


	if(!P.see_ghosts) ///Dont bother with this last bit if we can't see ghosts
		return
	for(var/datum/weakref/seen_ref in P.mobs_seen) //Any ghosts in the pic? its a haunted photo ooooo~
		var/mob/seen = seen_ref.resolve()
		if(!seen)
			P.mobs_seen -= seen_ref
			continue
		if(!isobserver(seen))
			continue
		set_custom_materials(list(/datum/material/hauntium =SHEET_MATERIAL_AMOUNT))
		grind_results = list(/datum/reagent/hauntium = 20)
		break

/obj/item/photo/update_icon_state()
	if(!istype(picture) || !picture.picture_image)
		return ..()
	var/icon/I = picture.get_small_icon(initial(icon_state))
	if(I)
		icon = I
	return ..()

/obj/item/photo/suicide_act(mob/living/carbon/human/user)
	user.visible_message(span_suicide("[user] is taking one last look at \the [src]! It looks like [user.p_theyre()] giving in to death!"))//when you wanna look at photo of waifu one last time before you die...
	if (!ishuman(user) || user.physique == MALE)
		playsound(user, 'sound/mobs/humanoids/human/laugh/manlaugh1.ogg', 50, TRUE)//EVERY TIME I DO IT MAKES ME LAUGH
	else
		playsound(user, 'sound/mobs/humanoids/human/laugh/womanlaugh.ogg', 50, TRUE)
	return OXYLOSS

/obj/item/photo/attack_self(mob/user)
	user.examinate(src)

/obj/item/photo/attackby(obj/item/P, mob/user, params)
	if(burn_paper_product_attackby_check(P, user))
		return
	if(IS_WRITING_UTENSIL(P))
		if(!user.can_write(P))
			return
		var/txt = tgui_input_text(user, "What would you like to write on the back?", "Photo Writing", max_length = 128)
		if(txt && user.can_perform_action(src))
			playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
			scribble = txt
	else
		return ..()

/obj/item/photo/examine(mob/user)
	. = ..()

	if(in_range(src, user) || isobserver(user))
		show(user)
	else
		. += span_warning("You need to get closer to get a good look at this photo!")

/obj/item/photo/proc/show(mob/user)
	if(!istype(picture) || !picture.picture_image)
		to_chat(user, span_warning("[src] seems to be blank..."))
		return
	user << browse_rsc(picture.picture_image, "tmp_photo.png")
	user << browse("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='480' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=photo_showing;size=480x608")
	onclose(user, "[name]")

/obj/item/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = tgui_input_text(usr, "What would you like to label the photo?", "Photo Labelling", max_length = MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if(n_name && (loc == usr || loc.loc && loc.loc == usr) && usr.stat == CONSCIOUS && !usr.incapacitated)
		name = "photo[(n_name ? "- '[n_name]'" : null)]"
	add_fingerprint(usr)

/obj/item/photo/old
	icon_state = "photo_old"
