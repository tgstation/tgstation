/obj/item/stackspawner
	name = "rapid stack spawner"
	desc = "Rapidly spawns a stack of a certain material."
	icon = 'modular_skyrat/modules/ghostcafe/icons/obj/machines/stackspawner.dmi'
	icon_state = "stackspawner"

	var/obj/item/stack/itemstack
	var/spawnamount = 50

/obj/item/stackspawner/attack_self(mob/user)
	. = ..()
	
	var/static/list/material_list
	if(!material_list)
		material_list = list(
			"Metal"						= image(icon = icon, icon_state = "metal"),
			"Glass"						= image(icon = icon, icon_state = "glass"),
			"Plasma"					= image(icon = icon, icon_state = "plasma"),
			"Silver"					= image(icon = icon, icon_state = "silver"),
			"Titanium"					= image(icon = icon, icon_state = "titanium"),
			"Gold"						= image(icon = icon, icon_state = "gold"),
			"Uranium"					= image(icon = icon, icon_state = "uranium"),
			"Diamond"					= image(icon = icon, icon_state = "diamond"),
			"Bluespace"					= image(icon = icon, icon_state = "bluespace"),
			"Bananium"					= image(icon = icon, icon_state = "bananium"),
			"Plasteel"					= image(icon = icon, icon_state = "plasteel"),
			"Plastic"					= image(icon = icon, icon_state = "plastic"),
			"Plastitanium"				= image(icon = icon, icon_state = "plastitanium"),
			"Reinforced Glass"			= image(icon = icon, icon_state = "rglass"),
			"Plasma Glass"				= image(icon = icon, icon_state = "pglass"),
			"Plasma Reinforced Glass"	= image(icon = icon, icon_state = "prglass"),
			"Titanium Glass"			= image(icon = icon, icon_state = "tglass"),
			"Plastitanium Glass"		= image(icon = icon, icon_state = "ptglass"),
			"Bronze"					= image(icon = icon, icon_state = "brass"),
			"Runite"					= image(icon = icon, icon_state = "runite"),
			"Runed"						= image(icon = icon, icon_state = "runed"),
			"Mythril"					= image(icon = icon, icon_state = "mythril"),
			"Adamantine"				= image(icon = icon, icon_state = "adamantine"),
			"Alien Alloy"				= image(icon = icon, icon_state = "alien"),
			//"Alien Glass"				= image(icon = icon, icon_state = "aglass"),
			"Coal"						= image(icon = icon, icon_state = "coal"),
			"Wood"						= image(icon = icon, icon_state = "wood"),
			"Rods"						= image(icon = icon, icon_state = "rods"),
			"Sandstone"					= image(icon = icon, icon_state = "sandstone"),
			"Snow"						= image(icon = icon, icon_state = "snow"),
			"Paper"						= image(icon = icon, icon_state = "paper"),
			"Cloth"						= image(icon = icon, icon_state = "cloth"),
			"Leather"					= image(icon = icon, icon_state = "leather"),
			"Durathread"				= image(icon = icon, icon_state = "durathread"),
			"Cardboard"					= image(icon = icon, icon_state = "cardboard"),
			"Bamboo"					= image(icon = icon, icon_state = "bamboo"),
			"Wrapping Paper"			= image(icon = icon, icon_state = "wrapping"),
			"Bone"						= image(icon = icon, icon_state = "bone"),
			"Sinew"						= image(icon = icon, icon_state = "sinew"),
			"Goliath Hide"				= image(icon = icon, icon_state = "goliath"),
			"Dragon Hide"				= image(icon = icon, icon_state = "dragon")
		)

	var/choice = show_radial_menu(user, src, material_list, radius = 50, tooltips = TRUE)
	if(!choice)
		return
	switch(choice)
		if("Metal")
			itemstack = /obj/item/stack/sheet/iron
		if("Glass")
			itemstack = /obj/item/stack/sheet/glass
		if("Plasma")
			itemstack = /obj/item/stack/sheet/mineral/plasma
		if("Silver")
			itemstack = /obj/item/stack/sheet/mineral/silver
		if("Titanium")
			itemstack = /obj/item/stack/sheet/mineral/titanium
		if("Gold")
			itemstack = /obj/item/stack/sheet/mineral/gold
		if("Uranium")
			itemstack = /obj/item/stack/sheet/mineral/uranium
		if("Diamond")
			itemstack = /obj/item/stack/sheet/mineral/diamond
		if("Bluespace")
			itemstack = /obj/item/stack/sheet/bluespace_crystal
		if("Bananium")
			itemstack = /obj/item/stack/sheet/mineral/bananium
		if("Plasteel")
			itemstack = /obj/item/stack/sheet/plasteel
		if("Plastic")
			itemstack = /obj/item/stack/sheet/plastic
		if("Plastitanium")
			itemstack = /obj/item/stack/sheet/mineral/plastitanium
		if("Reinforced Glass")
			itemstack = /obj/item/stack/sheet/rglass
		if("Plasma Glass")
			itemstack = /obj/item/stack/sheet/plasmaglass
		if("Plasma Reinforced Glass")
			itemstack = /obj/item/stack/sheet/plasmarglass
		if("Titanium Glass")
			itemstack = /obj/item/stack/sheet/titaniumglass
		if("Plastitanium Glass")
			itemstack = /obj/item/stack/sheet/plastitaniumglass
		if("Runite")
			itemstack = /obj/item/stack/sheet/mineral/runite
		if("Bronze")
			itemstack = /obj/item/stack/tile/bronze
		if("Runed")
			itemstack = /obj/item/stack/sheet/runed_metal
		if("Mythril")
			itemstack = /obj/item/stack/sheet/mineral/mythril
		if("Adamantine")	
			itemstack = /obj/item/stack/sheet/mineral/adamantine
		if("Alien Alloy")
			itemstack = /obj/item/stack/sheet/mineral/abductor
		//if("Alien Glass")
		//	itemstack = 
		if("Coal")
			itemstack = /obj/item/stack/sheet/mineral/coal
		if("Wood")
			itemstack = /obj/item/stack/sheet/mineral/wood
		if("Rods")
			itemstack = /obj/item/stack/rods
		if("Sandstone")
			itemstack = /obj/item/stack/sheet/mineral/sandstone
		if("Snow")
			itemstack = /obj/item/stack/sheet/mineral/snow
		if("Paper")
			itemstack = /obj/item/stack/sheet/paperframes
		if("Cloth")
			itemstack = /obj/item/stack/sheet/cloth
		if("Leather")
			itemstack = /obj/item/stack/sheet/leather
		if("Durathread")
			itemstack = /obj/item/stack/sheet/durathread
		if("Cardboard")
			itemstack = /obj/item/stack/sheet/cardboard
		if("Bamboo")
			itemstack = /obj/item/stack/sheet/mineral/bamboo
		if("Wrapping Paper")
			itemstack = /obj/item/stack/wrapping_paper
		if("Bone")
			itemstack = /obj/item/stack/sheet/bone
		if("Sinew")
			itemstack = /obj/item/stack/sheet/sinew
		if("Goliath Hide")
			itemstack = /obj/item/stack/sheet/animalhide/goliath_hide
			spawnamount = 6
		if("Dragon Hide")
			itemstack = /obj/item/stack/sheet/animalhide/ashdrake
			spawnamount = 10

/obj/item/stackspawner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag) 
		return
	var/obj/item/stack/spawnitemstack = new itemstack(get_turf(target))
	spawnitemstack.amount = spawnamount
