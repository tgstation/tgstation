/datum/uplink_category/special_kits
	name = "Special Kits"
	weight = 11

/datum/uplink_item/speckit
	category = /datum/uplink_category/special_kits

/datum/uplink_item/speckit/bond
	name = "Secret Agent Gear"
	desc = "A handgun & ammo, agent ID card, chameleon suit, stimulant pen, freedom implant, EMP flashlight, brick of \
		X4, a dishrag, a cyanide pill, and a deck of cards with which to sleuth your foes in poker - a customary set \
		of gear that harkens back to secret agents employed by governments like that of the Fourth Celestial Alignment."
	item = /obj/item/storage/box/syndicate/bundle/bond
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/ninja
	name = "Ninja Tools"
	desc = "A katana, throwing stars, stimulant pen, chameleon belt, doorjack card, agent ID, jump boots, chameleon device, \
		and a mighty book that teaches the user how to throw an efficient smokebomb, a staple of ancient ninja groups as \
		well as the modern Spider Clan."
	item = /obj/item/storage/box/syndicate/bundle/ninja
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/sith
	name = "Dark Lord's Panoply"
	desc = "An evil-looking double-bladed energy sword, alongside a set of telekinetic abilities that allow an individual to \
		manipulate objects from a distance, recall their weapon to their hand, or cast deadly bolts of lightning. Also comes \
		with an agent ID card, no-slip shoes, and an incredibly sinister hooded robe."
	item = /obj/item/storage/box/syndicate/bundle/sith
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/ahab
	name = "Whale Hunter's Armory"
	desc = "A harpoon gun, alongside a quiver of harpoons with which to fire, a carp-skin spacesuit, a carp grenade, and a dehydrated \
		space carp for you to re-hydrate and utilize as your own spacefaring battle mount. Legends say this outfit is similar to \
		gear once used by hunters looking for a mythical space whale."
	item = /obj/item/storage/box/syndicate/bundle/ahab
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/scientist
	name = "Mad Scientist's Tools"
	desc = "An evil-ass green labcoat, dark boots, a megaphone, and a pair of random cluster explosives, alongside a bioterror grenade, \
		energy dagger, Syndicate toolbox, wormhole gun, and a set of signallers for your dastardly armament. You could have anything \
		from a cluster of soap spewers to incendiary plasmafire grenades, so caution is certainly advised."
	item = /obj/item/storage/box/syndicate/bundle/scientist
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/bee
	name = "Bee Warrior's Weaponry"
	desc = "Comes with a bee costume, beesease bottle, deadly bee stinger blade, and a pair of ultra-powerful bee grenades that contain \
		chemically-infused bees conditioned to sting aggressively. The hive shall never perish so long as the warrior remains stalwart!"
	item = /obj/item/storage/box/syndicate/bundle/bees
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/freeze
	name = "Sub-Zero Specialist Gear"
	desc = "Cold-insulated clothing, a chameleon mask, a set of freezing gluon grenades, a freezing temperature gun, a cryo laser gun, a \
		blue energy sword, and a deadly pair of cryo & gelda-kinetic abilities, certain to help any field operative ensure those around \
		them can properly chill out."
	item = /obj/item/storage/box/syndicate/bundle/freeze
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/deadmoney
	name = "Criminal Mastermind Toolset"
	desc = "A specialist MODsuit, agent ID, chameleon mask, radio jammer, contractor baton, crew pinpointer, a signaller kit, and a deadly set \
		of explosive collars, perfect for subduing others and having them do your bidding for you. Does not come with willing operatives by \
		default; these must be 'acquired' in the field with the use of provided tools."
	item = /obj/item/storage/box/syndicate/bundle/deadmoney
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/samfisher
	name = "Covert Operative Armory"
	desc = "A set of combat fatigues and armor, alongside night vision goggles, krav-maga combat gloves, and a belt of covert operative equipment \
		that includes a supressed pistol with a light-breaker attachment, two spare magazines, a doorjack card, and a combat knife. Rumor has it \
		that this equipment is inspired by an ancient government operative that remained peerless in his field of infiltration."
	item = /obj/item/storage/box/syndicate/bundle/samfisher
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/prophunt
	name = "Household Object Saboteur"
	desc = "Containing a chameleon device, doorjack card, stealth implant, handgun, and thermal goggles, this kit is designed for operatives that specialize \
		in hiding as mundane or otherwise unremarkable objects and props."
	item = /obj/item/storage/box/syndicate/bundle/prophunt
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/speckit/original
	name = "Ancient Kit"
	desc = "An old-looking toolbox that contains the 'original' set of tools afforded to operatives in the field many many years ago. This includes a cryptographic \
		sequencer, a doorjack card (the original card used to do both!), a sleepy pen, a cyanide pill, a chameleon device, a freedom implant, and a .357 magnum \
		revolver. Also includes a single spare telecrystal with which to self-destruct your uplink."
	item = /obj/item/storage/toolbox/emergency/old/ancientbundle
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)
