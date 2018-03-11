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
	var/mob/living/touch_mob
	if(!istype(T))
		return
	if(is_type_in_typecache(T, GLOB.statechange_turf_blacklist))
		return
	if(!volume)
		return
	if(volume * 0.25 < 1)
		return
	if(atom)
		if(is_type_in_typecache(atom, GLOB.no_reagent_statechange_typecache))
			return
		if(istype(atom, /obj/item))
			var/obj/item/I = atom
			touch_mob = I.fingerprintslast
			if(istype(touch_mob))
				touch_msg = get_mob_by_key(touch_mob)
				touch_msg = "[ADMIN_LOOKUPFLW(touch_msg)]"

	if(is_type_in_typecache(src, GLOB.statechange_reagent_blacklist)) //Reagent states are interchangeable, so one blacklist to rule them all.
		return

	if(src.reagent_state == GAS) //VAPOR
		if(atom && istype(atom, /obj/effect/particle_effect))
			volume = volume * GAS_PARTICLE_EFFECT_EFFICIENCY//big nerf to smoke and foam duping

		var/turf/open/O = T
		if(istype(O))
			var/obj/effect/particle_effect/vapour/foundvape = locate() in T//if there's an existing vapour of the same type it just adds volume otherwise it creates a new instance
			if(foundvape && foundvape.reagent_type == src)
				foundvape.VM.volume = volume*50
			else
				var/obj/effect/particle_effect/vapour/master/V = new(O)
				V.volume = volume*50
				var/paths = subtypesof(/datum/reagent)
				for(var/path in paths)
					var/datum/reagent/RR = new path
					if(RR.id == id)
						V.reagent_type = RR
						break
					else
						qdel(RR)
			log_game("Reagent vapour of type [src] was released at [COORD(T)] Last Fingerprint: [touch_msg] ")


	if(src.reagent_state == LIQUID) //LIQUID
		if(atom && istype(atom, /obj/effect/particle_effect))
			volume = volume * LIQUID_PARTICLE_EFFECT_EFFICIENCY//big nerf to smoke and foam duping

		for(var/obj/effect/decal/cleanable/chempile/c in T.contents)//handles merging existing chempiles
			if(c.reagents)
				if(touch_msg)
					c.add_fingerprint(touch_mob)
				c.reagents.add_reagent("[src.id]", volume)
				var/mixcolor = mix_color_from_reagents(c.reagents.reagent_list)
				c.add_atom_colour(mixcolor, FIXED_COLOUR_PRIORITY)
				if(c.reagents && c.reagents.total_volume < 5 & REAGENT_NOREACT)
					c.reagents.set_reacting(TRUE)
				return TRUE

		var/obj/effect/decal/cleanable/chempile/C = new /obj/effect/decal/cleanable/chempile(T)//otherwise makes a new one
		if(touch_msg)
			C.add_fingerprint(touch_mob)
		C.reagents.add_reagent("[src.id]", volume)
		var/mixcolor = mix_color_from_reagents(C.reagents.reagent_list)
		C.add_atom_colour(mixcolor, FIXED_COLOUR_PRIORITY)

	if(src.reagent_state == SOLID) //SOLID
		if(atom && istype(atom, /obj/effect/particle_effect))
			volume = volume * SOLID_PARTICLE_EFFECT_EFFICIENCY//big nerf to smoke and foam duping

		for(var/obj/item/reagent_containers/food/snacks/solid_reagent/SR in T.contents)
			if(SR.reagents && SR.reagent_type == src.id && SR.reagents.total_volume < 200)
				if(touch_msg)
					SR.add_fingerprint(touch_mob)
				SR.reagents.add_reagent("[src.id]", volume)
				SR.bitecount = SR.reagents.total_volume*0.5
				return TRUE

		var/obj/item/reagent_containers/food/snacks/solid_reagent/Sr = new /obj/item/reagent_containers/food/snacks/solid_reagent(T)
		if(touch_msg)
			Sr.add_fingerprint(touch_mob)
		Sr.reagents.add_reagent("[src.id]", volume)
		Sr.reagent_type = src.id
		Sr.bitecount = Sr.reagents.total_volume*0.5
		Sr.name = "solidified [src]"
		Sr.add_atom_colour(src.color, FIXED_COLOUR_PRIORITY)
		Sr.filling_color = src.color
