/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	inhand_icon_state = "toolbox_red"
	material_flags = NONE
	throw_speed = 3 // red ones go faster

/obj/item/storage/toolbox/emergency/PopulateContents()
	var/obj/item/random_item
	switch(rand(1,3))
		if(1)
			random_item = /obj/item/flashlight
		if(2)
			random_item = /obj/item/flashlight/glowstick
		if(3)
			random_item = /obj/item/flashlight/flare

	return list(
		/obj/item/crowbar/red,
		/obj/item/weldingtool/mini,
		/obj/item/extinguisher/mini,
		random_item,
		/obj/item/radio/off,
	)

/obj/item/storage/toolbox/emergency/old
	name = "rusty red toolbox"
	icon_state = "toolbox_red_old"
	has_latches = FALSE
	material_flags = NONE
	storage_type = /datum/storage/toolbox/ancient_bundle

/obj/item/storage/toolbox/emergency/old/ancientbundle/PopulateContents()
	return list(
		/obj/item/card/emag, // 4 tc
		/obj/item/card/emag/doorjack, //emag used to do both. 3 tc
		/obj/item/pen/sleepy, // 4 tc
		/obj/item/reagent_containers/applicator/pill/cyanide,
		/obj/item/chameleon, //its not the original cloaking device, but it will do. 8 tc
		/obj/item/gun/ballistic/revolver, // 13 tc old one stays in the old box
		/obj/item/implanter/freedom, // 5 tc
		/obj/item/stack/telecrystal, //The failsafe/self destruct isn't an item we can physically include in the kit, but 1 TC is technically enough to buy the equivalent.
	)
