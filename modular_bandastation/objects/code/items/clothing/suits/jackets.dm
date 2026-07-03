/obj/item/clothing/suit/v_jacket
	name = "v jacket"
	desc = "Куртка так называемого V."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "v_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/takemura_jacket
	name = "takemura jacket"
	desc = "Куртка так называемого Такэмуры."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "takemura_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/katarina_jacket
	name = "katarina jacket"
	desc = "Куртка так называемой Катарины."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "katarina_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/katarina_cyberjacket
	name = "katarina cyberjacket"
	desc = "Кибер-куртка так называемой Катарины."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "katarina_cyberjacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/hooded/vi_arcane
	name = "vi jacket"
	desc = "Слегка потрёпанный жакет боевой девчушки Вай."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "vi_arcane"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	hoodtype = /obj/item/clothing/head/hooded/vi_arcane
	hood_up_affix = ""
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list()

/obj/item/clothing/head/hooded/vi_arcane
	name = "vi hood"
	desc = "Капюшон, прикреплённый к жакету Вай."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hood.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hood.dmi'
	icon_state = "vi_arcane"

	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEEARS | HIDEHAIR
	hair_mask = /datum/hair_mask/winterhood

/obj/item/clothing/suit/soundhand_white_jacket
	name = "soundhand silver jacket"
	desc = "Редкая серебристая куртка Саундхэнд. Ограниченная серия."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_white_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	allowed = list()

/obj/item/clothing/suit/soundhand_white_jacket/tag
	name = "soundhand tag silver jacket"
	desc = "Серебристая куртка с тэгом группы Саундхэнд, которую носят исполнители группы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_white_jacket_teg"
	worn_icon_state = "soundhand_white_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/soundhand_black_jacket
	name = "soundhand fan black jacket"
	desc = "Черная куртка группы Саундхэнд, исполненая в духе оригинала, но без логотипа на спине. С любовью для фанатов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_black_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	allowed = list()

/obj/item/clothing/suit/soundhand_black_jacket/tag
	name = "soundhand tag black jacket"
	desc = "Черная куртка с тэгом группы Саундхэнд, которую носят исполнители группы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_black_jacket_teg"
	worn_icon_state = "soundhand_black_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/soundhand_olive_jacket
	name = "soundhand fan olive jacket"
	desc = "Оливковая куртка гурппы Саундхэнд, исполненая в духе оригинала, но без логотипа на спине. С любовью для фанатов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_olive_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	allowed = list()

/obj/item/clothing/suit/soundhand_olive_jacket/tag
	name = "soundhand tag olive jacket"
	desc = "Оливковая куртка с тэгом группы Саундхэнд, которую носят исполнители группы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_olive_jacket_teg"
	worn_icon_state = "soundhand_olive_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/soundhand_brown_jacket
	name = "soundhand fan brown jacket"
	desc = "Коричневая куртка Саундхэнд, исполненая в духе оригинала, но без логотипа на спине. С любовью для фанатов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_brown_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	allowed = list()

/obj/item/clothing/suit/soundhand_brown_jacket/tag
	name = "soundhand tag brown jacket"
	desc = "Коричневая куртка с тэгом группы Саундхэнд, которую носят исполнители группы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_brown_jacket_teg"
	worn_icon_state = "soundhand_brown_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

// MARK: TSF
/obj/item/clothing/suit/toggle/tsf_jacket
	name = "federate long jacket"
	desc = "Свободная накидка из легкой ткани, выполненная в официальных цветах Сола."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/jacket.dmi'
	icon_state = "tsf_jacket"
	body_parts_covered = CHEST | GROIN | ARMS | LEGS

// MARK: Etamin ind.
/obj/item/clothing/suit/toggle/etamin_jacket
	name = "Gold on Black leather jacket"
	desc = "Сочетание настоящего рокерского духа и современного стиля. При взгляде на вас, у каждого возникнет лишь одна мысль: \"Это настоящий рок спирит!\"."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/jacket.dmi'
	icon_state = "ei_jacket"
	body_parts_covered = CHEST | GROIN | ARMS
