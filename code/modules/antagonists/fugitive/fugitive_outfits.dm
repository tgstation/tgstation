/datum/outfit/prisoner
	name = "Prison Escapee"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/knife/shiv

/datum/outfit/prisoner/post_equip(mob/living/carbon/human/prisoner, visualsOnly=FALSE)
	// This outfit is used by the assets SS, which is ran before the atoms SS
	if(SSatoms.initialized == INITIALIZATION_INSSATOMS)
		prisoner.w_uniform?.update_greyscale()
		prisoner.update_worn_undersuit()
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
	suit = /obj/item/clothing/suit/costume/striped_sweater
	head = /obj/item/clothing/head/waldo
	shoes = /obj/item/clothing/shoes/sneakers/brown
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/regular/circle

/datum/outfit/waldo/post_equip(mob/living/carbon/human/equipped_on, visualsOnly=FALSE)
	equipped_on.w_uniform?.update_greyscale()
	equipped_on.update_worn_undersuit()
	if(visualsOnly)
		return
	equipped_on.fully_replace_character_name(null, "Waldo")
	equipped_on.eye_color_left = COLOR_BLACK
	equipped_on.eye_color_right = COLOR_BLACK
	equipped_on.gender = MALE
	equipped_on.skin_tone = "caucasian3"
	equipped_on.hairstyle = "Business Hair 3"
	equipped_on.facial_hairstyle = "Shaved"
	equipped_on.hair_color = COLOR_BLACK
	equipped_on.facial_hair_color = COLOR_BLACK
	equipped_on.update_body(is_creating = TRUE)

	var/list/no_drops = list()
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_FEET)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_HEAD)
	no_drops += equipped_on.get_item_by_slot(ITEM_SLOT_EYES)
	for(var/obj/item/trait_needed as anything in no_drops)
		ADD_TRAIT(trait_needed, TRAIT_NODROP, CURSED_ITEM_TRAIT(trait_needed.type))

	var/datum/action/cooldown/spell/aoe/knock/waldos_key = new(equipped_on.mind || equipped_on)
	waldos_key.Grant(equipped_on)

/datum/outfit/synthetic
	name = "Factory Error Synth"
	uniform = /obj/item/clothing/under/color/white
	ears = /obj/item/radio/headset

/datum/outfit/synthetic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/organ/internal/eyes/robotic/glow/eyes = new()
	eyes.Insert(H, movement_flags = DELETE_IF_REPLACED)

/datum/outfit/invisible_man
	name = "Invisible Man"
	uniform = /obj/item/clothing/under/suit/black_really
	back = /obj/item/storage/backpack/satchel/leather
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/monocle
	mask = /obj/item/clothing/mask/cigarette/pipe
	ears = /obj/item/radio/headset

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/medipen/invisibility = 3,
	)

/datum/outfit/invisible_man/post_equip(mob/living/carbon/human/equipee, visualsOnly)
	. = ..()

	var/obj/item/implant/camouflage/invisibility_implant = new(equipee)
	invisibility_implant.implant(equipee)
