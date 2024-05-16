/datum/uplink_category/satellite_support
	name = "Syndicate Satellite"
	weight = 10

/datum/uplink_item/support_tools
	category = /datum/uplink_category/satellite_support
	surplus = 0

//Nothing in this category can be bought until the satellite is spawned in
/datum/uplink_item/support_tools/can_be_bought(datum/uplink_handler/source)
	if(LAZYACCESS(SSmapping.loaded_lazy_templates, LAZY_TEMPLATE_KEY_SYNDICATE_SATELLITE))
		return TRUE
	return FALSE

/datum/uplink_item/support_tools/syndie_satellite_spawner
	name = "Syndicate Gate kit"
	desc = "Contains a beacon which reveals the coordinates of the station in order to call in a support satellite."
	item = /obj/item/syndicate_beacon
	limited_stock = 1
	cost = 10
	refundable = TRUE

//Has to be purchaseable so you can actually spawn in the satellite
/datum/uplink_item/support_tools/syndie_satellite_spawner/can_be_bought(datum/uplink_handler/source)
	return TRUE

/datum/uplink_item/support_tools/syndicate_gate_bundle
	name = "Syndicate Gate bundle"
	desc = "Contains a bundle which allows you to travel to and from a syndicate satellite"
	item = /obj/item/storage/box/syndie_kit/syndicate_gate_bundle
	cost = 10

/datum/uplink_item/support_tools/wallframe_teleporter
	name = "Teleporter Painting"
	desc = "A painting which allows you to teleport to any activated syndicate gate. \
			Using this without the proper authorization is extremely risky and can have unforseen consequences."
	item = /obj/item/wallframe/painting/syndicate_teleporter
	cost = 3

/datum/uplink_item/support_tools/gate_authorization
	name = "Gate authorization implanter"
	desc = "Ensures safe travels through Syndicate gates"
	item = /obj/item/implanter/gate_authorization
	cost = 5
