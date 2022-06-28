/datum/outfit/prisoner
	name = "Prison Escapee"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/knife/shiv

/datum/outfit/prisoner/post_equip(mob/living/carbon/human/prisoner, visualsOnly=FALSE)
	// This outfit is used by the assets SS, which is ran before the atoms SS
	if(SSatoms.initialized == INITIALIZATION_INSSATOMS)
		prisoner.w_uniform?.update_greyscale()
		prisoner.update_inv_w_uniform()
	if(visualsOnly)
		return
	prisoner.fully_replace_character_name(null,"NTP #CC-0[rand(111,999)]") //same as the lavaland prisoner transport, but this time they are from CC, or CentCom

/datum/outfit/yalp_cultist
	name = "Cultist of Yalp Elor"
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	suit = /obj/item/clothing/suit/chaplainsuit/holidaypriest
	gloves = /obj/item/clothing/gloves/color/red
	shoes = /obj/item/clothing/shoes/sneakers/black
	mask = /obj/item/clothing/mask/gas/tiki_mask/yalp_elor

/datum/outfit/waldo
	name = "Waldo"
	uniform = /obj/item/clothing/under/pants/jeans
	suit = /obj/item/clothing/suit/striped_sweater
	head = /obj/item/clothing/head/beanie/waldo
	shoes = /obj/item/clothing/shoes/sneakers/brown
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/regular/circle

/datum/outfit/waldo/post_equip(mob/living/carbon/human/equipped_on, visualsOnly=FALSE)
	if(visualsOnly)
		return
	equipped_on.fully_replace_character_name(null,"Waldo")
	equipped_on.eye_color_left = "#000000"
	equipped_on.eye_color_right = "#000000"
	equipped_on.gender = MALE
	equipped_on.skin_tone = "caucasian3"
	equipped_on.hairstyle = "Business Hair 3"
	equipped_on.facial_hairstyle = "Shaved"
	equipped_on.hair_color = "#000000"
	equipped_on.facial_hair_color = equipped_on.hair_color
	equipped_on.update_body()
	if(equipped_on.mind)
		equipped_on.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
	var/list/no_drops = list()
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_FEET)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_HEAD)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_EYES)
	for(var/obj/item/trait_needed as anything in no_drops)
		ADD_TRAIT(trait_needed, TRAIT_NODROP, CURSED_ITEM_TRAIT(trait_needed.type))

/datum/outfit/synthetic
	name = "Factory Error Synth"
	uniform = /obj/item/clothing/under/color/white
	ears = /obj/item/radio/headset

/datum/outfit/synthetic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/organ/internal/eyes/robotic/glow/eyes = new()
	eyes.Insert(H, drop_if_replaced = FALSE)

/datum/outfit/spacepol
	name = "Spacepol Officer"
	uniform = /obj/item/clothing/under/rank/security/officer/spacepol
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	belt = /obj/item/gun/ballistic/automatic/pistol/m1911
	head = /obj/item/clothing/head/helmet/police
	gloves = /obj/item/clothing/gloves/tackler/combat
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/swat/spacepol
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset
	l_pocket = /obj/item/ammo_box/magazine/m45
	r_pocket = /obj/item/restraints/handcuffs
	id = /obj/item/card/id/advanced

/datum/outfit/spacepol/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.assignment = "Police Officer"
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()

/datum/outfit/russian_hunter
	name = "Russian Hunter"
	id = /obj/item/card/id/advanced
	uniform = /obj/item/clothing/under/costume/soviet
	suit = /obj/item/clothing/suit/armor/bulletproof
	suit_store = /obj/item/gun/ballistic/rifle/boltaction/brand_new
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/tackler/combat
	head = /obj/item/clothing/head/helmet/alt
	shoes = /obj/item/clothing/shoes/russian
	l_pocket = /obj/item/ammo_box/a762
	r_pocket = /obj/item/restraints/handcuffs/cable/zipties

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
		/obj/item/clothing/head/bearpelt,
		/obj/item/clothing/head/ushanka,
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
	head = /obj/item/clothing/head/ushanka
	shoes = /obj/item/clothing/shoes/combat

/datum/outfit/russian_hunter/leader/pre_equip(mob/living/carbon/human/equip_to)
	return // None of the RNG russian equipment stuff.

/datum/outfit/bountyarmor
	name = "Bounty Hunter - Armored"
	uniform = /obj/item/clothing/under/rank/prisoner
	back = /obj/item/storage/backpack
	head = /obj/item/clothing/head/hunter
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
	head = /obj/item/clothing/head/scarecrow_hat
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
	l_hand = /obj/item/pinpointer/shuttle

	backpack_contents = list(
		/obj/item/bountytrap = 4
		)

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
