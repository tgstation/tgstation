/obj/item/clothing/suit/hooded/dinojammies
	name = "dinosaur pajamas"
	desc = "The ultimate in reptile-pajama-costume fusion."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "dinojammies"
	worn_icon_state = "dinojammies"
	hoodtype = /obj/item/clothing/head/hooded/dinojammies

/obj/item/clothing/head/hooded/dinojammies
	desc = "A dinosaur head hood."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "dinojammies_hood"
	worn_icon_state = "dinojammies_hood"
	flags_inv = HIDEHAIR

/obj/item/clothing/suit/hooded/gorilla
	name = "gorilla costume"
	desc = "Ooga!"
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "gorilla"
	worn_icon_state = "gorilla"
	hoodtype = /obj/item/clothing/head/hooded/gorilla
	alternative_screams = list('sound/creatures/gorilla.ogg')

/obj/item/clothing/head/hooded/gorilla
	desc = "A gorilla costume hood."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "gorilla"
	worn_icon_state = "gorilla"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/suit/shipwreckedsuit
	name = "shipwrecked captain suit"
	desc = "DISCLAIMER:Not Space Proof. Wearing this suit gives you the luck of a true space captain! Just avoid the space rocks..."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "shipwrecked_suit"
	worn_icon_state = "shipwrecked_suit"

/obj/item/clothing/head/shipwreckedhelmet
	name = "shipwrecked captain helmet"
	desc = "DISCLAIMER:Not Space Proof. A vital part of keeping out the poisonous oxygen!... what do you mean oxygen is good for me?"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "shipwrecked_helmet"
	worn_icon_state = "shipwrecked_helmet"
	worn_y_offset = 4

/obj/item/clothing/suit/kingofbugssuit
	name = "king of bugs suit"
	desc = "DISCLAIMER:Not Space Proof. Dandori Issues "
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "kingofbugs_suit"
	worn_icon_state = "kingofbugs_suit"

/obj/item/clothing/head/kingofbugshelmet
	name = "king of bugs helmet"
	desc = "DISCLAIMER:Not Space Proof. FOOD!!!"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "kingofbugs_helmet"
	worn_icon_state = "kingofbugs_helmet"
	worn_y_offset = 5

/obj/item/clothing/head/helldiverhelmet
	name = "helldiver helmet"
	desc = "Have a Nice Cup of LIBER-TEA"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "helldiver_helm"
	worn_icon_state = "helldiver_helm"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT

/datum/loadout_item/head/helldiverhelmet
	name = "Helldiver Helmet"
	item_path = /obj/item/clothing/head/helldiverhelmet

/datum/store_item/head/helldiverhelmet
	name = "Helldiver Helmet"
	item_path = /obj/item/clothing/head/helldiverhelmet
	item_cost = 10000

/obj/item/clothing/suit/helldiverarmor
	name = "helldiver armor"
	desc = "How Do You Like The Taste of DEMOCRACY?!"
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "helldiver_armor"
	worn_icon_state = "helldiver_armor"
	flags_inv = HIDEJUMPSUIT

/datum/loadout_item/suit/helldiverarmor
	name = "Helldiver Armor"
	item_path = /obj/item/clothing/suit/helldiverarmor

/datum/store_item/suit/helldiverarmor
	name = "Helldiver Armor"
	item_path = /obj/item/clothing/suit/helldiverarmor
	item_cost = 10000

/obj/item/clothing/suit/hooded/ashsuit
	name = "ashsuit suit"
	desc = "Whoever controls the Plasma, controls the Spinward Sector."
	icon_state = "ashsuit"
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/hooded/ashsuit
	armor_type = /datum/armor/hooded_ashsuit
	allowed = list(
		/obj/item/flashlight,
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/storage/bag/ore,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/tank/internals,
		)
	resistance_flags = FIRE_PROOF
	clothing_traits = list(TRAIT_SNOWSTORM_IMMUNE)

/datum/armor/hooded_ashsuit
	melee = 30
	bullet = 10
	laser = 10
	energy = 20
	bomb = 50
	fire = 50
	acid = 50

/obj/item/clothing/head/hooded/ashsuit
	name = "ashsuit hood"
	desc = "For covering your face when walking the ash dunes."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "ashsuit"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	armor_type = /datum/armor/hooded_explorer
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/hooded/ashsuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/head/hooded/ashsuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)
