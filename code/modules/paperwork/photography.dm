/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*
 * Film
 */
/obj/item/device/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = 1.0


/*
 * Photo
 */
/obj/item/weapon/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = 1.0
	var/icon/img		//Big photo image
	var/scribble		//Scribble on the back.
	var/blueprints = 0	//Does it include the blueprints?


/obj/item/weapon/photo/attack_self(mob/user)
	examine()


/obj/item/weapon/photo/attackby(obj/item/weapon/P, mob/user)
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null)  as text)
		txt = copytext(txt, 1, 128)
		if(loc == user && user.stat == 0)
			scribble = txt
	..()


/obj/item/weapon/photo/examine()
	set src in oview(1)
	if(is_blind(usr))	return

	if(in_range(usr, src))
		show(usr)
		usr << desc
	else
		usr << "<span class='notice'>It is too far away.</span>"


/obj/item/weapon/photo/proc/show(mob/user)
	user << browse_rsc(img, "tmp_photo.png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden'>" \
		+ "<div> <img src='tmp_photo.png' width = '180'" \
		+ "[scribble ? "<div> Written on the back:<br><i>[scribble]</i>" : ]"\
		+ "</body></html>", "window=book;size=200x[scribble ? 400 : 200]")
	onclose(user, "[name]")


/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text), 1, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == 0)
		name = "photo[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)


/*
 * Photo album
 */
/obj/item/weapon/storage/photo_album
	name = "photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list("/obj/item/weapon/photo",)


/*
 * Camera
 */
/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack"
	w_class = 2.0
	flags = FPRINT | CONDUCT | TABLEPASS
	slot_flags = SLOT_BELT
	m_amt = 2000
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/blueprints = 0	//are blueprints visible in the current photo being created?
	var/list/aipictures = list() //Allows for storage of pictures taken by AI, in a similar manner the datacore stores info


/obj/item/device/camera/ai_camera //camera AI can take pictures with
	name = "AI photo camera"
	var/in_camera_mode = 0

	verb/picture()
		set category ="AI Commands"
		set name = "Take Image"
		set src in usr

		toggle_camera_mode()

	verb/viewpicture()
		set category ="AI Commands"
		set name = "View Images"
		set src in usr

		viewpictures()


/obj/item/device/camera/attack(mob/living/carbon/human/M, mob/user)
	return


/obj/item/device/camera/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/camera_film))
		if(pictures_left)
			user << "<span class='notice'>[src] still has some film in it!</span>"
			return
		user << "<span class='notice'>You insert [I] into [src].</span>"
		user.drop_item()
		del(I)
		pictures_left = pictures_max
		return
	..()


/obj/item/device/camera/proc/camera_get_icon(turf/the_turf, blueprints)
	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	var/icon/res = icon('icons/effects/96x96.dmi', "")

	var/icon/turficon = build_composite_icon(the_turf)
	res.Blend(turficon, ICON_OVERLAY, 33, 33)

	var/atoms[] = list()
	for(var/atom/A in the_turf)
		if(A.invisibility) continue
		atoms.Add(A)

	//Sorting icons based on levels
	var/gap = atoms.len
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= atoms.len; i++)
			var/atom/l = atoms[i]		//Fucking hate
			var/atom/r = atoms[gap+i]	//how lists work here
			if(l.layer > r.layer)		//no "atoms[i].layer" for me
				atoms.Swap(i, gap + i)
				swapped = 1

	for(var/i; i <= atoms.len; i++)
		var/atom/A = atoms[i]
		if(A)
			var/icon/img = getFlatIcon(A, A.dir)//build_composite_icon(A)
			if(istype(img, /icon))
				res.Blend(new/icon(img, "", A.dir), ICON_OVERLAY, 33 + A.pixel_x, 33 + A.pixel_y)
		if(!blueprints && istype(A, /obj/item/blueprints))
			blueprints = 1
	return res


/obj/item/device/camera/proc/camera_get_mobs(turf/the_turf)
	var/mob_detail
	for(var/mob/living/carbon/A in the_turf)
		if(A.invisibility) continue
		var/holding = null
		if(A.l_hand || A.r_hand)
			if(A.l_hand) holding = "They are holding \a [A.l_hand]"
			if(A.r_hand)
				if(holding)
					holding += " and \a [A.r_hand]"
				else
					holding = "They are holding \a [A.r_hand]"

		if(!mob_detail)
			mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail


/obj/item/device/camera/proc/captureimage(atom/target, mob/user, flag)  //Proc for both regular and AI-based camera to take the image
	var/x_c = target.x - 1
	var/y_c = target.y + 1
	var/z_c	= target.z

	var/icon/temp = icon('icons/effects/96x96.dmi',"")
	temp.Blend("#000", ICON_OVERLAY)
	var/mobs = ""
	var/viewer = user
	var/list/seen
	if(!istype(user,/mob/living/silicon/ai)) //crappy check, but without it AI photos would be subject to line of sight from the AI Eye object. Made the best of it by moving the sec camera check inside
		if(user.client)		//To make shooting through security cameras possible
			viewer = user.client.eye
		seen = hear(world.view, viewer)
	else
		seen = hear(world.view, target)
	for(var/i = 1; i <= 3; i++)
		for(var/j = 1; j <= 3; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			if(T in seen)
				if(istype(user,/mob/living/silicon/ai))
					if(0 == cameranet.checkTurfVis(T)) //Checks to see if this turf is visible to the AI's cameras
						x_c++  //because continue would skip the x_c++ further down, and it is rather important to this proc to work right
						continue
				temp.Blend(camera_get_icon(T), ICON_OVERLAY, 32 * (j-1-1), 32 - 32 * (i-1))
				mobs += camera_get_mobs(T)
			x_c++
		y_c--
		x_c -= 3
	if(!istype(usr,/mob/living/silicon/ai))
		printpicture(user, temp, mobs, blueprints, flag)
	else
		aipicture(user, temp, mobs, blueprints)



/obj/item/device/camera/proc/printpicture(mob/user, icon/temp, mobs, blueprints, flag) //Normal camera proc for creating photos
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
	user.put_in_hands(P)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	P.icon = ic
	P.img = temp
	P.desc = mobs
	P.pixel_x = rand(-10, 10)
	P.pixel_y = rand(-10, 10)

	if(blueprints)
		P.blueprints = 1
	blueprints = 0


/obj/item/device/camera/proc/aipicture(mob/user, icon/temp, mobs, blueprints) //instead of printing a picture like a regular camera would, we do this instead for the AI

	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	var/icon = ic
	var/img = temp
	var/desc = mobs
	var/pixel_x = rand(-10, 10)
	var/pixel_y = rand(-10, 10)

	if(blueprints)
		blueprints = 1

	injectaialbum(icon, img, desc, pixel_x, pixel_y, blueprints)


/datum/picture
	var/name = "image"
	var/list/fields = list()


/obj/item/device/camera/proc/injectaialbum(var/icon, var/img, var/desc, var/pixel_x, var/pixel_y, var/blueprints) //stores image information to a list similar to that of the datacore
	var/numberer = 1
	for(var/datum/picture in src.aipictures)
		numberer++
	var/datum/picture/P = new()
	P.fields["name"] = "Image [numberer]"
	P.fields["icon"] = icon
	P.fields["img"] = img
	P.fields["desc"] = desc
	P.fields["pixel_x"] = pixel_x
	P.fields["pixel_y"] = pixel_y
	P.fields["blueprints"] = blueprints

	aipictures += P
	usr << "<FONT COLOR=blue><B>Image recorded</B>"	//feedback to the AI player that the picture was taken


/obj/item/device/camera/ai_camera/proc/viewpictures() //AI proc for viewing pictures they have taken
	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	if(src.aipictures.len == 0)
		usr << "<FONT COLOR=red><B>No images saved</B>"
		return
	for(var/datum/picture/t in src.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image (numbered in order taken)") in nametemp
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
	for(var/datum/picture/q in src.aipictures)
		if(q.fields["name"] == find)
			selection = q
			break  	// just in case some AI decides to take 10 thousand pictures in a round
	P.icon = selection.fields["icon"]
	P.img = selection.fields["img"]
	P.desc = selection.fields["desc"]
	P.pixel_x = selection.fields["pixel_x"]
	P.pixel_y = selection.fields["pixel_y"]

	P.show(usr)
	usr << P.desc
	del P    //so 10 thousdand pictures items are not left in memory should an AI take them and then view them all.

/obj/item/device/camera/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || ismob(target.loc)) return
	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	desc = "A polaroid camera. It has [pictures_left] photos left."
	user << "<span class='notice'>[pictures_left] photos left.</span>"
	icon_state = "camera_off"
	on = 0
	spawn(64)
		icon_state = "camera"
		on = 1

/obj/item/device/camera/ai_camera/proc/toggle_camera_mode()
	if(in_camera_mode)
		camera_mode_off()
	else
		camera_mode_on()

/obj/item/device/camera/ai_camera/proc/camera_mode_off()
	src.in_camera_mode = 0
	usr << "<B>Camera Mode deactivated</B>"

/obj/item/device/camera/ai_camera/proc/camera_mode_on()
	src.in_camera_mode = 1
	usr << "<B>Camera Mode activated</B>"