/datum/uplink_category/explosives
	name = "Explosives"
	weight = 10

/datum/uplink_item/explosives
	category = /datum/uplink_category/explosives

/datum/uplink_item/explosives/soap_clusterbang
	name = "Slipocalypse Clusterbang"
	desc = "A traditional clusterbang grenade with a payload consisting entirely of Syndicate soap. Useful in any scenario!"
	item = /obj/item/grenade/clusterbuster/soap
	cost = 3

/datum/uplink_item/explosives/c4
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, sabotage equipment, or connect \
			an assembly to it in order to alter the way it detonates. It can be attached to almost all objects and has a modifiable timer with a \
			minimum setting of 10 seconds."
	item = /obj/item/grenade/c4
	cost = 1

/datum/uplink_item/explosives/c4bag
	name = "Bag of C-4 explosives"
	desc = "Because sometimes quantity is quality. Contains 10 C-4 plastic explosives."
	item = /obj/item/storage/backpack/duffelbag/syndie/c4
	cost = 8 //20% discount!
	cant_discount = TRUE

/datum/uplink_item/explosives/x4bag
	name = "Bag of X-4 explosives"
	desc = "Contains 3 X-4 shaped plastic explosives. Similar to C4, but with a stronger blast that is directional instead of circular. \
			X-4 can be placed on a solid surface, such as a wall or window, and it will blast through the wall, injuring anything on the opposite side, while being safer to the user. \
			For when you want a controlled explosion that leaves a wider, deeper, hole."
	progression_minimum = 20 MINUTES
	item = /obj/item/storage/backpack/duffelbag/syndie/x4
	cost = 4
	cant_discount = TRUE

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

/datum/uplink_item/explosives/pizza_bomb
	name = "Pizza Bomb"
	desc = "A pizza box with a bomb cunningly attached to the lid. The timer needs to be set by opening the box; afterwards, \
			opening the box again will trigger the detonation after the timer has elapsed. Comes with free pizza, for you or your target!"
	progression_minimum = 15 MINUTES
	item = /obj/item/pizzabox/bomb
	cost = 6
	surplus = 8

/datum/uplink_item/explosives/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The minibomb is a grenade with a five-second fuse. Upon detonation, it will create a small hull breach \
			in addition to dealing high amounts of damage to nearby personnel."
	progression_minimum = 30 MINUTES
	item = /obj/item/grenade/syndieminibomb
	cost = 6
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/syndicate_bomb/emp
	name = "Syndicate EMP Bomb"
	desc = "A variation of the syndicate bomb designed to produce a large EMP effect."
	item = /obj/item/sbeacondrop/emp
	cost = 7

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

/datum/uplink_item/explosives/syndicate_bomb/New()
	. = ..()
	desc = replacetext(desc, "%MIN_BOMB_TIMER", SYNDIEBOMB_MIN_TIMER_SECONDS)
/** Later.
/datum/uplink_item/explosives/trap_disk
	name = "Box of Syndicate Trapped Disks"
	desc = "Five bombs disguised as syndicate disks that triggers on removal or when tampered with. High-ranking Nanotrasen staff will likely be able to identify its true nature at a glance."
	item = /obj/item/storage/box/syndie_kit/trappeddisks
	cost = 2
	surplus = 10
**/
/datum/uplink_item/explosives/trickcigs
	name = "Trick Cigarettes"
	desc = "A normal cigarette packet containing 6 explosive cigarettes. They explode violently after they've been lit and put out. \
			Explosions are powerful enough to cause hull breaches, and cigarettes are lit for only 60 seconds before exploding. \
			Only contains 5 units of nicotine each."
	item = /obj/item/storage/fancy/cigarettes/trick_cigs
	cost = 2
	surplus = 40
	progression_minimum = 5 MINUTES

/datum/uplink_item/explosives/explosivepen
	name = "Explosive Pen"
	desc = "A normal black pen, it's been filled with explosives. Has a 5 second timer, and is completely silent when being armed. \
			The explosion is TINY but extremely powerful."
	item = /obj/item/pen/explosive
	cost = 1
	surplus = 60
	progression_minimum = 10 MINUTES
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/molotovs
	name = "Box of Molotovs"
	desc = "A box containing 8 homemade molotovs with each one containing a different flammable reagent. \
			Often useful for area denial. Comes with a lighter."
	item = /obj/item/storage/box/syndie_kit/molotovs
	cost = 1
	surplus = 30
	illegal_tech = FALSE

/datum/uplink_item/explosives/grenadierbelt
	name = "Grenadier Belt"
	desc = "A belt fully equipped with a plethora of dangerous explosive devices for mass-destruction and mayhem."
	item = /obj/item/storage/belt/grenade/full
	surplus = 1
	cost = 20
	illegal_tech = FALSE
	progression_minimum = 30 MINUTES
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/bioterrorfoam
	name = "Bioterror Foam Grenade"
	desc = "A powerful chemical foam grenade which creates a deadly torrent of foam that will mute, blind, confuse, \
			mutate, and irritate carbon lifeforms. Specially brewed by Tiger Cooperative chemical weapons specialists \
			using additional spore toxin. Ensure suit is sealed before use."
	item = /obj/item/grenade/chem_grenade/bioterrorfoam
	cost = 4
	surplus = 35
	progression_minimum = 10 MINUTES

/datum/uplink_item/explosives/saxitoxinnade
	name = "Saxitoxin Grenade"
	desc = "A smoke grenade containing Saxitoxin, a toxin capable of causing \
			brain damage, burn damage, AND toxin damage simultaneously to those who breathe it."
	item = /obj/item/grenade/chem_grenade/saxitoxin
	cost = 5
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/explosives/shrapnelgrenademega
	name = "FRAGmentation Grenade"
	desc = "A singular FRAGmentation Grenade. Anything adjacent when it explodes will likely get shredded to atoms. VERY Likely to kill anyone nearby. Has no additional explosive power."
	item = /obj/item/grenade/frag/mega
	cost = 3
	surplus = 40
	progression_minimum = 30 MINUTES
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/banananade
	name = "Banana Grenade"
	desc = "A singular Banana Grenade. Temporarily blinds those nearby without eye protection, and shoots banana peels everywhere nearby. \
			Useful for gaining distance from would-be pursuers."
	item = /obj/item/grenade/spawnergrenade/bananapeel
	cost = 1
	surplus = 0
	purchasable_from = (UPLINK_TRAITORS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/rotfragnade
	name = "ROTFrag Grenade"
	desc = "A singular ROTFrag Grenade. After priming, shake rapidly in hand to increase it's shrapnel potential, then throw."
	item = /obj/item/grenade/primer
	cost = 3
	surplus = 20
	progression_minimum = 25 MINUTES
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/spesscarp
	name = "Space Carp Grenade"
	desc = "A grenade that when detonated, will release 5 space carps into the immediate vicinity. No hydration required!"
	item = /obj/item/grenade/spawnergrenade/spesscarp
	cost = 6
	surplus = 10
	progression_minimum = 5 MINUTES

/datum/uplink_item/explosives/bombchameleon
	name = "Chameleon Bomb"
	desc = "An explosive device fitted with our chameleon technology, when used on an object, the bomb will disguise itself as that object. \
			To arm, remove the bomb from your hands, disguised or not, the bomb will arm itself and will detonate upon being picked up. \
			The explosive isn't super powerful, but can seriously harm those who pick it up and leave them incapacitated temporarily."
	item = /obj/item/device/chameleon/bomb
	cost = 2
	surplus = 50
	progression_minimum = 10 MINUTES

/datum/uplink_item/explosives/flashbangs
	name = "Flashbangs"
	desc = "A pouch containing approximately 5 Flashbangs. Causes temporary blindness and deafness in those nearby who are unprotected. \
			Capable of leaving many station personnel in your kind, and of-so-loving hands."
	item = /obj/item/ammo_box/nadepouch/flashbang
	cost = 2
	surplus = 50

/datum/uplink_item/explosives/firecrackers
	name = "Firecrackers"
	desc = "A pouch containing approximately 10 Firecrackers. Not super powerful, but are great for area denial. \
			Doesn't come with a lighter."
	item = /obj/item/ammo_box/nadepouch/firecracker
	cost = 2
	surplus = 30

/datum/uplink_item/explosives/stingbangs
	name = "Stingbangs"
	desc = "A pouch containing approximately 5 Stingbangs. Useful for subdueing unarmored targets, or those who'd normally be resistant to flashbangs."
	item = /obj/item/ammo_box/nadepouch/stingbang
	cost = 4
	surplus = 40

/datum/uplink_item/explosives/mirages
	name = "Mirage Grenades"
	desc = "A pouch containing approximately 5 Mirage Grenades. After exploding, these mirage grenades will temporarily project your form where they were thrown. \
			Useful for confusing people or throwing idiotic security personnel off your trail."
	item = /obj/item/ammo_box/nadepouch/mirage
	cost = 3
	surplus = 30

/datum/uplink_item/explosives/shrapnelgrenades
	name = "Fragmentation Grenades"
	desc = "A pouch containing approximately 5 Fragmentation Grenades. Anything adjacent when it explodes will be heavily damaged. Likely to kill anyone nearby."
	item = /obj/item/ammo_box/nadepouch/frag
	cost = 7
	surplus = 40
	progression_minimum = 10 MINUTES
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/gluongrenades
	name = "Gluon Grenades"
	desc = "A pouch containing approximately 5 Gluon Grenades, an advanced grenade that releases a harmful stream of gluons inducing radiation in those nearby. \
			These gluon streams will also make victims feel exhausted, and induce shivering. This extreme coldness will also likely wet any nearby floors."
	item = /obj/item/ammo_box/nadepouch/gluon
	cost = 4
	surplus = 25
	progression_minimum = 10 MINUTES

/datum/uplink_item/explosives/concussgrenades
	name = "Concussion Grenades"
	desc = "A pouch containing approximately 5 Concussion Grenades. These grenades repulse everything around them away with extremely strong force. \
			Leaves both organic and silicon lifeforms stunned for an extended period of time."
	item = /obj/item/ammo_box/nadepouch/concussion
	cost = 5
	surplus = 40
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/incengrenades
	name = "Incendiary Grenades"
	desc = "A pouch containing approximately 5 Incendiary Grenades. These grenades are capable of flooding rooms with fire quickly and can be difficult to extinguish."
	item = /obj/item/ammo_box/nadepouch/incendiary
	cost = 4
	surplus = 30
	purchasable_from = ~UPLINK_CLOWN_OPS
	progression_minimum = 10 MINUTES

/datum/uplink_item/explosives/sonicgrenades
	name = "Sonic Grenades"
	desc = "A pouch containing approximately 5 Sonic Grenades. These grenades are capable of incapacitating both carbon-based and silicon-based lifeforms. \
			The extremely loud screeching sound emitted will damage the ears and temporarily stun and confuse all nearby. Ear-protection won't protect you or them."
	item = /obj/item/ammo_box/nadepouch/sonic
	cost = 6
	surplus = 20

/datum/uplink_item/explosives/antigravity
	name = "Anti-Gravity Grenades"
	desc = "A pouch containing 6 whole Anti-Gravity Grenades, when detonated they will release a payload capable of distorting the fabric of space-time, causing the 20-tile area nearby to be unfit for gravity stabilization for the next 60 seconds. \
			The anti-gravity effect can be blocked by obstacles and barely makes it past airlocks, most effective in open areas."
	item = /obj/item/ammo_box/nadepouch/antigrav
	cost = 2
	surplus = 40

/datum/uplink_item/explosives/radbombs
	name = "Radiation Bombs"
	desc = "A pouch containing approximately 5 Radiation Grenades. For when you just want to watch the world burn slowly. \
			Causes a smoke cloud which irradiates targets within it and invokes random mutations."
	item = /obj/item/ammo_box/nadepouch/rads
	cost = 4
	surplus = 30
	purchasable_from = ~UPLINK_CLOWN_OPS
	progression_minimum = 10 MINUTES

/datum/uplink_item/explosives/acidfoamnades
	name = "Highly-Acidic Grenades"
	desc = "A pouch containing approximately 5 Highly-Acidic Foam Grenades. Especially effective against security officers who are now donning security hardsuits."
	item = /obj/item/ammo_box/nadepouch/highacidfoam
	cost = 5
	surplus = 30
	purchasable_from = ~UPLINK_CLOWN_OPS
	progression_minimum = 15 MINUTES

/datum/uplink_item/explosives/eyebreakersmoke
	name = "Eyebreaker Smokebombs"
	desc = "A pouch containing 5 chemical grenades, housing smoke laced with a unique reagent known for destroying the eyes of those it's exposed too."
	item = /obj/item/ammo_box/nadepouch/eyebreak
	cost = 4
	surplus = 40
	illegal_tech = FALSE
	progression_minimum = 10 MINUTES

/datum/uplink_item/explosives/supermatternades
	name = "Supermatter Grenades"
	desc = "A pouch containing 5 specialized gravitational grenades, has a 3 second timer before anything happens. \
			The grenade will suck in nearby objects and people for a short time before exploding. \
			The explosion itself is relatively weak but still destructive."
	item = /obj/item/ammo_box/nadepouch/sm
	cost = 7
	surplus = 35
	purchasable_from = ~UPLINK_CLOWN_OPS
	progression_minimum = 20 MINUTES

/datum/uplink_item/explosives/whiteholenades
	name = "Whitehole Grenades"
	desc = "A pouch containing 5 specialized gravitational grenades, has a 3 second timer before anything happens. \
			The grenade will occasionally repulse anything and anyone nearby away from it before violently exploding. \
			Due to the grenades' effects, this explosive will fling itself around making it difficult to dispose of and use precisely. \
			The explosion is quite major, but can be used reasonably if you don't intend to harm anyone."
	item = /obj/item/ammo_box/nadepouch/wh
	cost = 7
	surplus = 35
	purchasable_from = ~UPLINK_CLOWN_OPS
	progression_minimum = 20 MINUTES

/datum/uplink_item/explosives/hellgrenades
	name = "Hellfoam Grenades"
	desc = "A pouch containing approximately 5 Hellfoam Grenades. Perfect for clearing large areas of both station AND personnel."
	item = /obj/item/ammo_box/nadepouch/clf3
	limited_stock = 1
	cost = 10
	surplus = 6
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_SPY)
	progression_minimum = 20 MINUTES

/datum/uplink_item/explosives/explosivemines
	name = "Box of Explosive Mines"
	desc = "A box containing approximately 5 Explosive landmines which can be planted on any tile. These mines can easily kill and gib those who step on them as well as destroying all of their stuff."
	item = /obj/item/storage/box/syndie_kit/explosivemines
	cost = 6
	surplus = 10
	purchasable_from = ~UPLINK_CLOWN_OPS
	progression_minimum = 20 MINUTES

/datum/uplink_item/explosives/stunmines
	name = "Box of Stun Mines"
	desc = "A box containing approximately 5 Stun landmines which can be planted on any tile. These mines will stun targets who walk over them."
	item = /obj/item/storage/box/syndie_kit/stunmine
	cost = 3
	surplus = 50

/datum/uplink_item/explosives/heavymines
	name = "Box of Sledgehammer Stun Mines"
	desc = "A box containing approximately 5 Sledgehammer Stun landmines which can be planted on any tile. These mines take a while to plant, but leave a target helpless and disarmed for a long period of time."
	item = /obj/item/storage/box/syndie_kit/heavymine
	cost = 4
	surplus = 50

/datum/uplink_item/explosives/plasmafiremines
	name = "Box of Plasma Mines"
	desc = "A box containing approximately 5 Plasma landmines which can be planted on any tile. When stepped on, these mines eject highly toxic plasma gas and ignite it, causing a major fire hazard."
	item = /obj/item/storage/box/syndie_kit/plasmafiremine
	cost = 5
	surplus = 40
	purchasable_from = ~UPLINK_CLOWN_OPS
	progression_minimum = 20 MINUTES

/datum/uplink_item/explosives/sleepymines
	name = "Box of Sleepy Gas Mines"
	desc = "A box containing approximately 5 Nitrous Oxide gas landmines which can be planted on any tile. When triggered, the mine releases a large amount of N20 Gas."
	item = /obj/item/storage/box/syndie_kit/sleepymine
	cost = 4
	surplus = 45
	progression_minimum = 20 MINUTES

/datum/uplink_item/explosives/riggedstunbaton
	name = "Rigged Stun Baton"
	desc = "A syndicate minibomb cleverly disguised as one of Nanotrasen's stun batons often given to their security team. Perfect for tricking the security team into blowing themselves up and maybe other people too."
	item = /obj/item/disguisedgrenade/riggedstunbaton
	cost = 6
	surplus = 50
	purchasable_from = ~UPLINK_NUKE_OPS
	progression_minimum = 30 MINUTES

/datum/uplink_item/explosives/tricktelecrystal
	name = "Trick Telecrystal"
	desc = "A poorly manufactured telecrystal that's become highly unstable, upon being inserted into an uplink OR when used to attack something \
			this telecrystal will violently explode dealing MASSIVE damage to both target and user. The explosion is always powerful enough to leave \
			a hull breach and likely gib the target or user if either one doesn't have any explosive protection. \
			Often used to fool other syndicate agents or scientific personnel into killing themselves."
	item = /obj/item/stack/telecrystal/trick
	cost = 5
	surplus = 0
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	progression_minimum = 30 MINUTES

/datum/uplink_item/explosives/riggedcells
	name = "Box of Rigged Power Cells"
	desc = "A box containing six of our specialty-designed rigged power cells! \
			Each are designed to be as powerful as a bluespace power cell, but explode 60 seconds after their installation. \
			These cells explode in a more devastating manner than a normal rigged power cell."
	item = /obj/item/storage/box/syndie_kit/syndirigcells
	cost = 5
	surplus = 30
	progression_minimum = 20 MINUTES

/datum/uplink_item/explosives/riggedlights
	name = "Box of Rigged Replacement Lights"
	desc = "A box containing approximately fourteen of our specialty-designed rigged lights! \
			Each release plasma when shattered, and after a full minute: explode to breach walls nearby. \
			Having an electrical storm blow out all the lights for you would probably get the shuttle called."
	item = /obj/item/storage/box/lights/mixed/syndirigged
	cost = 7
	surplus = 25
	progression_minimum = 20 MINUTES

/datum/uplink_item/explosives/clusterclf3
	name = "The Hell-Bomb Cluster"
	desc = "A cluster bomb containing more clf3 foam than you can imagine, with just one of these you'll turn a massive area of the station into lava. Be sure to give a heads-up to your fellow operatives to seek shelter before using this."
	item = /obj/item/grenade/clusterbuster/clf3
	cost = 20
	surplus = 3
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/explosives/clusterminibombs
	name = "Syndicate Minibomb Cluster"
	desc = "A cluster bomb containing more minibombs than you can poke a stick at. Leaves a massive hole whenever it's used, and will likely leave everyone caught in the fray gibbed or helpless."
	item = /obj/item/grenade/clusterbuster/syndieminibomb
	cost = 15
	surplus = 3
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/explosives/clusterspesscarp
	name = "Space Carp Army"
	desc = "A cluster bomb containing an over-abundance of space carp payloads. Throw and run to ensure your army doesn't turn against you."
	item = /obj/item/grenade/clusterbuster/spawner_spesscarp
	cost = 15
	surplus = 3
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/clusteremp
	name = "EMP Clusterbomb"
	desc = "A cluster bomb containing more emp grenades than is frankly necessary. Leading to a massive emp black-out of most electrical equipment."
	item = /obj/item/grenade/clusterbuster/emp
	cost = 10
	surplus = 3
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/clustermanhacks
	name = "Vicserator Clusterbomb"
	desc = "A cluster bomb packed to the brim with vicserator delivery grenades. The moment you prime this thing you'll know: This is gonna be a night to remember."
	item = /obj/item/grenade/clusterbuster/spawner_manhacks
	cost = 20
	surplus = 3
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/clusteracid
	name = "Acidic Clusterbomb"
	desc = "A cluster bomb containing far more acid grenades than any sane person would think is okay. Perfect for leaving groups of armored opponents helpless or dead, and for leaving a large area dangerous to walk over."
	item = /obj/item/grenade/clusterbuster/facid
	cost = 8
	surplus = 3
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/explosives/clusterfire
	name = "Inferno Clusterbomb"
	desc = "A cluster bomb containing a frankly absurd amount of incendiary equipment. Will likely leave the area and the next flooded with fire."
	item = /obj/item/grenade/clusterbuster/inferno
	cost = 10
	surplus = 3
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/explosives/clustersmoke
	name = "Smoke Clusterbomb"
	desc = "A cluster bomb containing an abundance of smoke bombs. For when you want to clear a room or escape it."
	item = /obj/item/grenade/clusterbuster/smoke
	cost = 1
	surplus = 15

/datum/uplink_item/explosives/clustermetalfoam
	name = "Metal Foam Clusterbomb"
	desc = "A cluster bomb containing an abundance of metal foam grenades. Perfect for causing a massive disturbance."
	item = /obj/item/grenade/clusterbuster/metalfoam
	cost = 2
	surplus = 10
	progression_minimum = 10 MINUTES
