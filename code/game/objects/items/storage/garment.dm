/obj/item/storage/bag/garment
	name = "garment bag"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "garment_bag"
	desc = "A bag for storing extra clothes and shoes."
	slot_flags = NONE
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/garment

/obj/item/storage/bag/garment/captain
	name = "captain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the captain."

/obj/item/storage/bag/garment/hos
	name = "head of security's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of security."

/obj/item/storage/bag/garment/warden
	name = "warden's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the warden."

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

/obj/item/storage/bag/garment/quartermaster
	name = "quartermasters's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the quartermaster."

/obj/item/storage/bag/garment/captain/PopulateContents()
	return list(
		/obj/item/clothing/under/rank/captain,
		/obj/item/clothing/under/rank/captain/skirt,
		/obj/item/clothing/under/rank/captain/parade,
		/obj/item/clothing/suit/armor/vest/capcarapace,
		/obj/item/clothing/suit/armor/vest/capcarapace/captains_formal,
		/obj/item/clothing/suit/hooded/wintercoat/captain,
		/obj/item/clothing/suit/jacket/capjacket,
		/obj/item/clothing/glasses/sunglasses/gar/giga,
		/obj/item/clothing/gloves/captain,
		/obj/item/clothing/head/costume/crown/fancy,
		/obj/item/clothing/head/hats/caphat,
		/obj/item/clothing/head/hats/caphat/parade,
		/obj/item/clothing/neck/cloak/cap,
		/obj/item/clothing/shoes/laceup,
	)

/obj/item/storage/bag/garment/hop/PopulateContents()
	return list(
		/obj/item/clothing/under/rank/civilian/head_of_personnel,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt,
		/obj/item/clothing/suit/armor/vest/hop,
		/obj/item/clothing/suit/hooded/wintercoat/hop,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/head/hats/hopcap,
		/obj/item/clothing/neck/cloak/hop,
		/obj/item/clothing/shoes/laceup,
	)

/obj/item/storage/bag/garment/hos/PopulateContents()
	return list(
		/obj/item/clothing/under/rank/security/head_of_security/skirt,
		/obj/item/clothing/under/rank/security/head_of_security/alt,
		/obj/item/clothing/under/rank/security/head_of_security/alt/skirt,
		/obj/item/clothing/under/rank/security/head_of_security/grey,
		/obj/item/clothing/under/rank/security/head_of_security/parade,
		/obj/item/clothing/under/rank/security/head_of_security/parade/female,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/suit/armor/hos,
		/obj/item/clothing/suit/armor/hos/hos_formal,
		/obj/item/clothing/suit/armor/hos/trenchcoat/winter,
		/obj/item/clothing/suit/armor/vest/leather,
		/obj/item/clothing/glasses/hud/security/sunglasses/eyepatch,
		/obj/item/clothing/glasses/hud/security/sunglasses/gars/giga,
		/obj/item/clothing/head/hats/hos/beret,
		/obj/item/clothing/head/hats/hos/cap,
		/obj/item/clothing/mask/gas/sechailer/swat,
		/obj/item/clothing/neck/cloak/hos,
	)

/obj/item/storage/bag/garment/warden/PopulateContents()
	return list(
		/obj/item/clothing/suit/armor/vest/warden,
		/obj/item/clothing/head/hats/warden,
		/obj/item/clothing/head/hats/warden/drill,
		/obj/item/clothing/head/beret/sec/navywarden,
		/obj/item/clothing/suit/armor/vest/warden/alt,
		/obj/item/clothing/under/rank/security/warden/formal,
		/obj/item/clothing/under/rank/security/warden/skirt,
		/obj/item/clothing/gloves/krav_maga/sec,
		/obj/item/clothing/glasses/hud/security/sunglasses,
		/obj/item/clothing/mask/gas/sechailer,
	)

/obj/item/storage/bag/garment/research_director/PopulateContents()
	return list(
		/obj/item/clothing/under/rank/rnd/research_director,
		/obj/item/clothing/under/rank/rnd/research_director/skirt,
		/obj/item/clothing/under/rank/rnd/research_director/alt,
		/obj/item/clothing/under/rank/rnd/research_director/alt/skirt,
		/obj/item/clothing/under/rank/rnd/research_director/turtleneck,
		/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt,
		/obj/item/clothing/suit/hooded/wintercoat/science/rd,
		/obj/item/clothing/head/beret/science/rd,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/neck/cloak/rd,
		/obj/item/clothing/shoes/jackboots,
	)

/obj/item/storage/bag/garment/chief_medical/PopulateContents()
	return list(
		/obj/item/clothing/under/rank/medical/chief_medical_officer,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/scrubs,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck/skirt,
		/obj/item/clothing/suit/hooded/wintercoat/medical/cmo,
		/obj/item/clothing/suit/toggle/labcoat/cmo,
		/obj/item/clothing/gloves/latex/nitrile,
		/obj/item/clothing/head/beret/medical/cmo,
		/obj/item/clothing/head/utility/surgerycap/cmo,
		/obj/item/clothing/neck/cloak/cmo,
		/obj/item/clothing/shoes/sneakers/blue ,
	)

/obj/item/storage/bag/garment/engineering_chief/PopulateContents()
	return list(
		/obj/item/clothing/under/rank/engineering/chief_engineer,
		/obj/item/clothing/under/rank/engineering/chief_engineer/skirt,
		/obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck,
		/obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck/skirt,
		/obj/item/clothing/suit/hooded/wintercoat/engineering/ce,
		/obj/item/clothing/glasses/meson/engine,
		/obj/item/clothing/gloves/chief_engineer,
		/obj/item/clothing/head/utility/hardhat/white,
		/obj/item/clothing/head/utility/hardhat/welding/white,
		/obj/item/clothing/neck/cloak/ce,
		/obj/item/clothing/shoes/sneakers/brown,
	)

/obj/item/storage/bag/garment/quartermaster/PopulateContents()
	return list(
		/obj/item/clothing/under/rank/cargo/qm,
		/obj/item/clothing/under/rank/cargo/qm/skirt,
		/obj/item/clothing/suit/hooded/wintercoat/cargo/qm,
		/obj/item/clothing/suit/utility/fire/firefighter,
		/obj/item/clothing/gloves/fingerless,
		/obj/item/clothing/suit/jacket/quartermaster,
		/obj/item/clothing/head/soft,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/neck/cloak/qm,
		/obj/item/clothing/shoes/sneakers/brown,
	)
