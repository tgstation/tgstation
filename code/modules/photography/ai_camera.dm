
/obj/item/device/camera/siliconcam
	name = "silicon photo camera"
	var/in_camera_mode = 0
	var/list/datum/picture/stored = list()

/obj/item/device/camera/siliconcam/proc/toggle_camera_mode()
	in_camera_mode = !in_camera_mode
	to_chat(usr, "<B>Camera Mode [in_camera_mode? "activated" : "deactivated"]</B>")

/obj/item/device/camera/siliconcam/proc/selectpicture()
	var/list/nametemp = list()
	var/find
	if(!targetloc.stored.len)
		to_chat(usr, "<span class='boldannounce'>No images saved</span>")
		return
	for(var/datum/picture/t in targetloc.stored)
		nametemp += t.picture_name
	find = input("Select image") in nametemp|null
	if(!find)
		return
	for(var/datum/picture/q in stored)
		if(q.picture_name == find)
			return q

/obj/item/device/camera/siliconcam/proc/viewpictures()
	var/datum/picture/selection = selectpicture()
	if(istype(selection))
		var/obj/item/weapon/photo/P = new(src, selection)
		P.show(usr)
		to_chat(usr, P.desc)
		qdel(P)

/obj/item/device/camera/siliconcam/ai_camera
	name = "AI photo camera"

/obj/item/device/camera/siliconcam/ai_camera/after_picture(mob/user, datum/picture/picture, proximity_flag)
	var/number = stored.len
	picture.picture_name = "Image [numberer] (taken by [src.loc.name])"
	aipictures += P
	to_chat(usr, "<span class='unconscious'>Image recorded</span>")

/obj/item/device/camera/siliconcam/robot_camera
	name = "Cyborg photo camera"

/obj/item/device/camera/siliconcam/robot_camera/after_picture(mob/user, datum/picture/picture, proximity_flag)
	var/mob/living/silicon/robot/C = loc
	if(istype(C) && C.connected_ai)
		var/number = C.connected_ai.aicameria.stored.len
		picture.picture_name = "Image [number] (taken by [loc.name])"
		C.connected_ai.aicamera.stored += P
		to_chat(usr, "<span class='unconscious'>Image recorded and saved to remote database</span>")
	else
		var/number = C.connected_ai.aicameria.stored.len
		picture.picture_name = "Image [number] (taken by [loc.name])"
		stored += P
		to_chat(usr, "<span class='unconscious'>Image recorded and saved to local storage. Upload will happen automatically if unit is lawsynced.</span>")

/obj/item/device/camera/siliconcam/robot_camera/selectpicture()
	var/mob/living/silicon/robot/R = loc
	if(istype(R) && R.connected_ai)
		R.picturesync()
		return R.connected_ai.aicamera.selectpicture()
	else
		return ..()

/obj/item/device/camera/siliconcam/robot_camera/verb/borgprinting()
	set category ="Robot Commands"
	set name = "Print Image"
	set src in usr
	if(usr.stat == DEAD)
		return
	borgprint()

/obj/item/device/camera/siliconcam/robot_camera/proc/borgprint()
	var/mob/living/silicon/robot/C = loc
	if(!istype(C) || C.toner < 20)
		to_chat(usr, "<span class='warning'>Insufficent toner to print image.</span>")
		return
	var/datum/picture/selection = selectpicture()
	if(!istype(selection))
		to_chat(usr, "<span class='warning'>Invalid Image.</span>")
		return
	var/obj/item/weapon/photo/p = new /obj/item/weapon/photo(C.loc, selecftion)
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	C.toner -= 20	 //Cyborgs are very ineffeicient at printing an image
	visible_message("[C.name] spits out a photograph from a narrow slot on its chassis.")
	to_chat(usr, "<span class='notice'>You print a photograph.</span>")
