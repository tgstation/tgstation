/datum/uplink_category/species
	name = "Species Restricted"
	weight = 2

/datum/uplink_item/species_restricted
	category = /datum/uplink_category/species
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS | UPLINK_SPY)

/datum/uplink_item/species_restricted/moth_lantern
	name = "Extra-Bright Lantern"
	desc = "We heard that moths such as yourself really like lamps, so we decided to grant you early access to a prototype \
	Syndicate brand \"Extra-Bright Lantern™\". Enjoy."
	cost = 2
	item = /obj/item/flashlight/lantern/syndicate
	restricted_species = list(SPECIES_MOTH)
	surplus = 0

/datum/uplink_item/species_restricted/superhuman
	name = "Super-Human Mutator"
	desc = "This DNA mutator contains a highly experimental mutation that significantly boosts a human's physical and mental attributes to it's peak potential. \
			Superhuman's slowly regenerate health, have greater stamina, have greater maximum health, slightly resist damage, are immune to stuns, have near-immunity to slips, easily ignore pain, and cannot be dismembered. \
			Mutadone CANNOT cure this mutation, but this mutation causes great genetic instability. Proceed with extreme caution. Incompatible with hulk mutations."
	cost = 20
	surplus = 0
	item = /obj/item/dnainjector/superhuman
	restricted_species = list(SPECIES_HUMAN)

/datum/uplink_item/species_restricted/hulk // cheaper...
	name = "Hulk Mutator"
	desc = "Stolen research from a SIC scientist who went postal led to the development of this revolutionary mutator. Causes extreme muscle growth, enough to punch through walls, and practically limitless stamina, at the cost of reduced cognitive ability, and green skin pigmentation."
	cost = 8
	item = /obj/item/dnainjector/hulkmut
	restricted_species = list(SPECIES_HUMAN)

/datum/uplink_item/species_restricted/xray
	name = "X-Ray Vision Mutator"
	desc = "One of our most popular mutations to date, this mutator grants the mutatee X-Ray vision, allowing them to see past any and all obstacles and obstructions. \
			This mutation CAN BE CURED via mutadone."
	cost = 8
	item = /obj/item/dnainjector/xraymut
	restricted_species = list(SPECIES_HUMAN)

/datum/uplink_item/species_restricted/xenospitter
	name = "Xenomorphic Pistol"
	desc = "A reagent pistol modeled to look after the alien species it was originally inspired by. \
			It fires globs of a highly acidic reagent as well as a small amount of an alien neurotoxin. \
			Refuels itself automatically but very slowly. Does no damage outright, but useful when attempting to incapacitate someone."
	cost = 8
	item = /obj/item/gun/energy/xenospitter
	restricted_species = list(SPECIES_PLASMAMAN)

/datum/uplink_item/species_restricted/killertomatos
	name = "Box of Killer Tomatoes"
	desc = "The Syndicates local gardeners brewed these up for our plant comrades (does not work against fellow plants). Contains a seed packet for killer tomatos and five fully grown specimen."
	cost = 3
	item = /obj/item/storage/box/syndie_kit/killertomato
	restricted_species = list(SPECIES_PODPERSON)

/datum/uplink_item/species_restricted/beegrenades
	name = "Buzzkill Grenade"
	desc = "A grenade containing multiple of our venomous bees, shake extra hard before pulling the pin. Bees are passive to phytosians."
	cost = 2
	item = /obj/item/grenade/spawnergrenade/buzzkill
	restricted_species = list(SPECIES_PODPERSON)

/datum/uplink_item/species_restricted/kudzu_seed
	name = "Kudzu Seed Packet"
	desc = "A single seed packet of the Kudzu vine species. These seeds can be planted outside of a tray to cause havoc. \
			Giving kudzu a high amount of potency will make them even more devastating. Great for a massive distraction."
	item = /obj/item/seeds/kudzu
	cost = 3
	surplus = 0
	restricted_species = list(SPECIES_PODPERSON)

/datum/uplink_item/species_restricted/eternal_mutagen
	name = "Eternal Flask of Unstable Mutagen"
	desc = "A bottle that's only glass-like in appearance. The container itself harbors redspace technology \
			that will fill the container slowly over time with Unstable Mutagen for a maximum of 50 units. \
			A botanists friend, or if you intend to acquire certain uncurable mutations."
	item = /obj/item/reagent_containers/cup/bottle/eternal/mutagen
	cost = 1
	surplus = 0
	restricted_species = list(SPECIES_PODPERSON)

/datum/uplink_item/species_restricted/eternal_diethylamine
	name = "Eternal Flask of Diethylamine"
	desc = "A bottle that's only glass-like in appearance. The container itself harbors redspace technology \
			that will fill the container slowly over time with Diethylamine for a maximum of 50 units. \
			Diethylamine is capable of providing healing to Phytosians, can still be overdosed upon if more than 20 units is consumed."
	item = /obj/item/reagent_containers/cup/bottle/eternal/diethylamine
	cost = 2
	surplus = 0
	restricted_species = list(SPECIES_PODPERSON)

/datum/uplink_item/species_restricted/phytosiansmoke
	name = "Phytosian Smoke Bomb"
	desc = "A large grenade filled to the brim with EZ-Nutrient and Smoke-producing chemicals. \
			EZ-Nutrient in all but Phytosians will poison them slowly over time, and find it difficult to purge from their bloodstream. \
			Also loaded within are Robust Harvest, Saltpetre, and Diethylamine for healing if you're caught in the smoke."
	item = /obj/item/grenade/chem_grenade/large/phytosiansmoke
	cost = 3
	surplus = 0
	restricted_species = list(SPECIES_PODPERSON)

/datum/uplink_item/species_restricted/tesliumnades
	name = "Tesla Grenades"
	desc = "A pouch containing 5 pyro grenades filled to the brim with teslium. Perfect for mass electrocutions."
	cost = 5
	item = /obj/item/ammo_box/nadepouch/tesla
	restricted_species = list(SPECIES_ETHEREAL)

/datum/uplink_item/species_restricted/universal_tele
	name = "Universal Hand Teleporter"
	desc = "A hand tele previously secured by our agents in the field, we've upgraded it with unregulated bluespace technology to allow it to recieve signals from all teleportation points. \
			Can lock onto Teleportation Hubs, Tracking Beacons, and Tracking Implants. Can be upgraded by replacing the manipulator within."
	cost = 10
	item = /obj/item/hand_tele/universal
	restricted_species = list(SPECIES_FLYPERSON)
	purchasable_from = (UPLINK_TRAITORS | UPLINK_SPY)

/datum/uplink_item/species_restricted/syndilampflash
	name = "Flashing Lantern"
	desc = "One of our Syndicate Lanterns, we've modified it with flashing capabilities at the request of ex'hai everywhere. \
			The lantern can only flash someone every 5 seconds, but the bulb will NEVER burn out! Hurray!"
	cost = 2
	item = /obj/item/assembly/flash/lantern
	restricted_species = list(SPECIES_MOTH)

/datum/uplink_item/species_restricted/lethal_flare
	name = "Lethal Flare"
	desc = "A flare, which when activated will burn for a VERY long time. It can be used as a weapon to deal decent Burn damage and light your target ablaze."
	item = /obj/item/flashlight/flare/lethal
	cost = 4
	surplus = 0
	restricted_species = list(SPECIES_MOTH)

/datum/uplink_item/species_restricted/riggedglowsticks
	name = "Box of Rigged Glowsticks"
	desc = "A box containing 6 glowsticks of random colors, they're all rigged with explosives and will detonate violently after they are expended."
	item = /obj/item/storage/box/syndie_kit/riggedglowsticks
	cost = 4
	surplus = 8
	restricted_species = list(SPECIES_MOTH)

/datum/uplink_item/species_restricted/lizardsbane
	name = "Syndicate Liz o' Nine Tails"
	desc = "A whip fashioned from the severed tails of lizards who attempted to stab us in the back. \
			We'll sell this to you JUST to remind you not to try anything funny. Deals moderate brute damage, but nearly 2x as much vs. other lizards."
	item = /obj/item/melee/chainofcommand/tailwhip/syndicate
	cost = 6
	surplus = 0
	restricted_species = list(SPECIES_LIZARD)

/datum/uplink_item/species_restricted/lizardplushiebomb
	name = "Explosive Lizard Plushie"
	desc = "A lizard plushie we've rigged with explosives much to our dismay, simply pull the tag on the back to prime the grenade."
	item = /obj/item/disguisedgrenade/lizardplush
	cost = 4
	surplus = 0
	restricted_species = list(SPECIES_LIZARD)

/datum/uplink_item/species_restricted/degeneratewhip
	name = "Infinite Cat o' Nine Tails"
	desc = "A whip fashioned from felinid tails, to remind you of what happens when you give into temptation. \
			Attacking people with this weapon several times over is often enough to subvert them into your... wicked ways."
	item = /obj/item/melee/chainofcommand/tailwhip/kitty/syndicate
	cost = 6
	surplus = 0
	restricted_species = list(SPECIES_FELINE)

/datum/uplink_item/species_restricted/angryralsei
	name = "Prince of Darkness"
	desc = "A prince of the dark, unfortunately he has no subjects. He's extremely insistant on giving out hugs, why don't you... assist him in that endeavor? \
			This plushie actively rams into targets nearby with little downtime, and deals over twice as much damage than normal angry plushies. \
			Can be subdued and disposed of easily. WILL RAM YOU AS WELL. Can be emagged to increase it's potential."
	item = /obj/item/toy/plush/goatplushie/angry/syndicate
	cost = 2
	surplus = 0
	restricted_species = list(SPECIES_FELINE)

/datum/uplink_item/species_restricted/riggedplushies
	name = "Box of Rigged Plushies"
	desc = "Six plushies of various kinds that can be planted much like a regular explosive mine. \
			Plushies are not concealed after being planted and the blast isn't as effective as our regular explosive mines."
	item = /obj/item/storage/box/syndie_kit/riggedplushies
	cost = 4
	surplus = 0
	restricted_species = list(SPECIES_FELINE)

/datum/uplink_item/species_restricted/jellypersonregen
	name = "Gelatine Sythesis Implant Autosurgeon"
	desc = "A regenerative implant specifically tailored to jellypeople, it's roughly twice as effective on jellypeople and will stimulate blood production."
	item = /obj/item/autosurgeon/syndicate/jellypersonregen
	cost = 5
	surplus = 0
	restricted_species = list(SPECIES_JELLYPERSON)

/datum/uplink_item/species_restricted/jellysmokebomb
	name = "Jelly Mutation Toxin Smokebomb"
	desc = "If there were ever a time to get lynched, it's going to be today. Pairs well with the Mutation Toxin Kit, to reverse any changes upon yourself or fellow agents."
	item = /obj/item/grenade/chem_grenade/jellypersonsmoke
	cost = 5
	surplus = 0
	restricted_species = list(SPECIES_JELLYPERSON)
