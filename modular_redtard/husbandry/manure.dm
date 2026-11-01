/// Manure (Ratwood simple_animal.dm Life() and poop(), pooptype; rogueitems/natural/poo.dm): a beast that has food in it drops
/// its droppings where it stands every so often. They fertilize the soil beds of farming/ and go into crafting.
/// Unlike Ratwood a tile holds only so many droppings (manure_tile_cap), so a herd does not bury its pasture.
/mob/living/basic/rockhill
	/// Ratwood pooptype: what this kind drops; null - nothing.
	var/rogue_manure_type

/datum/component/rogue_livestock
	/// Seconds the beast has had food in it since its last droppings (Ratwood pooprog).
	var/manure = 0

/// Called while the beast has food in it: once enough time has passed, droppings fall where it stands.
/datum/component/rogue_livestock/proc/digest(mob/living/basic/rockhill/beast, seconds_per_tick)
	if(!beast.rogue_manure_type)
		return
	manure += seconds_per_tick
	if(manure < ROGUE_MANURE_TIME || !isturf(beast.loc))
		return
	var/cap = ROGUE_MANURE_TILE_CAP
	if(cap > 0)
		var/lying = 0
		for(var/obj/item/natural/poo/droppings in beast.loc)
			lying++
			if(lying >= cap)
				return
	manure = 0
	new beast.rogue_manure_type(beast.loc)
