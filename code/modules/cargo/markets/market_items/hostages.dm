///A special category for mobs captured by pirates, tots and contractors, should someone ever want to get them back in advance.
/datum/market_item/hostage
	category = "Hostages"
	abstract_path = /datum/market_item/hostage
	stock = 1
	availability_prob = 100
	shipping_override = list(SHIPPING_METHOD_LTSRBT = 0, SHIPPING_METHOD_SUPPLYPOD = 350)
	/// temporary reference to the 4 in 7 chances of signaler and electropack.
	var/obj/item/assembly/signaler/signaler

/datum/market_item/hostage/New(mob/living/mob, new_price)
	..()
	set_item(mob)
	name = "[mob.real_name]"
	var/specimen = initial(mob.name)
	var/humie_mob = ishuman(mob)
	if(humie_mob)
		var/mob/living/carbon/human/humie = mob
		specimen = humie.dna.species.name
	desc = pick(list(
		"If you're looking for a recently stolen [specimen], you've come to the right place.",
		"we've recently aquired a fine [specimen] from a station around here, eheh...",
		"For a limited time, we're offering this [specimen] for you to buy (back).",
	))
	desc += " DISCLAIMER: The offer will expire once the creature is returned to the station."
	if(humie_mob)
		desc += "[mob.p_they(TRUE)] may be delivered handcuffed, for safety of course."

	price = new_price
	RegisterSignal(mob, COMSIG_LIVING_RETURN_FROM_CAPTURE, PROC_REF(on_return_from_capture))

/datum/market_item/hostage/proc/on_return_from_capture(mob/living/source, turf/destination)
	SIGNAL_HANDLER
	qdel(src) //as if we never existed, our mentions we'll be removed from the market.

/datum/market_item/hostage/Destroy()
	signaler = null
	return ..()

/datum/market_item/hostage/buy(obj/item/market_uplink/uplink, mob/buyer, shipping_method)
	. = ..()
	var/mob/living/humie = item
	if(!. || !istype(humie) || !prob(57)) // 3 in 7 chance of the electropack set not spawning...
		return
	signaler = new(uplink.drop_location())
	RegisterSignal(signaler, COMSIG_QDELETING, PROC_REF(clear_signaler_ref))
	signaler.set_frequency(sanitize_frequency(rand(MIN_FREE_FREQ, MAX_FREE_FREQ)))
	signaler.code = rand(1, 100)
	buyer.put_in_hands(signaler)
	to_chat(buyer, span_notice("A [signaler] appears [buyer.is_holding(signaler) ? "in your hands" : "at your feet"]!"))

/datum/market_item/hostage/proc/clear_signaler_ref(datum/source)
	SIGNAL_HANDLER
	signaler = null

/datum/market_item/hostage/spawn_item(loc, datum/market_purchase/purchase)
	var/mob/living/mob = item
	UnregisterSignal(mob, COMSIG_LIVING_RETURN_FROM_CAPTURE)
	if(!mob.IsUnconscious())
		to_chat(mob, span_boldnicegreen("You have been <u>bought</u> back to the station. Be grateful to whoever got you out of the holding facility early."))
	if(!ishuman(item))
		return ..()
	var/mob/living/carbon/human/humie = item
	if(signaler) //57% chance that the mob is equipped with electropack and cuffs
		humie.equip_to_slot_or_del(new /obj/item/restraints/handcuffs, ITEM_SLOT_HANDCUFFED, indirect_action = TRUE)
		if(humie.back) //try to remove the neck item if possible before we attempt to install the collar bomb
			humie.transferItemToLoc(humie.back, loc)
		var/obj/item/electropack/pack = new(loc)
		pack.set_frequency(signaler.frequency)
		pack.code = signaler.code
		humie.equip_to_slot_if_possible(pack, ITEM_SLOT_BACK, disable_warning = TRUE)
		UnregisterSignal(signaler, COMSIG_QDELETING)
		signaler = null
	else if(prob(66)) // 29% chance of just cuffs
		humie.equip_to_slot_or_del(new /obj/item/restraints/handcuffs, ITEM_SLOT_HANDCUFFED, indirect_action = TRUE)
	else // 14% chance of just a tee souvenir and pin, no cuffs and shit.
		var/obj/item/clothing/under/misc/syndicate_souvenir/souvenir = new(loc)
		humie.equip_to_slot_if_possible(souvenir, ITEM_SLOT_ICLOTHING, indirect_action = TRUE)
		var/obj/item/clothing/accessory/anti_sec_pin/pin = new(loc)
		pin.attach(souvenir)

	if(isnull(humie.w_uniform))
		//FUCKING SLAVES, GET YOUR CLOTHES BACK ON!
		humie.equip_to_slot_or_del(new /obj/item/clothing/under/costume/jabroni(humie), ITEM_SLOT_ICLOTHING, indirect_action = TRUE)
	return ..()
