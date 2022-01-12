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
	equipped_on.eye_color = "#000000"
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
	var/obj/item/organ/eyes/robotic/glow/eyes = new()
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

/datum/outfit/russiancorpse/hunter
	ears = /obj/item/radio/headset
	r_hand = /obj/item/gun/ballistic/rifle/boltaction/brand_new

/datum/outfit/russiancorpse/hunter/pre_equip(mob/living/carbon/human/H)
	if(prob(50))
		head = /obj/item/clothing/head/ushanka

/datum/outfit/bountyarmor
	name = "Bounty Hunter - Armored"
	uniform = /obj/item/clothing/under/rank/prisoner
	back = /obj/item/storage/backpack
	head = /obj/item/clothing/head/hunter
	suit = /obj/item/clothing/suit/space/hunter
	gloves = /obj/item/clothing/gloves/tackler/combat
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/hunter
	glasses = /obj/item/clothing/glasses/sunglasses/gar
	ears = /obj/item/radio/headset
	r_pocket = /obj/item/restraints/handcuffs/cable
	id = /obj/item/card/id/advanced
	l_hand = /obj/item/tank/internals/plasma/full
	r_hand = /obj/item/flamethrower/full/tank

/datum/outfit/bountyarmor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.assignment = "Bounty Hunter"
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
	id = /obj/item/card/id/advanced
	r_hand = /obj/item/gun/ballistic/shotgun/hook

	backpack_contents = list(
		/obj/item/ammo_casing/shotgun/incapacitate = 6
		)

/datum/outfit/bountyhook/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.assignment = "Bounty Hunter"
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
	id = /obj/item/card/id/advanced
	r_hand = /obj/item/storage/firstaid/regular
	l_hand = /obj/item/pinpointer/shuttle

	backpack_contents = list(
		/obj/item/bountytrap = 4
		)

/datum/outfit/bountysynth/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/datum/species/synth/synthetic_appearance = new()
	H.set_species(synthetic_appearance)
	synthetic_appearance.assume_disguise(synthetic_appearance, H)
	H.update_hair()
	var/obj/item/card/id/W = H.wear_id
	W.assignment = "Bounty Hunter"
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
