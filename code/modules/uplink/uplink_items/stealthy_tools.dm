/datum/uplink_category/stealthy_tools
	name = "Stealth Gadgets"
	weight = 5

/datum/uplink_item/stealthy_tools
	category = /datum/uplink_category/stealthy_tools


/datum/uplink_item/stealthy_tools/spy_bug
	name = "Box of Spy Bugs"
	desc = "A box of 10 spy bugs. These attach onto the target invisibly and cannot be removed, and broadcast all they hear to the secure syndicate channel.\
	Can be attached to animals and objects. Does not come with a syndicate encryption key."
	item = /obj/item/storage/box/syndie_kit/bugs
	cost = 1

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent Identification Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and hold up to 5 wildcards \
			from other identification cards. In addition, they can be forged to display a new assignment, name and trim. \
			This can be done an unlimited amount of times. Some Syndicate areas and devices can only be accessed \
			with these cards."
	item = /obj/item/card/id/advanced/chameleon
	cost = 2

/datum/uplink_item/stealthy_tools/ai_detector
	name = "Artificial Intelligence Detector"
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it, and can be \
			activated to get an rough estimate of the AI's presence. Knowing when \
			an artificial intelligence is watching you is useful for knowing when to maintain cover."
	item = /obj/item/multitool/ai_detect
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	cost = 1

/datum/uplink_item/stealthy_tools/shadowcloak
	name = "Cloaker Belt"
	desc = "A tactical belt that renders the wearer invisible while active. Has a short charge that is refilled in darkness; only charges when in use."
	item = /obj/item/storage/belt/military/shadowcloak
	cost = 15
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_tools/nuclearshadowcloak
	name = "Cloaker Belt"
	desc = "A tactical belt that renders the wearer invisible while active. Has a short charge that is refilled in darkness; only charges when in use."
	item = /obj/item/storage/belt/military/shadowcloak
	cost = 20
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_tools/syndireverse
	name = "Bluespace Projectile Weapon Disrupter"
	desc = "Hidden in an ordinary-looking playing card, this device will teleport an opponent's gun to your hand when they fire at you. Just make sure to hold this in your hand!"
	item = /obj/item/syndicateReverseCard
	cost = 4

/datum/uplink_item/stealthy_tools/chameleon
	name = "Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping and skillchips are sold separately."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 2
	purchasable_from = ~UPLINK_NUKE_OPS //clown ops are allowed to buy this kit, since it's basically a costume

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "No-Slip Chameleon Shoes"
	desc = "These shoes will allow the wearer to run on wet floors and slippery objects without falling down. \
			They do not work on heavily lubricated surfaces."
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't \
			move the projector from their hand. Disguised users move slowly, and projectiles pass over them."
	item = /obj/item/chameleon
	cost = 7

/datum/uplink_item/stealthy_tools/codespeak_manual
	name = "Codespeak Manual"
	desc = "Syndicate agents can be trained to use a series of codewords to convey complex information, which sounds like random concepts and drinks to anyone listening. \
			This manual teaches you this Codespeak. You can also hit someone else with the manual in order to teach them. This is the deluxe edition, which has unlimited uses."
	item = /obj/item/language_manual/codespeak_manual/unlimited
	cost = 3

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "A small, self-recharging, short-ranged EMP device disguised as a working flashlight. \
			Useful for disrupting headsets, cameras, doors, lockers and borgs during stealth operations. \
			Attacking a target with this flashlight will direct an EM pulse at it and consumes a charge."
	item = /obj/item/flashlight/emp
	cost = 4
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

/datum/uplink_item/stealthy_tools/mulligan
	name = "Mulligan"
	desc = "Screwed up and have security on your tail? This handy syringe will give you a completely new identity \
			and appearance."
	item = /obj/item/reagent_containers/syringe/mulligan
	cost = 4
	surplus = 30
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/jammer
	name = "Radio Jammer"
	desc = "This device will disrupt any nearby outgoing radio communication when activated. Does not affect binary chat."
	item = /obj/item/jammer
	cost = 5

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling; great for stashing \
			your stolen goods. Comes with a crowbar, a floor tile and some contraband inside."
	item = /obj/item/storage/backpack/satchel/flat/with_tools
	cost = 1
	surplus = 30
	illegal_tech = FALSE

/datum/uplink_item/stealthy_tools/mousecubes
	name = "Box of Mouse Cubes"
	desc = "A box with twenty four Waffle Co. brand mouse cubes. Deploy near wiring. \
			Caution: Product may rehydrate when exposed to water."
	item = /obj/item/storage/box/monkeycubes/syndicate/mice
	cost = 1

/datum/uplink_item/stealthy_tools/angelcoolboy
	name = "Angelic Potion"
	desc = "After many failed attempts, the syndicate has reverse engineered an angel potion smuggled off of the lava planet V-227. \
			Those who drink the contents of the bottle provided will immediately sprout wings capable of sustained flight. Wings may vary in appearance."
	cost = 2
	item = /obj/item/reagent_containers/cup/bottle/potion/flight

/datum/uplink_item/stealthy_tools/mail_counterfeit
	name = "GLA Brand Mail Counterfeit Device"
	desc = "A device capable of counterfeiting NT's mail. This device is also able to place a trap within the mail for... malicious actions. The trap will \"activate\" any item inside of mail. Also it might be used for contraband purposes. Integrated micro-computer will give you great configuration optionality for your needs."
	item = /obj/item/storage/mail_counterfeit_device
	cost = 1
	surplus = 30

/datum/uplink_item/stealthy_tools/nocturine
	name = "Nocturine Bottle"
	desc = "A bottle containing 30 units of Nocturine, a chemical agent capable of robbing any living organism's conscience from it extremely quickly -- even in small doses."
	item = /obj/item/reagent_containers/glass/bottle/nocturine
	cost = 3
	surplus = 40

/datum/uplink_item/stealthy_tools/bluespace_chameleon_backpack
	name = "Bluespace Chameleon Backpack"
	desc = "A backpack outfitted with both chameleon and bluespace technology. The backpack can match any desired appearance and typically hold more than a duffel bag would."
	item = /obj/item/storage/backpack/bluespacechameleon
	cost = 4
	surplus = 30

/datum/uplink_item/stealthy_tools/syndistache
	name = "Syndicate Moustache"
	desc = "A moustache to prevent people from recognizing you. Be sure to conceal your real identification card or it won't work. \
			The moustache provided is completely fire proof, and has minor protection technology installed to aid you should you be found out. \
			Also allows you to properly use internals, and even has a slot for smoking cigarettes."
	item = /obj/item/clothing/mask/fakemoustache/syndicate
	cost = 3
	surplus = 50

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	desc = "A mask with voice changing capabilities and chameleon technology, it'll change your voice automatically to match the appearance or ID you have. Be sure to conceal your real identity or it won't work."
	item = /obj/item/clothing/mask/chameleon
	cost = 1
	surplus = 50

/datum/uplink_item/stealthy_tools/chameleon_tie
	name = "Chameleon Storage Tie"
	desc = "A tie fitted with our chameleon technology, it also has several pockets within it for additional storage."
	item = /obj/item/storage/chameleonstoragetie
	cost = 2
	surplus = 35

/datum/uplink_item/stealthy_tools/desynchronizer
	name = "Desynchronizer"
	desc = "An experimental device that can temporarily desynchronize the user from spacetime, effectively making them disappear while it's active. \
			Beware that this device can be used for a total of 5 minutes, but the cooldown will always be for as long as it was previously used."
	item = /obj/item/desynchronizer
	cost = 4
	surplus = 20
	illegal_tech = TRUE
/**
/datum/uplink_item/stealthy_tools/pseudocider
	name = "Pseudocider"
	desc = "Disguised as a common pocket watch, the pseudocider will convincingly feign your fall, making you invisible \
			and completely silent as you slip away from the scene, or into a better position! You will not be able to take \
			any actions for the 7 second duration."
	item = /obj/item/pseudocider
	cost = 6
	surplus = 20
	purchasable_from = ~UPLINK_NUKE_OPS
**/
/datum/uplink_item/stealthy_tools/bluespace_briefcase
	name = "Bluespace Briefcase"
	desc = "One of our secure briefcases, it's been fitted with bluespace technology allowing it to hold even the bulkiest of items \
			in addition to holding far more than it should normally allow. It's also been fitted with lavaproofing, fireproofing, and acidproofing. \
			Take care to not allow security to read it's protection classes tag, or they may not give it back. This briefcase packs a bit more of a punch as usual."
	item = /obj/item/storage/briefcase/secure/bluespace
	cost = 2
	surplus = 30

/datum/uplink_item/stealthy_tools/target_tracker
	name = "Target Tracker"
	desc = "One of Nanotrasen's crew pinpointers smuggled out by our agents and repurposed by our programmers. \
			It's capable of detecting and tracking suit sensors (regardless of the level they're set to) AND tracking implants."
	item = /obj/item/pinpointer/crew/syndicate
	cost = 3
	surplus = 0
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/tracking_implants
	name = "Box of Tracking Implants"
	desc = "A box containing SIX of our finest tracking implants, undetectable except through SecHUDs. \
			The implanter included can be used extremely quickly and isn't noticeable by the implantee or on-lookers."
	item = /obj/item/storage/box/syndie_kit/trackingimplants
	cost = 1
	surplus = 0
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/thievesgloves
	name = "Thieves Gloves"
	desc = "A pair of insulated combat gloves which are fitted with our chameleon technology. \
			It also has several bluespace pockets within it for additional storage. Comes with a screwdriver, multitool, and a crowbar."
	item = /obj/item/storage/box/syndie_kit/thievesgloves
	cost = 1
	surplus = 20

/datum/uplink_item/stealthy_tools/holodisguiser
	name = "Holographic Disguiser"
	desc = "A peculiar device modeled after extensive research into stabilized green extracts. \
			While held, or within your backpack the device will automatically activate, projecting a false appearance AND voice. \
			Excellent for mulligan tactics, pair with a Agent Identification Card and Chameleon Kit for an excellent combo."
	item = /obj/item/holodisguiser
	cost = 4
	surplus = 40

/datum/uplink_item/stealthy_tools/manifest_spoofer
	name = "Crew Manifest Spoofer"
	desc = "A signaler capable of copying your current identity straight to the crew manifest of the station. \
			Goes hand-in-hand with mulligan tactics. Can be used once every 20 minutes."
	item = /obj/item/manifest_spoofer
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/lightbreaker
	name = "Light Breaker"
	desc = "A sonic device concealed as a universal tape recorder. When activated, it emits a screeching sound capable of \
			shattering all light tubes or bulbs near the user, the sound is horribly loud to all nearby, causing all without ear protection to crumble \
			to the ground in pain for a short time. Can be used four times, but can be rewound with a screwdriver at the cost of it's stability. \
			Has no recording capablilities, and won't hold up well to scrutiny by security officers or detectives."
	item = /obj/item/lightbreaker
	cost = 4
	surplus = 30
	purchasable_from = ~UPLINK_SPY
