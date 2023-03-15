/obj/item/storage/bag/garment
	name = "garment bag"
	icon = 'monkestation/icons/obj/storage/garment.dmi'
	icon_state = "garment_bag"
	desc = "A bag for storing extra clothes and shoes."
	slot_flags = NONE
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/garment/captain
	name = "captain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the captain."
	icon_state = "garment_bag_captain"

/obj/item/storage/bag/garment/hop
	name = "head of personnel's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of personnel."
	icon_state = "garment_bag_hop"

/obj/item/storage/bag/garment/hos
	name = "head of security's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of security."
	icon_state = "garment_bag_hos"

/obj/item/storage/bag/garment/warden
	name = "warden's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the warden."
	icon_state = "garment_bag_hos"

/obj/item/storage/bag/garment/research_director
	name = "research director's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the research director."
	icon_state = "garment_bag_rd"

/obj/item/storage/bag/garment/chief_medical
	name = "chief medical officer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief medical officer."
	icon_state = "garment_bag_cmo"

/obj/item/storage/bag/garment/engineering_chief
	name = "chief engineer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief engineer."
	icon_state = "garment_bag_ce"

/obj/item/storage/bag/garment/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.display_numerical_stacking = FALSE
	STR.max_combined_w_class = 200
	STR.max_items = 15
	STR.insert_preposition = "in"
	STR.set_holdable(list(
		/obj/item/clothing,
	))

/obj/item/storage/bag/garment/captain/PopulateContents()
	new /obj/item/clothing/head/caphat/beret(src)
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	new /obj/item/clothing/neck/cloak/cap(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/rank/captain/skirt(src)
	new	/obj/item/clothing/suit/armor/vest/capcarapace/jacket(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/head/caphat(src)
	new /obj/item/clothing/under/rank/captain/parade(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/alt(src)
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/head/crown/fancy(src)
	new /obj/item/clothing/glasses/sunglasses/advanced/gar/supergar(src)
	new /obj/item/clothing/gloves/color/captain(src)

/obj/item/storage/bag/garment/hop/PopulateContents()
	new /obj/item/clothing/neck/cloak/hop(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/skirt(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/alt(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/alt/skirt(src)
	new /obj/item/clothing/head/hopcap(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/suit/armor/vest/alt(src)
	new /obj/item/clothing/glasses/sunglasses/advanced(src)

/obj/item/storage/bag/garment/hos/PopulateContents()
	new /obj/item/clothing/neck/cloak/hos(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade/female(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade(src)
	new /obj/item/clothing/suit/armor/vest/leather(src)
	new /obj/item/clothing/suit/armor/hos/trenchcoat(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/under/rank/security/head_of_security(src)
	new /obj/item/clothing/under/rank/security/head_of_security/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt/skirt(src)
	new /obj/item/clothing/head/hos(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/gars/supergars(src)
	new /obj/item/clothing/under/rank/security/head_of_security/white(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)

/obj/item/storage/bag/garment/warden/PopulateContents()
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/warden(src)
	new /obj/item/clothing/head/warden/drill(src)
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	new /obj/item/clothing/head/beret/corpwarden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/under/rank/security/warden/formal(src)
	new /obj/item/clothing/under/rank/security/warden(src)
	new /obj/item/clothing/under/rank/security/warden/skirt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/mask/gas/sechailer(src)

/obj/item/storage/bag/garment/research_director/PopulateContents()
	new /obj/item/clothing/head/beret/sci(src)
	new /obj/item/clothing/neck/cloak/rd(src)
	new /obj/item/clothing/suit/toggle/labcoat/rd(src)
	new /obj/item/clothing/under/rank/rnd/research_director(src)
	new /obj/item/clothing/under/rank/rnd/research_director/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/vest(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/mask/gas(src)

/obj/item/storage/bag/garment/chief_medical/PopulateContents()
	new /obj/item/clothing/head/beret/cmo(src)
	new /obj/item/clothing/neck/cloak/cmo(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/skirt(src)
	new /obj/item/clothing/shoes/sneakers/brown	(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)


/obj/item/storage/bag/garment/engineering_chief/PopulateContents()
	new /obj/item/clothing/head/beret/ce(src)
	new /obj/item/clothing/neck/cloak/ce(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/skirt(src)
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/head/hardhat/weldhat/white(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson/engine(src)

