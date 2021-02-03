
/atom/movable/screen/blob
	icon = 'icons/hud/blob.dmi'

/atom/movable/screen/blob/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/atom/movable/screen/blob/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/blob/blob_help
	icon_state = "ui_help"
	name = "Blob Help"
	desc = "Help on playing blob!"

/atom/movable/screen/blob/blob_help/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/atom/movable/screen/blob/jump_to_node
	icon_state = "ui_tonode"
	name = "Jump to Node"
	desc = "Moves your camera to a selected blob node."

/atom/movable/screen/blob/jump_to_node/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/atom/movable/screen/blob/jump_to_core
	icon_state = "ui_tocore"
	name = "Jump to Core"
	desc = "Moves your camera to your blob core."

/atom/movable/screen/blob/jump_to_core/MouseEntered(location,control,params)
	if(hud?.mymob && isovermind(hud.mymob))
		var/mob/camera/blob/B = hud.mymob
		if(!B.placed)
			name = "Place Blob Core"
			desc = "Attempt to place your blob core at this location."
		else
			name = initial(name)
			desc = initial(desc)
	..()

/atom/movable/screen/blob/jump_to_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		if(!B.placed)
			B.place_blob_core(0)
		B.transport_core()

/atom/movable/screen/blob/blobbernaut
	icon_state = "ui_blobbernaut"
	// Name and description get given their proper values on Initialize()
	name = "Produce Blobbernaut (ERROR)"
	desc = "Produces a strong, smart blobbernaut from a factory blob for (ERROR) resources.<br>The factory blob used will become fragile and unable to produce spores."

/atom/movable/screen/blob/blobbernaut/Initialize()
	. = ..()
	name = "Produce Blobbernaut ([BLOBMOB_BLOBBERNAUT_RESOURCE_COST])"
	desc = "Produces a strong, smart blobbernaut from a factory blob for [BLOBMOB_BLOBBERNAUT_RESOURCE_COST] resources.<br>The factory blob used will become fragile and unable to produce spores."

/atom/movable/screen/blob/blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/atom/movable/screen/blob/resource_blob
	icon_state = "ui_resource"
	// Name and description get given their proper values on Initialize()
	name = "Produce Resource Blob (ERROR)"
	desc = "Produces a resource blob for ERROR resources.<br>Resource blobs will give you resources every few seconds."

/atom/movable/screen/blob/resource_blob/Initialize()
	. = ..()
	name = "Produce Resource Blob ([BLOB_STRUCTURE_RESOURCE_COST])"
	desc = "Produces a resource blob for [BLOB_STRUCTURE_RESOURCE_COST] resources.<br>Resource blobs will give you resources every few seconds."

/atom/movable/screen/blob/resource_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.createSpecial(BLOB_STRUCTURE_RESOURCE_COST, /obj/structure/blob/special/resource, BLOB_RESOURCE_MIN_DISTANCE, TRUE)

/atom/movable/screen/blob/node_blob
	icon_state = "ui_node"
	// Name and description get given their proper values on Initialize()
	name = "Produce Node Blob (ERROR)"
	desc = "Produces a node blob for ERROR resources.<br>Node blobs will expand and activate nearby resource and factory blobs."

/atom/movable/screen/blob/node_blob/Initialize()
	. = ..()
	name = "Produce Node Blob ([BLOB_STRUCTURE_NODE_COST])"
	desc = "Produces a node blob for [BLOB_STRUCTURE_NODE_COST] resources.<br>Node blobs will expand and activate nearby resource and factory blobs."

/atom/movable/screen/blob/node_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.createSpecial(BLOB_STRUCTURE_NODE_COST, /obj/structure/blob/special/node, BLOB_NODE_MIN_DISTANCE, FALSE)

/atom/movable/screen/blob/factory_blob
	icon_state = "ui_factory"
	// Name and description get given their proper values on Initialize()
	name = "Produce Factory Blob (ERROR)"
	desc = "Produces a factory blob for ERROR resources.<br>Factory blobs will produce spores every few seconds."

/atom/movable/screen/blob/factory_blob/Initialize()
	. = ..()
	name = "Produce Factory Blob ([BLOB_STRUCTURE_FACTORY_COST])"
	desc = "Produces a factory blob for [BLOB_STRUCTURE_FACTORY_COST] resources.<br>Factory blobs will produce spores every few seconds."

/atom/movable/screen/blob/factory_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.createSpecial(BLOB_STRUCTURE_FACTORY_COST, /obj/structure/blob/special/factory, BLOB_FACTORY_MIN_DISTANCE, TRUE)

/atom/movable/screen/blob/readapt_strain
	icon_state = "ui_chemswap"
	// Description gets given its proper values on Initialize()
	name = "Readapt Strain"
	desc = "Allows you to choose a new strain from ERROR random choices for ERROR resources."

/atom/movable/screen/blob/readapt_strain/MouseEntered(location,control,params)
	if(hud?.mymob && isovermind(hud.mymob))
		var/mob/camera/blob/B = hud.mymob
		if(B.free_strain_rerolls)
			name = "[initial(name)] (FREE)"
			desc = "Randomly rerolls your strain for free."
		else
			name = "[initial(name)] ([BLOB_POWER_REROLL_COST])"
			desc = "Allows you to choose a new strain from [BLOB_POWER_REROLL_CHOICES] random choices for [BLOB_POWER_REROLL_COST] resources."
	..()

/atom/movable/screen/blob/readapt_strain/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.strain_reroll()

/atom/movable/screen/blob/relocate_core
	icon_state = "ui_swap"
	// Name and description get given their proper values on Initialize()
	name = "Relocate Core (ERROR)"
	desc = "Swaps a node and your core for ERROR resources."

/atom/movable/screen/blob/relocate_core/Initialize()
	. = ..()
	name = "Relocate Core ([BLOB_POWER_RELOCATE_COST])"
	desc = "Swaps a node and your core for [BLOB_POWER_RELOCATE_COST] resources."

/atom/movable/screen/blob/relocate_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()

/datum/hud/blob_overmind/New(mob/owner)
	..()
	var/atom/movable/screen/using

	blobpwrdisplay = new /atom/movable/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	blobpwrdisplay.plane = ABOVE_HUD_PLANE
	blobpwrdisplay.hud = src
	infodisplay += blobpwrdisplay

	healths = new /atom/movable/screen/healths/blob()
	healths.hud = src
	infodisplay += healths

	using = new /atom/movable/screen/blob/blob_help()
	using.screen_loc = "WEST:6,NORTH:-3"
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/jump_to_node()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/jump_to_core()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/blobbernaut()
	using.screen_loc = ui_belt
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/resource_blob()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/node_blob()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/factory_blob()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/readapt_strain()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/relocate_core()
	using.screen_loc = ui_storage2
	using.hud = src
	static_inventory += using
