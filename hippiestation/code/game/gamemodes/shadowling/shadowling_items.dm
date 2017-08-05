/obj/item/clothing/under/shadowling
	name = "blackened flesh"
	desc = "Black, chitinous skin."
	item_state = null
	origin_tech = null
	icon_state = "shadowling"
	has_sensor = 0
	flags = ABSTRACT | NODROP | UNACIDABLE


/obj/item/clothing/suit/space/shadowling
	name = "chitin shell"
	desc = "A dark, semi-transparent shell. Protects against vacuum, but not against the light of the stars." //Still takes damage from spacewalking but is immune to space itself
	icon_state = "shadowling"
	item_state = null
	body_parts_covered = FULL_BODY //Shadowlings are immune to space
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 0
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	armor = list(melee = 25, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 100)
	flags = ABSTRACT | NODROP | THICKMATERIAL | STOPSPRESSUREDMAGE | UNACIDABLE


/obj/item/clothing/shoes/shadowling
	name = "chitin feet"
	desc = "Charred-looking feet. They have minature hooks that latch onto flooring."
	icon_state = "shadowling"
	item_state = null
	flags = NOSLIP | ABSTRACT | NODROP | UNACIDABLE


/obj/item/clothing/mask/gas/shadowling
	name = "chitin mask"
	desc = "A mask-like formation with slots for facial features. A red film covers the eyes."
	icon_state = "shadowling"
	item_state = null
	origin_tech = null
	siemens_coefficient = 0
	flags = ABSTRACT | NODROP | UNACIDABLE


/obj/item/clothing/gloves/shadowling
	name = "chitin hands"
	desc = "An electricity-resistant covering of the hands."
	icon_state = "shadowling"
	item_state = null
	origin_tech = null
	siemens_coefficient = 0
	flags = ABSTRACT | NODROP | UNACIDABLE


/obj/item/clothing/head/shadowling
	name = "chitin helm"
	desc = "A helmet-like enclosure of the head."
	icon_state = "shadowling"
	item_state = null
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	origin_tech = null
	flags = ABSTRACT | NODROP | STOPSPRESSUREDMAGE | UNACIDABLE


/obj/item/clothing/glasses/night/shadowling
	name = "crimson eyes"
	desc = "A shadowling's eyes. Very light-sensitive and can detect body heat through walls."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "ling_thermal"
	item_state = null
	origin_tech = null
	vision_flags = SEE_MOBS
	darkness_view = 1
	invis_view = 2
	flash_protect = -1
	darkness_view = 8
	actions_types = list()
	var/isOn = TRUE
	flags = ABSTRACT | NODROP | UNACIDABLE


/obj/item/clothing/glasses/night/shadowling/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/eyes/E = user.getorganslot("eye_sight")
	if(H.dna.species.id != "shadowling")
		to_chat(user, "<span class='warning'>You aren't sure how to do this...</span>")
		return
	if (!isOn)
		E.sight_flags |= (SEE_MOBS|SEE_SELF)
		E.see_in_dark = 8
		darkness_view = 8
		to_chat(user, "<span class='notice>Your night vision rises beyond human levels, allowing you to see no matter the light level</span>")
	else
		E.sight_flags -= (SEE_MOBS|SEE_SELF)
		E.see_in_dark = 2
		darkness_view = 0
		to_chat(user, "<span class='notice>Your night vision subsides to that of a human.</span>")

	user.update_sight()