var/list/uplink_items = list()

/proc/get_uplink_items()
	// If not already initialized..
	if(!uplink_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		var/list/last = list()
		for(var/item in typesof(/datum/uplink_item))

			var/datum/uplink_item/I = new item()
			if(!I.item)
				continue
			if(I.gamemodes.len && ticker && !(ticker.mode.name in I.gamemodes))
				continue
			if(I.last)
				last += I
				continue

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

		for(var/datum/uplink_item/I in last)

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

	return uplink_items

// You can change the order of the list by putting datums before/after one another OR
// you can use the last variable to make sure it appears last, well have the category appear last.

/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/item = null
	var/cost = 0
	var/last = 0 // Appear last
	var/list/gamemodes = list() // Empty list means it is in all the gamemodes. Otherwise place the gamemode name here.

/datum/uplink_item/proc/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)
	if(item)
		U.uses -= max(cost, 0)
		feedback_add_details("traitor_uplink_items_bought", "[item]")
		return new item(loc)

/datum/uplink_item/proc/buy(var/obj/item/device/uplink/U, var/mob/user)

	..()
	if(!istype(U))
		return 0

	if (!user || user.stat || user.restrained())
		return 0

	if (!( istype(user, /mob/living/carbon/human)))
		return 0

	// If the uplink's holder is in the user's contents
	if ((U.loc in user.contents || (in_range(U.loc, user) && istype(U.loc.loc, /turf))))
		user.set_machine(U)
		if(cost > U.uses)
			return 0

		var/obj/I = spawn_item(get_turf(user), U)

		if(istype(I, /obj/item) && ishuman(user))
			var/mob/living/carbon/human/A = user
			A.put_in_any_hand_if_possible(I)
			U.purchase_log += "[user] ([user.ckey]) bought [name]."

		U.interact(user)
		return 1
	return 0

/*
//
//	UPLINK ITEMS
//
*/

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Highly Visible and Dangerous Weapons"

/datum/uplink_item/dangerous/revolver
	name = "Revolver"
	item = /obj/item/weapon/gun/projectile
	cost = 6

/datum/uplink_item/dangerous/ammo
	name = "Ammo-357"
	item = /obj/item/ammo_magazine/a357
	cost = 2

/datum/uplink_item/dangerous/crossbow
	name = "Energy Crossbow"
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 5

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	item = /obj/item/weapon/melee/energy/sword
	cost = 4

/datum/uplink_item/dangerous/emp
	name = "5 EMP Grenades"
	item = /obj/item/weapon/storage/box/emps
	cost = 3


// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/para_pen
	name = "Paralysis Pen"
	item = /obj/item/weapon/pen/paralysis
	cost = 3

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	item = /obj/item/weapon/cartridge/syndicate
	cost = 3


// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	item = /obj/item/clothing/under/chameleon
	cost = 3

/datum/uplink_item/stealthy_tools/syndigolashes
	name = "No-Slip Syndicate Shoes"
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 2

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	item = /obj/item/weapon/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	item = /obj/item/clothing/mask/gas/voice
	cost = 4

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	item = /obj/item/device/chameleon
	cost = 4


// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	item = /obj/item/weapon/card/emag
	cost = 3

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/space_suit
	name = "Space Suit"
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 3

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 3

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	item = /obj/item/device/encryptionkey/binary
	cost = 3

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	item = /obj/item/weapon/aiModule/syndicate
	cost = 7

/datum/uplink_item/device_tools/plastic_explosives
	name = "C-4 (Destroys Walls)"
	item = /obj/item/weapon/plastique
	cost = 2

/datum/uplink_item/device_tools/powersink
	name = "Powersink (DANGER!)"
	item = /obj/item/device/powersink
	cost = 5

/datum/uplink_item/device_tools/singularity_beacon
	name = "Singularity Beacon (DANGER!)"
	item = /obj/item/device/sbeacondrop
	cost = 7

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	item = /obj/item/weapon/circuitboard/teleporter
	cost = 20
	gamemodes = list("nuclear emergency")


// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 3

/datum/uplink_item/implants/uplink
	name = "Uplink Implant (Contains 5 Telecrystals)"
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 10


// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	item = /obj/item/weapon/storage/box/syndicate
	cost = 10

/datum/uplink_item/badass/balloon
	name = "For showing that You Are The Boss (Useless Balloon)"
	item = /obj/item/toy/syndicateballoon
	cost = 10

/datum/uplink_item/badass/random
	name = "Random Item (??)"
	item = /obj/item/weapon/storage/box/syndicate
	cost = 0

/datum/uplink_item/badass/random/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)

	var/list/buyable_items = get_uplink_items()
	var/list/possible_items = list()

	for(var/category in buyable_items)
		for(var/datum/uplink_item/I in buyable_items[category])
			if(I == src)
				continue
			if(I.cost > U.uses)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		U.uses -= max(0, I.cost)
		feedback_add_details("traitor_uplink_items_bought","RN")
		return new I.item(loc)
