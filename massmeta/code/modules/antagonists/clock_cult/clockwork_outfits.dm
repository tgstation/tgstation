/datum/outfit/clockcult
	name = "Servant of Ratvar"

	uniform = /obj/item/clothing/under/chameleon/ratvar
	shoes = /obj/item/clothing/shoes/chameleon
	gloves = /obj/item/clothing/gloves/color/yellow
	back = /obj/item/storage/backpack/chameleon
	ears = /obj/item/radio/headset/chameleon
	id = /obj/item/card/id/advanced/ratvar
	belt = /obj/item/storage/belt/utility/servant
	var/weapon = null

/datum/outfit/clockcult/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(weapon)
		var/weapon_to_spawn = new weapon(get_turf(H))
		H.put_in_inactive_hand(weapon_to_spawn)

/datum/outfit/clockcult_plasmaman
	name = "Servant of Ratvar Plasmaman"
	head = /obj/item/clothing/head/helmet/space/plasmaman
	uniform = /obj/item/clothing/under/plasmaman

/datum/outfit/clockcult/armaments
	name = "Servant of Ratvar - Armaments"

	suit = /obj/item/clothing/suit/clockwork
	weapon = /obj/item/clockwork/weapon/brass_spear
	head = /obj/item/clothing/head/helmet/clockcult
	shoes = /obj/item/clothing/shoes/clockcult
	gloves = /obj/item/clothing/gloves/clockcult

/datum/outfit/clockcult/armaments/hammer
	name = "Servant of Ratvar - Armaments (hammer)"
	weapon = /obj/item/clockwork/weapon/brass_battlehammer

/datum/outfit/clockcult/armaments/sword
	name = "Servant of Ratvar - Armaments (sword)"
	weapon = /obj/item/clockwork/weapon/brass_sword

/datum/outfit/clockcult/armaments/bow
	name = "Servant of Ratvar - Armaments (bow)"
	weapon = /obj/item/gun/energy/kinetic_accelerator/crossbow/clockwork
