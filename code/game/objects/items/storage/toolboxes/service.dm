/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	inhand_icon_state = "toolbox_yellow"
	material_flags = NONE
	storage_type = /datum/storage/toolbox/electrical

/obj/item/storage/toolbox/electrical/PopulateContents()
	var/pickedcolor = pick(GLOB.cable_colors)

	var/obj/item/insert
	if(prob(5))
		insert = /obj/item/clothing/gloves/color/yellow
	else
		var/obj/item/stack/cable_coil/new_cable_three = new (null, MAXCOIL)
		new_cable_three.set_cable_color(pickedcolor)
		insert = new_cable_three

	var/obj/item/stack/cable_coil/new_cable_one = new (null, MAXCOIL)
	new_cable_one.set_cable_color(pickedcolor)
	var/obj/item/stack/cable_coil/new_cable_two = new (null, MAXCOIL)
	new_cable_two.set_cable_color(pickedcolor)

	return list(
		/obj/item/screwdriver,
		/obj/item/wirecutters,
		/obj/item/t_scanner,
		/obj/item/crowbar,
		/obj/item/clothing/gloves/color/yellow,
		new_cable_one,
		new_cable_two,
		insert,
	)
