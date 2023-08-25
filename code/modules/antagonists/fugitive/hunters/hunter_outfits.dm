/datum/outfit/spacepol
	name = "Spacepol Officer"
	uniform = /obj/item/clothing/under/rank/security/officer/spacepol
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	belt = /obj/item/gun/ballistic/automatic/pistol/m1911
	head = /obj/item/clothing/head/hats/warden/police
	gloves = /obj/item/clothing/gloves/tackler/combat
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/swat/spacepol
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset
	l_pocket = /obj/item/ammo_box/magazine/m45
	r_pocket = /obj/item/restraints/handcuffs
	id = /obj/item/card/id/advanced/bountyhunter
	id_trim = /datum/id_trim/bounty_hunter/police

/datum/outfit/spacepol/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.icon_state = "card_black" //Less flamey, more modest, still unique enough to convey that they're fugitive hunters.
	W.update_label()
	W.update_icon()


/datum/id_trim/bounty_hunter/police
	assignment = "Police Officer"
	trim_state = "trim_warden"
	department_color = COLOR_STRONG_BLUE

	access = list(ACCESS_HUNTER)

/datum/outfit/russian_hunter
	name = "Russian Hunter"
	uniform = /obj/item/clothing/under/costume/soviet
	suit = /obj/item/clothing/suit/armor/bulletproof
	suit_store = /obj/item/gun/ballistic/rifle/boltaction
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/tackler/combat
	head = /obj/item/clothing/head/helmet/alt
	shoes = /obj/item/clothing/shoes/russian
	l_pocket = /obj/item/ammo_box/strilka310
	r_pocket = /obj/item/restraints/handcuffs/cable/zipties
	id = /obj/item/card/id/advanced/bountyhunter

/datum/outfit/russian_hunter/pre_equip(mob/living/carbon/human/equip_to)

	// Let's give the Russians a bit of randomization for style.
	var/static/list/alt_uniforms = list(
		/obj/item/clothing/under/syndicate/soviet,
		/obj/item/clothing/under/syndicate/combat,
		/obj/item/clothing/under/syndicate/rus_army,
		/obj/item/clothing/under/syndicate/camo,
	)
	var/static/list/alt_suits = list(
		/obj/item/clothing/suit/armor/vest/russian,
		/obj/item/clothing/suit/armor/vest/russian_coat,
	)
	var/static/list/alt_helmets = list(
		/obj/item/clothing/head/costume/bearpelt,
		/obj/item/clothing/head/costume/ushanka,
		/obj/item/clothing/head/helmet/rus_helmet,
	)

	if(prob(80))
		uniform = pick(alt_uniforms)
	if(prob(50))
		suit = pick(alt_suits)
	if(prob(50))
		head = pick(alt_helmets)

/datum/outfit/russian_hunter/post_equip(mob/living/carbon/human/equip_to, visualsOnly = FALSE)
	if(visualsOnly)
		return

	if(istype(equip_to.wear_id, /obj/item/card/id))
		var/obj/item/card/id/equipped_card = equip_to.wear_id
		equipped_card.assignment = "Russian Bounty Hunter"
		equipped_card.registered_name = equip_to.real_name
		equipped_card.update_label()
		equipped_card.update_icon()

	if(istype(equip_to.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/uniform = equip_to.w_uniform
		uniform.sensor_mode = NO_SENSORS
		uniform.has_sensor = NO_SENSORS

/datum/outfit/russian_hunter/leader
	name = "Russian Hunter Leader"
	head = /obj/item/clothing/head/costume/ushanka
	shoes = /obj/item/clothing/shoes/combat

/datum/outfit/russian_hunter/leader/pre_equip(mob/living/carbon/human/equip_to)
	return // None of the RNG russian equipment stuff.

/datum/outfit/bountyarmor
	name = "Bounty Hunter - Armored"
	uniform = /obj/item/clothing/under/rank/prisoner
	back = /obj/item/storage/backpack
	head = /obj/item/clothing/head/cowboy/bounty
	suit = /obj/item/clothing/suit/space/hunter
	belt = /obj/item/gun/ballistic/automatic/pistol/fire_mag
	gloves = /obj/item/clothing/gloves/tackler/combat
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/hunter
	glasses = /obj/item/clothing/glasses/sunglasses/gar
	ears = /obj/item/radio/headset
	r_pocket = /obj/item/restraints/handcuffs/cable
	l_pocket = /obj/item/ammo_box/magazine/m9mm/fire
	id = /obj/item/card/id/advanced/bountyhunter
	l_hand = /obj/item/gun/ballistic/shotgun/automatic/dual_tube/bounty

	backpack_contents = list(
		/obj/item/ammo_casing/shotgun/rubbershot = 4,
		/obj/item/ammo_casing/shotgun/incendiary/no_trail = 4,
	)

/datum/outfit/bountyarmor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()

/datum/outfit/bountyhook
	name = "Bounty Hunter - Hook"
	uniform = /obj/item/clothing/under/rank/prisoner
	back = /obj/item/storage/backpack
	head = /obj/item/clothing/head/costume/scarecrow_hat
	gloves = /obj/item/clothing/gloves/botanic_leather
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/scarecrow
	r_pocket = /obj/item/restraints/handcuffs/cable
	id = /obj/item/card/id/advanced/bountyhunter
	r_hand = /obj/item/gun/ballistic/shotgun/hook

	backpack_contents = list(
		/obj/item/ammo_casing/shotgun/incapacitate = 6
		)

/datum/outfit/bountyhook/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()

/datum/outfit/bountysynth
	name = "Bounty Hunter - Synth"
	uniform = /obj/item/clothing/under/rank/prisoner
	back = /obj/item/storage/backpack
	suit = /obj/item/clothing/suit/armor/riot
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/eyepatch
	r_pocket = /obj/item/restraints/handcuffs/cable
	ears = /obj/item/radio/headset
	id = /obj/item/card/id/advanced/bountyhunter
	r_hand = /obj/item/storage/medkit/regular

	backpack_contents = list(
		/obj/item/bountytrap = 4
		)

/datum/id_trim/bounty_hunter/psykers
	assignment = "Psyker-gang Shikari"

/datum/id_trim/bounty_hunter/psykers/captain
	assignment = "Psyker-gang Shikari Captain"

/datum/id_trim/bounty_hunter/psykers/seer
	assignment = "Psyker-gang Shikari Seer"

/datum/outfit/psyker/captain
	name = "Psyker-Shikari Leader"

	id_trim = /datum/id_trim/bounty_hunter/psykers/captain
	suit = /obj/item/clothing/suit/armor/reactive/psykerboost
	uniform = /obj/item/clothing/under/pants/camo

/datum/outfit/psyker
	name = "Psyker-Shikari Hunter"
	glasses = null
	head = null
	ears = /obj/item/radio/headset/syndicate/alt/psyker
	uniform = /obj/item/clothing/under/pants/track
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/gore
	r_pocket = /obj/item/reagent_containers/hypospray/medipen/gore
	id = /obj/item/card/id/advanced/bountyhunter

	id_trim = /datum/id_trim/bounty_hunter/psykers

/datum/outfit/psyker/post_equip(mob/living/carbon/human/equipped)
	. = ..()
	equipped.psykerize()

/datum/outfit/psyker_seer
	name = "Psyker-Shikari Seer"
	glasses = /obj/item/clothing/glasses/regular/thin
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/pants/jeans
	suit = /obj/item/clothing/suit/hazardvest
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/sandal
	l_pocket = /obj/item/restraints/handcuffs/cable/zipties
	r_pocket = /obj/item/restraints/handcuffs/cable/zipties
	id = /obj/item/card/id/advanced/bountyhunter

	id_trim = /datum/id_trim/bounty_hunter/psykers/seer

//ids and ert code

/obj/item/card/id/advanced/bountyhunter
	assignment = "Bounty Hunter"
	icon_state = "card_flame" //oh SHIT
	trim = /datum/id_trim/bounty_hunter

/datum/outfit/bountyarmor/ert
	id = /obj/item/card/id/advanced/bountyhunter/ert

/datum/outfit/bountyhook/ert
	id = /obj/item/card/id/advanced/bountyhunter/ert

/datum/outfit/bountysynth/ert
	id = /obj/item/card/id/advanced/bountyhunter/ert

/obj/item/card/id/advanced/bountyhunter/ert
	trim = /datum/id_trim/centcom/bounty_hunter
