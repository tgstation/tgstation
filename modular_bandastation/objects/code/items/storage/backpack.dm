/obj/item/storage/backpack/blueshield
	name = "blueshield backpack"
	desc = "A robust backpack issued to Nanotrasen's finest."
	icon = 'modular_bandastation/objects/icons/obj/storage/backpack.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/back.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_righthand.dmi'
	icon_state = "backpack_blueshield"
	inhand_icon_state = "backpack_blueshield"

/obj/item/storage/backpack/satchel/blueshield
	name = "blueshield satchel"
	desc = "A robust satchel issued to Nanotrasen's finest."
	icon = 'modular_bandastation/objects/icons/obj/storage/backpack.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/back.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_righthand.dmi'
	icon_state = "satchel_blueshield"
	inhand_icon_state = "satchel_blueshield"

/obj/item/storage/backpack/duffelbag/blueshield
	name = "blueshield duffelbag"
	desc = "A robust duffelbag issued to Nanotrasen's finest."
	icon = 'modular_bandastation/objects/icons/obj/storage/backpack.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/back.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_righthand.dmi'
	icon_state = "duffel_blueshield"
	inhand_icon_state = "duffel_blueshield"

// MARK: TSF
/obj/item/storage/backpack/tsf
	name = "TSF backpack"
	desc = "Специальный тактический рюкзак, разработанный и прозводящийся для вооруженных сил ТСФ."
	icon = 'modular_bandastation/objects/icons/obj/storage/backpack.dmi'
	icon_state = "backpack_tsf"
	inhand_icon_state = "backpack_tsf"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_righthand.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/back.dmi'
	storage_type = /datum/storage/backpack/tsf

/datum/storage/backpack/tsf
	max_total_storage = 26
	max_slots = 26

// MARK: USSP
/obj/item/storage/backpack/ussp
	name = "USSP backpack"
	desc = "Вместительная полевая сумка."
	icon = 'modular_bandastation/objects/icons/obj/storage/backpack.dmi'
	icon_state = "backpack_ussp"
	inhand_icon_state = "backpack_ussp"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_righthand.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/back.dmi'
	storage_type = /datum/storage/backpack/ussp

/datum/storage/backpack/ussp
	max_total_storage = 26
	max_slots = 26

// MARK: Etamin ind.
/obj/item/storage/backpack/etamin_ind
	name = "Gold on Black backpack"
	desc = "Вместительный рюкзак от Etamin Industry. На ткани угольного цвета красуется логотип корпорации - Золотое Солнце."
	icon = 'modular_bandastation/objects/icons/obj/storage/backpack.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/back.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/backpack_righthand.dmi'
	icon_state = "backpack_ei"
	inhand_icon_state = "backpack_ei"

// MARK: ERT
/obj/item/storage/backpack/ert/extra_large
	name = "emergency response large backpack"
	desc = "Специальный тактический рюкзак."
	storage_type = /datum/storage/backpack/ert_large

/datum/storage/backpack/ert_large
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = 21
	max_slots = 26
