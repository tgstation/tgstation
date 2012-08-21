/obj/item/clothing/head/wizard
	name = "wizard hat"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"
	//Not given any special protective value since the magic robes are full-body protection --NEO

/obj/item/clothing/head/wizard/red
	name = "red wizard hat"
	desc = "Strange-looking, red, hat-wear that most certainly belongs to a real magic user."
	icon_state = "redwizard"

/obj/item/clothing/head/wizard/fake
	name = "wizard hat"
	desc = "It has WIZZARD written across it in sequins. Comes with a cool beard."
	icon_state = "wizard-fake"

/obj/item/clothing/head/wizard/marisa
	name = "Witch Hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"

/obj/item/clothing/head/wizard/magus
	name = "Magus Helm"
	desc = "A mysterious helmet that hums with an unearthly power"
	icon_state = "magus"
	item_state = "magus"


/obj/item/clothing/suit/wizrobe
	name = "wizard robe"
	desc = "A magnificant, gem-lined robe that seems to radiate power."
	icon_state = "wizard"
	item_state = "wizrobe"
	gas_transfer_coefficient = 0.01 // IT'S MAGICAL OKAY JEEZ +1 TO NOT DIE
	permeability_coefficient = 0.01
	body_parts_covered = FULL_BODY //It's magic, I ain't gotta explain shit. --NEO
	armor = list(melee = 30, bullet = 20, laser = 20,energy = 20, bomb = 20, bio = 20, rad = 20)
	allowed = list(/obj/item/weapon/teleportation_scroll)
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A magnificant, red, gem-lined robe that seems to radiate power."
	icon_state = "redwizard"
	item_state = "redwizrobe"


/obj/item/clothing/suit/wizrobe/marisa
	name = "Witch Robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"

/obj/item/clothing/suit/wizrobe/magusblue
	name = "Magus Robe"
	desc = "A set of armoured robes that seem to radiate a dark power"
	icon_state = "magusblue"
	item_state = "magusblue"

/obj/item/clothing/suit/wizrobe/magusred
	name = "Magus Robe"
	desc = "A set of armoured robes that seem to radiate a dark power"
	icon_state = "magusred"
	item_state = "magusred"


/obj/item/clothing/suit/wizrobe/fake
	name = "wizard robe"
	desc = "A rather dull, blue robe meant to mimick real wizard robes."
	icon_state = "wizard-fake"
	item_state = "wizrobe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/wizard/marisa/fake
	name = "Witch Hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/wizrobe/marisa/fake
	name = "Witch Robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

