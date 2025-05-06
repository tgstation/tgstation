/**
 * CYBERSUN SIM
 */
/datum/outfit/deathmatch_loadout/cybersun_sim
	name = "DM: Cybersun Grunt"
	display_name = "Cybersun Grunt"

	uniform = /obj/item/clothing/under/syndicate/combat
	mask = /obj/item/clothing/mask/neck_gaiter/cybersun
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/card/id/advanced/chameleon

// Chromed out loadouts
/datum/outfit/deathmatch_loadout/cyberpunk
	name = "DM: Cyberpunk Implant Loadout Base"
	display_name = "Evil Broken Debug Loadout"
	desc = "HEEEEEELP!!!"
	/// What cybernetics to add to this loadout's owner
	var/list/implants_to_add = list()
	/// Bodyparts to make and replace on the loadout's owner
	var/list/bodyparts_to_replace = list()

/datum/outfit/deathmatch_loadout/cyberpunk/post_equip(mob/living/carbon/human/squaddie, visualsOnly = FALSE)
	if(visualsOnly)
		return
	squaddie.mind?.adjust_experience(/datum/skill/athletics, 10000000)
	for(var/iterated_implant in implants_to_add)
		var/obj/item/organ/new_implant = new iterated_implant()
		new_implant.Insert(squaddie)
	for(var/iterated_bodypart in bodyparts_to_replace)
		var/obj/item/bodypart/new_bodypart = new iterated_bodypart()
		new_bodypart.replace_limb(squaddie, special = TRUE)
	return ..()

// Chromed out loadouts
/datum/outfit/deathmatch_loadout/cyberpunk/silverhands
	name = "DM: James Silverhands"
	display_name = "James Silverhands"
	desc = "Time to party like it's 2523."
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/fingerless
	uniform = /obj/item/clothing/under/pants/camo
	suit = /obj/item/clothing/suit/armor/vest/alt/sec
	glasses = /obj/item/clothing/glasses/hud/ar/aviator
	belt = /obj/item/gun/ballistic/automatic/pistol/clandestine
	l_pocket = /obj/item/ammo_box/magazine/m10mm/ap
	r_pocket = /obj/item/ammo_box/magazine/m10mm
	implants_to_add = list(
		/obj/item/organ/cyberimp/trickshotter,
	)
	bodyparts_to_replace = list(
		/obj/item/bodypart/arm/left/robot/advanced,
		/obj/item/bodypart/arm/right/robot/advanced,
	)

/datum/outfit/deathmatch_loadout/cyberpunk/gorilla
	name = "DM: Cyberilla"
	display_name = "Cyberilla"
	desc = "You might not be a gorilla, but technology means you can get pretty close."
	shoes = /obj/item/clothing/shoes/jackboots
	uniform = /obj/item/clothing/under/pants/jeans
	head = /obj/item/clothing/head/costume/pirate/bandana
	suit = /obj/item/clothing/suit/armor/vest
	glasses = /obj/item/clothing/glasses/cold
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/deforest/demoneye
	implants_to_add = list(
		/obj/item/organ/cyberimp/arm/strongarm,
		/obj/item/organ/cyberimp/arm/strongarm,
		/obj/item/organ/cyberimp/chest/spine/atlas,
	)
	bodyparts_to_replace = list()

/datum/outfit/deathmatch_loadout/cyberpunk/sandevistan
	name = "DM: The Special One"
	display_name = "The Special One"
	desc = "You keep saying you're special, remember that? You won't stop talking about it."
	shoes = /obj/item/clothing/shoes/swagshoes
	uniform = /obj/item/clothing/under/costume/tmc
	suit = /obj/item/clothing/suit/costume/pg
	gloves = /obj/item/clothing/gloves/fingerless
	implants_to_add = list(
		/obj/item/organ/cyberimp/sensory_enhancer,
		/obj/item/organ/cyberimp/arm/shell_launcher,
	)
	bodyparts_to_replace = list()

/datum/outfit/deathmatch_loadout/cyberpunk/psycho_hunter
	name = "DM: Psycho Squad"
	display_name = "Psycho Squad Member"
	desc = "A member of the mysterious psycho hunter squad, rumored to not even be real."
	shoes = /obj/item/clothing/shoes/combat/swat
	uniform = /obj/item/clothing/under/rank/centcom/military
	suit = /obj/item/clothing/suit/armor/vest/secjacket
	suit_store = /obj/item/gun/ballistic/automatic/smartgun
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/neck_gaiter/cybersun
	l_pocket = /obj/item/ammo_box/magazine/smartgun
	implants_to_add = list(
		/obj/item/organ/cyberimp/arm/razorwire,
		/obj/item/organ/heart/cybernetic/anomalock/prebuilt,
	)
	bodyparts_to_replace = list()

/datum/outfit/deathmatch_loadout/cyberpunk/just_ken
	name = "DM: Just Ken"
	display_name = "Just A Dude"
	desc = "You don't have any special implants or modifications. You're just him."
	shoes = /obj/item/clothing/shoes/jackboots
	uniform = /obj/item/clothing/under/costume/osi
	suit = /obj/item/clothing/suit/costume/deckers
	gloves = /obj/item/clothing/gloves/fingerless
	glasses = /obj/item/clothing/glasses/orange
	belt = /obj/item/storage/belt/secsword/deathmatch
	implants_to_add = list()
	bodyparts_to_replace = list()
