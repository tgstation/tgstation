/datum/uplink_category/satellite_support
	name = "Syndicate Satellite"
	weight = 10

/datum/uplink_item/support_tools
	category = /datum/uplink_category/satellite_support
	surplus = 0
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

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

/datum/uplink_item/support_tools/bio_key
	name = "Interdyne Pharmaeceutical Access Card"
	desc = "For some of our best Operatives, watching corpo space stations blow up with a flash of retribution just isn't enough. \
		Folks like those prefer a more personal touch to their artistry. For those interested, a special Authorization Key \
		can be instantly delivered to your location. Create groundbreaking chemical agents, cook up, sell the best of drugs, \
		and listen to the best classic music today!"
	item = /obj/item/keycard/satellite_chemistry
	cost = 8

/obj/item/keycard/satellite_chemistry
	name = "Interdyne Pharmaeceutical Access Card"
	desc = "A red keycard with an image of a beaker. Using this will allow you to gain access to the pharmaeceutical wing aboard the satellite base."
	color = "#9c0e26"
	puzzle_id = "satellite_chemistry"
