// helmets

/obj/item/clothing/head/helmet/tajaran
	name = "\improper Tajaran flophelmet"
	desc = "An unremarkable helmet with more than remarkable decoration. A large, royal purple flophat decorates the top \
		of this in an unmistakably Tajaran show of fashion."
	icon = 'modular_doppler/species_clothes/icons/tajara/gear.dmi'
	icon_state = "flophelmet"
	worn_icon = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi'
	worn_icon_state = "flophelmet"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	supported_bodyshapes = null
	flags_cover = EARS_COVERED
	flags_inv = null
	hair_mask = /datum/hair_mask/standard_hat_middle

/obj/item/clothing/head/helmet/tajaran/contract
	name = "\improper Tajaran high flophelmet"
	desc = "An unremarkable helmet with more than remarkable decoration. A large, silvery flophat decorates the top of this \
		in an unmistakably Tajaran show of fashion and status. It even has reflective gold-lined glass to protect the eyes."
	icon_state = "flophelmet_rich"
	worn_icon_state = "flophelmet_rich"
	flags_cover = HEADCOVERSEYES|EARS_COVERED

/obj/item/clothing/head/helmet/vulp
	name = "\improper Vulpkanin skirmisher helmet"
	desc = "A strong and simple helmet. Taking design notes from the Tizirians, the front is strongly angled to \
		give a much greater chance at glancing blows. Different, however, is the much more open air and artistic design."
	icon = 'modular_doppler/species_clothes/icons/vulp/gear.dmi'
	icon_state = "skirmisher"
	worn_icon = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi'
	worn_icon_state = "skirmisher"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	supported_bodyshapes = null
	flags_cover = EARS_COVERED
	flags_inv = null
	hair_mask = /datum/hair_mask/standard_hat_middle

// armor vest

/obj/item/clothing/suit/armor/tajaran
	name = "\improper Tajaran plate"
	desc = "Full upper body plate armor, made of exceptional modern material and decorated extensively. No one set of plate \
		looks the same as another, and the value of each set is measured in not only it's material, but also a complete \
		original mural without plate replacement despite seeing combat."
	icon = 'modular_doppler/species_clothes/icons/tajara/gear.dmi'
	icon_state = "armor"
	worn_icon = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi'
	worn_icon_state = "armor"
	supported_bodyshapes = null

/obj/item/clothing/suit/armor/tajaran/gold
	name = "\improper Tajaran high plate"
	desc = "Full upper body plate armor, made of exceptional modern material and decorated extensively. No one set of plate \
		looks the same as another, and the value of each set is measured in not only it's material, but also a complete \
		original mural without plate replacement despite seeing combat. This set is adorned with brilliant gold accents \
		likely to denote the wearer as someone of greater importance."
	icon_state = "armor_high"
	worn_icon_state = "armor_high"

/obj/item/clothing/suit/armor/vulp
	name = "\improper Vulpkanin skirmisher armor"
	desc = "Beautiful in function, a heavy set of Vulpkanin armor is never identical to another set in overall design. \
		Much like the crab, each set is a completely different design of armor that has evolved to a similar point, each \
		made by a completely different engineer for their favorite vatborn."
	icon = 'modular_doppler/species_clothes/icons/vulp/gear.dmi'
	icon_state = "armor"
	worn_icon = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi'
	worn_icon_state = "armor"
	supported_bodyshapes = null

// leg armor

/obj/item/clothing/shoes/tajaran_shins
	name = "gold-plate greaves"
	desc = "Thick plated greaves worn commonly by Tajaran warriors, protecting their legs from such modern dangers as \
		minor damage during impossible tasks like doing your own work, or fighting people shorter than you."
	icon = 'modular_doppler/species_clothes/icons/tajara/gear.dmi'
	icon_state = "guards"
	worn_icon = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi'
	worn_icon_state = "guards"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	body_parts_covered = FEET|LEGS
	fastening_type = SHOES_STRAPS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/species_clothes/icons/tajara/gear_worn_dig.dmi',
	)
	armor_type = /datum/armor/colonist_armor

/obj/item/clothing/shoes/vulp_shins
	name = "alloy shin plate"
	desc = "Thick plates worn on what counts as the shins of something digitigrade, for protecting the wearer. \
		Against what? Just daily wear and tear, such as kicking enemies, or machines that don't work, or enemies."
	icon = 'modular_doppler/species_clothes/icons/vulp/gear.dmi'
	icon_state = "guards"
	worn_icon = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi'
	worn_icon_state = "guards"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	body_parts_covered = FEET|LEGS
	fastening_type = SHOES_STRAPS
	item_flags = IGNORE_DIGITIGRADE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/species_clothes/icons/vulp/gear_worn_dig.dmi',
	)
	armor_type = /datum/armor/colonist_armor

// gloves

/obj/item/clothing/gloves/tajaran_gloves
	name = "gold-plate gauntlets"
	desc = "Gold-plated armored gauntlets, as only the finest decorated hands should be responsible for the end of your life."
	icon = 'modular_doppler/species_clothes/icons/tajara/gear.dmi'
	icon_state = "gloves"
	worn_icon = 'modular_doppler/species_clothes/icons/tajara/gear_worn.dmi'
	worn_icon_state = "gloves"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	body_parts_covered = HANDS|ARMS
	armor_type = /datum/armor/colonist_armor

/obj/item/clothing/gloves/vulp_gloves
	name = "alloy gauntlets"
	desc = "Alloy-plated armored gauntlets, as only the finest armored hands should be responsible for the end of your life."
	icon = 'modular_doppler/species_clothes/icons/vulp/gear.dmi'
	icon_state = "gloves"
	worn_icon = 'modular_doppler/species_clothes/icons/vulp/gear_worn.dmi'
	worn_icon_state = "gloves"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	body_parts_covered = HANDS|ARMS
	armor_type = /datum/armor/colonist_armor
