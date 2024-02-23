/datum/outfit/minesite
	name = "Mining Site Worker"

	uniform = /obj/item/clothing/under/rank/cargo/miner
	suit = /obj/item/clothing/suit/hooded/wintercoat
	back = /obj/item/storage/backpack/duffelbag
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/winterboots/ice_boots
	head = /obj/item/clothing/head/utility/hardhat/orange

/datum/outfit/minesite/overseer
	name = "Mining Site Overseer"

	uniform = /obj/item/clothing/under/rank/cargo/qm
	suit = /obj/item/clothing/suit/hooded/wintercoat
	back = /obj/item/storage/backpack/duffelbag
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/winterboots/ice_boots
	head = /obj/item/clothing/head/utility/hardhat/white
	glasses = /obj/item/clothing/glasses/sunglasses
	r_hand = /obj/item/megaphone
	l_hand = /obj/item/clipboard

/obj/effect/mob_spawn/corpse/human/minesite
	name = "Mining Site Worker"
	outfit = /datum/outfit/minesite
	icon_state = "corpseminer"

// Gives the minesite corpses the gutted effect so that the boss ignores them
/obj/effect/mob_spawn/corpse/human/minesite/special(mob/living/spawned_mob)
	. = ..()
	spawned_mob.apply_status_effect(/datum/status_effect/gutted)

/obj/effect/mob_spawn/corpse/human/minesite/overseer
	name = "Mining Site Overseer"
	outfit = /datum/outfit/minesite/overseer
	icon_state = "corpsecargotech"

/obj/item/paper/crumpled/bloody/ruins/mining_site
	name = "blood-written note"
	default_raw_text = "<br><br><font color='red'>STRENGTH... UNPARALLELED. UNNATURAL.</font>"
