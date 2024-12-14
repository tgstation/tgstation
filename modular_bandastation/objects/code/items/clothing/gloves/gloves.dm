// CentCom
/obj/item/clothing/gloves/combat/centcom
	name = "fleet officer's gloves"
	desc = "Солидные перчатки офицеров Центрального Командования Нанотрейзен."
	icon = 'modular_bandastation/aesthetics/clothing/centcom/icons/obj/clothing/gloves/gloves.dmi'
	worn_icon = 'modular_bandastation/aesthetics/clothing/centcom/icons/mob/clothing/gloves/gloves.dmi'
	lefthand_file = 'modular_bandastation/aesthetics/clothing/centcom/icons/inhands/clothing/gloves_lefthand.dmi'
	righthand_file = 'modular_bandastation/aesthetics/clothing/centcom/icons/inhands/clothing/gloves_righthand.dmi'
	icon_state = "centcom"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | FREEZE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/gloves/combat/centcom/diplomat
	desc = "Изящные и солидные перчатки офицеров Центрального Командования Нанотрейзен."
	icon_state = "centcom_diplomat"

// Detective (forensics) gloves
/obj/item/clothing/gloves/color/black/forensics
	name = "forensics gloves"
	desc = "Эти высокотехнологичные перчатки не оставляют никаких следов на предметах, к которым прикасаются. Идеально подходят для того, чтобы оставить место преступления нетронутым... как до, так и после преступления."
	icon = 'modular_bandastation/objects/icons/obj/clothing/gloves.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/gloves.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/gloves_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/gloves_righthand.dmi'
	icon_state = "forensics"
	clothing_flags = FIBERLESS_GLOVES

/obj/item/clothing/gloves/examine_tags(mob/user)
	. = ..()
	if(clothing_flags & FIBERLESS_GLOVES)
		.["безволоконная"] = "Не оставляет волокна."
