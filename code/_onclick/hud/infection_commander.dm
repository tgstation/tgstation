
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
	desc = "Moves your camera to a selected blob node."

/obj/screen/infection/JumpToNode/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.jump_to_node()

/obj/screen/infection/JumpToCore
	icon_state = "ui_tocore"
	name = "Jump to Core"
	desc = "Moves your camera to your blob core."

/obj/screen/infection/JumpToCore/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.transport_core()

/obj/screen/infection/Infesternaut
	icon_state = "ui_blobbernaut"
	name = "Produce Infesternaut (40)"
	desc = "Produces a strong, smart infesternaut from a factory infection for 40 resources.<br>The factory infection used will become fragile and unable to produce spores."

/obj/screen/infection/Infesternaut/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.create_infesternaut()

/obj/screen/infection/ResourceInfection
	icon_state = "ui_resource"
	name = "Produce Resource Infection (40)"
	desc = "Produces a resource infection for 40 resources.<br>Resource infections will give you resources every few seconds."

/obj/screen/infection/ResourceInfection/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.create_resource()

/obj/screen/infection/NodeInfection
	icon_state = "ui_node"
	name = "Produce Node Infection (50)"
	desc = "Produces a node infection for 50 resources.<br>Node infections will expand and activate nearby resource and factory infections."

/obj/screen/infection/NodeInfection/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.create_node()

/obj/screen/infection/FactoryInfection
	icon_state = "ui_factory"
	name = "Produce Factory Infection (60)"
	desc = "Produces a factory infection for 60 resources.<br>Factory infections will produce spores every few seconds."

/obj/screen/infection/FactoryInfection/Click()
	if(iscommander(usr))
		var/mob/camera/commander/I = usr
		I.create_factory()

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

	using = new /obj/screen/infection/InfectionHelp()
	using.screen_loc = "WEST:6,NORTH:-3"
	static_inventory += using

	using = new /obj/screen/infection/JumpToNode()
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/infection/JumpToCore()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /obj/screen/infection/Infesternaut()
	using.screen_loc = ui_belt
	static_inventory += using

	using = new /obj/screen/infection/ResourceInfection()
	using.screen_loc = ui_back
	static_inventory += using

	using = new /obj/screen/infection/NodeInfection()
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /obj/screen/infection/FactoryInfection()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new /obj/screen/infection/Evolve()
	using.screen_loc = ui_storage1
	static_inventory += using
