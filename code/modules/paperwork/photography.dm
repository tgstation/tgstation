/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 *		Picture Frames
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
	var/list/mobinfo
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

	if(in_range(src, user))
		user << who_are_they(user)
		show(user)
	else
		to_chat(user, "<span class='warning'>You need to get closer to get a good look at this photo!</span>")


/obj/item/weapon/photo/proc/show(mob/user)
	user << browse_rsc(img, "tmp_photo.png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=book;size=192x[scribble ? 400 : 192]")
	onclose(user, "[name]")

/obj/item/weapon/photo/proc/who_are_they(mob/user)
	if(user && mobinfo && mobinfo.len)
		for(var/list/m_info in mobinfo)
			var/m_name
			if(m_info[1])
				if(!user.mind)
					continue
				m_name = user.mind.remembered_faceprint_name(m_info[2])
			else
				m_name = m_info[2]
			if(!m_name)
				continue
			. = "[.]You can see [m_name] on the photo.[m_info[3] ? " They look injured." : null]"
			if(m_info.len > 3)
				var/list/m_items = m_info.Copy(3)
				var/text_items
				for(var/i_name in m_items)
					text_items = "[text_items], \an [i_name]"
				if(length(text_items))
					. = "[.] They are holding[text_items]."
			. = "[.]\n"


/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text), 1, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == 0 && usr.canmove && !usr.restrained())
		name = "photo[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)

/obj/item/weapon/photo/proc/photocreate(inicon, inimg, inmobinfo, inblueprints)
	icon = inicon
	img = inimg
	mobinfo = inmobinfo
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
		visible_message("[IDENTITY_SUBJECT(1)] has been imbued with godlike power!", subjects=list(C))
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
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		qdel(I)
		pictures_left = pictures_max
		return
	..()


/obj/item/device/camera/examine(mob/user)
	..()
	to_chat(user, "It has [pictures_left] photos left.")


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
	var/list/mob_detail = list()
	for(var/mob/M in the_turf)
		var/list/M_info = new(PHOTO_MOB_INFO_LEN) //[1] = if it's a faceprint or just a direct name, [2] = for the faceprint or direct name, [3] = looks hurt or not, [thereafter] = stuff they are holding
		if(M.invisibility)
			if(see_ghosts && isobserver(M))
				var/mob/dead/observer/O = M
				if(O.orbiting)
					continue
				M_info[1] = FALSE
				M_info[2] = "a g-g-g-g-ghooooost"
				M_info[3] = FALSE
			else
				continue

		if(isliving(M))
			var/mob/living/L = M

			if(L.can_see_face())
				var/face_print = L.get_faceprint()
				if(face_print)
					M_info[1] = TRUE
					M_info[2] = face_print
				else
					M_info[1] = FALSE
					M_info[2] = L.name
				M_info[3] = L.health < (L.maxHealth * 0.75)

				for(var/obj/item/I in L.held_items)
					M_info += I.name

		if(M_info.len)
			mob_detail[++mob_detail.len] = M_info

	return mob_detail


/obj/item/device/camera/proc/captureimage(atom/target, mob/user, flag)  //Proc for both regular and AI-based camera to take the image
	var/list/mobs = list()
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
	for(var/_T in spiral_range_turfs(1, target))
		var/turf/T = _T
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
	if(in_range(src, user)) //needed because of TK
		user.put_in_hands(P)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	P.icon = ic
	P.img = temp
	P.mobinfo = mobs
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
	var/mobinfo = mobs
	var/pixel_x = rand(-10, 10)
	var/pixel_y = rand(-10, 10)

	var/injectblueprints = 1
	if(blueprints)
		injectblueprints = 1
		blueprints = 0

	if(isAi)
		injectaialbum(icon, img, mobinfo, pixel_x, pixel_y, injectblueprints)
	else
		injectmasteralbum(icon, img, mobinfo, pixel_x, pixel_y, injectblueprints)



/datum/picture
	var/name = "image"
	var/list/fields = list()


/obj/item/device/camera/proc/injectaialbum(icon, img, mobinfo, pixel_x, pixel_y, blueprintsinject) //stores image information to a list similar to that of the datacore
	var/numberer = 1
	for(var/datum/picture in src.aipictures)
		numberer++
	var/datum/picture/P = new()
	P.fields["name"] = "Image [numberer] (taken by [src.loc.name])"
	P.fields["icon"] = icon
	P.fields["img"] = img
	P.fields["mobinfo"] = mobinfo
	P.fields["pixel_x"] = pixel_x
	P.fields["pixel_y"] = pixel_y
	P.fields["blueprints"] = blueprintsinject

	aipictures += P
	to_chat(usr, "<span class='unconscious'>Image recorded</span>") //feedback to the AI player that the picture was taken

/obj/item/device/camera/proc/injectmasteralbum(icon, img, mobinfo, pixel_x, pixel_y, blueprintsinject) //stores image information to a list similar to that of the datacore
	var/numberer = 1
	var/mob/living/silicon/robot/C = src.loc
	if(C.connected_ai)
		for(var/datum/picture in C.connected_ai.aicamera.aipictures)
			numberer++
		var/datum/picture/P = new()
		P.fields["name"] = "Image [numberer] (taken by [src.loc.name])"
		P.fields["icon"] = icon
		P.fields["img"] = img
		P.fields["mobinfo"] = mobinfo
		P.fields["pixel_x"] = pixel_x
		P.fields["pixel_y"] = pixel_y
		P.fields["blueprints"] = blueprintsinject

		C.connected_ai.aicamera.aipictures += P
		to_chat(usr, "<span class='unconscious'>Image recorded and saved to remote database</span>") //feedback to the Cyborg player that the picture was taken
	else
		injectaialbum(icon, img, mobinfo, pixel_x, pixel_y, blueprintsinject)

/obj/item/device/camera/siliconcam/proc/selectpicture(obj/item/device/camera/siliconcam/targetloc)
	var/list/nametemp = list()
	var/find
	if(targetloc.aipictures.len == 0)
		to_chat(usr, "<span class='boldannounce'>No images saved</span>")
		return
	for(var/datum/picture/t in targetloc.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image (numbered in order taken)") in nametemp
	for(var/datum/picture/q in targetloc.aipictures)
		if(q.fields["name"] == find)
			return q

/obj/item/device/camera/siliconcam/proc/viewpichelper(obj/item/device/camera/siliconcam/targetloc, mob/user)
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
	var/datum/picture/selection = selectpicture(targetloc)
	if(selection)
		P.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["mobinfo"])
		P.pixel_x = selection.fields["pixel_x"]
		P.pixel_y = selection.fields["pixel_y"]

		to_chat(user, P.who_are_they(user))
		P.show(user)
	qdel(P)    //so 10 thousand picture items are not left in memory should an AI take them and then view them all

/obj/item/device/camera/siliconcam/proc/viewpictures(user)
	if(iscyborg(user)) // Cyborg
		var/mob/living/silicon/robot/C = src.loc
		var/obj/item/device/camera/siliconcam/Cinfo
		if(C.connected_ai)
			Cinfo = C.connected_ai.aicamera
			viewpichelper(Cinfo, user)
		else
			Cinfo = C.aicamera
			viewpichelper(Cinfo, user)
	else // AI
		var/Ainfo = src
		viewpichelper(Ainfo, user)

/obj/item/device/camera/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || !isturf(target.loc))
		return

	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
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
	to_chat(usr, "<B>Camera Mode deactivated</B>")

/obj/item/device/camera/siliconcam/proc/camera_mode_on()
	src.in_camera_mode = 1
	to_chat(usr, "<B>Camera Mode activated</B>")

/obj/item/device/camera/siliconcam/robot_camera/proc/borgprint()
	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	var/mob/living/silicon/robot/C = src.loc
	var/obj/item/device/camera/siliconcam/targetcam = null
	if(C.toner < 20)
		to_chat(usr, "Insufficent toner to print image.")
		return
	if(C.connected_ai)
		targetcam = C.connected_ai.aicamera
	else
		targetcam = C.aicamera
	if(targetcam.aipictures.len == 0)
		to_chat(usr, "<span class='userdanger'>No images saved</span>")
		return
	for(var/datum/picture/t in targetcam.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image (numbered in order taken)") in nametemp
	for(var/datum/picture/q in targetcam.aipictures)
		if(q.fields["name"] == find)
			selection = q
			break
	var/obj/item/weapon/photo/p = new /obj/item/weapon/photo(C.loc)
	p.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["mobinfo"], selection.fields["blueprints"])
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	C.toner -= 20	 //Cyborgs are very ineffeicient at printing an image
	visible_message("[IDENTITY_SUBJECT(1)] spits out a photograph from a narrow slot on its chassis.", subjects=list(C))
	to_chat(usr, "<span class='notice'>You print a photograph.</span>")

// Picture frames

/obj/item/weapon/picture_frame
	name = "picture frame"
	desc = "The perfect showcase for your favorite deathtrap memories."
	icon = 'icons/obj/decals.dmi'
	icon_state = "frame-empty"
	var/obj/item/weapon/photo/displayed

/obj/item/weapon/picture_frame/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/photo))
		if(!displayed)
			var/obj/item/weapon/photo/P = I
			if(!user.transferItemToLoc(P, src))
				return
			displayed = P
			update_icon()
		else
			to_chat(user, "<span class=notice>\The [src] already contains a photo.</span>")

	..()

/obj/item/weapon/picture_frame/attack_hand(mob/user)
	if(user.get_inactive_held_item() != src)
		..()
		return
	if(contents.len)
		var/obj/item/I = pick(contents)
		user.put_in_hands(I)
		to_chat(user, "<span class='notice'>You carefully remove the photo from \the [src].</span>")
		displayed = null
		update_icon()

/obj/item/weapon/picture_frame/attack_self(mob/user)
	user.examinate(src)

/obj/item/weapon/picture_frame/examine(mob/user)
	if(user.is_holding(src) && displayed)
		displayed.show(user)
	else
		..()

/obj/item/weapon/picture_frame/update_icon()
	cut_overlays()
	if(displayed)
		add_overlay(getFlatIcon(displayed))
	else
		icon_state = initial(icon_state)

/obj/item/weapon/picture_frame/afterattack(atom/target, mob/user, proximity)
	var/turf/T = target
	if(!iswallturf(T))
		return
	user.visible_message("<span class='notice'>[IDENTITY_SUBJECT(1)] fastens [src] to [T].</span>", \
						 "<span class='notice'>You attach the sign to [T].</span>", subjects=list(user))
	playsound(T, 'sound/items/Deconstruct.ogg', 50, 1)
	var/obj/structure/sign/picture_frame/PF = new /obj/structure/sign/picture_frame(T)
	PF.copy_overlays(src)
	if(displayed)
		PF.framed = displayed
	if(contents.len)
		var/obj/item/I = pick(contents)
		I.forceMove(PF)
	qdel(src)

/obj/structure/sign/picture_frame
	name = "picture frame"
	desc = "Every time you look it makes you laugh."
	icon = 'icons/obj/decals.dmi'
	icon_state = "frame-empty"
	var/obj/item/weapon/photo/framed

/obj/structure/sign/picture_frame/examine(mob/user)
	if(in_range(src, user) && framed)
		framed.show(user)
	else
		..()

/obj/structure/sign/picture_frame/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/screwdriver))
		user.visible_message("<span class='notice'>[IDENTITY_SUBJECT(1)] starts removing [src]...</span>", \
							 "<span class='notice'>You start unfastening [src].</span>", subjects=list(user))
		playsound(src, O.usesound, 50, 1)
		if(!do_after(user, 30*O.toolspeed, target = src))
			return
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("<span class='notice'>[IDENTITY_SUBJECT(1)] unfastens [src].</span>", \
							 "<span class='notice'>You unfasten [src].</span>", subjects=list(user))
		var/obj/item/weapon/picture_frame/F = new /obj/item/weapon/picture_frame(get_turf(user))
		if(framed)
			F.displayed = framed
			framed = null
		if(contents.len)
			var/obj/item/I = pick(contents)
			I.forceMove(F)
		F.update_icon()
		qdel(src)

	else if(istype(O, /obj/item/weapon/photo))
		if(!framed)
			var/obj/item/weapon/photo/P = O
			if(!user.transferItemToLoc(P, src))
				return
			framed = P
			update_icon()
		else
			to_chat(user, "<span class=notice>\The [src] already contains a photo.</span>")

	..()

/obj/structure/sign/picture_frame/attack_hand(mob/user)
	if(framed)
		framed.show()

/obj/structure/sign/picture_frame/update_icon()
	cut_overlays()
	if(framed)
		add_overlay(getFlatIcon(framed))
	else
		icon_state = initial(icon_state)