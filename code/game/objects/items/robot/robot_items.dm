//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/borg/stun
	name = "electrified arm"
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "elecarm"

/obj/item/borg/stun/attack(mob/M as mob, mob/living/silicon/robot/user as mob)

	user.cell.charge -= 30

	M.Weaken(5)
	if (M.stuttering < 5)
		M.stuttering = 5
	M.Stun(5)

	for(var/mob/O in viewers(M, null))
		if (O.client)
			O.show_message("<span class='danger'>[user] has prodded [M] with an electrically-charged arm!</span>", 1,
							 "<span class='italics'>You hear someone fall.</span>", 2)
	add_logs(user, M, "stunned", object="[src.name]", addition="(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/overdrive
	name = "overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	var/sight_mode = null


/obj/item/borg/sight/xray
	name = "\proper x-ray Vision"
	sight_mode = BORGXRAY


/obj/item/borg/sight/thermal
	name = "\proper thermal vision"
	sight_mode = BORGTHERM
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "thermal"


/obj/item/borg/sight/meson
	name = "\proper meson vision"
	sight_mode = BORGMESON
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "meson"


/obj/item/borg/sight/hud
	name = "hud"
	var/obj/item/clothing/glasses/hud/hud = null


/obj/item/borg/sight/hud/med
	name = "medical hud"
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "healthhud"


/obj/item/borg/sight/hud/med/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/health(src)
	return


/obj/item/borg/sight/hud/sec
	name = "security hud"
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "securityhud"

/obj/item/borg/sight/hud/sec/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/security(src)
	return
