/obj/item/stack/tile/mineral
	/// Determines what stack is gotten out of us when welded.
	var/mineralType = null

/obj/item/stack/tile/mineral/welder_act(mob/living/user, obj/item/tool)
	if(get_amount() < 4)
		to_chat(user, span_warning("You need at least four tiles to do this!"))
		return ITEM_INTERACT_BLOCKING
	if(!mineralType)
		to_chat(user, span_warning("You can not reform this!"))
		stack_trace("A mineral tile of type [type] doesn't have its mineralType set.")
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 0, volume=40))
		return ITEM_INTERACT_BLOCKING
	var/sheet_type = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
	var/obj/item/stack/sheet/mineral/new_item = new sheet_type(user.drop_location())
	user.visible_message(span_notice("[user] shaped [src] into [new_item] with [tool]."), \
						span_notice("You shaped [src] into [new_item] with [tool]."), \
						span_hear("You hear welding."))
	var/holding = user.is_holding(src)
	use(4)
	if(holding && QDELETED(src))
		user.put_in_hands(new_item)
	return ITEM_INTERACT_SUCCESS

/obj/item/stack/tile/mineral/plasma
	name = "plasma tile"
	singular_name = "plasma floor tile"
	desc = "A tile made out of highly flammable plasma. This can only end well."
	icon_state = "tile_plasma"
	inhand_icon_state = "tile-plasma"
	turf_type = /turf/open/floor/mineral/plasma
	mineralType = "plasma"
	mats_per_unit = list(/datum/material/plasma=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/plasma
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/plasma,
		/obj/item/stack/tile/mineral/plasma/tiled,
	)

/obj/item/stack/tile/mineral/plasma/tiled
	icon_state = "plasma_tiled"
	turf_type = /turf/open/floor/mineral/plasma/tiled
	merge_type = /obj/item/stack/tile/mineral/plasma/tiled

/obj/item/stack/tile/mineral/uranium
	name = "uranium tile"
	singular_name = "uranium floor tile"
	desc = "A tile made out of uranium. You feel a bit woozy."
	icon_state = "tile_uranium"
	inhand_icon_state = "tile-uranium"
	turf_type = /turf/open/floor/mineral/uranium
	mineralType = "uranium"
	mats_per_unit = list(/datum/material/uranium=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/uranium
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/uranium,
		/obj/item/stack/tile/mineral/uranium/tiled,
	)

/obj/item/stack/tile/mineral/uranium/tiled
	icon_state = "uranium_tiled"
	turf_type = /turf/open/floor/mineral/uranium/tiled
	merge_type = /obj/item/stack/tile/mineral/uranium/tiled

/obj/item/stack/tile/mineral/gold
	name = "gold tile"
	singular_name = "gold floor tile"
	desc = "A tile made out of gold, the swag seems strong here."
	icon_state = "tile_gold"
	inhand_icon_state = "tile-gold"
	turf_type = /turf/open/floor/mineral/gold
	mineralType = "gold"
	mats_per_unit = list(/datum/material/gold=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/gold
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/gold,
		/obj/item/stack/tile/mineral/gold/tiled,
		/obj/item/stack/tile/mineral/gold/sun,
	)

/obj/item/stack/tile/mineral/gold/tiled
	icon_state = "gold_tiled"
	turf_type = /turf/open/floor/mineral/gold/tiled
	merge_type = /obj/item/stack/tile/mineral/gold/tiled

/obj/item/stack/tile/mineral/gold/sun
	icon_state = "gold_sun"
	desc = "A tile made out of gold, portraying the sun."
	turf_type = /turf/open/floor/mineral/gold/sun
	merge_type = /obj/item/stack/tile/mineral/gold/sun

/obj/item/stack/tile/mineral/silver
	name = "silver tile"
	singular_name = "silver floor tile"
	desc = "A tile made out of silver, the light shining from it is blinding."
	icon_state = "tile_silver"
	inhand_icon_state = "tile-silver"
	turf_type = /turf/open/floor/mineral/silver
	mineralType = "silver"
	mats_per_unit = list(/datum/material/silver=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/silver
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/silver,
		/obj/item/stack/tile/mineral/silver/tiled,
		/obj/item/stack/tile/mineral/silver/moon,
	)

/obj/item/stack/tile/mineral/silver/tiled
	icon_state = "silver_tiled"
	turf_type = /turf/open/floor/mineral/silver/tiled
	merge_type = /obj/item/stack/tile/mineral/uranium/tiled

/obj/item/stack/tile/mineral/silver/moon
	icon_state = "silver_moon"
	desc = "A tile made out of silver, portraying the moon."
	turf_type = /turf/open/floor/mineral/gold/sun
	merge_type = /obj/item/stack/tile/mineral/silver/moon
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST)

/obj/item/stack/tile/mineral/diamond
	name = "diamond tile"
	singular_name = "diamond floor tile"
	desc = "A tile made out of diamond. Wow, just, wow."
	icon_state = "tile_diamond"
	inhand_icon_state = "tile-diamond"
	turf_type = /turf/open/floor/mineral/diamond
	mineralType = "diamond"
	mats_per_unit = list(/datum/material/diamond=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/diamond
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/diamond,
		/obj/item/stack/tile/mineral/diamond/tiled,
	)

/obj/item/stack/tile/mineral/diamond/tiled
	icon_state = "diamond_tiled"
	turf_type = /turf/open/floor/mineral/diamond/tiled
	merge_type = /obj/item/stack/tile/mineral/diamond/tiled

/obj/item/stack/tile/mineral/bananium
	name = "bananium tile"
	singular_name = "bananium floor tile"
	desc = "A slippery tile made out of bananium, HOOOOOOOOONK!"
	icon_state = "tile_bananium"
	inhand_icon_state = "tile-bananium"
	turf_type = /turf/open/floor/mineral/bananium
	mineralType = "bananium"
	mats_per_unit = list(/datum/material/bananium=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/bananium
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/bananium,
		/obj/item/stack/tile/mineral/bananium/tiled,
	)

/obj/item/stack/tile/mineral/bananium/tiled
	icon_state = "bananium_tiled"
	turf_type = /turf/open/floor/mineral/bananium/tiled
	merge_type = /obj/item/stack/tile/mineral/bananium/tiled

/obj/item/stack/tile/mineral/bluespace
	name = "bluespace tile"
	singular_name = "bluespace floor tile"
	desc = "A tile made out of bluespace crystals. Latest innovation in random teleportation."
	icon_state = "tile_bluespace_c"
	inhand_icon_state = "tile-bluespace"
	turf_type = /turf/open/floor/mineral/bluespace
	mineralType = "bluespace"
	mats_per_unit = list(/datum/material/bluespace=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/bluespace
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/bluespace,
		/obj/item/stack/tile/mineral/bluespace/tiled,
	)

/obj/item/stack/tile/mineral/bluespace/tiled
	icon_state = "bluespace_c_tiled"
	turf_type = /turf/open/floor/mineral/bluespace/tiled
	merge_type = /obj/item/stack/tile/mineral/bluespace/tiled

/obj/item/stack/tile/mineral/bluespace/n
	icon_state = "bluespace_c_n"
	turf_type = /turf/open/floor/mineral/bluespace/n
	merge_type = /obj/item/stack/tile/mineral/bluespace/n

/obj/item/stack/tile/mineral/telecrystal
	name = "telecrystal tile"
	singular_name = "telecrystal floor tile"
	desc = "A tile made out of telecrystals. Pretty sure its illegal."
	icon_state = "tile_telecrystal"
	inhand_icon_state = "tile-telecrystal"
	turf_type = /turf/open/floor/mineral/telecrystal
	mineralType = "telecrystal"
	mats_per_unit = list(/datum/material/telecrystal=SHEET_MATERIAL_AMOUNT*0.25)

	merge_type = /obj/item/stack/tile/mineral/telecrystal
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/telecrystal,
		/obj/item/stack/tile/mineral/telecrystal/tiled,
	)

/obj/item/stack/tile/mineral/telecrystal/tiled
	icon_state = "telecrystal_tiled"
	turf_type = /turf/open/floor/mineral/bluespace/tiled
	merge_type = /obj/item/stack/tile/mineral/telecrystal/tiled

/obj/item/stack/tile/mineral/telecrystal/s
	icon_state = "telecrystal_s"
	turf_type = /turf/open/floor/mineral/telecrystal/s
	merge_type = /obj/item/stack/tile/mineral/telecrystal/s

/obj/item/stack/tile/mineral/adamantine
	name = "adamantine tile"
	singular_name = "adamantine floor tile"
	desc = "A tile made out of adamantine. Industrial style, favourite of golems."
	icon_state = "tile_adamantine"
	inhand_icon_state = "tile-adamantium"
	turf_type = /turf/open/floor/mineral/adamantine
	mineralType = "adamantine"
	mats_per_unit = list(/datum/material/adamantine=SHEET_MATERIAL_AMOUNT*0.25)

	merge_type = /obj/item/stack/tile/mineral/telecrystal
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/adamantine,
		/obj/item/stack/tile/mineral/adamantine/alt,
	)

/obj/item/stack/tile/mineral/adamantine/alt
	icon_state = "adamantine_alt"
	turf_type = /turf/open/floor/mineral/adamantine/alt
	merge_type = /obj/item/stack/tile/mineral/adamantine/alt

/obj/item/stack/tile/mineral/metal_hydrogen
	name = "metal hydrogen tile"
	singular_name = "metal hydrogen floor tile"
	desc = "A tile made out of metal hydrogen. Like walking on a cloud!"
	icon_state = "tile_metal_hydrogen"
	inhand_icon_state = "tile-metalhydrogen"
	turf_type = /turf/open/floor/mineral/metal_hydrogen
	mineralType = "metal hydrogen"
	mats_per_unit = list(/datum/material/metalhydrogen=SHEET_MATERIAL_AMOUNT*0.25)

	merge_type = /obj/item/stack/tile/mineral/metal_hydrogen
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/metal_hydrogen,
		/obj/item/stack/tile/mineral/metal_hydrogen/tiled,
	)

/obj/item/stack/tile/mineral/metal_hydrogen/tiled
	icon_state = "metal_hydrogen_tiled"
	turf_type = /turf/open/floor/mineral/metal_hydrogen/tiled
	merge_type = /obj/item/stack/tile/mineral/metal_hydrogen/tiled

/obj/item/stack/tile/mineral/runite
	name = "runite tile"
	singular_name = "runite floor tile"
	desc = "A quite magical tile made from runite. You feel its polarity is determined by the direction of the winds of magic."
	icon_state = "tile_runite"
	inhand_icon_state = "tile-runite"
	turf_type = /turf/open/floor/mineral/runite
	mineralType = "runite"
	mats_per_unit = list(/datum/material/runite=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/runite
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST)

/obj/item/stack/tile/mineral/mythril
	name = "mythril tile"
	singular_name = "mythril floor tile"
	desc = "Definetly the best use of such an legendary, unfathomable material."
	icon_state = "tile_mythril"
	inhand_icon_state = "tile-mythril"
	turf_type = /turf/open/floor/mineral/mythril
	mineralType = "mythril"
	mats_per_unit = list(/datum/material/mythril=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/mythril


///glassed variants of bunch of the floors which otherwise might not be the best to walk through.

/obj/item/stack/tile/mineral/glassed/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "tile_glass", layer = src.layer+0.01)

/obj/item/stack/tile/mineral/glassed
	/// Determines what stack floor type this splits into.
	var/floorType = null
	merge_type = /obj/item/stack/tile/mineral/glassed

/obj/item/stack/tile/mineral/glassed/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(W.tool_behaviour == TOOL_WELDER)
		if(!floorType)
			to_chat(user, span_warning("You can split these!"))
			stack_trace("A glassed mineral tile of type [type] doesn't have its floorType set.")
			return
		if(W.use_tool(src, user, 0, volume=40))
			var/floor_type = text2path("/obj/item/stack/tile/mineral/[floorType]")
			var/obj/item/stack/tile/mineral/new_item = new floor_type(user.drop_location())
			user.visible_message(span_notice("[user] split [src] into [new_item] and glass tiles with [W]."), \
				span_notice("You shaped [src] into [new_item] with [W]."), \
				span_hear("You hear welding."))
			var/holding = user.is_holding(src)
			use(4)
			if(holding && QDELETED(src))
				user.put_in_hands(new_item)
				user.put_in_hands(/obj/item/stack/tile/glass)
	else
		return ..()

/obj/item/stack/tile/mineral/glassed/plasma
	name = "plasma tile"
	singular_name = "plasma floor tile"
	desc = "A tile made out of highly flammable plasma, glassed as to prevent the fire from actually getting to it."
	icon_state = "tile_plasma"
	inhand_icon_state = "tile-plasma"
	turf_type = /turf/open/floor/mineral/glassed/plasma
	floorType = "plasma"
	mats_per_unit = list(/datum/material/plasma=SHEET_MATERIAL_AMOUNT*0.25, /datum/material/glass=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/glassed/plasma
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/glassed/plasma,
		/obj/item/stack/tile/mineral/glassed/plasma/tiled,
	)

/obj/item/stack/tile/mineral/glassed/plasma/tiled
	icon_state = "plasma_tiled"
	floorType = "plasma/tiled"
	turf_type = /turf/open/floor/mineral/glassed/plasma/tiled
	merge_type = /obj/item/stack/tile/mineral/glassed/plasma/tiled

/obj/item/stack/tile/mineral/glassed/uranium
	name = "uranium tile"
	singular_name = "uranium floor tile"
	desc = "A tile made out of uranium. Glassed so you won't get irradiated."
	icon_state = "tile_uranium"
	inhand_icon_state = "tile-uranium"
	turf_type = /turf/open/floor/mineral/glassed/uranium
	floorType = "uranium"
	mats_per_unit = list(/datum/material/uranium=SHEET_MATERIAL_AMOUNT*0.25, /datum/material/glass=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/glassed/uranium
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/glassed/uranium,
		/obj/item/stack/tile/mineral/glassed/uranium/tiled,
	)

/obj/item/stack/tile/mineral/glassed/uranium/tiled
	icon_state = "uranium_tiled"
	floorType = "uranium/tiled"
	turf_type = /turf/open/floor/mineral/glassed/uranium/tiled
	merge_type = /obj/item/stack/tile/mineral/glassed/uranium/tiled

/obj/item/stack/tile/mineral/glassed/bananium
	name = "bananium tile"
	singular_name = "bananium floor tile"
	desc = "A glassed, and thus non-slippery tile made out of bananium, HOOOOOOOOONK!"
	icon_state = "tile_bananium"
	inhand_icon_state = "tile-bananium"
	turf_type = /turf/open/floor/mineral/glassed/bananium
	floorType = "bananium"
	mats_per_unit = list(/datum/material/bananium=SHEET_MATERIAL_AMOUNT*0.25, /datum/material/glass=SHEET_MATERIAL_AMOUNT*0.25)
	material_flags = NONE
	merge_type = /obj/item/stack/tile/mineral/glassed/bananium
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/glassed/bananium,
		/obj/item/stack/tile/mineral/glassed/bananium/tiled,
	)

/obj/item/stack/tile/mineral/glassed/bananium/tiled
	icon_state = "bananium_tiled"
	floorType = "bananium/tiled"
	turf_type = /turf/open/floor/mineral/glassed/bananium/tiled
	merge_type = /obj/item/stack/tile/mineral/glassed/bananium/tiled

/obj/item/stack/tile/mineral/glassed/bluespace
	name = "bluespace tile"
	singular_name = "bluespace floor tile"
	desc = "A glassed tile made out of bluespace crystals. Save to walk on even barefoot."
	icon_state = "tile_bluespace_c"
	inhand_icon_state = "tile-bluespace"
	turf_type = /turf/open/floor/mineral/glassed/bluespace
	floorType = "bluespace"
	mats_per_unit = list(/datum/material/bluespace=SHEET_MATERIAL_AMOUNT*0.25, /datum/material/glass=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/glassed/bluespace
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/glassed/bluespace,
		/obj/item/stack/tile/mineral/glassed/bluespace/tiled,
	)

/obj/item/stack/tile/mineral/glassed/bluespace/tiled
	icon_state = "bluespace_c_tiled"
	floorType = "bluespace/tiled"
	turf_type = /turf/open/floor/mineral/glassed/bluespace/tiled
	merge_type = /obj/item/stack/tile/mineral/glassed/bluespace/tiled

/obj/item/stack/tile/mineral/glassed/bluespace/n
	icon_state = "bluespace_c_n"
	floorType = "bluespace_n"
	turf_type = /turf/open/floor/mineral/glassed/bluespace/n
	merge_type = /obj/item/stack/tile/mineral/glassed/bluespace/n

/obj/item/stack/tile/mineral/glassed/telecrystal
	name = "telecrystal tile"
	singular_name = "telecrystal floor tile"
	desc = "A glassed tile made out of telecrystals. Pretty sure its illegal. But at least its safe to walk on."
	icon_state = "tile_telecrystal"
	inhand_icon_state = "tile-telecrystal"
	turf_type = /turf/open/floor/mineral/glassed/telecrystal
	mineralType = "telecrystal"
	mats_per_unit = list(/datum/material/telecrystal=SHEET_MATERIAL_AMOUNT*0.25, /datum/material/glass=SHEET_MATERIAL_AMOUNT*0.25)

	merge_type = /obj/item/stack/tile/mineral/glassed/telecrystal
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/glassed/telecrystal,
		/obj/item/stack/tile/mineral/glassed/telecrystal/tiled,
	)

/obj/item/stack/tile/mineral/glassed/telecrystal/tiled
	icon_state = "telecrystal_tiled"
	floorType = "telecrystal/tiled"
	turf_type = /turf/open/floor/mineral/glassed/bluespace/tiled
	merge_type = /obj/item/stack/tile/mineral/glassed/telecrystal/tiled

/obj/item/stack/tile/mineral/glassed/telecrystal/s
	icon_state = "telecrystal_s"
	floorType = "telecrystal/s"
	turf_type = /turf/open/floor/mineral/glassed/telecrystal/s
	merge_type = /obj/item/stack/tile/mineral/glassed/telecrystal/s

///

/obj/item/stack/tile/mineral/abductor
	name = "alien floor tile"
	singular_name = "alien floor tile"
	desc = "A tile made out of alien alloy."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "tile_abductor"
	inhand_icon_state = "tile-abductor"
	mats_per_unit = list(/datum/material/alloy/alien=SHEET_MATERIAL_AMOUNT*0.25)
	turf_type = /turf/open/floor/mineral/abductor
	mineralType = "abductor"
	merge_type = /obj/item/stack/tile/mineral/abductor

/obj/item/stack/tile/mineral/titanium
	name = "titanium tile"
	singular_name = "titanium floor tile"
	desc = "Sleek titanium tiles, used for shuttles."
	icon_state = "tile_titanium"
	inhand_icon_state = "tile-shuttle"
	turf_type = /turf/open/floor/mineral/titanium
	mineralType = "titanium"
	mats_per_unit = list(/datum/material/titanium=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/titanium
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/titanium,
		/obj/item/stack/tile/mineral/titanium/yellow,
		/obj/item/stack/tile/mineral/titanium/blue,
		/obj/item/stack/tile/mineral/titanium/white,
		/obj/item/stack/tile/mineral/titanium/purple,
		/obj/item/stack/tile/mineral/titanium/tiled,
		/obj/item/stack/tile/mineral/titanium/tiled/yellow,
		/obj/item/stack/tile/mineral/titanium/tiled/blue,
		/obj/item/stack/tile/mineral/titanium/tiled/white,
		/obj/item/stack/tile/mineral/titanium/tiled/purple,
		)

/obj/item/stack/tile/mineral/titanium/yellow
	name = "yellow titanium tile"
	singular_name = "yellow titanium floor tile"
	desc = "Sleek yellow titanium tiles, used for shuttles."
	turf_type = /turf/open/floor/mineral/titanium/yellow
	icon_state = "tile_titanium_yellow"
	merge_type = /obj/item/stack/tile/mineral/titanium/yellow

/obj/item/stack/tile/mineral/titanium/blue
	name = "blue titanium tile"
	singular_name = "blue titanium floor tile"
	desc = "Sleek blue titanium tiles, used for shuttles."
	turf_type = /turf/open/floor/mineral/titanium/blue
	icon_state = "tile_titanium_blue"
	merge_type = /obj/item/stack/tile/mineral/titanium/blue

/obj/item/stack/tile/mineral/titanium/white
	name = "white titanium tile"
	singular_name = "white titanium floor tile"
	desc = "Sleek white titanium tiles, used for shuttles."
	turf_type = /turf/open/floor/mineral/titanium/white
	icon_state = "tile_titanium_white"
	merge_type = /obj/item/stack/tile/mineral/titanium/white

/obj/item/stack/tile/mineral/titanium/purple
	name = "purple titanium tile"
	singular_name = "purple titanium floor tile"
	desc = "Sleek purple titanium tiles, used for shuttles."
	turf_type = /turf/open/floor/mineral/titanium/purple
	icon_state = "tile_titanium_purple"
	merge_type = /obj/item/stack/tile/mineral/titanium/purple

/obj/item/stack/tile/mineral/titanium/tiled
	name = "tiled titanium tile"
	singular_name = "tiled titanium floor tile"
	desc = "Titanium floor tiles, used for shuttles."
	turf_type = /turf/open/floor/mineral/titanium/tiled
	icon_state = "tile_titanium_tiled"
	merge_type = /obj/item/stack/tile/mineral/titanium/tiled

/obj/item/stack/tile/mineral/titanium/tiled/yellow
	name = "yellow titanium tile"
	singular_name = "yellow titanium floor tile"
	desc = "Yellow titanium floor tiles, used for shuttles."
	turf_type = /turf/open/floor/mineral/titanium/tiled/yellow
	icon_state = "tile_titanium_tiled_yellow"
	merge_type = /obj/item/stack/tile/mineral/titanium/tiled/yellow

/obj/item/stack/tile/mineral/titanium/tiled/blue
	name = "blue titanium tile"
	singular_name = "blue titanium floor tile"
	desc = "Blue titanium floor tiles, used for shuttles."
	turf_type = /turf/open/floor/mineral/titanium/tiled/blue
	icon_state = "tile_titanium_tiled_blue"
	merge_type = /obj/item/stack/tile/mineral/titanium/tiled/blue

/obj/item/stack/tile/mineral/titanium/tiled/white
	name = "white titanium tile"
	singular_name = "white titanium floor tile"
	desc = "White titanium floor tiles, used for shuttles."
	turf_type = /turf/open/floor/mineral/titanium/tiled/white
	icon_state = "tile_titanium_tiled_white"
	merge_type = /obj/item/stack/tile/mineral/titanium/tiled/white

/obj/item/stack/tile/mineral/titanium/tiled/purple
	name = "purple titanium tile"
	singular_name = "purple titanium floor tile"
	desc = "Purple titanium floor tiles, used for shuttles."
	turf_type = /turf/open/floor/mineral/titanium/tiled/purple
	icon_state = "tile_titanium_tiled_purple"
	merge_type = /obj/item/stack/tile/mineral/titanium/tiled/purple

/obj/item/stack/tile/mineral/plastitanium
	name = "plastitanium tile"
	singular_name = "plastitanium floor tile"
	desc = "A tile made of plastitanium, used for very evil shuttles."
	icon_state = "tile_plastitanium"
	inhand_icon_state = "tile-darkshuttle"
	turf_type = /turf/open/floor/mineral/plastitanium
	mineralType = "plastitanium"
	mats_per_unit = list(/datum/material/alloy/plastitanium=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/mineral/plastitanium
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/plastitanium,
		/obj/item/stack/tile/mineral/plastitanium/red,
		/obj/item/stack/tile/mineral/plastitanium/pod,
		/obj/item/stack/tile/mineral/plastitanium/pod/light,
		/obj/item/stack/tile/mineral/plastitanium/pod/dark,
		/obj/item/stack/tile/mineral/plastitanium/pod/red,
		/obj/item/stack/tile/mineral/plastitanium/pod/redlight,
		)

/obj/item/stack/tile/mineral/plastitanium/red
	name = "red plastitanium tile"
	singular_name = "red plastitanium floor tile"
	desc = "A tile made of plastitanium, used for very red shuttles."
	turf_type = /turf/open/floor/mineral/plastitanium/red
	icon_state = "tile_plastitanium_red"
	merge_type = /obj/item/stack/tile/mineral/plastitanium/red

/obj/item/stack/tile/mineral/plastitanium/pod
	name = "pod floor tile"
	singular_name = "pod floor tile"
	desc = "A grooved floor tile."
	icon_state = "tile_pod"
	inhand_icon_state = "tile-pod"
	turf_type = /turf/open/floor/mineral/plastitanium/pod
	merge_type = /obj/item/stack/tile/mineral/plastitanium/pod

/obj/item/stack/tile/mineral/plastitanium/pod/light
	name = "light pod floor tile"
	singular_name = "light pod floor tile"
	desc = "A lightly colored grooved floor tile."
	icon_state = "tile_podlight"
	turf_type = /turf/open/floor/mineral/plastitanium/pod/light
	merge_type = /obj/item/stack/tile/mineral/plastitanium/pod/light

/obj/item/stack/tile/mineral/plastitanium/pod/dark
	name = "dark pod floor tile"
	singular_name = "dark pod floor tile"
	desc = "A darkly colored grooved floor tile."
	icon_state = "tile_poddark"
	turf_type = /turf/open/floor/mineral/plastitanium/pod/dark
	merge_type = /obj/item/stack/tile/mineral/plastitanium/pod/dark

/obj/item/stack/tile/mineral/plastitanium/pod/red
	name = "red pod floor tile"
	singular_name = "dark pod floor tile"
	desc = "A red colored grooved floor tile."
	icon_state = "tile_pod_red"
	turf_type = /turf/open/floor/mineral/plastitanium/pod/red
	merge_type = /obj/item/stack/tile/mineral/plastitanium/pod/red

/obj/item/stack/tile/mineral/plastitanium/pod/redlight
	name = "light red pod floor tile"
	singular_name = "light red pod floor tile"
	desc = "A light red colored grooved floor tile."
	icon_state = "tile_podlight_red"
	turf_type = /turf/open/floor/mineral/plastitanium/pod/redlight
	merge_type = /obj/item/stack/tile/mineral/plastitanium/pod/redlight

/obj/item/stack/tile/mineral/snow
	name = "snow tile"
	singular_name = "snow tile"
	desc = "A layer of snow."
	icon_state = "tile_snow"
	inhand_icon_state = "tile-silver"
	turf_type = /turf/open/floor/fake_snow
	mineralType = "snow"
	merge_type = /obj/item/stack/tile/mineral/snow
	mats_per_unit = list(/datum/material/snow = HALF_SHEET_MATERIAL_AMOUNT / 2)
