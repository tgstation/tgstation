#define RESKIN_LINEN "Linen"

/obj/item/storage/bag/plants
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Original" = list(
			RESKIN_ICON = 'icons/obj/service/hydroponics/equipment.dmi',
			RESKIN_ICON_STATE = "plantbag",
			RESKIN_WORN_ICON = 'icons/mob/clothing/belt.dmi',
			RESKIN_WORN_ICON_STATE = "plantbag",
		),
		RESKIN_LINEN = list(
			RESKIN_ICON = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/plant_bag.dmi',
			RESKIN_ICON_STATE = "plantbag_primitive",
			RESKIN_WORN_ICON = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/plant_bag_worn.dmi',
			RESKIN_WORN_ICON_STATE = "plantbag_primitive",
		),
	)


// This is so the linen reskin shows properly in the suit storage.
/obj/item/storage/bag/plants/build_worn_icon(default_layer, default_icon_file, isinhands, female_uniform, override_state, override_file, mutant_styles)
	if(default_layer == SUIT_STORE_LAYER && current_skin == RESKIN_LINEN)
		override_file = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/plant_bag_worn_mirror.dmi'

	return ..()


/// Simple helper to reskin this item into its primitive variant.
/obj/item/storage/bag/plants/proc/make_primitive()
	current_skin = RESKIN_LINEN

	icon = unique_reskin[current_skin][RESKIN_ICON]
	icon_state = unique_reskin[current_skin][RESKIN_ICON_STATE]
	worn_icon = unique_reskin[current_skin][RESKIN_WORN_ICON]
	worn_icon_state = unique_reskin[current_skin][RESKIN_WORN_ICON_STATE]

	update_appearance()


/// A helper for the primitive variant, for mappers.
/obj/item/storage/bag/plants/primitive
	current_skin = RESKIN_LINEN // Just so it displays properly when in suit storage
	uses_advanced_reskins = FALSE
	unique_reskin = null
	icon = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/plant_bag.dmi'
	icon_state = "plantbag_primitive"
	worn_icon = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/plant_bag_worn.dmi'
	worn_icon_state = "plantbag_primitive"


/obj/item/stack/sheet/cloth/on_item_crafted(mob/builder, atom/created)
	if(!istype(created, /obj/item/storage/bag/plants))
		return

	if(!isprimitivedemihuman(builder))
		return

	var/obj/item/storage/bag/plants/bag = created

	bag.make_primitive()


/obj/item/storage/bag/plants/portaseeder
	uses_advanced_reskins = FALSE
	unique_reskin = null


#undef RESKIN_LINEN
