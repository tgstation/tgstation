/// Some defines for items the daemon forge can create.
#define NARSIE_ARMOR "Nar'Sien Hardened Armor"
#define FLAGELLANT_ARMOR "Flagellant's Robe"
#define ELDRITCH_SWORD "Eldritch Longsword"

// Cult forge. Gives out combat weapons.
/obj/structure/destructible/cult/item_dispenser/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar'Sie."
	cult_examine_tip = "Can be used to create Nar'Sien hardened armor, flagellant's robes, and eldritch longswords."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	break_message = "<span class='warning'>The forge breaks apart into shards with a howling scream!</span>"

/obj/structure/destructible/cult/item_dispenser/forge/setup_options()
	var/static/list/forge_items = list(
		NARSIE_ARMOR = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "cult_armor"),
			OUTPUT_ITEMS = list(/obj/item/clothing/suit/hooded/cultrobes/hardened),
			),
		FLAGELLANT_ARMOR = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "cultrobes"),
			OUTPUT_ITEMS = list(/obj/item/clothing/suit/hooded/cultrobes/berserker),
			),
		ELDRITCH_SWORD = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "cultblade"),
			OUTPUT_ITEMS = list(/obj/item/melee/cultblade),
			),
	)

	options = forge_items

/obj/structure/destructible/cult/item_dispenser/forge/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cultitalic("You work [src] as dark knowledge guides your hands, creating [spawned_item]!"))

/obj/structure/destructible/cult/item_dispenser/forge/engine
	name = "magma engine"
	desc = "An arcane engine used for powering a shuttle."
	debris = list()

#undef NARSIE_ARMOR
#undef FLAGELLANT_ARMOR
#undef ELDRITCH_SWORD
