/obj/item/clothing/under/shadowling
	name = "blackened flesh"
	desc = "Black, chitinous skin."
	item_state = null
	origin_tech = null
	icon_state = "shadowling"
	has_sensor = 0
	unacidable = 1
	flags = ABSTRACT | NODROP


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
	unacidable = 1
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	armor = list(melee = 25, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 100)
	flags = ABSTRACT | NODROP | THICKMATERIAL | STOPSPRESSUREDMAGE


/obj/item/clothing/shoes/shadowling
	name = "chitin feet"
	desc = "Charred-looking feet. They have minature hooks that latch onto flooring."
	icon_state = "shadowling"
	item_state = null
	unacidable = 1
	flags = NOSLIP | ABSTRACT | NODROP


/obj/item/clothing/mask/gas/shadowling
	name = "chitin mask"
	desc = "A mask-like formation with slots for facial features. A red film covers the eyes."
	icon_state = "shadowling"
	item_state = null
	origin_tech = null
	siemens_coefficient = 0
	unacidable = 1
	flags = ABSTRACT | NODROP


/obj/item/clothing/gloves/shadowling
	name = "chitin hands"
	desc = "An electricity-resistant covering of the hands."
	icon_state = "shadowling"
	item_state = null
	origin_tech = null
	siemens_coefficient = 0
	unacidable = 1
	flags = ABSTRACT | NODROP


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
	unacidable = 1
	flags = ABSTRACT | NODROP | STOPSPRESSUREDMAGE


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
	unacidable = 1
	actions_types = list(/datum/action/item_action/hands_free/shift_nerves)
	var/max_darkness_view = 8
	var/min_darkness_view = 0
	flags = ABSTRACT | NODROP

/obj/item/clothing/glasses/night/shadowling/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.dna.species.id != "shadowling")
		user << "<span class='warning'>You aren't sure how to do this...</span>"
		return
	H.dna.species.darksight = 0 //so our species' vision in the dark doesn't interfere.
	var/new_dark_view
	new_dark_view = (input(user, "Enter the radius of tiles to see with night vision.", "Night Vision", "[new_dark_view]") as num)
	new_dark_view = Clamp(new_dark_view,min_darkness_view,max_darkness_view)
	switch(new_dark_view)
		if(0)
			user << "<span class='notice'>Your night vision capabilities fade away for the time being.</span>"
		else
			user << "<span class='notice'>You shift your night vision capabilities to see [new_dark_view] tiles away.</span>"
	darkness_view = new_dark_view
	user.update_sight()
