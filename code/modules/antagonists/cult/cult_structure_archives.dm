/// Some defines for items the cult archives can create.
#define CULT_BLINDFOLD "Zealot's Blindfold"
#define CURSE_ORB "Shuttle Curse"
#define VEIL_WALKER "Veil Walker Set"

// Cult archives. Gives out utility items.
/obj/structure/destructible/cult/item_dispenser/archives
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	cult_examine_tip = "Can be used to create zealot's blindfolds, shuttle curse orbs, and veil walker equipment."
	icon_state = "tomealtar"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	break_message = "<span class='warning'>The books and tomes of the archives burn into ash as the desk shatters!</span>"

/obj/structure/destructible/cult/item_dispenser/archives/setup_options()
	var/static/list/archive_items = list(
		CULT_BLINDFOLD = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "blindfold"),
			OUTPUT_ITEMS = list(/obj/item/clothing/glasses/hud/health/night/cultblind),
			),
		CURSE_ORB = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/antags/cult/items.dmi', icon_state = "shuttlecurse"),
			OUTPUT_ITEMS = list(/obj/item/shuttle_curse),
			),
		VEIL_WALKER = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/antags/cult/items.dmi', icon_state = "shifter"),
			OUTPUT_ITEMS = list(/obj/item/cult_shift, /obj/item/flashlight/flare/culttorch),
			),
	)

	options = archive_items

/obj/structure/destructible/cult/item_dispenser/archives/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cult_italic("You summon [spawned_item] from [src]!"))

// Preset for the library that doesn't spawn runed metal on destruction.
/obj/structure/destructible/cult/item_dispenser/archives/library
	debris = list()

#undef CULT_BLINDFOLD
#undef CURSE_ORB
#undef VEIL_WALKER
