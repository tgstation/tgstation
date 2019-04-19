/obj/screen/pai
	icon = 'icons/mob/screen_pai.dmi'

/obj/screen/pai/Click()
	if(isobserver(usr) || usr.incapacitated())
		return TRUE

/obj/screen/pai/software
	name = "Software Interface"
	icon_state = "pai"


/obj/screen/pai/software/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	pAI.paiInterface()

/obj/screen/pai/shell
	name = "Toggle Holoform"
	icon_state = "pai_holoform"

/obj/screen/pai/shell/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	if(pAI.holoform)
		pAI.fold_in(0)
	else
		pAI.fold_out()

/obj/screen/pai/chassis
	name = "Holochassis Appearance Composite"
	icon_state = "pai_chassis"

/obj/screen/pai/chassis/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	pAI.choose_chassis()

/obj/screen/pai/rest
	name = "Rest"
	icon_state = "pai_rest"

/obj/screen/pai/rest/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	pAI.lay_down()

/obj/screen/pai/light
	name = "Toggle Integrated Lights"
	icon_state = "light"

/obj/screen/pai/light/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	pAI.toggle_integrated_light()

/obj/screen/pai/newscaster
	name = "pAI Newscaster"
	icon_state = "newscaster"

/obj/screen/pai/newscaster/Click()
	var/mob/living/silicon/pai/pAI = usr
	pAI.newscaster.ui_interact(usr)

/obj/screen/pai/image_take
	name = "Take Image"
	icon_state = "take_picture"

/obj/screen/pai/image_take/Click()
	if(..())
		return
	if(issilicon(usr))
		var/mob/living/silicon/ai/pAI = usr
		pAI.aicamera.toggle_camera_mode(usr)

/obj/screen/pai/image_view
	name = "View Images"
	icon_state = "view_images"

/obj/screen/pai/image_view/Click()
	if(..())
		return
	if(issilicon(usr))
		var/mob/living/silicon/ai/pAI = usr
		pAI.aicamera.viewpictures(usr)

/datum/hud/pai/New(mob/owner)
	..()
	var/obj/screen/using

// Software menu
	using = new /obj/screen/pai/software
	using.screen_loc = ui_pai_software
	static_inventory += using

// Holoform
	using = new /obj/screen/pai/shell
	using.screen_loc = ui_pai_shell
	static_inventory += using

// Chassis Select Menu
	using = new /obj/screen/pai/chassis
	using.screen_loc = ui_pai_chassis
	static_inventory += using

// Rest
	using = new /obj/screen/pai/rest
	using.screen_loc = ui_pai_rest
	static_inventory += using

// Integrated Light
	using = new /obj/screen/pai/light
	using.screen_loc = ui_pai_light
	static_inventory += using

// Newscaster
	using = new /obj/screen/pai/newscaster
	using.screen_loc = ui_pai_newscaster
	static_inventory += using

// Language menu
	using = new /obj/screen/language_menu
	using.screen_loc = ui_borg_language_menu
	static_inventory += using

//Take image
	using = new /obj/screen/pai/image_take()
	using.screen_loc = ui_pai_take_picture
	static_inventory += using

//View images
	using = new /obj/screen/pai/image_view()
	using.screen_loc = ui_pai_view_images
	static_inventory += using