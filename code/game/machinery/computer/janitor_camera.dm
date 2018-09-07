
/mob/camera/aiEye/remote/janitor
	visible_icon = 1
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera_target"
	color = COLOR_PURPLE
	var/allowed_area = null

/mob/camera/aiEye/remote/janitor/Initialize()
	var/area/A = get_area(loc)
	allowed_area = A.name
	. = ..()

/mob/camera/aiEye/remote/janitor/setLoc(var/t)
	var/area/new_area = get_area(t)
	if(new_area && new_area.name == allowed_area || new_area && new_area.janicam_compatible)
		return ..()
	else
		return

/obj/machinery/computer/camera_advanced/janitor
	name = "Janitorial console"
	desc = "A computer used for remotely handling station cleaning duties."
	networks = list("ss13")
	circuit = /obj/item/circuitboard/computer/janicam
	var/datum/reagents/spray_reagents

	var/datum/action/innate/get_garbage/get_garbage_action
	var/datum/action/innate/camera_clean/camera_clean_action

	icon_screen = "slime_comp"
	icon_keyboard = "rd_key"

	light_color = LIGHT_COLOR_PURPLE

/obj/machinery/computer/camera_advanced/janitor/Initialize()
	. = ..()
	get_garbage_action = new /datum/action/innate/get_garbage()
	camera_clean_action = new /datum/action/innate/camera_clean()

	spray_reagents = new /datum/reagents(5)
	spray_reagents.add_reagent("cleaner", 5)

/obj/machinery/computer/camera_advanced/janitor/Destroy()
	return ..()

/obj/machinery/computer/camera_advanced/janitor/CreateEye()
	eyeobj = new /mob/camera/aiEye/remote/janitor(get_turf(src))
	eyeobj.origin = src
	eyeobj.visible_icon = 1
	eyeobj.icon = 'icons/obj/abductor.dmi'
	eyeobj.icon_state = "camera_target"

/obj/machinery/computer/camera_advanced/janitor/GrantActions(mob/living/user)
	..()

	if(get_garbage_action)
		get_garbage_action.target = src
		get_garbage_action.Grant(user)
		actions += get_garbage_action

	if(camera_clean_action)
		camera_clean_action.target = src
		camera_clean_action.Grant(user)
		actions += camera_clean_action


/datum/action/innate/get_garbage
	name = "Pickup Garbage"
	icon_icon = 'icons/obj/janitor.dmi'
	button_icon_state = "trashbag2"

/datum/action/innate/get_garbage/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/aiEye/remote/janitor/remote_eye = C.remote_control

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		for(var/obj/item/trash/T in remote_eye.loc)
			T.visible_message("<span class='notice'>[T] warps away!</span>")
			qdel(T)
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/camera_clean
	name = "Clean"
	icon_icon = 'icons/obj/janitor.dmi'
	button_icon_state = "cleaner"

/datum/action/innate/camera_clean/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/aiEye/remote/janitor/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/janitor/console = target

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		playsound(remote_eye.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
		var/obj/effect/decal/chempuff/D = new /obj/effect/decal/chempuff(remote_eye.loc)
		D.color = mix_color_from_reagents(console.spray_reagents.reagent_list)
		QDEL_IN(D, 5)
		for(var/atom/A in remote_eye.loc)
			if(A.invisibility)
				continue
			console.spray_reagents.reaction(A, VAPOR)
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")



/obj/item/janipermit
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	name = "advanced sanitation permits"
	desc = "A set of permits used to designate areas for cleaning with the janitorial console."
	color = COLOR_PURPLE

/obj/item/janipermit/attack_self(mob/user)
	var/area/A = get_area(src)
	if(A)
		if(user)
			if(A.janicam_compatible)
				to_chat(user, "<span class='notice'>This area is already marked as valid for advanced sanitation systems.</span>")
			else
				to_chat(user, "<span class='notice'>You mark the area for remote cleaning.</span>")
				A.janicam_compatible = TRUE
	else
		to_chat(user, "<span class='notice'>This area cannot be marked for cleaning.</span>")
