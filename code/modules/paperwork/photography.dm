/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 *		AI Photography
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
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/*
 * Photo
 */
/obj/item/weapon/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	obj_integrity = 50
	max_integrity = 50
	var/icon/img		//Big photo image
	var/scribble		//Scribble on the back.
	var/blueprints = 0	//Does it include the blueprints?
	var/sillynewscastervar  //Photo objects with this set to 1 will not be ejected by a newscaster. Only gets set to 1 if a silicon puts one of their images into a newscaster


/obj/item/weapon/photo/attack_self(mob/user)
	user.examinate(src)


/obj/item/weapon/photo/attackby(obj/item/weapon/P, mob/user, params)
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null)  as text)
		txt = copytext(txt, 1, 128)
		if(loc == user && user.stat == 0)
			scribble = txt
	..()


/obj/item/weapon/photo/examine(mob/user)
	..()

	if(in_range(user, src))
		show(user)
	else
		user << "<span class='warning'>You need to get closer to get a good look at this photo!</span>"


/obj/item/weapon/photo/proc/show(mob/user)
	user << browse_rsc(img, "tmp_photo.png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=book;size=192x[scribble ? 400 : 192]")
	onclose(user, "[name]")


/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text), 1, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == 0 && usr.canmove && !usr.restrained())
		name = "photo[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)

/obj/item/weapon/photo/proc/photocreate(inicon, inimg, indesc, inblueprints)
	icon = inicon
	img = inimg
	desc = indesc
	blueprints = inblueprints

/*
 * Photo album
 */
/obj/item/weapon/storage/photo_album
	name = "photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list(/obj/item/weapon/photo)
	resistance_flags = FLAMMABLE

/*
 * Camera
 */
/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	item_state = "electropack"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=2000)
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/blueprints = 0	//are blueprints visible in the current photo being created?
	var/list/aipictures = list() //Allows for storage of pictures taken by AI, in a similar manner the datacore stores info. Keeping this here allows us to share some procs w/ regualar camera
	var/see_ghosts = 0 //for the spoop of it


/obj/item/device/camera/CheckParts(list/parts_list)
	..()
	var/obj/item/device/camera/C = locate(/obj/item/device/camera) in contents
	if(C)
		pictures_max = C.pictures_max
		pictures_left = C.pictures_left
		visible_message("[C] has been imbued with godlike power!")
		qdel(C)


/obj/item/device/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = 1

/obj/item/device/camera/detective
	name = "Detective's camera"
	desc = "A polaroid camera with extra capacity for crime investigations."
	pictures_max = 30
	pictures_left = 30


/obj/item/device/camera/siliconcam //camera AI can take pictures with
	name = "silicon photo camera"
	var/in_camera_mode = 0

/obj/item/device/camera/siliconcam/ai_camera //camera AI can take pictures with
	name = "AI photo camera"

/obj/item/device/camera/siliconcam/robot_camera //camera cyborgs can take pictures with.. needs it's own because of verb CATEGORY >.>
	name = "Cyborg photo camera"

/obj/item/device/camera/siliconcam/robot_camera/verb/borgprinting()
	set category ="Robot Commands"
	set name = "Print Image"
	set src in usr

	if(usr.stat == DEAD)
		return //won't work if dead
	borgprint()

/obj/item/device/camera/attack(mob/living/carbon/human/M, mob/user)
	return


/obj/item/device/camera/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/camera_film))
		if(pictures_left)
			user << "<span class='notice'>[src] still has some film in it!</span>"
			return
		if(!user.unEquip(I))
			return
		user << "<span class='notice'>You insert [I] into [src].</span>"
		qdel(I)
		pictures_left = pictures_max
		return
	..()


/obj/item/device/camera/examine(mob/user)
	..()
	user << "It has [pictures_left] photos left."


/obj/item/device/camera/proc/camera_get_icon(list/turfs, turf/center)
	var/atoms[] = list()
	for(var/turf/T in turfs)
		atoms.Add(T)
		for(var/atom/movable/A in T)
			if(A.invisibility)
				if(see_ghosts && isobserver(A))
					var/mob/dead/observer/O = A
					if(O.orbiting) //so you dont see ghosts following people like antags, etc.
						continue
				else
					continue
			atoms.Add(A)

	var/list/sorted = list()
	var/j
	for(var/i = 1 to atoms.len)
		var/atom/c = atoms[i]
		for(j = sorted.len, j > 0, --j)
			var/atom/c2 = sorted[j]
			if(c2.layer <= c.layer)
				break
		sorted.Insert(j+1, c)

	var/icon/res = icon('icons/effects/96x96.dmi', "")

	for(var/atom/A in sorted)
		var/icon/img = getFlatIcon(A)
		if(isliving(A))
			var/mob/living/L = A
			if(L.lying)
				img.Turn(L.lying)

		var/offX = 32 * (A.x - center.x) + A.pixel_x + 33
		var/offY = 32 * (A.y - center.y) + A.pixel_y + 33
		if(istype(A, /atom/movable))
			offX += A:step_x
			offY += A:step_y

		res.Blend(img, blendMode2iconMode(A.blend_mode), offX, offY)

		if(istype(A, /obj/item/areaeditor/blueprints))
			blueprints = 1

	for(var/turf/T in turfs)
		res.Blend(getFlatIcon(T.loc), blendMode2iconMode(T.blend_mode), 32 * (T.x - center.x) + 33, 32 * (T.y - center.y) + 33)

	return res


/obj/item/device/camera/proc/camera_get_mobs(turf/the_turf)
	var/mob_detail
	for(var/mob/M in the_turf)
		if(M.invisibility)
			if(see_ghosts && isobserver(M))
				var/mob/dead/observer/O = M
				if(O.orbiting)
					continue
				if(!mob_detail)
					mob_detail = "You can see a g-g-g-g-ghooooost! "
				else
					mob_detail += "You can also see a g-g-g-g-ghooooost!"
			else
				continue

		var/list/holding = list()

		if(isliving(M))
			var/mob/living/L = M

			for(var/obj/item/I in L.held_items)
				if(!holding)
					holding += "[L.p_they(TRUE)] [L.p_are()] holding \a [I]"
				else
					holding += " and \a [I]"
			holding = holding.Join()

			if(!mob_detail)
				mob_detail = "You can see [L] on the photo[L.health < (L.maxHealth * 0.75) ? " - [L] looks hurt":""].[holding ? " [holding]":"."]. "
			else
				mob_detail += "You can also see [L] on the photo[L.health < (L.maxHealth * 0.75) ? " - [L] looks hurt":""].[holding ? " [holding]":"."]."


	return mob_detail


/obj/item/device/camera/proc/captureimage(atom/target, mob/user, flag)  //Proc for both regular and AI-based camera to take the image
	var/mobs = ""
	var/isAi = isAI(user)
	var/list/seen
	if(!isAi) //crappy check, but without it AI photos would be subject to line of sight from the AI Eye object. Made the best of it by moving the sec camera check inside
		if(user.client)		//To make shooting through security cameras possible
			seen = get_hear(world.view, user.client.eye) //To make shooting through security cameras possible
		else
			seen = get_hear(world.view, user)
	else
		seen = get_hear(world.view, target)

	var/list/turfs = list()
	for(var/turf/T in range(1, target))
		if(T in seen)
			if(isAi && !cameranet.checkTurfVis(T))
				continue
			else
				turfs += T
				mobs += camera_get_mobs(T)

	var/icon/temp = icon('icons/effects/96x96.dmi',"")
	temp.Blend("#000", ICON_OVERLAY)
	temp.Blend(camera_get_icon(turfs, target), ICON_OVERLAY)

	if(!issilicon(user))
		printpicture(user, temp, mobs, flag)
	else
		aipicture(user, temp, mobs, isAi, blueprints)




/obj/item/device/camera/proc/printpicture(mob/user, icon/temp, mobs, flag) //Normal camera proc for creating photos
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo(get_turf(src))
	if(Adjacent(user)) //needed because of TK
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


/obj/item/device/camera/proc/aipicture(mob/user, icon/temp, mobs, isAi) //instead of printing a picture like a regular camera would, we do this instead for the AI

	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	var/icon = ic
	var/img = temp
	var/desc = mobs
	var/pixel_x = rand(-10, 10)
	var/pixel_y = rand(-10, 10)

	var/injectblueprints = 1
	if(blueprints)
		injectblueprints = 1
		blueprints = 0

	if(isAi)
		injectaialbum(icon, img, desc, pixel_x, pixel_y, injectblueprints)
	else
		injectmasteralbum(icon, img, desc, pixel_x, pixel_y, injectblueprints)



/datum/picture
	var/name = "image"
	var/list/fields = list()


/obj/item/device/camera/proc/injectaialbum(icon, img, desc, pixel_x, pixel_y, blueprintsinject) //stores image information to a list similar to that of the datacore
	var/numberer = 1
	for(var/datum/picture in src.aipictures)
		numberer++
	var/datum/picture/P = new()
	P.fields["name"] = "Image [numberer] (taken by [src.loc.name])"
	P.fields["icon"] = icon
	P.fields["img"] = img
	P.fields["desc"] = desc
	P.fields["pixel_x"] = pixel_x
	P.fields["pixel_y"] = pixel_y
	P.fields["blueprints"] = blueprintsinject

	aipictures += P
	usr << "<span class='unconscious'>Image recorded</span>"	//feedback to the AI player that the picture was taken

/obj/item/device/camera/proc/injectmasteralbum(icon, img, desc, pixel_x, pixel_y, blueprintsinject) //stores image information to a list similar to that of the datacore
	var/numberer = 1
	var/mob/living/silicon/robot/C = src.loc
	if(C.connected_ai)
		for(var/datum/picture in C.connected_ai.aicamera.aipictures)
			numberer++
		var/datum/picture/P = new()
		P.fields["name"] = "Image [numberer] (taken by [src.loc.name])"
		P.fields["icon"] = icon
		P.fields["img"] = img
		P.fields["desc"] = desc
		P.fields["pixel_x"] = pixel_x
		P.fields["pixel_y"] = pixel_y
		P.fields["blueprints"] = blueprintsinject

		C.connected_ai.aicamera.aipictures += P
		usr << "<span class='unconscious'>Image recorded and saved to remote database</span>"	//feedback to the Cyborg player that the picture was taken
	else
		injectaialbum(icon, img, desc, pixel_x, pixel_y, blueprintsinject)

/obj/item/device/camera/siliconcam/proc/selectpicture(obj/item/device/camera/siliconcam/targetloc)
	var/list/nametemp = list()
	var/find
	if(targetloc.aipictures.len == 0)
		usr << "<span class='boldannounce'>No images saved</span>"
		return
	for(var/datum/picture/t in targetloc.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image (numbered in order taken)") in nametemp
	for(var/datum/picture/q in targetloc.aipictures)
		if(q.fields["name"] == find)
			return q

/obj/item/device/camera/siliconcam/proc/viewpichelper(obj/item/device/camera/siliconcam/targetloc)
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
	var/datum/picture/selection = selectpicture(targetloc)
	if(selection)
		P.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["desc"])
		P.pixel_x = selection.fields["pixel_x"]
		P.pixel_y = selection.fields["pixel_y"]

		P.show(usr)
		usr << P.desc
	qdel(P)    //so 10 thousand picture items are not left in memory should an AI take them and then view them all

/obj/item/device/camera/siliconcam/proc/viewpictures(user)
	if(iscyborg(user)) // Cyborg
		var/mob/living/silicon/robot/C = src.loc
		var/obj/item/device/camera/siliconcam/Cinfo
		if(C.connected_ai)
			Cinfo = C.connected_ai.aicamera
			viewpichelper(Cinfo)
		else
			Cinfo = C.aicamera
			viewpichelper(Cinfo)
	else // AI
		var/Ainfo = src
		viewpichelper(Ainfo)

/obj/item/device/camera/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || !isturf(target.loc))
		return

	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	user << "<span class='notice'>[pictures_left] photos left.</span>"
	icon_state = "camera_off"
	on = 0
	spawn(64)
		icon_state = "camera"
		on = 1

/obj/item/device/camera/siliconcam/proc/toggle_camera_mode()
	if(in_camera_mode)
		camera_mode_off()
	else
		camera_mode_on()

/obj/item/device/camera/siliconcam/proc/camera_mode_off()
	src.in_camera_mode = 0
	usr << "<B>Camera Mode deactivated</B>"

/obj/item/device/camera/siliconcam/proc/camera_mode_on()
	src.in_camera_mode = 1
	usr << "<B>Camera Mode activated</B>"

/obj/item/device/camera/siliconcam/robot_camera/proc/borgprint()
	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	var/mob/living/silicon/robot/C = src.loc
	var/obj/item/device/camera/siliconcam/targetcam = null
	if(C.toner < 20)
		usr << "Insufficent toner to print image."
		return
	if(C.connected_ai)
		targetcam = C.connected_ai.aicamera
	else
		targetcam = C.aicamera
	if(targetcam.aipictures.len == 0)
		usr << "<span class='userdanger'>No images saved</span>"
		return
	for(var/datum/picture/t in targetcam.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image (numbered in order taken)") in nametemp
	for(var/datum/picture/q in targetcam.aipictures)
		if(q.fields["name"] == find)
			selection = q
			break
	var/obj/item/weapon/photo/p = new /obj/item/weapon/photo(C.loc)
	p.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["desc"], selection.fields["blueprints"])
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	C.toner -= 20	 //Cyborgs are very ineffeicient at printing an image
	visible_message("[C.name] spits out a photograph from a narrow slot on its chassis.")
	usr << "<span class='notice'>You print a photograph.</span>"
