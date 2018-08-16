/*/////////////////////////////////////////////////////////////////////////////////
///////																		///////
///////			Cit's exclusive jumpsuits, uniforms, etc. go here			///////
///////																		///////
*//////////////////////////////////////////////////////////////////////////////////


/obj/item/clothing/under/rank/security/skirt
	name = "security skirt"
	desc = "A tactical security skirt for officers complete with Nanotrasen belt buckle."
	icon = 'modular_citadel/icons/obj/clothing/cit_clothes.dmi'
	icon_state = "secskirt"
	icon_override = 'modular_citadel/icons/mob/citadel/uniforms.dmi'
	item_state = "r_suit"
	item_color = "secskirt"

/obj/item/clothing/under/rank/head_of_security/skirt
	name = "head of security's skirt"
	desc = "A security skirt decorated for those few with the dedication to achieve the position of Head of Security."
	icon = 'modular_citadel/icons/obj/clothing/cit_clothes.dmi'
	icon_state = "hosskirt"
	icon_override = 'modular_citadel/icons/mob/citadel/uniforms.dmi'
	item_state = "gy_suit"
	item_color = "hosskirt"

/obj/item/clothing/under/corporateuniform
	name = "corporate uniform"
	desc = "A comfortable, tight fitting jumpsuit made of premium materials. Not space-proof."
	icon = 'modular_citadel/icons/obj/clothing/cit_clothes.dmi'
	icon_state = "tssuit"
	alternate_worn_icon = 'modular_citadel/icons/mob/citadel/uniforms.dmi'
	item_state = "r_suit"
	can_adjust = FALSE
	
/obj/item/clothing/under/rank/captain/femformal
	name ="captain's female formal outfit"
	desc = ""
	icon = 'modular_citadel/icons/obj/clothing/cit_clothes.dmi'
	icon_state = "lewdcap"
	icon_override = 'modular_citadel/icons/mob/citadel/uniforms.dmi'
	item_state = "lewdcap"
	item_color = "lewdcap"
	can_adjust = FALSE
	sensor_mode = SENSOR_COORDS  //it's still a captain's suit nerd
	random_sensor = FALSE
