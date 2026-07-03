/obj/item/clothing/suit/jacket/bomber
	inhand_icon_state =  null

// Science
/obj/item/clothing/suit/jacket/bomber/science
	name = "science bomber"
	desc = "Стильная черная куртка-бомбер, украшенная красной полосой слева."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/bomber.dmi'
	icon_state = "bombersci"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/bomber.dmi'

/obj/item/clothing/suit/jacket/bomber/science/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

// Roboticist
/obj/item/clothing/suit/jacket/bomber/roboticist
	name = "roboticist bomber"
	desc = "Стильная белая куртка-бомбер, украшенная Фиолетовой полосой слева."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/bomber.dmi'
	icon_state = "bomberrobo"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/bomber.dmi'

/obj/item/clothing/suit/jacket/bomber/roboticist/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)
