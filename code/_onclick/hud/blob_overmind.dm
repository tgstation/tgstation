
/obj/screen/blob
	icon = 'icons/mob/blob.dmi'

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

/obj/screen/blob/JumpToCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.transport_core()

/obj/screen/blob/Blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Produce Blobbernaut (30)"
	desc = "Produces a blobbernaut for 30 points."

/obj/screen/blob/Blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/obj/screen/blob/ResourceBlob
	icon_state = "ui_resource"
	name = "Produce Resource Blob (40)"
	desc = "Produces a resource blob for 40 points."

/obj/screen/blob/ResourceBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource()

/obj/screen/blob/NodeBlob
	icon_state = "ui_node"
	name = "Produce Node Blob (60)"
	desc = "Produces a node blob for 60 points."

/obj/screen/blob/NodeBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node()

/obj/screen/blob/FactoryBlob
	icon_state = "ui_factory"
	name = "Produce Factory Blob (60)"
	desc = "Produces a resource blob for 60 points."

/obj/screen/blob/FactoryBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory()

/obj/screen/blob/ReadaptChemical
	icon_state = "ui_chemswap"
	name = "Readapt Chemical (40)"
	desc = "Randomly rerolls your chemical for 40 points."

/obj/screen/blob/ReadaptChemical/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.chemical_reroll()

/obj/screen/blob/RelocateCore
	icon_state = "ui_swap"
	name = "Relocate Core (80)"
	desc = "Swaps a node and your core for 80 points."

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
	blobpwrdisplay.mouse_opacity = 0
	blobpwrdisplay.layer = 20
	infodisplay += blobpwrdisplay

	healths = new /obj/screen/healths/blob()
	static_inventory += healths

	using = new /obj/screen/blob/BlobHelp()
	using.screen_loc = "NORTH:-6,WEST:6"
	static_inventory += using

	using = new /obj/screen/blob/JumpToNode()
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/blob/JumpToCore()
	using.screen_loc = ui_zonesel
	static_inventory += using

	using = new /obj/screen/blob/Blobbernaut()
	using.screen_loc = ui_belt
	static_inventory += using

	using = new /obj/screen/blob/ResourceBlob()
	using.screen_loc = ui_back
	static_inventory += using

	using = new /obj/screen/blob/NodeBlob()
	using.screen_loc = ui_lhand
	static_inventory += using

	using = new /obj/screen/blob/FactoryBlob()
	using.screen_loc = ui_rhand
	static_inventory += using

	using = new /obj/screen/blob/ReadaptChemical()
	using.screen_loc = ui_storage1
	static_inventory += using

	using = new /obj/screen/blob/RelocateCore()
	using.screen_loc = ui_storage2
	static_inventory += using


/mob/camera/blob/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/blob_overmind(src)


