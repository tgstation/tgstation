/**
 * DUSTS
 */
/obj/item/stack/process_ore/dust
	icon = 'icons/obj/mining.dmi'
	icon_state = "dust_greyscale"
	greyscale_config = /datum/greyscale_config/ore_dust
	greyscale_colors = "#ffffff"
	var/refined_type = null

/obj/item/stack/process_ore/dust/uranium
	refined_type = /obj/item/stack/sheet/mineral/uranium
	greyscale_colors = COLOR_VIBRANT_LIME
/obj/item/stack/process_ore/dust/diamond
	refined_type = /obj/item/stack/sheet/mineral/diamond
	greyscale_colors = COLOR_CYAN
/obj/item/stack/process_ore/dust/titanium
	refined_type = /obj/item/stack/sheet/mineral/titanium
	greyscale_colors = COLOR_VERY_LIGHT_GRAY
/obj/item/stack/process_ore/dust/bluespace_crystal
	refined_type = /obj/item/stack/sheet/bluespace_crystal
	greyscale_colors = COLOR_STRONG_BLUE
/obj/item/stack/process_ore/dust/iron
	refined_type = /obj/item/stack/sheet/iron
	greyscale_colors = COLOR_FLOORTILE_GRAY
/obj/item/stack/process_ore/dust/plasma
	refined_type = /obj/item/stack/sheet/mineral/plasma
	greyscale_colors = COLOR_PURPLE
/obj/item/stack/process_ore/dust/gold
	refined_type = /obj/item/stack/sheet/mineral/gold
	greyscale_colors = COLOR_YELLOW
/obj/item/stack/process_ore/dust/silver
	refined_type = /obj/item/stack/sheet/mineral/silver
	greyscale_colors = COLOR_SILVER

/**
 * DIRTY DUSTS
 */
/obj/item/stack/process_ore/dirty_dust
	icon = 'icons/obj/mining.dmi'
	icon_state = "dust_greyscale"
	var/dust_type = null

/obj/item/stack/process_ore/dirty_dust/uranium
	dust_type = /obj/item/stack/process_ore/dust/uranium
/obj/item/stack/process_ore/dirty_dust/diamond
	dust_type = /obj/item/stack/process_ore/dust/diamond
/obj/item/stack/process_ore/dirty_dust/titanium
	dust_type = /obj/item/stack/process_ore/dust/titanium
/obj/item/stack/process_ore/dirty_dust/bluespace_crystal
	dust_type = /obj/item/stack/process_ore/dust/bluespace_crystal
/obj/item/stack/process_ore/dirty_dust/iron
	dust_type = /obj/item/stack/process_ore/dust/iron
/obj/item/stack/process_ore/dirty_dust/plasma
	dust_type = /obj/item/stack/process_ore/dust/plasma
/obj/item/stack/process_ore/dirty_dust/gold
	dust_type = /obj/item/stack/process_ore/dust/gold
/obj/item/stack/process_ore/dirty_dust/silver
	dust_type = /obj/item/stack/process_ore/dust/silver


/**
 * CLUMPS
 */
/obj/item/stack/process_ore/clump
	icon = 'icons/obj/mining.dmi'
	icon_state = "dust_greyscale"
	var/dirty_type = null

/obj/item/stack/process_ore/clump/uranium
	dirty_type = /obj/item/stack/process_ore/dirty_dust/uranium
/obj/item/stack/process_ore/clump/diamond
	dirty_type = /obj/item/stack/process_ore/dirty_dust/diamond
/obj/item/stack/process_ore/clump/titanium
	dirty_type = /obj/item/stack/process_ore/dirty_dust/titanium
/obj/item/stack/process_ore/clump/bluespace_crystal
	dirty_type = /obj/item/stack/process_ore/dirty_dust/bluespace_crystal
/obj/item/stack/process_ore/clump/iron
	dirty_type = /obj/item/stack/process_ore/dirty_dust/iron
/obj/item/stack/process_ore/clump/plasma
	dirty_type = /obj/item/stack/process_ore/dirty_dust/plasma
/obj/item/stack/process_ore/clump/gold
	dirty_type = /obj/item/stack/process_ore/dirty_dust/gold
/obj/item/stack/process_ore/clump/silver
	dirty_type = /obj/item/stack/process_ore/dirty_dust/silver


/**
 * SHARDS
 */
/obj/item/stack/process_ore/shard
	icon = 'icons/obj/mining.dmi'
	icon_state = "dust_greyscale"
	var/clump_type = null

/obj/item/stack/process_ore/shard/uranium
	clump_type = /obj/item/stack/process_ore/clump/uranium
/obj/item/stack/process_ore/shard/diamond
	clump_type = /obj/item/stack/process_ore/clump/diamond
/obj/item/stack/process_ore/shard/titanium
	clump_type = /obj/item/stack/process_ore/clump/titanium
/obj/item/stack/process_ore/shard/bluespace_crystal
	clump_type = /obj/item/stack/process_ore/clump/bluespace_crystal
/obj/item/stack/process_ore/shard/iron
	clump_type = /obj/item/stack/process_ore/clump/iron
/obj/item/stack/process_ore/shard/plasma
	clump_type = /obj/item/stack/process_ore/clump/plasma
/obj/item/stack/process_ore/shard/gold
	clump_type = /obj/item/stack/process_ore/clump/gold
/obj/item/stack/process_ore/shard/silver
	clump_type = /obj/item/stack/process_ore/clump/silver
