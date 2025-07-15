/// Some defines for items the cult archives can create.
#define CULT_BLINDFOLD "Zealot's Blindfold"
#define CURSE_ORB "Shuttle Curse"
#define VEIL_WALKER "Veil Walker"
#define CRIMSON_MEDALLION "Crimson Medallion"

// Cult archives. Gives out utility items.
/obj/structure/destructible/cult/item_dispenser/archives
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	cult_examine_tip = "Can be used to create zealot's blindfolds, shuttle curse orbs, and veil walker equipment."
	icon_state = "tomealtar"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	break_message = span_warning("The books and tomes of the archives burn into ash as the desk shatters!")
	mansus_conversion_path = /obj/item/codex_cicatrix

/obj/structure/destructible/cult/item_dispenser/archives/setup_options()
	var/static/list/archive_items = list(
		CULT_BLINDFOLD = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "blindfold"),
			OUTPUT_ITEMS = list(/obj/item/clothing/glasses/hud/health/night/cultblind),
			RADIAL_DESC = "Creates \a [/obj/item/clothing/glasses/hud/health/night/cultblind::name], a special blindfold which does not blind cultists. \
				Additionally, it reports the health of friends and foes alike, offers night vision, and even protects from bright lights.",
			),
		CURSE_ORB = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/antags/cult/items.dmi', icon_state = "shuttlecurse"),
			OUTPUT_ITEMS = list(/obj/item/shuttle_curse),
			RADIAL_DESC = "Produces a delicate [/obj/item/shuttle_curse::name] which can be shattered to curse the shuttle if it has been called, \
				delaying its arrival by some time. Only [MAX_SHUTTLE_CURSES] can be used.",
			),
		VEIL_WALKER = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/antags/cult/items.dmi', icon_state = "shifter"),
			OUTPUT_ITEMS = list(/obj/item/cult_shift),
			RADIAL_DESC = "Creates \a [/obj/item/cult_shift::name], a small wand that teleports the user \
				- and anyone the user is dragging - forward some distance.  Has [/obj/item/cult_shift::uses] uses.",
			),
	)

	var/extra_item = extra_options()

	options = archive_items
	if(!isnull(extra_item))
		options += extra_item

/obj/structure/destructible/cult/item_dispenser/archives/extra_options()
	if(!cult_team?.unlocked_heretic_items[CRIMSON_MEDALLION_UNLOCKED])
		return
	return list(CRIMSON_MEDALLION = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/clothing/neck.dmi', icon_state = "crimson_medallion"),
			OUTPUT_ITEMS = list(/obj/item/clothing/neck/heretic_focus/crimson_medallion),
			RADIAL_DESC = "Creates a [/obj/item/clothing/neck/heretic_focus/crimson_medallion::name], a powerful artifact that provides passive healing and the ability to prepare an additional spell. \
				It can also be squished in hand, consuming it for a powerful healing effect.",
			),
	)

/obj/structure/destructible/cult/item_dispenser/archives/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cult_italic("You summon [spawned_item] from [src]!"))

// Preset for the library that doesn't spawn runed metal on destruction, or glow.
/obj/structure/destructible/cult/item_dispenser/archives/library
	icon_state = "tomealtar_off"
	debris = list()

#undef CULT_BLINDFOLD
#undef CURSE_ORB
#undef VEIL_WALKER
#undef CRIMSON_MEDALLION
