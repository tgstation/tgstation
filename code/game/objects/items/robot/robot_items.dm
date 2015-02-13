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
							 "<span class='warning'> You hear someone fall</span>", 2)
	add_logs(user, M, "stunned", object="[src.name]", addition="(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/overdrive
	name = "overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/obj/item/borg/autostripper
	name = "autostripper"
	desc = "Properly used to quicky disrobe humans to aid in surgery and treatment, occasionally used as a rude party trick."
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "elecarm" //TODO: Needs unique icon
	var/busy = 0
	var/stripping_time = 50 //5 seconds

/obj/item/borg/autostripper/attack(mob/M, mob/user)
	if(busy)
		return
	if(!ishuman(M))
		user << "<span class='notice'>[M.name] doesn't seem like they can get any more naked.</span>"
		return
	busy = 1
	user.visible_message("<span class='warning'>[user] begins to prep the autostripper for [M.name]</span>", "<span class='notice'>You begin to prep the autostripper for [M.name].</span>")

	if(do_after(user, stripping_time)) //5 seconds to strip normally, only 1 if emagged
		var/removed_something = 0
		for(var/obj/item/W in M)
			M.unEquip(W)
			removed_something = 1
		if(removed_something)
			user.visible_message("<span class='warning'>[user] strips the clothing off [M.name]!</span>", "<span class='notice'>You strip the clothing off [M.name]!</span>")
			add_logs(user, M, "stripped", object="[src.name]", addition="(INTENT: [uppertext(user.a_intent)])")

	busy = 0

/obj/item/borg/autostripper/emag_act()
	stripping_time = 10 //1 second
	..()

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
