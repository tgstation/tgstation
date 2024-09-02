//////////////////
//CAPES & CLOAKS//
//////////////////

/obj/item/clothing/neck/robe_cape
	name = "robe cape"
	desc = "A comfortable northern-style cape, draped down your back and held around your neck with a brooch. Reminds you of a sort of robe."
	icon_state = "robe_cape"
	greyscale_config = /datum/greyscale_config/robe_cape
	greyscale_config_worn = /datum/greyscale_config/robe_cape/worn
	greyscale_colors = "#867361"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/neck/long_cape
	name = "long cape"
	desc = "A graceful cloak that carefully surrounds your body."
	icon_state = "long_cape"
	greyscale_config = /datum/greyscale_config/long_cape
	greyscale_config_worn = /datum/greyscale_config/long_cape/worn
	greyscale_colors = "#867361#4d433d#b2a69c#b2a69c"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/neck/long_cape/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/neck/wide_cape
	name = "wide cape"
	desc = "A proud, broad-shouldered cloak with which you can protect the honor of your back."
	icon_state = "wide_cape"
	greyscale_config = /datum/greyscale_config/wide_cape
	greyscale_config_worn = /datum/greyscale_config/wide_cape/worn
	greyscale_colors = "#867361#4d433d#b2a69c"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|ARMS

///////////
//SCARVES//
///////////

/obj/item/clothing/neck/face_scarf
	name = "face scarf"
	desc = "A warm looking scarf that you can easily put around your face."
	icon_state = "face_scarf"
	greyscale_config = /datum/greyscale_config/face_scarf
	greyscale_config_worn = /datum/greyscale_config/face_scarf/worn
	greyscale_colors = "#a52424"
	flags_1 = IS_PLAYER_COLORABLE_1
	flags_inv = HIDEFACIALHAIR

/obj/item/clothing/neck/face_scarf/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

///////////////
//MISCELLANIA//
///////////////

/obj/item/clothing/neck/maid_neck_cover
	name = "maid neck cover"
	desc = "A neckpiece for a maid costume, it smells faintly of disappointment."
	icon_state = "maid_neck_cover"
	greyscale_config = /datum/greyscale_config/maid_neck_cover
	greyscale_config_worn = /datum/greyscale_config/maid_neck_cover/worn
	greyscale_colors = "#7b9ab5#edf9ff"
	flags_1 = IS_PLAYER_COLORABLE_1
