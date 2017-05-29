/obj/item/clothing/suit/armor/vest/dwarf
	name = "dwarven armor"
	desc = "Great for stopping sponges."
	icon_state = "dwarf"
	item_state = "dwarf"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	armor = list(melee = 50, bullet = 10, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 80)
	strip_delay = 80
	put_on_delay = 60
	species_clothing_whitelist = list("dwarf")

/obj/item/clothing/suit/armor/vest/dwarf/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/mold_result/armor_plating/S = locate() in contents
	if(S)
		var/image/Q = image(icon, icon_state)
		Q.color = S.color
		add_overlay(Q)
		smelted_material = new S.smelted_material.type()
		name = "[S.material_type] armor"
		desc = "Armor forged from [S.material_type]."
		for(var/A in armor)
			A = S.attack_amt*2



/obj/item/clothing/under/dwarf
	name = "dwarf tunic"
	icon_state = "dwarf"
	item_state = "dwarf"
	item_color = "dwarf"
	species_clothing_whitelist = list("dwarf")

/obj/item/clothing/shoes/dwarf
	name = "dwarf shoes"
	icon_state = "dwarf"
	item_color = "dwarf"
	item_state = "dwarf"
	desc = "A pair of dwarven boots."
	species_clothing_whitelist = list("dwarf")

/obj/item/clothing/gloves/dwarf
	desc = "Great for holding pickaxes."
	name = "dwarven gloves"
	icon_state = "dwarf"
	item_color = "dwarf"
	item_state = "dwarf"
	species_clothing_whitelist = list("dwarf")

/obj/item/clothing/head/helmet/dwarf
	name = "dwarven helm"
	desc = "Protects the head from tantrums."
	icon_state = "dwarf"
	item_state = "dwarf"
	species_clothing_whitelist = list("dwarf")

/obj/item/clothing/head/helmet/dwarf/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/mold_result/helmet_plating/S = locate() in contents
	if(S)
		var/image/Q = image(icon, icon_state)
		Q.color = S.color
		add_overlay(Q)
		smelted_material = new S.smelted_material.type()
		name = "[S.material_type] helmet"
		desc = "Helmet forged from [S.material_type]."
		for(var/A in armor)
			A = S.attack_amt*2