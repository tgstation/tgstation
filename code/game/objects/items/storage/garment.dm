/obj/item/storage/bag/garment
	name = "garment bag"
	icon = 'icons/obj/storage.dmi'
	icon_state = "garment_bag"
	desc = "A bag for storing extra clothes and shoes."
	slot_flags = NONE
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/garment/captain
	name = "captain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the captain."

/obj/item/storage/bag/garment/hos
	name = "head of security's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of security."

/obj/item/storage/bag/garment/hop
	name = "head of personnel's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of personnel."

/obj/item/storage/bag/garment/research_director
	name = "research director's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the research director."

/obj/item/storage/bag/garment/chief_medical
	name = "chief medical officer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief medical officer."

/obj/item/storage/bag/garment/engineering_chief
	name = "chief engineer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief engineer."

/obj/item/storage/bag/garment/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_atom_size = WEIGHT_CLASS_NORMAL
	STR.max_total_atom_size = 200
	STR.max_items = 15
	STR.insert_preposition = "in"
	STR.set_holdable(list(
		/obj/item/clothing
		))

/obj/item/storage/bag/garment/captain/PopulateContents()
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/rank/captain/skirt(src)
	new /obj/item/clothing/under/rank/captain/parade(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/captains_formal(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/glasses/sunglasses/gar/giga(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/clothing/head/caphat(src)
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/head/crown/fancy(src)
	new /obj/item/clothing/neck/cloak/cap(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)


/obj/item/storage/bag/garment/hop/PopulateContents()
	new /obj/item/clothing/under/rank/civilian/head_of_personnel(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/skirt(src)
	new /obj/item/clothing/suit/armor/vest/alt(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/head/hopcap(src)
	new /obj/item/clothing/neck/cloak/hop(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/suit/hooded/wintercoat/hop(src)

/obj/item/storage/bag/garment/hos/PopulateContents()
	new /obj/item/clothing/under/rank/security/head_of_security/grey(src)
	new /obj/item/clothing/under/rank/security/head_of_security/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade/female(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/suit/armor/hos/hos_formal(src)
	new /obj/item/clothing/suit/armor/vest/leather(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/gars/giga(src)
	new /obj/item/clothing/head/hos(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/clothing/neck/cloak/hos(src)
	new /obj/item/clothing/suit/hooded/wintercoat/security/hos(src)

/obj/item/storage/bag/garment/research_director/PopulateContents()
	new /obj/item/clothing/under/rank/rnd/research_director(src)
	new /obj/item/clothing/under/rank/rnd/research_director/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt(src)
	new /obj/item/clothing/suit/toggle/labcoat(src)
	new /obj/item/clothing/head/beret/science(src)
	new /obj/item/clothing/neck/cloak/rd(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/suit/hooded/wintercoat/science/rd(src)

/obj/item/storage/bag/garment/chief_medical/PopulateContents()
	new /obj/item/clothing/under/rank/medical/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/skirt(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/neck/cloak/cmo(src)
	new /obj/item/clothing/shoes/sneakers/blue (src)
	new /obj/item/clothing/suit/hooded/wintercoat/medical/cmo(src)

/obj/item/storage/bag/garment/engineering_chief/PopulateContents()
	new /obj/item/clothing/under/rank/engineering/chief_engineer(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/skirt(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/clothing/gloves/color/chief_engineer(src)
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/head/hardhat/weldhat/white(src)
	new /obj/item/clothing/neck/cloak/ce(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/suit/hooded/wintercoat/engineering/ce(src)

