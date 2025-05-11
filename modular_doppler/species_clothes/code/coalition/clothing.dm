// head

/obj/item/clothing/head/tajaran_hat
	name = "earcap"
	desc = "The Tajaran headwear favorite. A stylish cap, thin enough to sit pretty between the ears of those who wear it."
	icon = 'modular_doppler/species_clothes/icons/tajara/gear.dmi'
	icon_state = "earcap"
	worn_icon = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi'
	worn_icon_state = "earcap"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	supported_bodyshapes = null

/obj/item/clothing/head/vulp_hat
	name = "flat-top"
	desc = "There is no real practical reason for this piece of Vulpkanin headwear, only that a majority of them agree it is, \
		and excuse the potential error in translation, \"Cool as fuck\"."
	icon = 'modular_doppler/species_clothes/icons/vulp/gear.dmi'
	icon_state = "flattop"
	worn_icon = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi'
	worn_icon_state = "flattop"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	supported_bodyshapes = null

/obj/item/clothing/head/vulp_hat/headband
	name = "\improper Vulpkanin bandana"
	desc = "A long, flowing bandana often wrapped around the heads of any Carcajoulein made to carry heavy weaponry. \
		No specific explaination for this has been found, it is simply a known fact of the universe."
	icon_state = "headband"
	worn_icon_state = "headband"

// eye hud

/obj/item/clothing/glasses/tajaran_hud
	name = "holographic infohud"
	desc = "An overly expensive piece of eyewear, as much a fashion piece as it is a practical tool. \
		Displays information for the wearer in a format that can be easily seen as the edges of their vision \
		on top of whatever they see currently."
	icon = 'modular_doppler/species_clothes/icons/tajara/gear.dmi'
	icon_state = "hud"
	worn_icon = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi'
	worn_icon_state = "hud"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null

/obj/item/clothing/glasses/tajaran_hud/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/glasses_stats_thief)

/obj/item/clothing/glasses/tajaran_hud/change_glass_color(new_color_type)
	if(glass_colour_type)
		RemoveElement(/datum/element/wearable_client_colour, glass_colour_type, ITEM_SLOT_EYES, forced = forced_glass_color, comsig_toggle = COMSIG_CLICK_CTRL)
	glass_colour_type = new_color_type
	if(glass_colour_type)
		AddElement(/datum/element/wearable_client_colour, glass_colour_type, ITEM_SLOT_EYES, forced = forced_glass_color, comsig_toggle = COMSIG_CLICK_CTRL)

// neck capes

/obj/item/clothing/neck/tajaran_cape
	name = "holder's cape"
	desc = "A gold-threaded cape, common on battlegrounds such as these to show those combatants who hold a real house \
		contract, and thus are more important than others."
	icon = 'modular_doppler/species_clothes/icons/tajara/gear.dmi'
	icon_state = "cape"
	worn_icon = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi'
	worn_icon_state = "cape"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null

/obj/item/clothing/neck/tajaran_cape/med
	name = "healer's cape"
	desc = "A cape made of fine red thread, dyed from the red made of a million small beetles of the Tajaran homeworld. \
		Notoriously difficult to cultivate, and thus reserved only for those who dedicate their lives to others. Who would even \
		think about using that in food?" // red dye 40
	icon_state = "cape_med"
	worn_icon_state = "cape_med"

/obj/item/clothing/neck/vulp_cape
	name = "skirmisher's cape"
	desc = "A brilliant shoulder cloak that extends far down the back, commonly enjoyed for minor protection in duels and \
		work. Most commonly work by Vulpkanin warriors."
	icon = 'modular_doppler/species_clothes/icons/vulp/gear.dmi'
	icon_state = "cape"
	worn_icon = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi'
	worn_icon_state = "cape"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null

/obj/item/clothing/neck/vulp_cape/med
	name = "medic's cape"
	desc = "A brilliant shoulder cloak that extends far down the back, dyed red like the blood of their wearers. \
		Worn almost always by those Vulpkanin who make it their life's work to fix those who cannot figure how."
	icon_state = "cape_medic"
	worn_icon_state = "cape_medic"

// suit items

/obj/item/clothing/suit/tajaran_dressing
	name = "regal dressing"
	desc = "Most equivalent to an exceptionally long scarf, worn wrapped around the body in many varying styles depending \
		on the house a Tajaran belongs to."
	icon = 'modular_doppler/species_clothes/icons/tajara/gear.dmi'
	icon_state = "dressing"
	worn_icon = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi'
	worn_icon_state = "dressing"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	supported_bodyshapes = null

/obj/item/clothing/neck/vulp_cloak
	name = "vatcloak"
	desc = "A gold-fastened white mini cloak often worn by the most skilled of a group of Vulpkanin, which most typically \
		tends to be the vatborn among them."
	icon = 'modular_doppler/species_clothes/icons/vulp/gear.dmi'
	icon_state = "vatcloak"
	worn_icon = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi'
	worn_icon_state = "vatcloak"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null

// kilts

/obj/item/clothing/under/tajaran_corset
	name = "\improper Tajaran warrior's corset"
	desc = "The strangest trend in Tajaran fashion in the past century, practical combat pants mixed with an unusual \
		silver-threaded corset on the upper half. Trendy and stylish for it's ability to make any warrior appear at the peak \
		of their physical prime, even those who are not quite there."
	icon = 'modular_doppler/species_clothes/icons/tajara/gear.dmi'
	icon_state = "corset"
	worn_icon = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi'
	worn_icon_state = "corset"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS
	can_adjust = FALSE
	female_sprite_flags = NO_FEMALE_UNIFORM
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/species_clothes/icons/tajara/gear_worn_dig.dmi',
	)

/obj/item/clothing/under/vulp_pants
	name = "padded combat pants"
	desc = "Plainly simple combat pants, to make kneeling and other fun combat activities less painful on the skin. \
		While many are made to be combined with a top of some sort, studies find ninety-nine percent are recycled into \
		bandages or armor decoration within the first 30 seconds of ownership. Who would want to cover a vatborn's \
		finely engineered fur patterns, after all?"
	icon = 'modular_doppler/species_clothes/icons/vulp/gear.dmi'
	icon_state = "pants"
	worn_icon = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi'
	worn_icon_state = "pants"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	body_parts_covered = GROIN|LEGS
	can_adjust = FALSE
	female_sprite_flags = NO_FEMALE_UNIFORM
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/species_clothes/icons/vulp/gear_worn_dig.dmi',
	)
