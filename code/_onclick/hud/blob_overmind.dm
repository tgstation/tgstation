
/obj/screen/blob
	icon = 'icons/mob/blob.dmi'

/obj/screen/blob/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/obj/screen/blob/MouseExited()
	closeToolTip(usr)

/obj/screen/blob/BlobHelp
	icon_state = "ui_help"
	name = "Blob Help"
	desc = "Help on playing blob!"

/obj/screen/blob/BlobHelp/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/obj/screen/blob/JumpToNode
	icon_state = "ui_tonode"
	name = "Jump to Node"
	desc = "Moves your camera to a selected blob node."

/obj/screen/blob/JumpToNode/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/obj/screen/blob/JumpToCore
	icon_state = "ui_tocore"
	name = "Jump to Core"
	desc = "Moves your camera to your blob core."

/obj/screen/blob/JumpToCore/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		var/mob/camera/blob/B = hud.mymob
		if(!B.placed)
			name = "Place Blob Core"
			desc = "Attempt to place your blob core at this location."
		else
			name = initial(name)
			desc = initial(desc)
	..()

/obj/screen/blob/JumpToCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		if(!B.placed)
			B.place_blob_core(B.base_point_rate, 0)
		B.transport_core()

/obj/screen/blob/Blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Produce Blobbernaut (40)"
	desc = "Produces a strong, smart blobbernaut from a factory blob for 40 resources.<br>The factory blob used will become fragile and unable to produce spores."

/obj/screen/blob/Blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/obj/screen/blob/ResourceBlob
	icon_state = "ui_resource"
	name = "Produce Resource Blob (40)"
	desc = "Produces a resource blob for 40 resources.<br>Resource blobs will give you resources every few seconds."

/obj/screen/blob/ResourceBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource()

/obj/screen/blob/NodeBlob
	icon_state = "ui_node"
	name = "Produce Node Blob (50)"
	desc = "Produces a node blob for 50 resources.<br>Node blobs will expand and activate nearby resource and factory blobs."

/obj/screen/blob/NodeBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node()

/obj/screen/blob/FactoryBlob
	icon_state = "ui_factory"
	name = "Produce Factory Blob (60)"
	desc = "Produces a factory blob for 60 resources.<br>Factory blobs will produce spores every few seconds."

/obj/screen/blob/FactoryBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory()

/obj/screen/blob/ReadaptChemical
	icon_state = "ui_chemswap"
	name = "Readapt Chemical (40)"
	desc = "Randomly rerolls your chemical for 40 resources."

/obj/screen/blob/ReadaptChemical/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		var/mob/camera/blob/B = hud.mymob
		if(B.free_chem_rerolls)
			name = "Readapt Chemical (FREE)"
			desc = "Randomly rerolls your chemical for free."
		else
			name = initial(name)
			desc = initial(desc)
	..()

/obj/screen/blob/ReadaptChemical/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.chemical_reroll()

/obj/screen/blob/RelocateCore
	icon_state = "ui_swap"
	name = "Relocate Core (80)"
	desc = "Swaps a node and your core for 80 resources."

/obj/screen/blob/RelocateCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()

/datum/hud/blob_overmind/New(mob/owner)
	..()
	var/obj/screen/using

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	blobpwrdisplay.plane = ABOVE_HUD_PLANE
	infodisplay += blobpwrdisplay

	healths = new /obj/screen/healths/blob()
	infodisplay += healths

	using = new /obj/screen/blob/BlobHelp()
	using.screen_loc = "WEST:6,NORTH:-3"
	static_inventory += using

	using = new /obj/screen/blob/JumpToNode()
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/blob/JumpToCore()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/Blobbernaut()
	using.screen_loc = ui_belt
	static_inventory += using

	using = new /obj/screen/blob/ResourceBlob()
	using.screen_loc = ui_back
	static_inventory += using

	using = new /obj/screen/blob/NodeBlob()
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /obj/screen/blob/FactoryBlob()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new /obj/screen/blob/ReadaptChemical()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/RelocateCore()
	using.screen_loc = ui_storage2
	static_inventory += using
