/datum/outfit/ninja
	name = "Space Ninja"
	uniform = /obj/item/clothing/under/syndicate/ninja
	glasses = /obj/item/clothing/glasses/night/colorless
	mask = /obj/item/clothing/mask/gas/ninja
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/grenade/c4/ninja
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	internals_slot = ITEM_SLOT_RPOCKET
	belt = /obj/item/energy_katana
	back = /obj/item/mod/control/pre_equipped/ninja
	implants = list(/obj/item/implant/explosive)

/datum/outfit/ninja/post_equip(mob/living/carbon/human/ninja)
	var/obj/item/grenade/c4/ninja/charge = ninja.l_store
	if(istype(charge))
		charge.set_detonation_area(ninja.mind?.has_antag_datum(/datum/antagonist/ninja))
	var/obj/item/mod/control/mod = ninja.back
	if(!istype(mod))
		return
	var/obj/item/mod/module/dna_lock/reinforced/lock = locate(/obj/item/mod/module/dna_lock/reinforced) in mod.modules
	lock.dna = ninja.dna.unique_enzymes
	var/obj/item/mod/module/weapon_recall/recall = locate(/obj/item/mod/module/weapon_recall) in mod.modules
	var/obj/item/weapon = ninja.belt
	if(!istype(weapon, recall.accepted_type))
		return
	recall.set_weapon(weapon)

/datum/outfit/ninja_preview
	name = "Space Ninja (Preview only)"

	uniform = /obj/item/clothing/under/syndicate/ninja
	back = /obj/item/mod/control/pre_equipped/empty/ninja
	belt = /obj/item/energy_katana
