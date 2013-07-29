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
	category = "Conspicuous and Dangerous Weapons"

/datum/uplink_item/dangerous/revolver
	name = "Fully Loaded Revolver"
	desc = "A traditional handgun which fires .357 rounds. Has 7 chambers. Can down an unarmoured target with two shots."
	item = /obj/item/weapon/gun/projectile
	cost = 6

/datum/uplink_item/dangerous/ammo
	name = "Ammo-357"
	desc = "Seven additional rounds for the revolver. Reports indicate the presence of machinery aboard Nanotrasen space stations suitable for producing extra .357 cartridges."
	item = /obj/item/ammo_magazine/a357
	cost = 2

/datum/uplink_item/dangerous/crossbow
	name = "Miniature Energy Crossbow"
	desc = "A miniature energy crossbow that is small enough both to fit into a pocket and to slip into a backpack unnoticed by observers. Fires bolts tipped with toxin, a poisonous substance that is the product of a living organism. Stuns enemies for a short period of time. Recharges automatically."
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 5

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "A damaging melee weapon. While inactive, it is small enough to be pocketed. Activating this weapon is loud."
	item = /obj/item/weapon/melee/energy/sword
	cost = 4

/datum/uplink_item/dangerous/emp
	name = "A box of 5 EMP Grenades"
	desc = "Electromagnetic pulse grenades cause transient disturbance on detonation, damaging electronic equipment."
	item = /obj/item/weapon/storage/box/emps
	cost = 3

/datum/uplink_item/dangerous/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "A handheld fragmentation grenade. Has a five second timer."
	item = /obj/item/weapon/grenade/syndieminibomb
	cost = 3

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/para_pen
	name = "Paralysis Pen"
	desc = "A syringe disguised as a pen, filled with a neuromuscular-blocking drug that renders a target immobile upon injection. The target will appear dead to observers. Side-effects of the drug include noticeable drooling, as subjects are unable to swallow their saliva. Health analysers are able to see past the muscle relaxant's effects. The pen only holds enough paralyzing agent for one dose, and cannot be refilled."
	item = /obj/item/weapon/pen/paralysis
	cost = 3

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "Useful for cleaning up bloodstains to prevent forensics from analysing them for their DNA content. Can be thrown underfoot to slip crew."
	item = /obj/item/weapon/soap/syndie
	cost = 1

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "Inserting this cartridge into your PDA will give you five opportunities to detonate the PDAs of crewmembers who have their messaging feature enabled. The concussive effect from the explosion will knock them out for a short period of time, and deafen them for longer."
	item = /obj/item/weapon/cartridge/syndicate
	cost = 3


// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "A jumpsuit used to disguise as various jobs aboard the station by mimicking their appropriate uniforms."
	item = /obj/item/clothing/under/chameleon
	cost = 3

/datum/uplink_item/stealthy_tools/syndigolashes
	name = "No-Slip Brown Syndicate Shoes"
	desc = "Useful for slipping opponents without being slipped yourself."
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 2

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "An identification card that prevents the AI from tracking you, and can copy access from other ID cards. The access is cumulative, so scanning one card won't erase the access gained from another."
	item = /obj/item/weapon/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	item = /obj/item/clothing/mask/gas/voice
	desc = "A conspicuous gas mask that mimics the voice of the person named on the wearer's ID card. Functions as a voice distorter when no ID is worn."
	cost = 4

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Disguises the user as any handheld object. While disguised, the user can only move at walking pace, and projectiles will pass over them."
	item = /obj/item/device/chameleon
	cost = 4

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Camera Bug"
	desc = "Allows an agent to bug cameras, to make them viewable remotely. Highly moddable, adding certain items to it alters its functions."
	item = /obj/item/device/camera_bug
	cost = 2

// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "Has a variety of effects when used on electronic devices. Breaks airlocks and secure closets open, albeit in a distinguishing way."
	item = /obj/item/weapon/card/emag
	cost = 3

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Syndicate Toolbox"
	desc = "A unique black and red toolbox that comes with tools, wires, and a multitool. Useful for both escape and infiltration. Agents are advised to acquire insulated gloves before attempting to hack electrical systems."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/space_suit
	name = "Syndicate Space Suit"
	desc = "A red syndicate space suit. It fits in backpacks, and has a slot for an agent's sidearm. NT crewmembers are trained to look out for agents in red space suits, so be careful."
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 3

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "Glasses that allow an agent to see organics and synthetics through walls. They do this by capturing the upper portion of the infrared light spectrum, which is emitted as heat by objects instead of simply reflected as light. Hotter objects, such as warm bodies and cyborgs, emit more of this light than cooler objects like walls and other structures."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 3

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into a radio headset, allows its wearer to listen to and converse on the binary frequency used by AIs and cyborgs. Nanotrasen do not posess this technology, so an agent can expect Asimov synthetics to report them to security if they converse with the AI or cyborgs using it."
	item = /obj/item/device/encryptionkey/binary
	cost = 3

/datum/uplink_item/device_tools/ai_detector
	name = "Disguised AI Detector"
	desc = "A multitool that turns red when it detects an AI watching it or its holder. Useful for knowing when to behave. Functions as a regular multitool."
	item = /obj/item/device/multitool/ai_detect
	cost = 1

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	desc = "When used in conjuction with an AI upload console, this upload module allows the user to upload first priority laws to the AI. An agent is advised to be precise with the wording of their laws."
	item = /obj/item/weapon/aiModule/syndicate
	cost = 7

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "A common variety of the plastic explosive known as Composition C. Used by agents to breach walls. Can be attached to organics or synthetics to destroy them."
	item = /obj/item/weapon/plastique
	cost = 2

/datum/uplink_item/device_tools/powersink
	name = "Powersink"
	desc = "When screwed to wiring attached to an electrical grid, this large device places excessive load on the grid, causing an overcurrent. Due to the size of the sink, it cannot be carried. It is advised that it is only ordered in the area of its intended use."
	item = /obj/item/device/powersink
	cost = 5

/datum/uplink_item/device_tools/singularity_beacon
	name = "Singularity Beacon"
	desc = "Pulls singularities towards it. Has the capacity to cause massive damage to a space station, leading to a full emergency evacuation."
	item = /obj/item/device/sbeacondrop
	cost = 7

/datum/uplink_item/device_tools/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "A large explosive device that cannot fit into backpacks. Has an adjustable timer with a minimum setting of 30 seconds. Can be wrenched down to prevent removal. Possibility of defusal apparent."
	item = /obj/item/device/sbeacondrop/bomb
	cost = 5

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	desc = "Used to complete the teleporter onboard the syndicate mothership. Agents are advised to test fire the teleporter before entering it, as teleporter malfunctions can occur."
	item = /obj/item/weapon/circuitboard/teleporter
	cost = 20
	gamemodes = list("nuclear emergency")


// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant designed to be injected into an agent's body. When activated with a predefined gesture, the implant will attempt to remove an agent's restraints."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 3

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant designed to be injected into an agent's body. When activated with a predefined gesture, this implant will grant an agent access to a syndicate uplink with 5 telecrystals. Useful for escaping confinement."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 10


// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "A group of items, randomly chosen from a list of specialised bundles, which arrive in a plain box. These items are worth more than 10 telecrystals, but the agent does not know what specialisation they will receive."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 10

/datum/uplink_item/badass/balloon
	name = "For showing that You Are The Boss"
	desc = "A red balloon, with an easily recognisable syndicate logo on it. Designed to lower morale among NT employees, as an agent forgoing useful equipment for a pointless balloon is a sure sign of a badass."
	item = /obj/item/toy/syndicateballoon
	cost = 10

/datum/uplink_item/badass/random
	name = "Random Item (??)"
	desc = "This will send an agent a random item from the list. Useful for amateur agents that find the task ahead of them so daunting that they cannot think clearly enough to formulate a strategy to tackle it with."
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
