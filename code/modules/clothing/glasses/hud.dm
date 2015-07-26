/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	var/hud_type = null

/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	if(hud_type && slot == slot_glasses)
		var/datum/atom_hud/H = huds[hud_type]
		H.add_hud_to(user)

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	if(hud_type && istype(user) && user.glasses == src)
		var/datum/atom_hud/H = huds[hud_type]
		H.remove_hud_from(user)

/obj/item/clothing/glasses/hud/emp_act(severity)
	if(emagged == 0)
		emagged = 1
		desc = desc + " The display flickers slightly."

/obj/item/clothing/glasses/hud/emag_act(mob/user)
	if(emagged == 0)
		emagged = 1
		user << "<span class='warning'>PZZTTPFFFT</span>"
		desc = desc + " The display flickers slightly."

/obj/item/clothing/glasses/hud/health
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	hud_type = DATA_HUD_MEDICAL_ADVANCED

/obj/item/clothing/glasses/hud/health/night
	name = "Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	item_state = "glasses"
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM

/obj/item/clothing/glasses/hud/security
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	hud_type = DATA_HUD_SECURITY_ADVANCED

/obj/item/clothing/glasses/hud/security/chameleon
	name = "Chamleon Security HUD"
	desc = "A stolen security HUD integrated with Syndicate chameleon technology. Toggle to disguise the HUD. Provides flash protection."
	flash_protect = 1

/obj/item/clothing/glasses/hud/security/chameleon/attack_self(mob/user)
	chameleon(user)


/obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	name = "Eyepatch HUD"
	desc = "A heads-up display that connects directly to the optical nerve of the user, replacing the need for that useless eyeball."
	icon_state = "hudpatch"

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	darkness_view = 1
	flash_protect = 1
	tint = 1

/obj/item/clothing/glasses/hud/security/night
	name = "Night Vision Security HUD"
	desc = "An advanced heads-up display which provides id data and vision in complete darkness."
	icon_state = "securityhudnight"
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM

/obj/item/clothing/glasses/hud/security/sunglasses/gars
	name = "HUD gar glasses"
	desc = "GAR glasses with a HUD."
	icon_state = "gars"
	item_state = "garb"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/clothing/glasses/hud/security/sunglasses/gars/supergars
	name = "giga HUD gar glasses"
	desc = "GIGA GAR glasses with a HUD."
	icon_state = "supergars"
	item_state = "garb"
	force = 12
	throwforce = 12

/obj/item/clothing/glasses/hud/toggle
	name = "Toggle Hud"
	desc = "A hud with multiple functions."
	action_button_name = "Switch HUD"

/obj/item/clothing/glasses/hud/toggle/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/wearer = user
	if (wearer.glasses != src)
		return

	if (hud_type)
		var/datum/atom_hud/H = huds[hud_type]
		H.remove_hud_from(user)

	if (hud_type == DATA_HUD_MEDICAL_ADVANCED)
		hud_type = null
	else if (hud_type == DATA_HUD_SECURITY_ADVANCED)
		hud_type = DATA_HUD_MEDICAL_ADVANCED
	else
		hud_type = DATA_HUD_SECURITY_ADVANCED

	if (hud_type)
		var/datum/atom_hud/H = huds[hud_type]
		H.add_hud_to(user)

/obj/item/clothing/glasses/hud/toggle/thermal
	name = "Thermal HUD Scanner"
	desc = "Thermal imaging HUD in the shape of glasses."
	icon_state = "thermal"
	hud_type = DATA_HUD_SECURITY_ADVANCED
	vision_flags = SEE_MOBS
	invis_view = 2

/obj/item/clothing/glasses/hud/toggle/thermal/attack_self(mob/user)
	..()
	switch (hud_type)
		if (DATA_HUD_MEDICAL_ADVANCED)
			icon_state = "meson"
		if (DATA_HUD_SECURITY_ADVANCED)
			icon_state = "thermal"
		else
			icon_state = "purple"
	user.update_inv_glasses()

/obj/item/clothing/glasses/hud/toggle/thermal/emp_act(severity)
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		if(M.glasses == src)
			M << "<span class='danger'>The [src] overloads and blinds you!</span>"
			M.eye_blind = 3
			M.eye_blurry = 5
			M.disabilities |= NEARSIGHT
			spawn(100)
				M.disabilities &= ~NEARSIGHT
	..()