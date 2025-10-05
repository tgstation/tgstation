/datum/uplink_category/explosives
	name = "Explosives"
	weight = 6

/datum/uplink_item/explosives
	category = /datum/uplink_category/explosives

/datum/uplink_item/explosives/soap_clusterbang
	name = "Slipocalypse Clusterbang"
	desc = "A traditional clusterbang grenade with a payload consisting entirely of Syndicate soap. Useful in any scenario!"
	item = /obj/item/grenade/clusterbuster/soap
	cost = 1

/datum/uplink_item/explosives/c4
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, sabotage equipment, or connect \
			an assembly to it in order to alter the way it detonates. It can be attached to almost all objects and has a modifiable timer with a \
			minimum setting of 10 seconds."
	item = /obj/item/grenade/c4
	cost = 1

/datum/uplink_item/explosives/x4
	name = "Composition X-4"
	desc = "Similar to C4, but with a stronger blast that is directional instead of circular. X-4 can be placed on a solid surface, such as a wall or window, \
		and it will blast through the wall, injuring anything on the opposite side, while being safer to the user. For when you want a controlled explosion that \
		leaves a wider, deeper, hole."
	item = /obj/item/grenade/c4/x4
	cost = 2
	limited_stock = 5
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS //nukies get their own version

/datum/uplink_item/explosives/c4bag
	name = "Bag of C-4 explosives"
	desc = "Because sometimes quantity is quality. Contains 10 C-4 plastic explosives."
	item = /obj/item/storage/backpack/duffelbag/syndie/c4
	cost = 5 // 50% discount!
	cant_discount = TRUE
	limited_stock = 2
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS //nukies get their own version

/datum/uplink_item/explosives/frag
	name = "Frag Grenade"
	desc = "A frag grenade. Pop the pin. Throw towards enemy. Keep clear of the shrapnel. Easy!"
	item = /obj/item/grenade/frag
	cost = 1
	limited_stock = 10
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS //nukies get a whole box of these at once at a considerable discount.

/datum/uplink_item/explosives/detomatix
	name = "Detomatix disk"
	desc = "When inserted into a tablet, this cartridge gives you four opportunities to \
			detonate tablets of crewmembers who have their message feature enabled. \
			The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer."
	item = /obj/item/computer_disk/virus/detomatix
	cost = 6
	restricted = TRUE

/datum/uplink_item/explosives/emp
	name = "EMP Grenades and Implanter Kit"
	desc = "A box that contains five EMP grenades and an EMP implant with three uses. Useful to disrupt communications, \
			security's energy weapons and silicon lifeforms when you're in a tight spot."
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 2

/datum/uplink_item/explosives/emp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

/datum/uplink_item/explosives/smoke
	name = "Smoke Grenades"
	desc = "A box that contains five smoke grenades a smoke implant with three uses and a gas smask. For when you want to sow discord, vanish \
		without a trace, or run with your arms awkwardly trailing behind you."
	item = /obj/item/storage/box/syndie_kit/smoke
	cost = 2

/datum/uplink_item/explosives/pizza_bomb
	name = "Pizza Bomb"
	desc = "A pizza box with a bomb cunningly attached to the lid. The timer needs to be set by opening the box; afterwards, \
			opening the box again will trigger the detonation after the timer has elapsed. Comes with free pizza, for you or your target!"
	item = /obj/item/pizzabox/bomb
	cost = 2
	limited_stock = 4
	surplus = 8
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS /// Ops get their own version.

/datum/uplink_item/explosives/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The minibomb is a grenade with a five-second fuse. Upon detonation, it will create a small hull breach \
			in addition to dealing high amounts of damage to nearby personnel."
	progression_minimum = 30 MINUTES
	item = /obj/item/grenade/syndieminibomb
	cost = 2
	limited_stock = 4
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS /// Ops get their own version.

/datum/uplink_item/explosives/syndicate_bomb/emp
	name = "Syndicate EMP Bomb"
	desc = "A variation of the syndicate bomb designed to produce a large EMP effect."
	item = /obj/item/sbeacondrop/emp
	cost = 7
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS /// Ops get their own version.
	limited_discount_stock = 4

/datum/uplink_item/explosives/syndicate_bomb/emp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 2

/datum/uplink_item/explosives/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate bomb is a fearsome device capable of massive destruction. It has an adjustable timer, \
		with a minimum of %MIN_BOMB_TIMER seconds, and can be bolted to the floor with a wrench to prevent \
		movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
		transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
		be defused, and some crew may attempt to do so. \
		The bomb core can be pried out and manually detonated with other explosives."
	progression_minimum = 30 MINUTES
	item = /obj/item/sbeacondrop/bomb
	cost = 11
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS /// Ops get their own version.
	limited_discount_stock = 4

/datum/uplink_item/explosives/syndicate_bomb/New()
	. = ..()
	desc = replacetext(desc, "%MIN_BOMB_TIMER", SYNDIEBOMB_MIN_TIMER_SECONDS)

/datum/uplink_item/dangerous/cat
	name = "Feral Cat Grenade Box"
	desc = "This box contains 5 grenades filled with 5 feral cats in stasis. Upon activation, the feral cats are awoken and unleashed unto unlucky bystanders. WARNING: The cats are not trained to discern friend from foe!"
	cost = 5
	item = /obj/item/storage/box/syndie_kit/feral_cat_grenades
	surplus = 30
	limited_stock = 2
	purchasable_from = ~UPLINK_ALL_SYNDIE_OPS
