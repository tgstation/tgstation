///A special category for mobs captured by ninjas or contractors, should someone buy them before they're sent back.
/datum/market_item/slave
	category = "Critters & Servants"
	stock = 1
	availability_prob = 100
	shipping_override = list(SHIPPING_METHOD_LTSRBT = 50, SHIPPING_METHOD_SUPPLYPOD = 400)
	/// temporary reference to the decapitator button that'll later be synced with the collar.
	var/obj/item/decapitator_button/button

/datum/market_item/slave/New(mob/living/slave, new_price, from_ransom = TRUE)
	..()
	set_item(slave)
	name = "[slave.real_name]"
	var/specimen = initial(slave.name)
	if(ishuman(slave))
		var/mob/living/carbon/human/humie = slave
		specimen = humie.dna.species.name
	desc = pick(list(
		"If you're looking for a [specimen] servant, you've come to the right place.",
		"If you're interested, we've recently aquired a fine [specimen].",
		"If you've coin, then you should buy this [specimen].",
	))
	desc += " DISCLAIMER: We're not responsible for catatonia, death and misbehavior of the product."
	if(from_ransom)
		desc +=" The offer will expire once the NT-paid ransom reaches us and the product is returned to the station."

	price = new_price

/datum/market_item/slave/Destroy()
	button = null
	return ..()

/datum/market_item/slave/buy(obj/item/market_uplink/uplink, mob/buyer, shipping_method)
	. = ..()
	if(!. || !ishuman(item))
		return
	var/obj/item/decapitator_button/button = new(uplink.drop_location())
	buyer.put_in_hands(button)

/datum/market_item/slave/spawn_item(loc, datum/market_purchase/purchase)
	var/mob/living/slave = item
	if(!ishuman(slave))
		return ..()
	var/mob/living/carbon/human/humie = slave
	if(isnull(humie.w_uniform))
		//FUCKING SLAVES, GET YOUR CLOTHES BACK ON!
		humie.equip_to_slot_or_del(new /obj/item/clothing/under/costume/jabroni(humie), ITEM_SLOT_ICLOTHING)
	if(humie.wear_neck) //try to remove the neck item if possible before we attempt to install the collar bomb
		humie.transferItemToLoc(humie.wear_neck, loc)
	var/obj/item/clothing/neck/decapitator = new(loc, button)
	humie.equip_to_slot_if_possible(decapitator, ITEM_SLOT_NECK)
	button = null
	return ..()
