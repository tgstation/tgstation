//THIS MIGHT BE UNBALANCED SO I DUNNO // it totally is.
/obj/item/twohanded/spear/explosive
	var/throw_hit_chance = 35

/obj/item/twohanded/spear/explosive/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(prob(throw_hit_chance) && iscarbon(hit_atom))
		if(!.) //not caught
			explosive.forceMove(get_turf(src))
			explosive.prime()
			qdel(src)
