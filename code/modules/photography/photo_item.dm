/*
 * Photo
 */
/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50
	grind_results = list("iodine" = 4)
	var/datum/picture/picture
	var/scribble		//Scribble on the back.
	var/sillynewscastervar  //Photo objects with this set to 1 will not be ejected by a newscaster. Only gets set to 1 if a silicon puts one of their images into a newscaster

/obj/item/photo/Initialize(mapload, datum/picture/P, datum_name = TRUE, datum_desc = TRUE)
	set_picture(P)
	return ..()

/obj/item/photo/proc/set_picture(datum/picture/P)
	if(!istype(P))
		return
	picture = P
	update_icon()
	if(P.caption)
		scribble = P.caption
	if(P.picture_name)
		name = P.picture_name

/obj/item/photo/update_icon()
	var/icon/I = picture.get_small_icon()
	if(I)
		icon = I

/obj/item/photo/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is taking one last look at \the [src]! It looks like [user.p_theyre()] giving in to death!</span>")//when you wanna look at photo of waifu one last time before you die...
	if (user.gender == MALE)
		playsound(user, 'sound/voice/human/manlaugh1.ogg', 50, 1)//EVERY TIME I DO IT MAKES ME LAUGH
	else if (user.gender == FEMALE)
		playsound(user, 'sound/voice/human/womanlaugh.ogg', 50, 1)
	return OXYLOSS

/obj/item/photo/attack_self(mob/user)
	user.examinate(src)

/obj/item/photo/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on [src]!</span>")
			return
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null)  as text)
		txt = copytext(txt, 1, 128)
		if(user.canUseTopic(src, BE_CLOSE))
			scribble = txt
	..()

/obj/item/photo/examine(mob/user)
	..()

	if(in_range(src, user))
		show(user)
	else
		to_chat(user, "<span class='warning'>You need to get closer to get a good look at this photo!</span>")

/obj/item/photo/proc/show(mob/user)
	user << browse_rsc(picture.picture_image, "tmp_photo.png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='[picture.psize_y]' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=book;size=[picture.psize_y]x[picture.psize_x + (scribble? (192 - 400) : 0)]")
	onclose(user, "[name]")

/obj/item/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text), 1, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == CONSCIOUS && usr.canmove && !usr.restrained())
		name = "photo[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
