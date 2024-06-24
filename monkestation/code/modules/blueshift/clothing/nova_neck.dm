/obj/item/clothing/neck/tie/disco
	name = "horrific necktie"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "eldritch_tie"
	desc = "The necktie is adorned with a garish pattern. It's disturbingly vivid. Somehow you feel as if it would be wrong to ever take it off. It's your friend now. You will betray it if you change it for some boring scarf."

/obj/item/clothing/neck/mantle
	name = "mantle"
	desc = "A decorative drape over the shoulders. This one has a simple, dry color."
	icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "mantle"

/obj/item/clothing/neck/mantle/regal
	name = "regal mantle"
	desc = "A colorful felt mantle. You feel posh just holding this thing."
	icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "regal-mantle"

/obj/item/clothing/neck/mantle/qm
	name = "\proper the quartermaster's mantle"
	desc = "A snug and comfortable looking shoulder covering garment, it has an air of rebellion and independence. Or annoyance and delusions, your call."
	icon_state = "qmmantle"

/obj/item/clothing/neck/mantle/hopmantle
	name = "\proper the head of personnel's mantle"
	desc = "A decorative draping of blue and red over your shoulders, signifying your stamping prowess."
	icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "hopmantle"

/obj/item/clothing/neck/mantle/cmomantle
	name = "\proper the chief medical officer's mantle"
	desc = "A light blue shoulder draping for THE medical professional. Contrasts well with blood."
	icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "cmomantle"

/obj/item/clothing/neck/mantle/rdmantle
	name = "\proper the research director's mantle"
	desc = "A terribly comfortable shoulder draping for the discerning scientist of fashion."
	icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "rdmantle"

/obj/item/clothing/neck/mantle/cemantle
	name = "\proper the chief engineer's mantle"
	desc = "A bright white and yellow striped mantle. Do not wear around active machinery."
	icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "cemantle"

/obj/item/clothing/neck/mantle/hosmantle
	name = "\proper the head of security's mantle"
	desc = "A plated mantle that one might wrap around the upper torso. The 'scales' of the garment signify the members of security and how you're carrying them on your shoulders."
	icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "hosmantle_blue" //There's a red version if you remove the _blue, but its not coded in currently.

/obj/item/clothing/neck/mantle/bsmantle
	name = "\proper the blueshield's mantle"
	desc = "A plated mantle with command colors. Suitable for the one assigned to making sure they're still breathing."
	icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "bsmantle"

/obj/item/clothing/neck/mantle/capmantle
	name = "\proper the captain's mantle"
	desc = "A formal mantle to drape around the shoulders. Others stand on the shoulders of giants. You're the giant they stand on."
	icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "capmantle"

/obj/item/clothing/neck/mantle/recolorable
	name = "mantle"
	desc = "A simple drape over the shoulders."
	icon = 'monkestation/code/modules/blueshift/gags/icons/neck/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/gags/icons/neck/neck.dmi'
	icon_state = "mantle"
	greyscale_colors = "#ffffff"
	greyscale_config = /datum/greyscale_config/mantle
	greyscale_config_worn = /datum/greyscale_config/mantle/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/face_scarf
	name = "face scarf"
	desc = "A warm looking scarf that you can easily put around your face."
	icon_state = "face_scarf"
	greyscale_config = /datum/greyscale_config/face_scarf
	greyscale_config_worn = /datum/greyscale_config/face_scarf/worn
	greyscale_colors = "#a52424"
	flags_1 = IS_PLAYER_COLORABLE_1
	flags_inv = HIDEFACIALHAIR | HIDESNOUT
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

/obj/item/clothing/neck/face_scarf/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, toggle_noun = "scarf")

/obj/item/clothing/neck/face_scarf/AltClick(mob/user) //Make sure that toggling actually hides the snout so that it doesn't clip
	if(icon_state != "face_scarf_t")
		flags_inv = HIDEFACIALHAIR | HIDESNOUT
	else
		flags_inv = HIDEFACIALHAIR
	return TRUE

/obj/item/clothing/neck/maid_neck_cover
	name = "maid neck cover"
	desc = "A neckpiece for a maid costume, it smells faintly of disappointment."
	icon_state = "maid_neck_cover"
	greyscale_config = /datum/greyscale_config/maid_neck_cover
	greyscale_config_worn = /datum/greyscale_config/maid_neck_cover/worn
	greyscale_colors = "#7b9ab5#edf9ff"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/cloak/colourable
	name = "colourable cloak"
	icon_state = "gags_cloak"
	greyscale_config = /datum/greyscale_config/cloak
	greyscale_config_worn = /datum/greyscale_config/cloak/worn
	greyscale_colors = "#917A57#4e412e#4e412e"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/cloak/colourable/veil
	name = "colourable veil"
	icon_state = "gags_veil"
	greyscale_config = /datum/greyscale_config/cloak/veil
	greyscale_config_worn = /datum/greyscale_config/cloak/veil/worn

/obj/item/clothing/neck/cloak/colourable/boat
	name = "colourable boatcloak"
	icon_state = "gags_boat"
	greyscale_config = /datum/greyscale_config/cloak/boat
	greyscale_config_worn = /datum/greyscale_config/cloak/boat/worn

/obj/item/clothing/neck/cloak/colourable/shroud
	name = "colourable shroud"
	icon_state = "gags_shroud"
	greyscale_config = /datum/greyscale_config/cloak/shroud
	greyscale_config_worn = /datum/greyscale_config/cloak/shroud/worn

/obj/item/clothing/neck/chaplain
	name = "bishop's cloak"
	desc = "Become the space pope."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "bishopcloak"

/obj/item/clothing/neck/chaplain/black
	name = "black bishop's cloak"
	icon_state = "blackbishopcloak"

/obj/item/clothing/neck/cloak/qm/nova/interdyne
	name = "deck officer's cloak"
	desc = "A cloak that represents the eternal Cargonia. There's little Mosin Nagant emblems woven into the fabric."

/obj/item/clothing/neck/cowboylea
	name = "green cowboy poncho"
	desc = "A sand covered cloak, there seems to be a small deer head with antlers embroidered inside."
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/neck.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "cowboy_poncho"
	heat_protection = CHEST

/obj/item/clothing/neck/cowboylea/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_clothes, "cowboy_poncho_t")

//This one is greyscale :)
/obj/item/clothing/neck/ranger_poncho
	name = "ranger poncho"
	desc = "Aim for the Heart, Ramon."
	icon_state = "ranger_poncho"
	greyscale_config = /datum/greyscale_config/ranger_poncho
	greyscale_config_worn = /datum/greyscale_config/ranger_poncho/worn
	greyscale_colors = "#917A57#858585"	//Roughly the same color as the original non-greyscale item was
	flags_1 = IS_PLAYER_COLORABLE_1
	heat_protection = CHEST

/obj/item/clothing/neck/ranger_poncho/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_clothes, "ranger_poncho_t")

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
	AddComponent(/datum/component/toggle_clothes, "long_cape_t")

/obj/item/clothing/neck/wide_cape
	name = "wide cape"
	desc = "A proud, broad-shouldered cloak with which you can protect the honor of your back."
	icon_state = "wide_cape"
	greyscale_config = /datum/greyscale_config/wide_cape
	greyscale_config_worn = /datum/greyscale_config/wide_cape/worn
	greyscale_colors = "#867361#4d433d#b2a69c"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|ARMS
