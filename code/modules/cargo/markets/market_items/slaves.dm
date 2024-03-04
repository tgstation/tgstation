///A special category for mobs captured by pirates, tots and contractors, should someone want to buy them before they come back.
/datum/market_item/slave
	category = "Serfs"
	stock = 1
	availability_prob = 100
	shipping_override = list(SHIPPING_METHOD_LTSRBT = 0, SHIPPING_METHOD_SUPPLYPOD = 400)
	/// temporary reference to the decapitator button that'll later be synced with the collar.
	var/obj/item/collar_bomb_button/button

/datum/market_item/slave/New(mob/living/slave, new_price)
	..()
	set_item(slave)
	name = "[slave.real_name]"
	var/specimen = initial(slave.name)
	var/humie_slave = ishuman(slave)
	if(humie_slave)
		var/mob/living/carbon/human/humie = slave
		specimen = humie.dna.species.name
	desc = pick(list(
		"If you're looking for a [specimen], you've come to the right place.",
		"If you're interested, we've recently aquired a fine [specimen].",
		"If you've coin, then you should buy this [specimen].",
	))
	desc += " DISCLAIMER: The offer will expire once the product is returned to the station."
	if(humie_slave)
		desc += "Comes with a pre-installed collar bomb and a button to trigger it."

	price = new_price
	RegisterSignal(slave, COMSIG_LIVING_RETURN_FROM_CAPTURE, PROC_REF(on_return_from_capture))

/datum/market_item/slave/proc/on_return_from_capture(mob/living/source, turf/destination)
	SIGNAL_HANDLER
	qdel(src) //as if we never existed, our mentions we'll be removed from the market.

/datum/market_item/slave/Destroy()
	button = null
	return ..()

/datum/market_item/slave/buy(obj/item/market_uplink/uplink, mob/buyer, shipping_method)
	. = ..()
	var/mob/living/slave = item
	if(!. || !ishuman(slave))
		slave.befriend(buyer) //least we can do.
		return
	button = new(uplink.drop_location())
	buyer.put_in_hands(button)
	to_chat(buyer, span_notice("A [button] appears [buyer.is_holding(button) ? "in your hands" : "at your feet"]!"))

/datum/market_item/slave/spawn_item(loc, datum/market_purchase/purchase)
	UnregisterSignal(item, COMSIG_LIVING_RETURN_FROM_CAPTURE)
	if(!ishuman(item))
		return ..()
	var/mob/living/carbon/human/humie = item
	if(isnull(humie.w_uniform))
		//FUCKING SLAVES, GET YOUR CLOTHES BACK ON!
		humie.equip_to_slot_or_del(new /obj/item/clothing/under/costume/jabroni(humie), ITEM_SLOT_ICLOTHING)
	if(humie.wear_neck) //try to remove the neck item if possible before we attempt to install the collar bomb
		humie.transferItemToLoc(humie.wear_neck, loc)
	var/obj/item/clothing/neck/collar_bomb/collar = new(loc, button)
	humie.equip_to_slot_if_possible(collar, ITEM_SLOT_NECK)
	button = null
	to_chat(humie, "[span_notice("You've been been <b>bought</b> back to the station early, however...")] \
		[span_warning("you've also been equipped with \a [collar]! The button to trigger it should be in your buyer's hands.")]")
	return ..()
