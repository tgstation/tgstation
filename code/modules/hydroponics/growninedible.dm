// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	burn_state = FLAMMABLE
	var/obj/item/seeds/seed = null // type path, gets converted to item on New(). It's safe to assume it's always a seed item.

/obj/item/weapon/grown/New(newloc, var/obj/item/seeds/new_seed = null)
	..()
	create_reagents(50)

	if(new_seed)
		seed = new_seed.Copy()
	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.potency = 50
		seed.prepare_result(src)
	else // Something is terribly wrong
		qdel(src)
		return

	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	add_juice()

	transform *= TransformUsingVariable(seed.potency, 100, 0.5)

	var/datum/plant_gene/trait/glow/G = seed.get_gene(/datum/plant_gene/trait/glow)
	if(G)
		if(istype(src.loc,/mob))
			pickup(src.loc)//adjusts the lighting on the mob
		else
			src.SetLuminosity(G.get_lum(seed))

/obj/item/weapon/grown/attackby(obj/item/O, mob/user, params)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		var/msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>\n"
		msg += seed.get_analyzer_text()
		msg += "</span>"
		usr << msg
		return

/obj/item/weapon/grown/proc/add_juice()
	if(reagents)
		return 1
	return 0


/obj/item/weapon/grown/Crossed(AM as mob|obj)
	var/datum/plant_gene/trait/slip/S = seed.get_gene(/datum/plant_gene/trait/slip)
	if(S && istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		var/stun = min(seed.potency * S.rate * 2, 1)
		var/weaken = min(seed.potency * S.rate, 0.5)
		if(M.slip(stun, weaken, src))
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_slip(src, M)
			return 1
	..()


// Glow gene procs
/obj/item/weapon/grown/Destroy()
	var/datum/plant_gene/trait/glow/G = seed.get_gene(/datum/plant_gene/trait/glow)
	if(G && istype(loc,/mob))
		loc.AddLuminosity(-G.get_lum(seed))
	return ..()

/obj/item/weapon/grown/pickup(mob/user)
	..()
	var/datum/plant_gene/trait/glow/G = seed.get_gene(/datum/plant_gene/trait/glow)
	if(G)
		SetLuminosity(0)
		user.AddLuminosity(G.get_lum(seed))

/obj/item/weapon/grown/dropped(mob/user)
	..()
	var/datum/plant_gene/trait/glow/G = seed.get_gene(/datum/plant_gene/trait/glow)
	if(G)
		user.AddLuminosity(-G.get_lum(seed))
		SetLuminosity(G.get_lum(seed))