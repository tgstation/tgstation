/atom/movable/screen/blob
	icon = 'icons/hud/blob.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/blob/MouseEntered(location,control,params)
	. = ..()
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/atom/movable/screen/blob/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/blob/jump_to_node
	name = "Jump to Node"
	desc = "Moves your camera to a selected blob node."
	icon_state = "ui_tonode"
	screen_loc = ui_inventory

/atom/movable/screen/blob/jump_to_node/Click()
	if(!isovermind(usr))
		return FALSE
	var/mob/eye/blob/blob = usr
	blob.jump_to_node()

/atom/movable/screen/blob/jump_to_core
	name = "Jump to Core"
	desc = "Moves your camera to your blob core."
	icon_state = "ui_tocore"
	screen_loc = ui_zonesel

/atom/movable/screen/blob/jump_to_core/MouseEntered(location,control,params)
	if(hud?.mymob && isovermind(hud.mymob))
		var/mob/eye/blob/B = hud.mymob
		if(!B.placed)
			name = "Place Blob Core"
			desc = "Attempt to place your blob core at this location."
		else
			name = initial(name)
			desc = initial(desc)
	return ..()

/atom/movable/screen/blob/jump_to_core/Click()
	if(!isovermind(usr))
		return FALSE
	var/mob/eye/blob/blob = usr
	if(!blob.placed)
		blob.place_blob_core(BLOB_NORMAL_PLACEMENT)
	blob.transport_core()

/atom/movable/screen/blob/blobbernaut
	// Name and description get given their proper values on Initialize()
	name = "Produce Blobbernaut (ERROR)"
	desc = "Produces a strong, smart blobbernaut from a factory blob for (ERROR) resources.<br>The factory blob used will become fragile and unable to produce spores."
	icon_state = "ui_blobbernaut"
	screen_loc = ui_belt

/atom/movable/screen/blob/blobbernaut/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Produce Blobbernaut ([BLOBMOB_BLOBBERNAUT_RESOURCE_COST])"
	desc = "Produces a strong, smart blobbernaut from a factory blob for [BLOBMOB_BLOBBERNAUT_RESOURCE_COST] resources.<br>The factory blob used will become fragile and unable to produce spores."

/atom/movable/screen/blob/blobbernaut/Click()
	if(!isovermind(usr))
		return FALSE
	var/mob/eye/blob/blob = usr
	blob.create_blobbernaut()

/atom/movable/screen/blob/resource_blob
	// Name and description get given their proper values on Initialize()
	name = "Produce Resource Blob (ERROR)"
	desc = "Produces a resource blob for ERROR resources.<br>Resource blobs will give you resources every few seconds."
	icon_state = "ui_resource"
	screen_loc = ui_back

/atom/movable/screen/blob/resource_blob/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Produce Resource Blob ([BLOB_STRUCTURE_RESOURCE_COST])"
	desc = "Produces a resource blob for [BLOB_STRUCTURE_RESOURCE_COST] resources.<br>Resource blobs will give you resources every few seconds."

/atom/movable/screen/blob/resource_blob/Click()
	if(!isovermind(usr))
		return FALSE
	var/mob/eye/blob/blob = usr
	blob.create_special(BLOB_STRUCTURE_RESOURCE_COST, /obj/structure/blob/special/resource, BLOB_RESOURCE_MIN_DISTANCE, TRUE)

/atom/movable/screen/blob/node_blob
	// Name and description get given their proper values on Initialize()
	name = "Produce Node Blob (ERROR)"
	desc = "Produces a node blob for ERROR resources.<br>Node blobs will expand and activate nearby resource and factory blobs."
	icon_state = "ui_node"

/atom/movable/screen/blob/node_blob/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Produce Node Blob ([BLOB_STRUCTURE_NODE_COST])"
	desc = "Produces a node blob for [BLOB_STRUCTURE_NODE_COST] resources.<br>Node blobs will expand and activate nearby resource and factory blobs."

/atom/movable/screen/blob/node_blob/Click()
	if(!isovermind(usr))
		return FALSE
	var/mob/eye/blob/blob = usr
	blob.create_special(BLOB_STRUCTURE_NODE_COST, /obj/structure/blob/special/node, BLOB_NODE_MIN_DISTANCE, FALSE)

/atom/movable/screen/blob/factory_blob
	// Name and description get given their proper values on Initialize()
	name = "Produce Factory Blob (ERROR)"
	desc = "Produces a factory blob for ERROR resources.<br>Factory blobs will produce spores every few seconds."
	icon_state = "ui_factory"

/atom/movable/screen/blob/factory_blob/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Produce Factory Blob ([BLOB_STRUCTURE_FACTORY_COST])"
	desc = "Produces a factory blob for [BLOB_STRUCTURE_FACTORY_COST] resources.<br>Factory blobs will produce spores every few seconds."

/atom/movable/screen/blob/factory_blob/Click()
	if(!isovermind(usr))
		return FALSE
	var/mob/eye/blob/blob = usr
	blob.create_special(BLOB_STRUCTURE_FACTORY_COST, /obj/structure/blob/special/factory, BLOB_FACTORY_MIN_DISTANCE, TRUE)

/atom/movable/screen/blob/readapt_strain
	// Description gets given its proper values on Initialize()
	name = "Readapt Strain"
	desc = "Allows you to choose a new strain from ERROR random choices for ERROR resources."
	icon_state = "ui_chemswap"
	screen_loc = ui_storage1

/atom/movable/screen/blob/readapt_strain/MouseEntered(location,control,params)
	if(hud?.mymob && isovermind(hud.mymob))
		var/mob/eye/blob/B = hud.mymob
		if(B.free_strain_rerolls)
			name = "[initial(name)] (FREE)"
			desc = "Randomly rerolls your strain for free."
		else
			name = "[initial(name)] ([BLOB_POWER_REROLL_COST])"
			desc = "Allows you to choose a new strain from [BLOB_POWER_REROLL_CHOICES] random choices for [BLOB_POWER_REROLL_COST] resources."
	return ..()

/atom/movable/screen/blob/readapt_strain/Click()
	if(isovermind(usr))
		var/mob/eye/blob/B = usr
		B.strain_reroll()

/atom/movable/screen/blob/relocate_core
	// Name and description get given their proper values on Initialize()
	name = "Relocate Core (ERROR)"
	desc = "Swaps a node and your core for ERROR resources."
	icon_state = "ui_swap"
	screen_loc = ui_storage2

/atom/movable/screen/blob/relocate_core/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	name = "Relocate Core ([BLOB_POWER_RELOCATE_COST])"
	desc = "Swaps a node and your core for [BLOB_POWER_RELOCATE_COST] resources."

/atom/movable/screen/blob/relocate_core/Click()
	if(isovermind(usr))
		var/mob/eye/blob/B = usr
		B.relocate_core()

/atom/movable/screen/blob/blob_power
	name = "blob power"
	icon_state = "block"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_HUD_PLANE
