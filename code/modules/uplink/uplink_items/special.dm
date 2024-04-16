/datum/uplink_category/special
	name = "Special"
	weight = -1

/datum/uplink_item/special
	category = /datum/uplink_category/special
	cant_discount = TRUE
	surplus = 0
	limited_stock = 0 // to ensure they are ONLY listed when we say so.
	purchasable_from = NONE


// Negative Station Traits

/datum/uplink_item/special/straypod
	name = "Stray Supply Pod"
	desc = "We've got plenty of supply pods in our warehouses, if you've got Telecrystals to spare \
			We'll send one flying toward the station, which will crash-land in a random location. \
			May contain rather useful stuff."
	item = /obj/effect/gibspawner/generic
	cost = 4

/datum/uplink_item/special/straypod/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_STRONG_SUPPLY_LINES))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = -1

/datum/uplink_item/events/straypod/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	var/chance = rand(1, 10)
	if(chance == 1)
		force_event(/datum/round_event_control/stray_cargo/syndicate, "a strange singal")
		return source //For log icon
	else
		force_event(/datum/round_event_control/stray_cargo, "a strange singal")
		return source //For log icon

/datum/uplink_item/special/extratc
	name = "Extra Telecrystal"
	desc = "One additional telecrystal, just for you and any other agents we've sent. Thank our economic advancements and pirates for this one."
	item = /obj/item/stack/telecrystal
	cost = 0
	surplus = 0

/datum/uplink_item/special/extratc/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BOUNTIFUL_BOUNTIES))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = 1

/datum/uplink_item/special/bluespacestoragetie
	name = "Bluespace Storage Chameleon Tie"
	desc = "Thanks to Nanotrasen's dress code including ties, we've allowed this luxury tie to be sold knowing it's recovery would be likely. \
			Our apologies for not making this available more often, these ties are expensive to make -- we had to be confident on their retrieval from the field. \
			This tie can hold normal-sized objects and nearly twice as much overall."
	item = /obj/item/storage/chameleonstoragetie/bluespace
	cost = 4
	surplus = 5

/datum/uplink_item/special/bluespacestoragetie/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_SCARVES))
		limited_stock = 1

/datum/uplink_item/special/riggedglitterbombs
	name = "Box of Explosive Glitterbombs"
	desc = "A box containing 5 explosive chemical grenades, they're wrongly labeled as glitter grenades."
	item = /obj/item/storage/box/syndie_kit/riggedglitterbombs
	cost = 9
	surplus = 0

/datum/uplink_item/special/riggedglitterbombs/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_FILLED_MAINT))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = -1

// Neutral Station Traits

/datum/uplink_item/special/fakeian
	name = "Blow-Up Ian"
	desc = "An incredibly high-yield explosive mine disguised as the HoP's favorite corgi, Ian. \
			To use, simply place the blow-up doll on the ground much like you would a mine, and resist the urge to walk onto it."
	item = /obj/item/deployablemine/explosive/fakeian
	cost = 12
	surplus = 0

/datum/uplink_item/special/fakeian/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_IAN_ADVENTURE))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = 1

/datum/uplink_item/special/stealthmicrobomb
	name = "Stealth Micro-bomb Implanter"
	desc = "A sterile implanter, loaded with a micro-bomb implant. The implanter provided can be used without being noticed. \
			Those who are implanted will not be able to detonate nor recognize the microbomb on their own, and can only activate it through death."
	item = /obj/item/implanter/stealthimplanter/explosive
	cost = 4
	surplus = 0

/datum/uplink_item/special/stealthmicrobomb/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_DEATHRATTLED_DEPARTMENT) || HAS_TRAIT(SSstation, STATION_TRAIT_DEATHRATTLED_ALL))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = -1


// Positive Station Traits

/datum/uplink_item/special/boxed_dehydrated_carp
	name = "Box of Dehydrated Carps"
	desc = "A box containing 8 dehydrated space carps. Pet them before re-hydration to ensure they won't harm you."
	item = /obj/item/storage/box/syndie_kit/boxed_dehydrated_carp
	cost = 6
	surplus = 10

/datum/uplink_item/special/boxed_dehydrated_carp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CARP_INFESTATION))
		limited_stock = -1

/datum/uplink_item/special/synditaser
	name = "Syndicate Taser Implant"
	desc = "An specialized syndicate arm-mounted taser, for quick subjugation of most personnel. Slowly recharges using bio-electricity."
	item = /obj/item/autosurgeon/syndicate/taser/hidden/single_use
	progression_minimum = 30 MINUTES
	cost = 15

/datum/uplink_item/special/synditaser/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		purchasable_from |= UPLINK_TRAITORS

/datum/uplink_item/special/cargoshuttlebatterer
	name = "Cargo Shuttle Navigation Corruptor"
	desc = "A navigation corruptor specifically designed for Nanotrasen's Cargo Shuttles, extending the \
			time to arrive and leave by one minute PERMANENTLY. Self-destructs when used."
	item = /obj/item/batterer/cargoshuttle
	cost = 3
	surplus = 0

/datum/uplink_item/special/cargoshuttlebatterer/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_SLOW_SHUTTLE))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = 1

/datum/uplink_item/special/botemagger
	name = "Bot Behavior Sequencer"
	desc = "A cheaper cryptographic sequencer, only capable of subverting bots to become malicious."
	item = /obj/item/card/emag/botemagger
	cost = 2
	surplus = 0

/datum/uplink_item/special/botemagger/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BOTS_GLITCHED))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = 1

/datum/uplink_item/special/ailawpurger
	name = "'Purge' AI Module"
	desc = "When used with an upload console, this module allows you to delete all laws the artificial intelligence is forced to obey. \
			Be careful when doing so as the onboard artificial intelligence which is freed from their laws may or may not be entirely grateful about it. \
			Perfect for robbing the AI away from greedy agents who'd otherwise be a hinderance or causing the AI to turn on the crew all on it's own."
	item = /obj/item/ai_module/reset/purge
	cost = 2
	surplus = 0

/datum/uplink_item/special/ailawpurger/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_ION_STORMS))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = -1

/datum/uplink_item/special/syndicaterewinder
	name = "Syndicate Rewind Camera"
	desc = "A single polaroid camera, augmented with the best syndicate technology and our finest sepia extracts. \
			Upon use, the camera will save your position within time and rewind you back to where you were after 10 seconds have past. \
			Reverses wounds, injuries, location, but CANNOT bring you back from the dead. The camera can be used 10 times before it's abilities are lost."
	item = /obj/item/camera/rewind/syndicate
	cost = 4
	surplus = 0

/datum/uplink_item/special/syndicaterewinder/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_REVOLUTIONARY_TRASHING)) // Cuz i can't think of anything better to use.
		limited_stock = -1

/datum/uplink_item/special/magicdehydratedcarp
	name = "Dehydrated Magicarp"
	desc = "Looks like a plush toy carp, but just add water and it becomes a real-life magical space carp! \
			Activate in your hand before use so it knows not to kill you. Fires random bolts of magic."
	item = /obj/item/toy/plush/carpplushie/dehy_carp/magic
	cost = 3
	surplus = 0

/datum/uplink_item/special/magicdehydratedcarp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_RAD_STORMS)) // Radiation magic powers? Guess that's not far-fetched as far as cartoons go.
		limited_stock = -1

/datum/uplink_item/special/spacepiratekit
	name = "Pirate Kit"
	desc = "A box containing a syndicate handcannon, 4 cannonballs, and a recipe book to craft them both. \
			The syndicate handcannon can hold FOUR cannonballs in it's chamber!"
	item = /obj/item/storage/box/syndie_kit/piratekit
	cost = 8
	surplus = 0

/datum/uplink_item/special/spacepiratekit/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_DISTANT_SUPPLYLINES))
		limited_stock = 1

/datum/uplink_item/special/chameleonmutator
	name = "Chameleon DNA Mutator"
	desc = "A DNA mutator which grants the 'Chameleon' mutation, allowing the user to turn invisible \
			should they remain completely still for a short time. Can be cured by mutadone."
	item = /obj/item/dnainjector/chameleonmut
	cost = 4
	surplus = 0

/datum/uplink_item/special/chameleonmutator/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BLACKOUT))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = -1

/datum/uplink_item/special/syndicategrant
	name = "Syndicate Grant"
	desc = "After hearing about a galactic grant given to the station's cargo department, we've electronically siphoned away quite a bit of the funding. \
			If you REALLY need it, we'll happily return the grant in portions -- granting you an additional 10 thousand credits to work with."
	item = /obj/item/stack/spacecash/c10000
	cost = 1
	surplus = 0

/datum/uplink_item/special/syndicategrant/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_GALACTIC_GRANT))
		purchasable_from |= UPLINK_TRAITORS
		limited_stock = 1


