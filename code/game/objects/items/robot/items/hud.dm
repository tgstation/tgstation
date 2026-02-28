/obj/item/borg/sight
	icon = 'icons/obj/clothing/glasses.dmi'
	///Define to a sight mode that we give to a cyborg while this item is equipped.
	var/sight_mode = null

/obj/item/borg/sight/equipped(mob/living/silicon/robot/user, slot, initial = FALSE)
	. = ..()
	if(!iscyborg(user))
		return .
	user.sight_mode |= sight_mode
	user.update_sight()

/obj/item/borg/sight/dropped(mob/living/silicon/robot/user, silent)
	if(!iscyborg(user))
		return ..()
	user.sight_mode &= ~sight_mode
	user.update_sight()
	return ..()

/obj/item/borg/sight/xray
	name = "\proper X-ray vision"
	icon_state = "securityhudnight"
	sight_mode = BORGXRAY

/obj/item/borg/sight/material
	name = "\proper material vision"
	sight_mode = BORGMATERIAL
	icon_state = "material"

/obj/item/borg/sight/hud
	name = "hud"
	var/obj/item/clothing/glasses/hud/hud = null

/obj/item/borg/sight/hud/Initialize(mapload)
	if (!isnull(hud))
		hud = new hud(src)
	return ..()

/obj/item/borg/sight/hud/med
	name = "medical hud"
	icon_state = "healthhud"
	hud = /obj/item/clothing/glasses/hud/health

/obj/item/borg/sight/hud/sec
	name = "security hud"
	icon_state = "securityhud"
	hud = /obj/item/clothing/glasses/hud/security
