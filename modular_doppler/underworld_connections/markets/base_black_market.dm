// This file contains a WHOLE BUNCH of cost defuckulations to bring the ancient black market stuff back into line with our current cargo pricing.
// I've also taken the liberty of redoing a few descs because man they kinda suck.
// Some availability_probs have been upped considerably for items that I think should be core to the "dodgy" character archetype, like switchblades, science goggles and the various maintenance pills.

// CLOTHING

/datum/market_item/clothing/ninja_mask
	price_min = PAYCHECK_CREW
	price_max = PAYCHECK_CREW * 3

/datum/market_item/clothing/durathread_vest
	desc = "Concerns about high asbestos content are completely unfounded. Note: may contain asbestos."
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 1.5

/datum/market_item/clothing/durathread_helmet
	desc = "Smells faintly like an icewalker. Weird. Goes on your head and is vaguely armoured. Note: may contain asbestos."
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 1.5

/datum/market_item/clothing/full_spacesuit_set
	desc = "Decommissioned thirty years ago, boxes of these ancient spaceproof relics keep showing up in warehouses somewhere. They're \"old style\"."
	price_min = PAYCHECK_CREW * 6
	price_max = PAYCHECK_CREW * 12

/datum/market_item/clothing/chameleon_hat
	desc = "Emulate the appearance of any hat in the sector! Warning: device not quality tested. \[REDACTED\] assumes no risk for malfunction or mortal injury."
	price_min = PAYCHECK_CREW
	price_max = PAYCHECK_CREW * 3

/datum/market_item/clothing/rocket_boots
	price_min = PAYCHECK_CREW * 6
	price_max = PAYCHECK_CREW * 12

/datum/market_item/clothing/anti_sec_pin
	price_min = PAYCHECK_CREW
	price_max = PAYCHECK_CREW * 3
	availability_prob = 100 //it's funny so why not

// CONSUMABLES
/datum/market_item/consumable/clown_tears
	desc = "Wrung by force from ethically-sourced clowns by your local jester. 100% guaranteed baton free."
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 1.5

/datum/market_item/consumable/donk_pocket_box
	price_min = PAYCHECK_CREW * 0.3
	price_max = PAYCHECK_CREW * 1
	availability_prob = 100 //you can always afford some (illegal) donkpockets. Donk Co loves you.

/datum/market_item/consumable/suspicious_pills
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 1.5

/datum/market_item/consumable/floor_pill
	desc = "Harvested daily by responsibly-paid assistants, this pill is guaranteed to a) have been on the floor, and b) is a pill. Good luck!"
	price_min = PAYCHECK_CREW * 0.1
	price_max = PAYCHECK_CREW * 0.3
	availability_prob = 100 // no shortage of unmarked pills babyyyy

/datum/market_item/consumable/pumpup
	desc = "Clean-up crews sell off these things by the dozen after every shift - get your hands on some today! What could possibly go wrong with maintenance drugs?"
	price_min = PAYCHECK_CREW * 0.2
	price_max = PAYCHECK_CREW * 0.4

// MISCELLANEOUS

/datum/market_item/misc/clear_pda
	desc = "Clearly show your appreciation for style with this limited edition clear PDA!"
	price_min = PAYCHECK_CREW
	price_max = PAYCHECK_CREW * 2

/datum/market_item/misc/jade_lantern
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW

/datum/market_item/misc/cap_gun
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW

/datum/market_item/misc/shoulder_holster
	name = "Shoulder Holster"
	//why in great googly moogly were these so expensive? what the fuck?
	price_min = PAYCHECK_CREW * 0.2
	price_max = PAYCHECK_CREW * 0.6

/datum/market_item/misc/donk_recycler
	price_min = PAYCHECK_CREW * 2
	price_max = PAYCHECK_CREW * 4

/datum/market_item/misc/shove_blocker
	// ok this is a seriously fucking good module so we'll make it cost a bit
	price_min = PAYCHECK_CREW * 8
	price_max = PAYCHECK_CREW * 14

/datum/market_item/misc/holywater
	desc = "The Spinward Independent Magicians assume no responsibility for the holy (or unholiness) of this magical reagent."
	price_min = PAYCHECK_CREW
	price_max = PAYCHECK_CREW * 3

/datum/market_item/misc/strange_seed
	desc = "Exotic varieties of seed outlawed in most sectors, including this one. What's the worst that could happen?"
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW

/datum/market_item/misc/smugglers_satchel
	//inventory gamers...
	price_min = PAYCHECK_CREW * 3
	price_max = PAYCHECK_CREW * 6

/datum/market_item/misc/roulette
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 6 // it's how the chips fall babyyy

/datum/market_item/misc/jawed_hook
	desc = "If you're struggling with the fishes, give 'em the jaws, see?"
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 1.5

/datum/market_item/misc/v8_engine
	name = "Genuine V8 Engine (Preserved)"
	price_min = PAYCHECK_CREW * 6
	price_max = PAYCHECK_CREW * 12

/datum/market_item/misc/fish
	name = "Case of Smuggled Fish"
	desc = "What makes these fish such hot products? We'd have to kill you if we told you."

// TOOLS
/datum/market_item/tool/caravan_wrench
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 2
	availability_prob = 100 // let's have all the experimental tools be always available, because why not?

/datum/market_item/tool/caravan_wirecutters
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 2
	availability_prob = 100

/datum/market_item/tool/caravan_screwdriver
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 2
	availability_prob = 100

/datum/market_item/tool/caravan_crowbar
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 2
	availability_prob = 100

/datum/market_item/tool/binoculars
	//we can roundstart with these so let's tone them way down
	desc = "Offworld military surplus. They'll never see you coming."
	price_min = PAYCHECK_CREW * 0.2
	price_max = PAYCHECK_CREW * 0.5

/datum/market_item/tool/riot_shield
	desc = "Bloodstains not included."
	price_min = PAYCHECK_CREW * 4
	price_max = PAYCHECK_CREW * 8

/datum/market_item/tool/thermite_bottle
	desc = "Fifty galactic units of an incendiary compound that will burn through just about anything."
	price_min = PAYCHECK_CREW * 2
	price_max = PAYCHECK_CREW * 6

/datum/market_item/tool/fake_scanner
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 2

/datum/market_item/tool/program_disk
	name = "Bootleg PDA Data Disk"
	desc = "Contains a random selection of limited PDA programs purloined by bitrunners from the FTU. Wait, we're not supposed to tell you that."
	price_min = PAYCHECK_CREW * 1.5
	price_max = PAYCHECK_CREW * 3
	availability_prob = 100 // not every program is useful but some of these are and they're fun and hackery, so why not?

// WEAPONS

/datum/market_item/weapon/bear_trap
	price_min = PAYCHECK_CREW * 2
	price_max = PAYCHECK_CREW * 4

/datum/market_item/weapon/shotgun_dart
	price_min = PAYCHECK_CREW * 0.1
	price_max = PAYCHECK_CREW * 0.3

/datum/market_item/weapon/bone_spear
	price_min = PAYCHECK_CREW * 0.5
	price_max = PAYCHECK_CREW * 2

/datum/market_item/weapon/chainsaw
	desc = "Once used to fell trees on Gaia worlds, the humble chainsaw has come into its own as the premiere anti-mold device of the sector. And you can have one right now for one easy payment!"
	price_min = PAYCHECK_CREW * 2
	price_max = PAYCHECK_CREW * 4
	availability_prob = 75 // USE CHAINSAWS FOR MOLDS MORE OH MY GOD

/datum/market_item/weapon/switchblade
	// This is force 20 like the sabre/shamshir so price it similarly. Also, make it always available so you can shank people in maints.
	desc = "Standard-issue hardware for shifty goons sector-wide. Pointy and sharp."
	price_min = PAYCHECK_CREW * 4.25
	price_max = PAYCHECK_CREW * 8
	availability_prob = 100

/datum/market_item/weapon/emp_grenade
	desc = "The bane of synthetics and station-engineers everywhere."
	price_min = PAYCHECK_CREW * 1.5
	price_max = PAYCHECK_CREW * 5

/datum/market_item/weapon/fisher
	price_min = PAYCHECK_CREW * 4
	price_max = PAYCHECK_CREW * 8
