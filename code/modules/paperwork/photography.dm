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
/obj/item/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items_and_weapons.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	materials = list(MAT_METAL = 10, MAT_GLASS = 10)

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
	var/icon/img		//Big photo image
	var/scribble		//Scribble on the back.
	var/blueprints = 0	//Does it include the blueprints?
	var/sillynewscastervar  //Photo objects with this set to 1 will not be ejected by a newscaster. Only gets set to 1 if a silicon puts one of their images into a newscaster

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
	user << browse_rsc(img, "tmp_photo.png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=book;size=192x[scribble ? 400 : 192]")
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

/obj/item/photo/proc/photocreate(inicon, inimg, indesc, inblueprints)
	icon = inicon
	img = inimg
	desc = indesc
	blueprints = inblueprints

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

/obj/item/storage/photo_album/Initialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.can_hold = typecacheof(list(/obj/item/photo))

/*
 * Camera
 */
/obj/item/camera
	name = "camera"
	icon = 'icons/obj/items_and_weapons.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	item_state = "electropack"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 50, MAT_GLASS = 150)
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = TRUE
	var/blueprints = 0	//are blueprints visible in the current photo being created?
	var/list/aipictures = list() //Allows for storage of pictures taken by AI, in a similar manner the datacore stores info. Keeping this here allows us to share some procs w/ regualar camera
	var/see_ghosts = 0 //for the spoop of it
	var/obj/item/disk/holodisk/disk


/obj/item/camera/CheckParts(list/parts_list)
	..()
	var/obj/item/camera/C = locate(/obj/item/camera) in contents
	if(C)
		pictures_max = C.pictures_max
		pictures_left = C.pictures_left
		visible_message("[C] has been imbued with godlike power!")
		qdel(C)


/obj/item/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = 1

/obj/item/camera/detective
	name = "Detective's camera"
	desc = "A polaroid camera with extra capacity for crime investigations."
	pictures_max = 30
	pictures_left = 30


/obj/item/camera/siliconcam //camera AI can take pictures with
	name = "silicon photo camera"
	var/in_camera_mode = 0

/obj/item/camera/siliconcam/ai_camera //camera AI can take pictures with
	name = "AI photo camera"

/obj/item/camera/siliconcam/robot_camera //camera cyborgs can take pictures with.. needs it's own because of verb CATEGORY >.>
	name = "Cyborg photo camera"

/obj/item/camera/siliconcam/robot_camera/verb/borgprinting()
	set category ="Robot Commands"
	set name = "Print Image"
	set src in usr

	if(usr.stat == DEAD)
		return //won't work if dead
	borgprint()

/obj/item/camera/attack(mob/living/carbon/human/M, mob/user)
	return


/obj/item/camera/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/camera_film))
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		qdel(I)
		pictures_left = pictures_max
		return
	if(istype(I, /obj/item/disk/holodisk))
		if (!disk)
			if(!user.transferItemToLoc(I, src))
				to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
				return TRUE
			to_chat(user, "<span class='notice'>You slide [I] into the back of [src].</span>")
			disk = I
		else
			to_chat(user, "<span class='warning'>There's already a disk inside [src].</span>")
		return TRUE //no afterattack
	..()

/obj/item/camera/attack_self(mob/user)
	if(!disk)
		return
	to_chat(user, "<span class='notice'>You eject [disk] out the back of [src].</span>")
	user.put_in_hands(disk)
	disk = null

/obj/item/camera/examine(mob/user)
	..()
	to_chat(user, "It has [pictures_left] photo\s left.")


/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center)
	var/list/atoms = list()
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

	var/list/sorted = sortTim(atoms,/proc/cmp_atom_layer_asc)

	var/icon/res = icon('icons/effects/96x96.dmi', "")

	for(var/atom/A in sorted)
		var/icon/img = getFlatIcon(A, no_anim = TRUE)
		if(isliving(A))
			var/mob/living/L = A
			if(L.lying)
				img.Turn(L.lying)

		var/offX = world.icon_size * (A.x - center.x) + A.pixel_x + 33
		var/offY = world.icon_size * (A.y - center.y) + A.pixel_y + 33
		if(ismovableatom(A))
			var/atom/movable/AM = A
			offX += AM.step_x
			offY += AM.step_y

		res.Blend(img, blendMode2iconMode(A.blend_mode), offX, offY)

		if(istype(A, /obj/item/areaeditor/blueprints))
			blueprints = 1

	for(var/turf/T in turfs)
		var/area/A = T.loc
		if(A.icon_state)//There's actually something to blend in.
			res.Blend(getFlatIcon(A,no_anim = TRUE), blendMode2iconMode(A.blend_mode), world.icon_size * (T.x - center.x) + 33, world.icon_size * (T.y - center.y) + 33)

	return res


/obj/item/camera/proc/camera_get_mobs(turf/the_turf)
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
					holding += "[L.p_theyre(TRUE)] holding \a [I]"
				else
					holding += " and \a [I]"
			holding = holding.Join()

			if(!mob_detail)
				mob_detail = "You can see [L] on the photo[L.health < (L.maxHealth * 0.75) ? " - [L] looks hurt":""].[holding ? " [holding]":"."]. "
			else
				mob_detail += "You can also see [L] on the photo[L.health < (L.maxHealth * 0.75) ? " - [L] looks hurt":""].[holding ? " [holding]":"."]."


	return mob_detail


/obj/item/camera/proc/captureimage(atom/target, mob/user, flag)  //Proc for both regular and AI-based camera to take the image
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
			if(isAi && !GLOB.cameranet.checkTurfVis(T))
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




/obj/item/camera/proc/printpicture(mob/user, icon/temp, mobs, flag) //Normal camera proc for creating photos
	var/obj/item/photo/P = new/obj/item/photo(get_turf(src))
	if(in_range(src, user)) //needed because of TK
		user.put_in_hands(P)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items_and_weapons.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
	P.icon = ic
	P.img = temp
	P.desc = mobs
	P.pixel_x = rand(-10, 10)
	P.pixel_y = rand(-10, 10)

	if(blueprints)
		P.blueprints = 1
		blueprints = 0


/obj/item/camera/proc/aipicture(mob/user, icon/temp, mobs, isAi) //instead of printing a picture like a regular camera would, we do this instead for the AI

	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items_and_weapons.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
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


/obj/item/camera/proc/injectaialbum(icon, img, desc, pixel_x, pixel_y, blueprintsinject) //stores image information to a list similar to that of the datacore
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
	to_chat(usr, "<span class='unconscious'>Image recorded</span>") //feedback to the AI player that the picture was taken

/obj/item/camera/proc/injectmasteralbum(icon, img, desc, pixel_x, pixel_y, blueprintsinject) //stores image information to a list similar to that of the datacore
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
		to_chat(usr, "<span class='unconscious'>Image recorded and saved to remote database</span>") //feedback to the Cyborg player that the picture was taken
	else
		injectaialbum(icon, img, desc, pixel_x, pixel_y, blueprintsinject)

/obj/item/camera/siliconcam/proc/selectpicture(obj/item/camera/siliconcam/targetloc)
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

/obj/item/camera/siliconcam/proc/viewpichelper(obj/item/camera/siliconcam/targetloc)
	var/obj/item/photo/P = new/obj/item/photo()
	var/datum/picture/selection = selectpicture(targetloc)
	if(selection)
		P.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["desc"])
		P.pixel_x = selection.fields["pixel_x"]
		P.pixel_y = selection.fields["pixel_y"]

		P.show(usr)
		to_chat(usr, P.desc)
	qdel(P)    //so 10 thousand picture items are not left in memory should an AI take them and then view them all

/obj/item/camera/siliconcam/proc/viewpictures(user)
	if(iscyborg(user)) // Cyborg
		var/mob/living/silicon/robot/C = src.loc
		var/obj/item/camera/siliconcam/Cinfo
		if(C.connected_ai)
			Cinfo = C.connected_ai.aicamera
			viewpichelper(Cinfo)
		else
			Cinfo = C.aicamera
			viewpichelper(Cinfo)
	else // AI
		var/Ainfo = src
		viewpichelper(Ainfo)

/obj/item/camera/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(!on || !pictures_left || !isturf(target.loc))
		return
	if (disk)
		if(ismob(target))
			if (disk.record)
				QDEL_NULL(disk.record)

			disk.record = new
			var/mob/M = target
			disk.record.caller_name = M.name
			disk.record.set_caller_image(M)
		else
			return
	else
		captureimage(target, user, flag)
		pictures_left--
		to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	icon_state = "camera_off"
	on = FALSE
	addtimer(CALLBACK(src, .proc/cooldown), 64)

/obj/item/camera/proc/cooldown()
	set waitfor = FALSE
	icon_state = "camera"
	on = TRUE

/obj/item/camera/siliconcam/proc/toggle_camera_mode()
	if(in_camera_mode)
		camera_mode_off()
	else
		camera_mode_on()

/obj/item/camera/siliconcam/proc/camera_mode_off()
	src.in_camera_mode = 0
	to_chat(usr, "<B>Camera Mode deactivated</B>")

/obj/item/camera/siliconcam/proc/camera_mode_on()
	src.in_camera_mode = 1
	to_chat(usr, "<B>Camera Mode activated</B>")

/obj/item/camera/siliconcam/robot_camera/proc/borgprint()
	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	var/mob/living/silicon/robot/C = src.loc
	var/obj/item/camera/siliconcam/targetcam = null
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
	var/obj/item/photo/p = new /obj/item/photo(C.loc)
	p.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["desc"], selection.fields["blueprints"])
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	C.toner -= 20	 //Cyborgs are very ineffeicient at printing an image
	visible_message("[C.name] spits out a photograph from a narrow slot on its chassis.")
	to_chat(usr, "<span class='notice'>You print a photograph.</span>")

// Picture frames

/obj/item/wallframe/picture
	name = "picture frame"
	desc = "The perfect showcase for your favorite deathtrap memories."
	icon = 'icons/obj/decals.dmi'
	materials = list()
	flags_1 = 0
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/picture_frame
	var/obj/item/photo/displayed

/obj/item/wallframe/picture/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/photo))
		if(!displayed)
			if(!user.transferItemToLoc(I, src))
				return
			displayed = I
			update_icon()
		else
			to_chat(user, "<span class=notice>\The [src] already contains a photo.</span>")
	..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/wallframe/picture/attack_hand(mob/user)
	if(user.get_inactive_held_item() != src)
		..()
		return
	if(contents.len)
		var/obj/item/I = pick(contents)
		user.put_in_hands(I)
		to_chat(user, "<span class='notice'>You carefully remove the photo from \the [src].</span>")
		displayed = null
		update_icon()
	return ..()

/obj/item/wallframe/picture/attack_self(mob/user)
	user.examinate(src)

/obj/item/wallframe/picture/examine(mob/user)
	if(user.is_holding(src) && displayed)
		displayed.show(user)
	else
		..()

/obj/item/wallframe/picture/update_icon()
	cut_overlays()
	if(displayed)
		add_overlay(getFlatIcon(displayed))

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
	icon_state = "frame-empty"
	var/obj/item/photo/framed

/obj/structure/sign/picture_frame/New(loc, dir, building)
	..()
	if(dir)
		setDir(dir)
	if(building)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -30 : 30)
		pixel_y = (dir & 3)? (dir ==1 ? -30 : 30) : 0

/obj/structure/sign/picture_frame/examine(mob/user)
	if(in_range(src, user) && framed)
		framed.show(user)
	else
		..()

/obj/structure/sign/picture_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver) || istype(I, /obj/item/wrench))
		to_chat(user, "<span class='notice'>You start unsecuring [name]...</span>")
		if(I.use_tool(src, user, 30, volume=50))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You unsecure [name].</span>")
			deconstruct()
		return

	else if(istype(I, /obj/item/photo))
		if(!framed)
			var/obj/item/photo/P = I
			if(!user.transferItemToLoc(P, src))
				return
			framed = P
			update_icon()
		else
			to_chat(user, "<span class=notice>\The [src] already contains a photo.</span>")

	..()

/obj/structure/sign/picture_frame/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(framed)
		framed.show(user)

/obj/structure/sign/picture_frame/update_icon()
	cut_overlays()
	if(framed)
		add_overlay(getFlatIcon(framed))

/obj/structure/sign/picture_frame/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/item/wallframe/picture/F = new /obj/item/wallframe/picture(loc)
		if(framed)
			F.displayed = framed
			framed = null
		if(contents.len)
			var/obj/item/I = pick(contents)
			I.forceMove(F)
		F.update_icon()
	qdel(src)
