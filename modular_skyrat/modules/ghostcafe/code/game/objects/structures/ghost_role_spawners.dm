/obj/effect/mob_spawn/robot
	mob_type = /mob/living/silicon/robot

/obj/effect/mob_spawn/robot/Initialize()
	. = ..()

/obj/effect/mob_spawn/robot/equip(mob/living/silicon/robot/R)
	. = ..()

/obj/effect/mob_spawn/robot/ghostcafe
	name = "Cafe Robotic Storage"
	uses = -1
	icon = 'modular_skyrat/modules/ghostcafe/icons/obj/machines/robot_storage.dmi'
	icon_state = "robostorage"
	mob_name = "a cafe robot"
	roundstart = FALSE
	anchored = TRUE
	density = FALSE
	death = FALSE
	short_desc = "You are a Cafe Robot!"
	flavour_text = "Who could have thought? This awesome local cafe accepts cyborgs too!"
	mob_type = /mob/living/silicon/robot/model/roleplay

/obj/effect/mob_spawn/robot/ghostcafe/special(mob/living/silicon/robot/new_spawn)
	if(new_spawn.client)
		new_spawn.custom_name = null
		new_spawn.updatename(new_spawn.client)
		new_spawn.gender = NEUTER
		var/area/A = get_area(src)
		//new_spawn.AddElement(/datum/element/ghost_role_eligibility, free_ghosting = TRUE) SKYRAT PORT -- Needs to be completely rewritten
		new_spawn.AddElement(/datum/element/dusts_on_catatonia)
		new_spawn.AddElement(/datum/element/dusts_on_leaving_area,list(A.type, /area/hilbertshotel, /area/centcom/holding/cafe, /area/centcom/holding/cafewar, /area/centcom/holding/cafebotany,
		/area/centcom/holding/cafebuild, /area/centcom/holding/cafevox, /area/centcom/holding/cafedorms, /area/centcom/holding/cafepark, /area/centcom/holding/cafeplumbing))
		ADD_TRAIT(new_spawn, TRAIT_SIXTHSENSE, GHOSTROLE_TRAIT)
		ADD_TRAIT(new_spawn, TRAIT_FREE_GHOST, GHOSTROLE_TRAIT)
		to_chat(new_spawn,"<span class='warning'><b>Ghosting is free!</b></span>")
		var/datum/action/toggle_dead_chat_mob/D = new(new_spawn)
		D.Grant(new_spawn)


/obj/effect/mob_spawn/human/ghostcafe
	name = "Cafe Sleeper"
	uses = -1
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_name = "a cafe visitor"
	roundstart = FALSE
	density = FALSE
	death = FALSE
	any_station_species = TRUE
	outfit = /datum/outfit
	short_desc = "You are a Cafe Visitor!"
	flavour_text = "You are off-duty and have decided to visit your favourite cafe. Enjoy yourself."

/obj/effect/mob_spawn/human/ghostcafe/special(mob/living/carbon/human/new_spawn)
	if(new_spawn.client)
		new_spawn.client.prefs.safe_transfer_prefs_to(new_spawn)
		var/area/A = get_area(src)
		//new_spawn.AddElement(/datum/element/ghost_role_eligibility, free_ghosting = TRUE)
		new_spawn.AddElement(/datum/element/dusts_on_catatonia)
		new_spawn.AddElement(/datum/element/dusts_on_leaving_area,list(A.type, /area/hilbertshotel, /area/centcom/holding/cafe, /area/centcom/holding/cafewar, /area/centcom/holding/cafebotany,
		/area/centcom/holding/cafebuild, /area/centcom/holding/cafevox, /area/centcom/holding/cafedorms, /area/centcom/holding/cafepark, /area/centcom/holding/cafeplumbing))
		ADD_TRAIT(new_spawn, TRAIT_SIXTHSENSE, GHOSTROLE_TRAIT)
		ADD_TRAIT(new_spawn, TRAIT_FREE_GHOST, GHOSTROLE_TRAIT)
		to_chat(new_spawn,"<span class='warning'><b>Ghosting is free!</b></span>")
		//to_chat(new_spawn,"<span class='narsiesmall'>Be warned: People who opt out of EORG will come here. Do not make the area uninhabitable and do NOT commit EORG. This is a safe-zone. If you attack people in EORG, you will be banned for griefing.</span>")
		var/datum/action/toggle_dead_chat_mob/D = new(new_spawn)
		new_spawn.put_in_hand(new /obj/item/storage/box/syndie_kit/chameleon/ghostcafe, LEFT_HANDS, forced = TRUE)
		new_spawn.equip_outfit_and_loadout(/datum/outfit/ghostcafe, new_spawn.client.prefs, FALSE, null)
		D.Grant(new_spawn)

/datum/outfit/ghostcafe
	name = "ID, jumpsuit and shoes"
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/sneakers/black
	id = /obj/item/card/id/advanced/ghost_cafe

/datum/action/toggle_dead_chat_mob
	icon_icon = 'icons/mob/mob.dmi'
	button_icon_state = "ghost"
	name = "Toggle deadchat"
	desc = "Turn off or on your ability to hear ghosts."

/datum/action/toggle_dead_chat_mob/Trigger()
	if(!..())
		return 0
	var/mob/M = target
	if(HAS_TRAIT_FROM(M,TRAIT_SIXTHSENSE,GHOSTROLE_TRAIT))
		REMOVE_TRAIT(M,TRAIT_SIXTHSENSE,GHOSTROLE_TRAIT)
		to_chat(M,"<span class='notice'>You're no longer hearing deadchat.</span>")
	else
		ADD_TRAIT(M,TRAIT_SIXTHSENSE,GHOSTROLE_TRAIT)
		to_chat(M,"<span class='notice'>You're once again hearing deadchat.</span>")

/obj/item/storage/box/syndie_kit/chameleon/ghostcafe
	name = "cafe costuming kit"
	desc = "Look just the way you did in life - or better!"

/obj/item/storage/box/syndie_kit/chameleon/ghostcafe/PopulateContents() // Doesn't contain a PDA, for isolation reasons.
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/clothing/neck/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/storage/belt/chameleon(src)

/obj/item/card/id/advanced/ghost_cafe
	name = "\improper Cafe ID"
	desc = "An ID straight from God."
	icon_state = "card_centcom"
	worn_icon_state = "card_centcom"
	assigned_icon_state = "assigned_centcom"
	registered_age = null
	trim = /datum/id_trim/admin
	wildcard_slots = WILDCARD_LIMIT_ADMIN

