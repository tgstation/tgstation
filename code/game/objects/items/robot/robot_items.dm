//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/part/cyborg/equipment/stun
	name = "Electrified Arm"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

	attack(mob/M as mob, mob/living/silicon/robot/user as mob)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

		log_attack(" <font color='red'>[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey])</font>")

		user.cell.charge -= 30

		M.Weaken(5)
		if (M.stuttering < 5)
			M.stuttering = 5
		M.Stun(5)

		for(var/mob/O in viewers(M, null))
			if (O.client)
				O.show_message("\red <B>[user] has prodded [M] with an electrically-charged arm!</B>", 1, "\red You hear someone fall", 2)

/obj/item/part/cyborg/equipment/overdrive
	name = "Overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/part/cyborg/equipment/sight
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	var/sight_mode = null


/obj/item/part/cyborg/equipment/sight/xray
	name = "X-ray Vision"
	sight_mode = BORGXRAY


/obj/item/part/cyborg/equipment/sight/thermal
	name = "Thermal Vision"
	sight_mode = BORGTHERM


/obj/item/part/cyborg/equipment/sight/meson
	name = "Meson Vision"
	sight_mode = BORGMESON


/obj/item/part/cyborg/equipment/sight/hud
	name = "Hud"
	var/obj/item/clothing/glasses/hud/hud = null


/obj/item/part/cyborg/equipment/sight/hud/med
	name = "Medical Hud"


	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/health(src)
		return


/obj/item/part/cyborg/equipment/sight/hud/sec
	name = "Security Hud"


	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/security(src)
		return