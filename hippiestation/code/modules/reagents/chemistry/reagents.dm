/datum/reagent
	reagent_state = LIQUID//since reagent states are now interchangeable it makes sense for them to all start as liquids preventing unnescessary messages
	var/boiling_point = 500//the point at which a reagent changes from a liquid to a gaseous state
	var/melting_point = 273//the point at which a reagent changes from a liquid to a solid state
	var/processes = FALSE

/datum/reagent/New()
	..()
	if(processes)
		START_PROCESSING(SSreagent_states, src)

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	if(processes)
		STOP_PROCESSING(SSreagent_states, src)
	holder = null

/datum/reagent/proc/FINISHONMOBLIFE(mob/living/M)
	current_cycle++
	M.reagents.remove_reagent(src.id, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.
	return TRUE

/datum/reagent/proc/handle_state_change(turf/T, volume, atom)
	var/touch_msg
	var/list/holder_blacklist_typecache = list(/obj/effect/particle_effect/water, /obj/effect/decal/cleanable, /mob/living)//blacklisted to prevent spam or other unforeseen consequences
	holder_blacklist_typecache = typecacheof(holder_blacklist_typecache)
	if(!istype(T))
		return
	if(isspaceturf(T))
		return
	if(!volume)
		return
	if(volume * 0.25 < 1)
		return

	if(atom)
		if(is_type_in_typecache(atom, holder_blacklist_typecache))
			return
		if(istype(atom, /obj/item))
			var/obj/item/I = atom
			touch_msg = I.fingerprintslast
			if(touch_msg)
				touch_msg = get_mob_by_key(touch_msg)
				touch_msg = "[ADMIN_LOOKUPFLW(touch_msg)]"

//vapour
	var/list/gas_reagent_blacklist = list("plasma", "oxygen", "nitrogen", "nitrous_oxide")//blacklisted paradoxical reagents such as plasma gas vapour
	if(src.reagent_state == GAS)
		if(src.id in gas_reagent_blacklist)
			return

		var/turf/open/O = T
		if(istype(O))
			var/obj/effect/particle_effect/vapour/foundvape = locate() in T//if there's an existing vapour of the same type it just adds volume otherwise it creates a new instance
			if(foundvape && foundvape.reagent_type == src)
				foundvape.VM.volume = volume*50
			else
				var/obj/effect/particle_effect/vapour/master/V = new(O)
				V.volume = volume*50
				V.reagent_type = src
			log_game("Reagent vapour of type [src.name] was released at [COORD(T)] Last Fingerprint: [touch_msg] ")
//liquid
	var/list/chempile_reagent_blacklist = list("water", "lube", "bleach", "cleaner", "colorful_reagent", "condensedcapsaicin", "radium", "thermite")//add stuff that doesn't make sense/is too op for turfchems
	if(src.reagent_state == LIQUID)
		if(src.id in chempile_reagent_blacklist)
			return

		if(atom && istype(atom, /obj/effect/particle_effect))
			volume = volume * 0.1//big nerf to smoke and foam duping

		for(var/obj/effect/decal/cleanable/chempile/c in T.contents)//handles merging existing chempiles
			if(c.reagents)
				c.reagents.add_reagent("[src.id]", volume * 0.25)
				var/mixcolor = mix_color_from_reagents(c.reagents.reagent_list)
				c.add_atom_colour(mixcolor, FIXED_COLOUR_PRIORITY)
				if(c.reagents && c.reagents.total_volume < 5 & REAGENT_NOREACT)
					c.reagents.set_reacting(TRUE)
				return TRUE

		var/obj/effect/decal/cleanable/chempile/C = new /obj/effect/decal/cleanable/chempile(T)//otherwise makes a new one
		C.reagents.add_reagent("[src.id]", volume * 0.25)
		var/mixcolor = mix_color_from_reagents(C.reagents.reagent_list)
		C.add_atom_colour(mixcolor, FIXED_COLOUR_PRIORITY)
//solid
	var/list/solid_reagent_blacklist = list("radium")
	if(src.reagent_state == SOLID)
		if(src.id in solid_reagent_blacklist)
			return

		if(atom && istype(atom, /obj/effect/particle_effect))
			volume = volume * 0.1//big nerf to smoke and foam duping

		for(var/obj/item/reagent_containers/food/snacks/solid_reagent/SR in T.contents)
			if(SR.reagents && SR.reagent_type == src.id && SR.reagents.total_volume < 200)
				SR.reagents.add_reagent("[src.id]", volume)
				SR.bitecount = SR.reagents.total_volume*0.5
				return TRUE

		var/obj/item/reagent_containers/food/snacks/solid_reagent/Sr = new /obj/item/reagent_containers/food/snacks/solid_reagent(T)
		Sr.reagents.add_reagent("[src.id]", volume)
		Sr.reagent_type = src.id
		Sr.bitecount = Sr.reagents.total_volume*0.5
		Sr.name = "solidified [src.name]"
		Sr.add_atom_colour(src.color, FIXED_COLOUR_PRIORITY)
		Sr.filling_color = src.color