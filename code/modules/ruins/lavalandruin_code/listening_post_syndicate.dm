///Syndicate Listening Post

/obj/effect/mob_spawn/human/lavaland_syndicate
	name = "Syndicate Bioweapon Scientist"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	flavour_text = "<span class='big bold'>You are a syndicate agent,</span><b> employed in a top secret research facility developing biological weapons. Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. <b>Continue your research as best you can, and try to keep a low profile. <font size=6>DON'T</font> abandon the base without good cause.</b> The base is rigged with explosives should the worst happen, do not let the base fall into enemy hands!</b>"
	outfit = /datum/outfit/lavaland_syndicate
	assignedrole = "Lavaland Syndicate"

/obj/effect/mob_spawn/human/lavaland_syndicate/special(mob/living/new_spawn)
	new_spawn.grant_language(/datum/language/codespeak)

/datum/outfit/lavaland_syndicate
	name = "Lavaland Syndicate Agent"
	r_hand = /obj/item/gun/ballistic/automatic/sniper_rifle
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/toggle/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/device/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	id = /obj/item/card/id/syndicate/anyone
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/lavaland_syndicate/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/human/lavaland_syndicate/comms
	name = "Syndicate Comms Agent"
	flavour_text = "<span class='big bold'>You are a syndicate agent,</span><b> employed in a top secret research facility developing biological weapons. Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. <b>Monitor enemy activity as best you can, and try to keep a low profile. <font size=6>DON'T</font> abandon the base without good cause.</b> Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!</b>"
	outfit = /datum/outfit/lavaland_syndicate/comms

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space/Initialize()
	. = ..()
	if(prob(90)) //only has a 10% chance of existing, otherwise it'll just be a NPC syndie.
		new /mob/living/simple_animal/hostile/syndicate/ranged(get_turf(src))
		return INITIALIZE_HINT_QDEL

/datum/outfit/lavaland_syndicate/comms
	name = "Lavaland Syndicate Comms Agent"
	r_hand = /obj/item/melee/transforming/energy/sword/saber
	mask = /obj/item/clothing/mask/chameleon/gps
	suit = /obj/item/clothing/suit/armor/vest

/obj/item/clothing/mask/chameleon/gps/Initialize()
	. = ..()
	new /obj/item/device/gps/internal/lavaland_syndicate_base(src)

/obj/item/device/gps/internal/lavaland_syndicate_base
	gpstag = "Encrypted Signal"
