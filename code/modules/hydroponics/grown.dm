// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

// Base type. Subtypes are found in /grown dir.
/obj/item/weapon/reagent_containers/food/snacks/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	var/obj/item/seeds/seed = null // type path, gets converted to item on New(). It's safe to assume it's always a seed item.
	var/plantname = ""
	var/bitesize_mod = 0
	var/splat_type = /obj/effect/decal/cleanable/plant_smudge
	// If set, bitesize = 1 + round(reagents.total_volume / bitesize_mod)
	dried_type = -1
	// Saves us from having to define each stupid grown's dried_type as itself.
	// If you don't want a plant to be driable (watermelons) set this to null in the time definition.
	burn_state = FLAMMABLE

/obj/item/weapon/reagent_containers/food/snacks/grown/New(newloc, var/obj/item/seeds/new_seed = null)
	..()
	if(new_seed)
		seed = new_seed.Copy()
	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.adjust_potency(50-seed.potency)

	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(dried_type == -1)
		dried_type = src.type

	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			T.on_new(src, newloc)
		seed.prepare_result(src)
		transform *= TransformUsingVariable(seed.potency, 100, 0.5) //Makes the resulting produce's sprite larger or smaller based on potency!
		add_juice()



/obj/item/weapon/reagent_containers/food/snacks/grown/proc/add_juice()
	if(reagents)
		if(bitesize_mod)
			bitesize = 1 + round(reagents.total_volume / bitesize_mod)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/snacks/grown/examine(user)
	..()
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			if(T.examine_line)
				user << T.examine_line

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(obj/item/O, mob/user, params)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		var/msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>.\n"
		if(seed)
			msg += seed.get_analyzer_text()
		msg += "\n- Nutritional value: [reagents.get_reagent_amount("nutriment")]\n"
		msg += "- Other substances: [reagents.total_volume-reagents.get_reagent_amount("nutriment")]\n"
		msg += "*---------*</span>"

		var/list/scannable_reagents = list("charcoal" = "Anti-Toxin", "morphine" = "Morphine", "amatoxin" = "Amatoxins",
			"toxin" = "Toxins", "mushroomhallucinogen" = "Mushroom Hallucinogen", "condensedcapsaicin" = "Condensed Capsaicin",
			"capsaicin" = "Capsaicin", "frostoil" = "Frost Oil", "gold" = "Mineral Content", "glycerol" = "Glycerol",
			"radium" = "Highly Radioactive Material", "uranium" = "Radioactive Material")
		var/reag_txt = ""
		if(seed)
			for(var/reagent_id in scannable_reagents)
				if(reagent_id in seed.reagents_add)
					var/amt = reagents.get_reagent_amount(reagent_id)
					reag_txt += "\n<span class='info'>- [scannable_reagents[reagent_id]]: [amt*100/reagents.maximum_volume]%</span>"

		if(reag_txt)
			msg += reag_txt
			msg += "<br><span class='info'>*---------*</span>"
		user << msg
		return
	return


// Various gene procs
/obj/item/weapon/reagent_containers/food/snacks/grown/attack_self(mob/user)
	if(seed && seed.get_gene(/datum/plant_gene/trait/squash))
		squash(user)
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/throw_impact(atom/hit_atom)
	if(!..()) //was it caught by a mob?
		if(seed && seed.get_gene(/datum/plant_gene/trait/squash))
			squash(hit_atom)

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/squash(atom/target)
	var/turf/T = get_turf(target)
	if(ispath(splat_type, /obj/effect/decal/cleanable/plant_smudge))
		if(filling_color)
			var/obj/O = new splat_type(T)
			O.color = filling_color
			O.name = "[name] smudge"
	else if(splat_type)
		new splat_type(T)

	if(trash)
		if(ispath(trash, /obj/item/weapon/grown) || ispath(trash, /obj/item/weapon/reagent_containers/food/snacks/grown))
			new trash(T, seed)
		else
			new trash(T)

	visible_message("<span class='warning'>[src] has been squashed.</span>","<span class='italics'>You hear a smack.</span>")
	if(seed)
		for(var/datum/plant_gene/trait/trait in seed.genes)
			trait.on_squash(src, target)

	for(var/A in T)
		reagents.reaction(A)

	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/On_Consume()
	if(iscarbon(usr))
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_consume(src, usr)
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/Crossed(atom/movable/AM)
	if(seed)
		var/datum/plant_gene/trait/slip/S = seed.get_gene(/datum/plant_gene/trait/slip)
		if(S && !ispath(trash, /obj/item/weapon/grown) && iscarbon(AM))
			var/mob/living/carbon/M = AM
			var/stun = max(seed.potency * S.rate * 2, 1)
			var/weaken = max(seed.potency * S.rate, 0.5)
			if(M.slip(stun, weaken, src))
				for(var/datum/plant_gene/trait/T in seed.genes)
					T.on_slip(src, M)
			return 1
	..()


// Glow gene procs
/obj/item/weapon/reagent_containers/food/snacks/grown/Destroy()
	if(seed)
		var/datum/plant_gene/trait/glow/G = seed.get_gene(/datum/plant_gene/trait/glow)
		if(G && ismob(loc))
			loc.AddLuminosity(-G.get_lum(seed))
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/pickup(mob/user)
	..()
	if(seed)
		var/datum/plant_gene/trait/glow/G = seed.get_gene(/datum/plant_gene/trait/glow)
		if(G)
			SetLuminosity(0)
			user.AddLuminosity(G.get_lum(seed))

/obj/item/weapon/reagent_containers/food/snacks/grown/dropped(mob/user)
	..()
	if(seed)
		var/datum/plant_gene/trait/glow/G = seed.get_gene(/datum/plant_gene/trait/glow)
		if(G)
			user.AddLuminosity(-G.get_lum(seed))
			SetLuminosity(G.get_lum(seed))



// For item-containing growns such as eggy or gatfruit
/obj/item/weapon/reagent_containers/food/snacks/grown/shell/attack_self(mob/user as mob)
	user.unEquip(src)
	if(trash)
		var/obj/item/weapon/T
		if(ispath(trash, /obj/item/weapon/grown) || ispath(trash, /obj/item/weapon/reagent_containers/food/snacks/grown))
			T = new trash(user.loc, seed)
		else
			T = new trash(user.loc)
		user.put_in_hands(T)
		user << "<span class='notice'>You open [src]\'s shell, revealing \a [T].</span>"
	qdel(src)
