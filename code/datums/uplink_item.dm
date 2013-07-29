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
	var/desc = "item description"
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
	desc = "A projectile velocitor. Holds seven rounds, 'cause it's nice. One in the chamber, six in the revolver. Two in the face and they'll fall over."
	item = /obj/item/weapon/gun/projectile
	cost = 6

/datum/uplink_item/dangerous/ammo
	name = "Ammo-357"
	desc = "These are revolver bullets. If you don't have a revolver, don't buy these. If you do have a revolver, consider a more renewable source of ammunition for it. Think. Act. Save."
	item = /obj/item/ammo_magazine/a357
	cost = 2

/datum/uplink_item/dangerous/crossbow
	name = "Energy Crossbow"
	desc = "Fires toxin darts that cause a lengthy stun. Fools won't see you bagging it, or know whose dart it was that hit them. Pocketable. Synthesises ammunition over time."
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 5

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "Loud as fuck and used in six space wars, this energy sword not only burns holes in people, it's great for cutting vegetables."
	item = /obj/item/weapon/melee/energy/sword
	cost = 4

/datum/uplink_item/dangerous/emp
	name = "5 EMP Grenades"
	desc = "These grenades short out power. They stun cyborgs, electrify airlocks, temporarily disable cameras, and lower firedoors. You only get 5, because they're two grand a piece."
	item = /obj/item/weapon/storage/box/emps
	cost = 3

/datum/uplink_item/dangerous/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "Useful for when your target is reading or something. Just like they taught you in movies: pull the pin, then throw. We don't recommend holding a primed Minibomb for longer than five seconds."
	item = /obj/item/weapon/grenade/syndieminibomb
	cost = 3

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/para_pen
	name = "Paralysis Pen"
	desc = "Stick 'em with the pointy end, and they'll look dead. Goes through armour, as the pen is mightier than the armour. Your target will drool a little, so bring some tissues. Also works as a pen!"
	item = /obj/item/weapon/pen/paralysis
	cost = 3

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "Specially formulated to remove even the toughest of blood stains. Try not to step on it."
	item = /obj/item/weapon/soap/syndie
	cost = 1

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "Takes blowing up someone's phone to a whole nother level. Comes with 5 charges. Don't expect any fatalities from this, though it may make a target vulnerable for a short period of time."
	item = /obj/item/weapon/cartridge/syndicate
	cost = 3


// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "A jumpsuit that can change its appearance to mimic the jumpsuits of NT's crew. Don't wear this around EMPs, unless you're on your way to a discotheque."
	item = /obj/item/clothing/under/chameleon
	cost = 3

/datum/uplink_item/stealthy_tools/syndigolashes
	name = "No-Slip Syndicate Shoes"
	desc = "Brown shoes that prevent slipping. Useful for navigating slippery floors. Perhaps you made the slippery floors. Perhaps the slippery floors were outside security. Perhaps you rendered the HoS into a floorbound pile of leather? Now you're thinking with clowns."
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 2

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "A card which makes you untrackable by the AI, and can copy access from other ID cards. The access accumulates, so collect them all."
	item = /obj/item/weapon/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	desc = "A creepy-looking gas mask that mimics the voice of the crewmember named on your ID card. If you aren't wearing an ID, it will simply anonymise your voice, which isn't suspicious at all."
	cost = 4

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Scan an object with this, activate the projector, and suddenly you look like that object! While disguised as an object, you can only move at walking speed, and projectiles pass over you."
	item = /obj/item/device/chameleon
	cost = 4

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Camera Bug"
	desc = "An item which allows you to bug cameras, to make them viewable remotely. Highly moddable, adding certain items to it alters its functions."
	item = /obj/item/device/camera_bug
	cost = 2

// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "Breaks locked doors and lockers open, at the cost of breaking them open. Try not to leave a trail of busted airlocks in your wake. Has a variety of effects when used on machines and consoles."
	item = /obj/item/weapon/card/emag
	cost = 3

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "A suspicious black toolbox (blue paint is expensive) that comes with tools, wires, and a multitool. Useful for hacking, construction, and deconstruction. Doesn't come with insulated gloves, though."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/space_suit
	name = "Space Suit"
	desc = "A red syndicate space suit. Fits in bags, and has a slot designed to hold a weapon. NT crewmembers are trained to look out for people wearing these, so be careful."
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 3

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "Thermals disguised as Optical Meson Scanners. They make organic and synthetic lifeforms visible through walls. Very useful for stealth specialists. Cannot see inside closets. Don't ask, don't tell."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 3

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into your headset, allows you to listen to and converse on the binary frequency of AIs and cyborgs. NT do not have this technology, so expect Asimov synthetics to out you if you talk to them using it."
	item = /obj/item/device/encryptionkey/binary
	cost = 3

/datum/uplink_item/device_tools/ai_detector
	name = "Disguised AI Detector"
	desc = "A multitool that turns red when it detects an AI watching it. Useful for keeping tabs on Big Brother keeping tabs on you. Also functions as an honest to Space God multitool."
	item = /obj/item/device/multitool/ai_detect
	cost = 1

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	desc = "When used in conjuction with an AI upload console, this upload module allows the user to upload first priority laws to the AI. Hope you can spell!"
	item = /obj/item/weapon/aiModule/syndicate
	cost = 7

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "A common variety of the plastic explosive known as Composition C. Useful for breaching walls. Able to be attached to organics or synthetics to create a mess."
	item = /obj/item/weapon/plastique
	cost = 2

/datum/uplink_item/device_tools/powersink
	name = "Powersink"
	desc = "When screwed to a wire attached to an electrical grid, this bulky device sucks all the power out of it. Don't order this in public, numbnuts. You think you've got problems with pocket spaghetti, try pocket powersinks."
	item = /obj/item/device/powersink
	cost = 5

/datum/uplink_item/device_tools/singularity_beacon
	name = "Singularity Beacon"
	desc = "Pulls singularities towards it. Useful for bringing the station to its knees. Expect the emergency shuttle to be called."
	item = /obj/item/device/sbeacondrop
	cost = 7

/datum/uplink_item/device_tools/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "'Oh my Space God, Captain, a bomb!' Wrench this down, unless you want the mime to push it out of an airlock."
	item = /obj/item/device/sbeacondrop/bomb
	cost = 5

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	desc = "Used to complete the teleporter on your mothership. Always test before using, as syndicate health coverage does not extend to fly monstrosities."
	item = /obj/item/weapon/circuitboard/teleporter
	cost = 20
	gamemodes = list("nuclear emergency")


// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "Pull a facial muscle to slip off your cuffs!"
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 3

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant containing 5 telecrystals, this allows you to order items on the go. Works well in conjunction with tubed yoghurt. Useful if you plan on jailtime."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 10


// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "A box of crap that's been sitting in my office for some time now. Some of this shit is not standard issue, and probably amounts to more than your allotted allowance. But I'm nice, you can have it."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 10

/datum/uplink_item/badass/balloon
	name = "For showing that You Are The Boss"
	desc = "It's a balloon. Has the easily recognisable syndicate logo on it. Cannot be popped, and the helium will never escape. Great for parties on the mothership."
	item = /obj/item/toy/syndicateballoon
	cost = 10

/datum/uplink_item/badass/random
	name = "Random Item (??)"
	desc = "Spin the wheel! Try not to end up with bullets for a gun you don't have!"
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
