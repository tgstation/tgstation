/datum/outfit/prisoner
	name = "Prison Escapee"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/kitchen/knife/carrotshiv

/datum/outfit/prisoner/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	if(visualsOnly)
		return
	H.fully_replace_character_name(null,"NTP #CC-0[rand(111,999)]") //same as the lavaland prisoner transport, but this time they are from CC, or CentCom

/datum/outfit/yalp_cultist
	name = "Cultist of Yalp Elor"
	uniform = /obj/item/clothing/under/rank/chaplain
	suit = /obj/item/clothing/suit/holidaypriest
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

/datum/outfit/waldo/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	if(visualsOnly)
		return
	H.fully_replace_character_name(null,"Waldo")
	H.eye_color = "000"
	H.gender = MALE
	H.skin_tone = "caucasian3"
	H.hair_style = "Business Hair 3"
	H.facial_hair_style = "Shaved"
	H.hair_color = "000"
	H.facial_hair_color = H.hair_color
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
	var/list/no_drops = list()
	// The shielded hardsuit is already NODROP
	no_drops += H.get_item_by_slot(SLOT_SHOES)
	no_drops += H.get_item_by_slot(SLOT_W_UNIFORM)
	no_drops += H.get_item_by_slot(SLOT_EARS)
	no_drops += H.get_item_by_slot(SLOT_WEAR_SUIT)
	no_drops += H.get_item_by_slot(SLOT_HEAD)
	no_drops += H.get_item_by_slot(SLOT_GLASSES)
	for(var/i in no_drops)
		var/obj/item/I = i
		I.add_trait(TRAIT_NODROP, CURSED_ITEM_TRAIT)

/datum/outfit/synthetic
	name = "Factory Error Synth"
	uniform = /obj/item/clothing/under/color/white
	ears = /obj/item/radio/headset

/datum/outfit/synthetic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/organ/eyes/robotic/glow/eyes = new()
	eyes.Insert(src, drop_if_replaced = FALSE)

/datum/outfit/spacepol
	name = "Spacepol Officer"
	uniform = /obj/item/clothing/under/rank/security/spacepol
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	belt = /obj/item/gun/ballistic/automatic/pistol/m1911
	head = /obj/item/clothing/head/helmet/police
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/swat/spacepol
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/ammo_box/magazine/m45
	r_pocket = /obj/item/ammo_box/magazine/m45
