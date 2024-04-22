/obj/item/var/stamina_cost = 0

/obj/item/smithed_part
	name = "generic smithed item"
	desc = "A forged item."

	icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	base_icon_state = "chain"
	icon_state = "chain"

	var/base_name = "generic item"

	var/smithed_quality = 100

/obj/item/smithed_part/Initialize(mapload, obj/item/created_from, quality)
	. = ..()

	smithed_quality = max(quality, 25)

	if(!created_from)
		created_from = new /obj/item/stack/sheet/mineral/gold


	if(isstack(created_from) && !created_from.material_stats)
		var/obj/item/stack/stack = created_from
		create_stats_from_material(stack.material_type)
	else
		create_stats_from_material_stats(created_from.material_stats)

	name = "[material_stats.material_name] [base_name]"

	var/damage_state
	switch(smithed_quality)
		if(0 to 25)
			damage_state = "damage-4"
		if(25 to 50)
			damage_state = "damage-3"
		if(50 to 60)
			damage_state = "damage-2"
		if(60 to 90)
			damage_state = "damage-1"
		else
			damage_state = null

	if(damage_state)
		add_filter("damage_filter", 1, alpha_mask_filter(icon = icon('monkestation/code/modules/smithing/icons/forge_items.dmi', damage_state), flags = MASK_INVERSE))


/obj/item/smithed_part/update_name(updates)
	. = ..()
	name = "[material_stats.material_name] [base_name]"

/obj/item/smithed_part/weapon_part
	var/complete = FALSE
	var/hilt_icon_state
	var/left_weapon_inhand = 'monkestation/code/modules/smithing/icons/forge_weapon_l.dmi'
	var/right_weapon_inhand = 'monkestation/code/modules/smithing/icons/forge_weapon_r.dmi'
	var/weapon_inhand_icon_state
	var/hilt_icon
	var/weapon_name

/obj/item/smithed_part/weapon_part/update_name(updates)
	. = ..()
	if(complete)
		name = "[material_stats.material_name] [weapon_name]"

/obj/item/smithed_part/weapon_part/update_overlays()
	. = ..()
	if(complete)
		. += mutable_appearance(hilt_icon, hilt_icon_state, appearance_flags = KEEP_APART)

/obj/item/smithed_part/weapon_part/proc/finish_weapon()
	complete = TRUE
	inhand_icon_state = weapon_inhand_icon_state
	lefthand_file = left_weapon_inhand
	righthand_file = right_weapon_inhand
	update_appearance()
