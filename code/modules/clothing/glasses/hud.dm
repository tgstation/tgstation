/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	hud = 1

/* /obj/item/clothing/glasses/hud/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/card/emag))
		if(emagged == 0)
			emagged = 1
			user << "<span class='warning'>PZZTTPFFFT</span>"
			desc = desc+ " The display flickers slightly."
		else
			user << "<span class='warning'>It is already emagged!</span>" */ //No emags allowed

/obj/item/clothing/glasses/hud/emp_act(severity)
	if(emagged == 0)
		emagged = 1
		desc = desc + " The display flickers slightly."


/obj/item/clothing/glasses/hud/health
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"


/obj/item/clothing/glasses/hud/health/process_hud(var/mob/M)
	process_data_hud(M,DATA_HUD_MEDICAL,DATA_HUD_ADVANCED)


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

/obj/item/clothing/glasses/hud/security/eyepatch
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

/obj/item/clothing/glasses/hud/security/sunglasses/emp_act(severity)
	if(emagged == 0)
		emagged = 1
		desc = desc + " The display flickers slightly."

/obj/item/clothing/glasses/hud/security/jensenshades
	name = "Augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	item_state = "jensenshades"
	vision_flags = SEE_MOBS
	invis_view = 2

/obj/item/clothing/glasses/hud/security/process_hud(var/mob/M)
	process_data_hud(M,DATA_HUD_SECURITY,DATA_HUD_ADVANCED)
