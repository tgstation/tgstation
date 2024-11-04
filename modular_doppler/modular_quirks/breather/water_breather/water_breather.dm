/datum/quirk/item_quirk/breather/water_breather
	name = "Water Breather"
	desc = "You have a pair of gills and are only capable of breathing oxygen through water, stay wet to breathe!"
	icon = FA_ICON_FISH
	medical_record_text = "Patient has a pair of gills on their body."
	gain_text = "<span class='danger'>You suddenly have a hard time breathing through thin air."
	lose_text = "<span class='notice'>You suddenly feel like you aren't bound to breathing through liquid anymore."
	value = 0
	breath_type = "water"

/datum/quirk/item_quirk/breather/water_breather/add_unique(client/client_source)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/lungs/target_lungs = quirk_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	var/obj/item/clothing/accessory/breathing/target_tag = new(get_turf(quirk_holder))
	target_tag.breath_type = breath_type

	give_item_to_holder(target_tag, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	give_item_to_holder(
		/obj/item/clothing/accessory/vaporizer,
		list(
			LOCATION_HANDS = ITEM_SLOT_HANDS,
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK
		), "Be sure to equip your vaporizer, or you may end up choking to death!"
	)
	// if your lungs already have this trait, no need to update
	if(target_lungs.type == /obj/item/organ/lungs/fish)
		return
	target_lungs.safe_oxygen_min = 0
	// update lung procs
	target_lungs.breathe_always = list(/datum/gas/water_vapor = "breathe_water")
	// reflect correct lung flags
	target_lungs.respiration_type = RESPIRATION_OXYGEN
	// flavor
	target_lungs.AddElement(/datum/element/noticable_organ, "%PRONOUN_Theyve a set of gills on %PRONOUN_their neck.", BODY_ZONE_PRECISE_MOUTH)
	target_lungs.AddComponent(/datum/component/bubble_icon_override, "fish", BUBBLE_ICON_PRIORITY_ORGAN)
	// add the gills overlay
	var/obj/item/bodypart/chest/target_chest = quirk_holder.get_bodypart(BODY_ZONE_CHEST)
	if(target_chest) // just to be sure
		target_chest.add_bodypart_overlay(new /datum/bodypart_overlay/simple/gills)
