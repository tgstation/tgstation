/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g buckshot shells)"
	desc = "A drum magazine of shotgun shells, suitable for the Bulldog combat shotgun."
	icon_state = "m12gb"
	base_icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec
	caliber = CALIBER_SHOTGUN
	max_ammo = 8
	casing_phrasing = "shell"

/obj/item/ammo_box/magazine/m12g/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[CEILING(ammo_count(FALSE)/8, 1)*8]"

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g taser slugs)"
	icon_state = "m12gs"
	base_icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/slug
	name = "shotgun magazine (12g slugs)"
	icon_state = "m12gsl"
	base_icon_state = "m12gsl"
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g dragon's breath)"
	icon_state = "m12gf"
	base_icon_state = "m12gf"
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12g bioterror)"
	icon_state = "m12gt"
	base_icon_state = "m12gt"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bioterror

/obj/item/ammo_box/magazine/m12g/meteor
	name = "shotgun magazine (12g meteor slugs)"
	icon_state = "m12gbc"
	base_icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/meteorslug

/obj/item/ammo_box/magazine/m12g/flechette
	name = "shotgun magazine (12g flechette)"
	icon_state = "m12gfl"
	base_icon_state = "m12gfl"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/donk
	name = "shotgun magazine (12g Donk Co. 'Donk Spike' flechette)"
	desc = "A drum magazine of shotgun shells, suitable for the Bulldog combat shotgun. It is covered in Donk Co. scratch-and-sniff \
		stickers. You're not sure you want to try and get a whiff..."
	icon_state = "m12gd"
	base_icon_state = "m12gd"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette/donk

/obj/item/ammo_box/magazine/m12g/donk/examine_more(mob/user)
	. = ..()
	if(ishuman(user))
		return

	var/mob/living/carbon/human/human_sniffer = user
	if(!HAS_TRAIT(human_sniffer, TRAIT_ANOSMIA) && human_sniffer.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING|FORBID_TELEKINESIS_REACH))
		. += span_notice("You scratch and sniff the stickers.")
		. += span_warning("<i>Oh god, where did they pull this from, a landfill?</i>")
		human_sniffer.add_mood_event("stink-pocket", /datum/mood_event/disgusted)

