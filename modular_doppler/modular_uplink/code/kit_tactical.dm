/datum/uplink_category/tactical_kits
	name = "Tactical Kits"
	weight = 12

/datum/uplink_item/tackit
	category = /datum/uplink_category/tactical_kits

/datum/uplink_item/tackit/recon
	name = "Recon Equipment"
	desc = "Featuring x-ray goggles, a briefcase launchpad, binoculars, grenades, a MODsuit, a portable EMP device, \
		and an encryption key, this set of equipment is specialized for rapid infiltration and reconnaissance efforts."
	item = /obj/item/storage/box/syndicate/bundle/recon
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/spytf2
	name = "Spy Equipment"
	desc = "A panoply of gear featuring lightweight chameleon clothing, a portable app for accessing all cameras, an \
		AI detector multitool, an encryption key, a mulligan syringe, a chameleon device, a storage implant, and \
		both a knife and portable EMP device, superbly suitable for the silent close-quarters operative. Also \
		happens to come with free omnizine cigarettes."
	item = /obj/item/storage/box/syndicate/bundle/spytf2
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/stealth
	name = "Stealth Operative Equipment"
	desc = "A standard suite of equipment sporting a potent miniature ebow, a sleepy pen, a radiation laser, chameleon \
		device, thermal goggles, radio jammer, EMP flashlight, and specialized soap for cleaning up messes, tailored \
		towards the efficient worker that's never seen at all."
	item = /obj/item/storage/box/syndicate/bundle/stealthy
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/fucked
	name = "Terrorist Equipment"
	desc = "A bomb, a power sink, a minibomb, an encryption key, and a spacesuit. Nothing stops the mail."
	item = /obj/item/storage/box/syndicate/bundle/fucked
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/sabotage
	name = "Saboteur Equipment"
	desc = "A combo bag of C4 and X4 charges, alongside a camera app disk, power sink, detomatix app, pizza bomb, EMP \
		kit, and a Syndicate-issue toolbox, made for operatives that really need shit blown up."
	item = /obj/item/storage/box/syndicate/bundle/sabotage
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/garbageday
	name = "Magnum Specialist Equipment"
	desc = "A revolver and two speedloaders, as well as a holster, doorjack card, a brick of C4, and a classical outfit \
		that harkens back to bank robbers of old. Sometimes, you just really need to shoot your way out."
	item = /obj/item/storage/box/syndicate/bundle/payday
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/killer
	name = "Assassin Equipment"
	desc = "An energy sword, doorjack card, thermal goggles, no-slip shoes, a minibomb, and an encryption key - though \
		remarkably simple, it's everything a would-be assassin needs to get their target in the ground."
	item = /obj/item/storage/box/syndicate/bundle/killer
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/implants
	name = "Cybernetic Equipment"
	desc = "A freedom implant, EMP implant, storage implant, explosive implant, and uplink implant, for the tech-inclined \
		operative that needs a myriad of solutions for every problem."
	item = /obj/item/storage/box/syndicate/bundle/implants
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/hacker
	name = "Hacker Equipment"
	desc = "A custom AI law module, cryptographic sequencer, doorjack card, binary encryption key, AI detector multitool, \
		camera app card, thermal goggles, agent ID card, and a sleek Syndicate toolbox, plus an AI toy for coming up \
		with all sorts of fantastical new laws, purpose-tailored towards subversion of silicon units."
	item = /obj/item/storage/box/syndicate/bundle/hacker
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/sniper
	name = "Sniper Specialist Equipment"
	desc = "A .50 caliber sniper rifle, penetrator magazine, thermal goggles, and a lightweight outfit perfect for a careful, \
		cautious, accurate operative. Spare ammunition may be impossible to find, so make every shot count."
	item = /obj/item/storage/box/syndicate/bundle/sniper
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/ops
	name = "Nuclear Operative Equipment"
	desc = "A Gorlex Marauder MODsuit, bulldog shotgun, two spare drum mags, a microbomb implant, two bricks of C4, and a \
		cryptographic sequencer alongside a doorjack card, ideal for faking a nuclear operative infiltration, or engaging \
		in an overt engagement of your own."
	item = /obj/item/storage/box/syndicate/bundle/ops
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/tackit/rev
	name = "Revolutionary Leader Equipment"
	desc = "A hypnosis-inducing flashbulb, nagant revolver, radiation laser scanner, sleepy pen, bottle of LSD pills, and a \
		box of seditious posters alongside a fantastical outfit made to instill anti-government and anti-corporate ideas \
		into onlookers."
	item = /obj/item/storage/box/syndicate/bundle/rev
	cost = 20
	purchasable_from = ~(UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)
