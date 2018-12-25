/datum/outfit/santa //ho ho ho!
	name = "Santa Claus"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/sneakers/red
	suit = /obj/item/clothing/suit/space/santa
	head = /obj/item/clothing/head/santa
	back = /obj/item/storage/backpack/santabag
	mask = /obj/item/clothing/mask/breath
	r_pocket = /obj/item/device/flashlight
	gloves = /obj/item/clothing/gloves/color/red
	belt = /obj/item/tank/internals/emergency_oxygen/double
	id = /obj/item/card/id/gold

/datum/outfit/santa/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	H.fully_replace_character_name(H.real_name, "Santa Claus")
	H.mind.assigned_role = "Santa"
	H.mind.special_role = "Santa"

	H.hair_style = "Long Hair"
	H.facial_hair_style = "Full Beard"
	H.hair_color = "FFF"
	H.facial_hair_color = "FFF"
	//Locking santas dna and making him always male. -falaskian
	H.gender = MALE
	H.dna.update_dna_identity()
	H.updateappearance()

	//giveing santa all access as I believe was intended from previous build. -falaskian
	if(istype(H.wear_id,/obj/item/card/id))
		var/obj/item/card/id/id = H.wear_id
		var/datum/job/captain/J = new/datum/job/captain
		id.access = J.get_access()
		id.registered_name = H.real_name
		id.assignment = "Santa Claus"
		id.name = "[id.registered_name]'s ID Card ([id.assignment])"

	var/obj/item/storage/backpack/bag = H.back
	var/obj/item/a_gift/gift = new(H)
	while(bag.can_be_inserted(gift, 1))
		bag.handle_item_insertion(gift, 1)
		gift = new(H)
