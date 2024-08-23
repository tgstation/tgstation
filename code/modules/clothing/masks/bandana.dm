/obj/item/clothing/mask/bandana
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK
	adjusted_flags = ITEM_SLOT_HEAD
	species_exception = list(/datum/species/golem)
	dying_key = DYE_REGISTRY_BANDANA
	flags_1 = IS_PLAYER_COLORABLE_1
	name = "bandana"
	desc = "A fine bandana with nanotech lining."
	icon_state = "bandana"
	icon_state_preview = "bandana_cloth"
	inhand_icon_state = "greyscale_bandana"
	greyscale_config = /datum/greyscale_config/bandana
	greyscale_config_worn = /datum/greyscale_config/bandana/worn
	greyscale_config_inhand_left = /datum/greyscale_config/bandana/inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/bandana/inhands_right
	greyscale_colors = "#2e2e2e"

/obj/item/clothing/mask/bandana/examine(mob/user)
	. = ..()
	if(up)
		. += "Use in-hand to untie it to wear as a mask!"
		return
	if(slot_flags & ITEM_SLOT_NECK)
		. += "Alt-click to untie it to wear as a mask!"
	else
		. += "Use in-hand to tie it up to wear as a hat!"
		. += "Alt-click to tie it up to wear on your neck!"

/obj/item/clothing/mask/bandana/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/mask/bandana/adjust_visor(mob/living/user)
	if(slot_flags & ITEM_SLOT_NECK)
		to_chat(user, span_warning("You must undo [src] in order to push it into a hat!"))
		return FALSE
	return ..()

/obj/item/clothing/mask/bandana/visor_toggling()
	. = ..()
	if(up)
		undyeable = TRUE
	else
		undyeable = initial(undyeable)

/obj/item/clothing/mask/bandana/click_alt(mob/user)
	if(!iscarbon(user))
		return NONE

	var/mob/living/carbon/char = user
	var/matrix/widen = matrix()
	if((char.get_item_by_slot(ITEM_SLOT_NECK) == src) || (char.get_item_by_slot(ITEM_SLOT_MASK) == src) || (char.get_item_by_slot(ITEM_SLOT_HEAD) == src))
		to_chat(user, span_warning("You can't tie [src] while wearing it!"))
		return CLICK_ACTION_BLOCKING
	else if(slot_flags & ITEM_SLOT_HEAD)
		to_chat(user, span_warning("You must undo [src] before you can tie it into a neckerchief!"))
		return CLICK_ACTION_BLOCKING
	else if(!user.is_holding(src))
		to_chat(user, span_warning("You must be holding [src] in order to tie it!"))
		return CLICK_ACTION_BLOCKING

	if(slot_flags & ITEM_SLOT_MASK)
		undyeable = TRUE
		slot_flags = ITEM_SLOT_NECK
		worn_y_offset = -3
		widen.Scale(1.25, 1)
		transform = widen
		user.visible_message(span_notice("[user] ties [src] up like a neckerchief."), span_notice("You tie [src] up like a neckerchief."))
	else
		undyeable = initial(undyeable)
		slot_flags = initial(slot_flags)
		worn_y_offset = initial(worn_y_offset)
		transform = initial(transform)
		user.visible_message(span_notice("[user] unties the neckercheif."), span_notice("You untie the neckercheif."))
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	desc = "A fine red bandana with nanotech lining."
	greyscale_colors = "#A02525"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	desc = "A fine blue bandana with nanotech lining."
	greyscale_colors = "#294A98"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/purple
	name = "purple bandana"
	desc = "A fine purple bandana with nanotech lining."
	greyscale_colors = "#9900CC"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	desc = "A fine green bandana with nanotech lining."
	greyscale_colors = "#3D9829"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	desc = "A fine gold bandana with nanotech lining."
	greyscale_colors = "#DAC20E"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/orange
	name = "orange bandana"
	desc = "A fine orange bandana with nanotech lining."
	greyscale_colors = "#da930e"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	desc = "A fine black bandana with nanotech lining."
	greyscale_colors = "#2e2e2e"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/white
	name = "white bandana"
	desc = "A fine white bandana with nanotech lining."
	greyscale_colors = "#DCDCDC"
	flags_1 = NONE
	icon_state_preview = "bandana_cloth"

/obj/item/clothing/mask/bandana/durathread
	name = "durathread bandana"
	desc = "A bandana made from durathread, you wish it would provide some protection to its wearer, but it's far too thin..."
	greyscale_colors = "#5c6d80"
	flags_1 = NONE
	icon_preview = 'icons/obj/fluff/previews.dmi'
	icon_state_preview = "bandana_durathread"

/obj/item/clothing/mask/bandana/striped
	name = "striped bandana"
	desc = "A fine bandana with nanotech lining and a stripe across."
	icon_state = "bandstriped"
	greyscale_config = /datum/greyscale_config/bandana/striped
	greyscale_config_worn = /datum/greyscale_config/bandana/striped/worn
	greyscale_config_inhand_left = /datum/greyscale_config/bandana/striped/inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/bandana/striped/inhands_right
	greyscale_colors = "#2e2e2e#C6C6C6"
	undyeable = TRUE

/obj/item/clothing/mask/bandana/striped/black
	name = "striped bandana"
	desc = "A fine black and white bandana with nanotech lining and a stripe across."
	greyscale_colors = "#2e2e2e#C6C6C6"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/security
	name = "striped security bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and security colors."
	greyscale_colors = "#A02525#2e2e2e"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/science
	name = "striped science bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and science colors."
	greyscale_colors = "#DCDCDC#8019a0"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/engineering
	name = "striped engineering bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and engineering colors."
	greyscale_colors = "#dab50e#ec7404"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/medical
	name = "striped medical bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and medical colors."
	greyscale_colors = "#DCDCDC#5995BA"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/cargo
	name = "striped cargo bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and cargo colors."
	greyscale_colors = "#967032#5F350B"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/striped/botany
	name = "striped botany bandana"
	desc = "A fine bandana with nanotech lining, a stripe across and botany colors."
	greyscale_colors = "#3D9829#294A98"
	flags_1 = NONE

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "A fine bandana with nanotech lining and a skull emblem."
	icon_state = "bandskull"
	greyscale_config = /datum/greyscale_config/bandana/skull
	greyscale_config_worn = /datum/greyscale_config/bandana/skull/worn
	greyscale_config_inhand_left = /datum/greyscale_config/bandana/skull/inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/bandana/skull/inhands_right
	greyscale_colors = "#2e2e2e#C6C6C6"
	undyeable = TRUE

/obj/item/clothing/mask/bandana/skull/black
	desc = "A fine black bandana with nanotech lining and a skull emblem."
	greyscale_colors = "#2e2e2e#C6C6C6"
	flags_1 = NONE

/obj/item/clothing/mask/facescarf
	name = "facescarf"
	desc = "Cover your face like in the cowboy movies. It also has breathtube so you can wear it everywhere!"
	actions_types = list(/datum/action/item_action/adjust)
	icon_state = "facescarf"
	inhand_icon_state = "greyscale_facescarf"
	alternate_worn_layer = BACK_LAYER
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT|MASKINTERNALS
	flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#eeeeee"
	greyscale_config = /datum/greyscale_config/facescarf
	greyscale_config_worn = /datum/greyscale_config/facescarf/worn
	greyscale_config_inhand_left = /datum/greyscale_config/facescarf/inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/facescarf/inhands_right
	flags_1 = IS_PLAYER_COLORABLE_1
	interaction_flags_click = NEED_DEXTERITY|ALLOW_RESTING

/obj/item/clothing/mask/facescarf/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/mask/facescarf/click_alt(mob/user)
	adjust_visor(user)
	return CLICK_ACTION_SUCCESS


/obj/item/clothing/mask/facescarf/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to adjust it.")
