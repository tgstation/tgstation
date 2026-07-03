/obj/item/storage/backpack/duffelbag/syndie/centcom
	name = "modified duffel bag"
	desc = "Большая сумка для хранения дополнительных тактических принадлежностей. Она оснащена смазанной пластитановой молнией для максимально быстрого тактического застегивания и лучше сбалансирована на спине, чем обычная сумка. Может вместить три громоздких предмета!"
	icon_state = "duffel-srt"
	icon = 'modular_bandastation/objects/icons/obj/storage/duffelbag/duffelbag.dmi'
	worn_icon = 'modular_bandastation/objects/icons/obj/clothing/back/duffelbag.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/obj/storage/duffelbag/duffelbag_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/obj/storage/duffelbag/duffelbag_righthand.dmi'
	worn_icon_state = "duffel-srt-back"
	inhand_icon_state = "duffel-srt"
	storage_type = /datum/storage/duffel/syndicate/centcom
	resistance_flags = FIRE_PROOF
	// No slowdown while unzipped.
	zip_slowdown = 0
	// Faster unzipping. Utilizes the same noise as zipping up to fit the unzip duration.
	unzip_duration = 0.5 SECONDS

/obj/item/storage/backpack/duffelbag/syndie/centcom/ammo
	name = "modified ammo duffel bag"
	inhand_icon_state = "duffel-srtammo"
	icon_state = "duffel-srtammo"
	worn_icon_state = "duffel-srtammo-back"

/obj/item/storage/backpack/duffelbag/syndie/centcom/med
	name = "modified med duffel bag"
	inhand_icon_state = "duffel-srtmed"
	icon_state = "duffel-srtmed"
	worn_icon_state = "duffel-srtmed-back"

/datum/storage/duffel/syndicate/centcom
	silent = TRUE
	exception_max = 3
