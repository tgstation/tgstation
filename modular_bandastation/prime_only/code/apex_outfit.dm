// CentCom Apex Field Officer
/datum/outfit/centcom/commander/field/apex
	name = "Apex Nanotrasen Navy Field Officer"
	suit = null
	mask = null
	accessory = /obj/item/clothing/accessory/holster/tacticool/ert_gp93r
	l_pocket = null
	head = /obj/item/clothing/head/beret/centcom/soo
	neck = /obj/item/clothing/neck/cloak/centcom/gr_cape
	uniform = /obj/item/clothing/under/rank/centcom/gr_under
	gloves = /obj/item/clothing/gloves/combat
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom,
		/obj/item/stamp/centcom,
		/obj/item/door_remote/omni,
		/obj/item/flashlight/seclite,
		/obj/item/clothing/mask/gas/sechailer,
		/obj/item/reagent_containers/hypospray/combat,
		/obj/item/reagent_containers/spray/cleaner
	)
	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/freedom,
		/obj/item/implant/empprotection
	)

/datum/outfit/centcom/commander/field/apex/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()

	if(visuals_only)
		return

	// skills
	var/datum/action/cooldown/spell/dodge_mode/dodge = new()
	dodge.Grant(H)

	// limbs
	var/obj/item/bodypart/arm/left/strongarm/left_arm = new()
	var/obj/item/bodypart/arm/right/strongarm/right_arm = new()
	var/obj/item/bodypart/leg/left/strongleg/left_leg = new()
	var/obj/item/bodypart/leg/right/strongleg/right_leg = new()

	var/obj/item/bodypart/old_left_arm = H.get_bodypart(BODY_ZONE_L_ARM)
	left_arm.replace_limb(H, TRUE)
	qdel(old_left_arm)

	var/obj/item/bodypart/old_right_arm = H.get_bodypart(BODY_ZONE_R_ARM)
	right_arm.replace_limb(H, TRUE)
	qdel(old_right_arm)

	var/obj/item/bodypart/old_left_leg = H.get_bodypart(BODY_ZONE_L_LEG)
	left_leg.replace_limb(H, TRUE)
	qdel(old_left_leg)

	var/obj/item/bodypart/old_right_leg = H.get_bodypart(BODY_ZONE_R_LEG)
	right_leg.replace_limb(H, TRUE)
	qdel(old_right_leg)

	// cyberimps
	var/list/implants_to_add = list(
		/obj/item/organ/cyberimp/chest/pump/centcom,
		/obj/item/organ/cyberimp/eyes/hud/security/shielded,
		/obj/item/organ/cyberimp/chest/reviver,
		/obj/item/organ/cyberimp/brain/anti_stun
	)
	for(var/imp_type in implants_to_add)
		var/obj/item/organ/cyberimp/imp = new imp_type()
		imp.Insert(H, special = TRUE)

	// khaaroot survivor
	H.apply_status_effect(/datum/status_effect/khaaroot_survivor)
	var/datum/action/cooldown/spell/khaaroot_adrenaline_surge/surge = new()
	surge.Grant(H)
	var/datum/action/cooldown/spell/pointed/khaaroot_infect/infect = new()
	infect.Grant(H)
