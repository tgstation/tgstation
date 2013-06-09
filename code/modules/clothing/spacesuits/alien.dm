/obj/item/clothing/head/helmet/space/unathi

	var/up = 0 //So Unathi helmets play nicely with the weldervision check.
	mob_can_equip(M as mob, slot)
		var/mob/living/carbon/human/U = M
		if(U.dna.mutantrace != "lizard")
			U << "<span class='warning'>This clearly isn't designed for your species!</span>"
			return 0
		return ..()

/obj/item/clothing/suit/space/unathi/mob_can_equip(M as mob, slot)
	var/mob/living/carbon/human/U = M
	if(U.dna.mutantrace != "lizard")
		U << "<span class='warning'>This clearly isn't designed for your species!</span>"
		return 0

	return ..()

/obj/item/clothing/head/helmet/space/unathi/helmet_cheap
	name = "NT breacher helmet"
	desc = "Hey! Watch it with that thing! It's a knock-off of a Unathi battle-helm, and that spike could put someone's eye out."
	icon_state = "unathi_helm_cheap"
	item_state = "unathi_helm_cheap"
	color = "unathi_helm_cheap"
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE

/obj/item/clothing/suit/space/unathi/rig_cheap
	name = "NT breacher chassis"
	desc = "A cheap NT knock-off of a Unathi battle-rig. Looks like a fish, moves like a fish, steers like a cow."
	icon_state = "rig-unathi-cheap"
	item_state = "rig-unathi-cheap"
	slowdown = 3
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE

// Vox space gear (vaccuum suit, low pressure armour)
// Can't be equipped by any other species due to bone structure and vox cybernetics.

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 2
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/vox/mob_can_equip(M as mob, slot)
	var/mob/living/carbon/human/V = M
	if(V.dna.mutantrace != "vox")
		V << "<span class='warning'>This clearly isn't designed for your species!</span>"
		return 0
	return ..()

/obj/item/clothing/suit/space/vox/mob_can_equip(M as mob, slot)
	var/mob/living/carbon/human/V = M
	if(V.dna.mutantrace != "vox")
		V << "<span class='warning'>This clearly isn't designed for your species!</span>"
		return 0

	return ..()

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"
	color = "vox-casual-1"
	item_state = "vox-casual-1"

/obj/item/clothing/under/vox/vox_robes
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"
	color = "vox-casual-2"
	item_state = "vox-casual-2"