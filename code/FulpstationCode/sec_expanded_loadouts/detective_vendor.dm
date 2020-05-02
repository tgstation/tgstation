/obj/machinery/vending/dic
	name = "\improper DicTech"
	desc = "A fashion and essentials vendor for the discerning detective."
	product_ads = "Just one more question: Are you ready to look swag?; Upgrade your LA Noir threads today!;Evidence bags? Cigs? Matches? We got it all!;Get your fix of cheap cigs and burnt coffee!;Stogies here to complete that classic noir look!;Stylish apparel here! Crack your case in style!;Fedoras for her tipping pleasure.;Why not have a donut?"
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "det"
	icon_deny = "det-deny"
	req_access = list(ACCESS_FORENSICS_LOCKERS)
	products = list(/obj/item/clothing/suit/det_suit/disco = 1,
					/obj/item/clothing/suit/det_suit/disco/aerostatic = 1,
					/obj/item/clothing/suit/det_suit = 1,
					/obj/item/clothing/suit/det_suit/grey = 1,
					/obj/item/clothing/suit/det_suit/noir = 1,
					/obj/item/clothing/suit/armor/vest/det_suit = 1,
					/obj/item/clothing/under/rank/security/detective/disco = 4,
					/obj/item/clothing/under/rank/security/detective/disco/aerostatic = 4,
					/obj/item/clothing/under/rank/security/detective = 4,
					/obj/item/clothing/under/rank/security/detective/skirt = 4,
					/obj/item/clothing/under/rank/security/detective/grey = 4,
					/obj/item/clothing/under/rank/security/detective/grey/skirt = 4,
					/obj/item/clothing/accessory/waistcoat = 4,
					/obj/item/clothing/neck/tie/detective/disco_necktie = 4,
					/obj/item/clothing/gloves/color/black/aerostatic_gloves = 4,
					/obj/item/clothing/gloves/color/black = 4,
					/obj/item/clothing/shoes/sneakers/disco = 4,
					/obj/item/clothing/shoes/jackboots/aerostatic = 4,
					/obj/item/clothing/shoes/laceup/digitigrade = 4,
					/obj/item/clothing/shoes/laceup = 4,
					/obj/item/clothing/glasses/sunglasses/disco = 4,
					/obj/item/clothing/head/fedora/det_hat = 4,
					/obj/item/clothing/head/fedora = 4,
					/obj/item/assembly/flash/handheld = 4,
					/obj/item/flashlight/seclite = 4,
					/obj/item/radio/off/security = 4,
					/obj/item/detective_scanner = 1,
					/obj/item/radio/headset/headset_sec = 1,
					/obj/item/holosign_creator/security = 1,
					/obj/item/reagent_containers/spray/pepper = 1,
					/obj/item/storage/belt/holster/detective/full = 1,
					/obj/item/pinpointer/crew = 1,
					/obj/item/binoculars = 1,
					/obj/item/storage/box/rxglasses/spyglasskit = 1,
					/obj/item/folder = 4,
					/obj/item/disk/forensic = 12,
					/obj/item/storage/box/evidence = 12,
					/obj/item/storage/box/matches = 12,
					/obj/item/storage/fancy/cigarettes/cigars = 12,
					/obj/item/reagent_containers/food/drinks/coffee = 12,
					/obj/item/reagent_containers/food/snacks/donut = 12)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,
					  /obj/item/storage/fancy/donut_box = 2)
	premium = list(/obj/item/storage/belt/security/webbing = 5,
					/obj/item/coin/antagtoken = 1,
					/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 4,
					/obj/item/storage/box/gum/nicotine = 2,
					/obj/item/lighter = 4,
					/obj/item/clothing/mask/cigarette/pipe = 4,
					/obj/item/storage/fancy/cigarettes/cigars/havana = 12,
					/obj/item/storage/fancy/cigarettes/cigars/cohiba = 12)

	refill_canister = /obj/item/vending_refill/detective
	extra_price = 100
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/dic/pre_throw(obj/item/I)
	if(istype(I, /obj/item/grenade))
		var/obj/item/grenade/G = I
		G.preprime()
	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		F.on = TRUE
		F.update_brightness()

/obj/item/vending_refill/detective
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "refill_det"


//Here we replace that insanely cluttered closet with a vendor.
/obj/structure/closet/secure_closet/detective/Initialize()
	..()
	var/turf/T = get_turf(src)
	new /obj/machinery/vending/dic(T)
	qdel(src)


/datum/supply_pack/security/vending/detective
	name = "DicTech Supply Crate"
	desc = "Did the other detectives snatch all the good outfits and gear? Regain your swag with this!"
	cost = 1500
	contains = list(/obj/item/vending_refill/detective)
	crate_name = "DicTech supply crate"
