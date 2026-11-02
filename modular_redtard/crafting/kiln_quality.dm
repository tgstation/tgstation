// Ratwood's fired pottery (roguejobs/ceramicist/clay.dm apply_pottery_quality(), rogueitems/ceramics.dm pottery_throw_shatter()):
// what comes out of the kiln is named by its pottery tier at every tier, the crude and poor ones too ("crude clay cup"), is worth
// 0.4 to 1.5 times its price by the tier, and is fragile - a fired cup, bottle or vase that is thrown shatters where it lands, as
// Ratwood's clay vessels and ceramic cups always do. The tier itself comes from crafting/pottery.dm (on_fired()); this file adds
// the kiln's naming, price and fragility.

#define KILN_SHATTER_CHANCE rogue_value("survival_pottery_shatter_chance")

/obj/item
	/// Fired pottery, fragile (Ratwood pottery_fragile): a vessel of it shatters when thrown.
	var/rogue_pottery_fragile = FALSE

/// Ratwood's kiln names of the pottery tiers, crude to masterwork; the plain tier keeps the plain name.
GLOBAL_LIST_INIT(rogue_kiln_prefixes, list("crude", "poor", null, "fine", "flawless", "masterwork"))

/// Ratwood's kiln price factor of a pottery tier (0 crude ... 5 masterwork).
/proc/rogue_kiln_price_factor(tier)
	switch(tier)
		if(0)
			return rogue_value("survival_kiln_price_crude")
		if(1)
			return rogue_value("survival_kiln_price_poor")
		if(2)
			return rogue_value("survival_kiln_price_plain")
		if(3)
			return rogue_value("survival_kiln_price_fine")
		if(4)
			return rogue_value("survival_kiln_price_flawless")
	return rogue_value("survival_kiln_price_masterwork")

/// The kiln names, prices and makes fragile the piece it fired, by the tier pottery.dm gave it.
/obj/item/natural/clay/on_fired(datum/source, obj/item/fired)
	. = ..()
	if(!isitem(fired))
		return
	fired.rogue_apply_kiln_quality(isnull(rogue_quality) ? 0 : clamp(rogue_quality - ROGUE_QUALITY_CRUDE, 0, ROGUE_QUALITY_MASTERWORK - ROGUE_QUALITY_CRUDE))

/// Ratwood apply_pottery_quality() of the kiln: the tier's name, the tier's price, fragile. The general price factor of the
/// quality (economy/prices.dm get_real_price()) is taken out, so the piece is worth the kiln's factor.
/obj/item/proc/rogue_apply_kiln_quality(tier)
	var/prefix = GLOB.rogue_kiln_prefixes[clamp(tier, 0, length(GLOB.rogue_kiln_prefixes) - 1) + 1]
	if(prefix)
		name = "[prefix] [initial(name)]"
	if(sellprice > 0)
		var/general = isnull(rogue_quality) ? 1 : rogue_quality_price_mult(rogue_quality)
		sellprice = max(round(sellprice * rogue_kiln_price_factor(tier) / general), 1)
	rogue_pottery_fragile = TRUE

/// Ratwood pottery_throw_shatter(): a fragile vessel thrown shatters on impact; what was in it is lost.
/obj/item/reagent_containers/glass/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, do_splash = TRUE)
	if(!rogue_pottery_fragile || !prob(KILN_SHATTER_CHANCE))
		return ..()
	var/turf/spot = get_turf(src)
	visible_message(span_warning("[src] shatters on impact!"))
	new /obj/effect/decal/cleanable/debris/glassy(spot)
	playsound(spot, /datum/sound_effect/shatter, 75, TRUE)
	qdel(src)

// Ratwood's clay vessels and ceramic cups are fragile whoever made them (ceramics.dm pottery_fragile = TRUE).

/obj/item/reagent_containers/glass/bottle/claybottle
	rogue_pottery_fragile = TRUE

/obj/item/reagent_containers/glass/bottle/claybottleclassic
	rogue_pottery_fragile = TRUE

/obj/item/reagent_containers/glass/bottle/clayvase
	rogue_pottery_fragile = TRUE

/obj/item/reagent_containers/glass/bottle/clayvaseclassic
	rogue_pottery_fragile = TRUE

/obj/item/reagent_containers/glass/bottle/clayfancyvase
	rogue_pottery_fragile = TRUE

/obj/item/reagent_containers/glass/bottle/clayfancyvaseclassic
	rogue_pottery_fragile = TRUE

/obj/item/reagent_containers/glass/cup/claycup
	rogue_pottery_fragile = TRUE

/obj/item/reagent_containers/glass/cup/claycupclassic
	rogue_pottery_fragile = TRUE

/obj/item/reagent_containers/glass/cup/ceramic
	rogue_pottery_fragile = TRUE

#undef KILN_SHATTER_CHANCE
