
/obj/screen/infection
	icon = 'icons/mob/blob.dmi'

/obj/screen/infection/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/obj/screen/infection/MouseExited()
	closeToolTip(usr)

/obj/screen/infection/InfectionHelp
	icon_state = "ui_help"
	name = "Infection Help"
	desc = "Help on playing the infection!"

/obj/screen/infection/InfectionHelp/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.infection_help()

/obj/screen/infection/JumpToNode
	icon_state = "ui_tonode"
	name = "Jump to Node"
	desc = "Moves your camera to a selected node."

/obj/screen/infection/JumpToNode/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.jump_to_node()

/obj/screen/infection/JumpToCore
	icon_state = "ui_tocore"
	name = "Jump to Core"
	desc = "Moves your camera to your core."

/obj/screen/infection/JumpToCore/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.transport_core()

/obj/screen/infection/Evolve
	icon_state = "ui_swap"
	name = "Evolution"
	desc = "Purchase traits that make you stronger."

/obj/screen/infection/Evolve/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.evolve_menu()

/datum/hud/infection_commander/New(mob/owner)
	..()
	var/obj/screen/using

	infectionpwrdisplay = new /obj/screen()
	infectionpwrdisplay.name = "infection power"
	infectionpwrdisplay.icon_state = "block"
	infectionpwrdisplay.screen_loc = ui_health
	infectionpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	infectionpwrdisplay.layer = ABOVE_HUD_LAYER
	infectionpwrdisplay.plane = ABOVE_HUD_PLANE
	infodisplay += infectionpwrdisplay

	healths = new /obj/screen/healths/blob()
	infodisplay += healths

	using = new /obj/screen/infection/JumpToNode()
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/infection/JumpToCore()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /obj/screen/infection/Evolve()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new /obj/screen/infection/InfectionHelp()
	using.screen_loc = ui_hand_position(2)
	static_inventory += using