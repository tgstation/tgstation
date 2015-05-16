//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

var/const/TOUCH = 1
var/const/INGEST = 2

///////////////////////////////////////////////////////////////////////////////////

datum/reagents
	var/list/datum/reagent/reagent_list = new/list()
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/chem_temp = 150
	var/last_tick = 1
	var/addiction_tick = 1
	var/list/datum/reagent/addiction_list = new/list()

datum/reagents/New(maximum=100)
	maximum_volume = maximum
	SSobj.processing |= src
	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!chemical_reagents_list)
		//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
		var/paths = typesof(/datum/reagent) - /datum/reagent
		chemical_reagents_list = list()
		for(var/path in paths)
			var/datum/reagent/D = new path()
			chemical_reagents_list[D.id] = D
	if(!chemical_reactions_list)
		//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
		// It is filtered into multiple lists within a list.
		// For example:
		// chemical_reaction_list["plasma"] is a list of all reactions relating to plasma

		var/paths = typesof(/datum/chemical_reaction) - /datum/chemical_reaction
		chemical_reactions_list = list()

		for(var/path in paths)

			var/datum/chemical_reaction/D = new path()
			var/list/reaction_ids = list()

			if(D.required_reagents && D.required_reagents.len)
				for(var/reaction in D.required_reagents)
					reaction_ids += reaction

			// Create filters based on each reagent id in the required reagents list
			for(var/id in reaction_ids)
				if(!chemical_reactions_list[id])
					chemical_reactions_list[id] = list()
				chemical_reactions_list[id] += D
				break // Don't bother adding ourselves to other reagent ids, it is redundant.

datum/reagents/Destroy()
	..()
	SSobj.processing.Remove(src)
	for(var/datum/reagent/R in reagent_list)
		qdel(R)
	reagent_list.Cut()
	reagent_list = null
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null

datum/reagents/proc/remove_any(var/amount=1)
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1,reagent_list.len)

	while(total_transfered != amount)
		if(total_transfered >= amount) break
		if(total_volume <= 0 || !reagent_list.len) break

		if(current_list_element > reagent_list.len) current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]

		src.remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++
		src.update_total()

	handle_reactions()
	return total_transfered

datum/reagents/proc/get_master_reagent_name()
	var/the_name = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_name = A.name

	return the_name

datum/reagents/proc/get_master_reagent_id()
	var/the_id = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_id = A.id

	return the_id

datum/reagents/proc/trans_to(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	if (!target )
		return
	var/datum/reagents/R
	if(istype(target,/datum/reagents/))
		R = target
	else
		if (!target.reagents || src.total_volume<=0)
			return
		R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (current_reagent.id == "blood" && ishuman(target))
			var/mob/living/carbon/human/H = target
			H.inject_blood(my_atom, amount)
			continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = copy_data(current_reagent)
		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, src.chem_temp)
		src.remove_reagent(current_reagent.id, current_reagent_transfer)

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount

datum/reagents/proc/copy_to(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1)
	if(!target)
		return
	if(!target.reagents || src.total_volume<=0)
		return
	var/datum/reagents/R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data
		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data)

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount

datum/reagents/proc/trans_id_to(var/obj/target, var/reagent, var/amount=1, var/preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if(current_reagent.id == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.id, amount, trans_data, src.chem_temp)
			src.remove_reagent(current_reagent.id, amount, 1)
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	//src.handle_reactions() Don't need to handle reactions on the source since you're (presumably isolating and) transferring a specific reagent.
	return amount

/*
				if (!target) return
				var/total_transfered = 0
				var/current_list_element = 1
				var/datum/reagents/R = target.reagents
				var/trans_data = null
				//if(R.total_volume + amount > R.maximum_volume) return 0

				current_list_element = rand(1,reagent_list.len) //Eh, bandaid fix.

				while(total_transfered != amount)
					if(total_transfered >= amount) break //Better safe than sorry.
					if(total_volume <= 0 || !reagent_list.len) break
					if(R.total_volume >= R.maximum_volume) break

					if(current_list_element > reagent_list.len) current_list_element = 1
					var/datum/reagent/current_reagent = reagent_list[current_list_element]
					if(preserve_data)
						trans_data = current_reagent.data
					R.add_reagent(current_reagent.id, (1 * multiplier), trans_data)
					src.remove_reagent(current_reagent.id, 1)

					current_list_element++
					total_transfered++
					src.update_total()
					R.update_total()
				R.handle_reactions()
				handle_reactions()

				return total_transfered
*/

datum/reagents/proc/metabolize(var/mob/M)
	if(M)
		chem_temp = M.bodytemperature
		handle_reactions()

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(!R.holder)
			continue
		if(!M)
			M = R.holder.my_atom
		if(M && R)
			if(M.reagent_check(R) != 1)
				if(R.overdose_threshold)
					if(R.volume >= R.overdose_threshold && !R.overdosed)
						R.overdosed = 1
						R.overdose_start(M)
				if(R.addiction_threshold)
					if(R.volume >= R.addiction_threshold && !is_type_in_list(R, addiction_list))
						var/datum/reagent/new_reagent = new R.type()
						addiction_list.Add(new_reagent)
				if(R.overdosed)
					R.overdose_process(M)
				if(is_type_in_list(R,addiction_list))
					for(var/datum/reagent/addicted_reagent in addiction_list)
						if(istype(R, addicted_reagent))
							addicted_reagent.addiction_stage = -15 // you're satisfied for a good while.
				R.on_mob_life(M)

	if(addiction_tick == 6)
		addiction_tick = 1
		for(var/A in addiction_list)
			var/datum/reagent/R = A
			if(M && R)
				if(R.addiction_stage <= 0)
					R.addiction_stage++
				if(R.addiction_stage > 0 && R.addiction_stage <= 10)
					R.addiction_act_stage1(M)
					R.addiction_stage++
				if(R.addiction_stage > 10 && R.addiction_stage <= 20)
					R.addiction_act_stage2(M)
					R.addiction_stage++
				if(R.addiction_stage > 20 && R.addiction_stage <= 30)
					R.addiction_act_stage3(M)
					R.addiction_stage++
				if(R.addiction_stage > 30 && R.addiction_stage <= 40)
					R.addiction_act_stage4(M)
					R.addiction_stage++
				if(R.addiction_stage > 40)
					M << "<span class = 'notice'>You feel like you've gotten over your need for [R.name].</span>"
					addiction_list.Remove(R)
	addiction_tick++
	update_total()

datum/reagents/process()
	for(var/datum/reagent/R in reagent_list)
		R.on_tick()
	return

datum/reagents/proc/conditional_update_move(var/atom/A, var/Running = 0)
	for(var/datum/reagent/R in reagent_list)
		R.on_move (A, Running)
	update_total()

datum/reagents/proc/conditional_update(var/atom/A)
	for(var/datum/reagent/R in reagent_list)
		R.on_update (A)
	update_total()

datum/reagents/proc/handle_reactions()
	if(my_atom.flags & NOREACT) return //Yup, no reactions here. No siree.

	var/reaction_occured = 0
	do
		reaction_occured = 0
		for(var/datum/reagent/R in reagent_list) // Usually a small list
			for(var/reaction in chemical_reactions_list[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id

				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction
				var/total_required_reagents = C.required_reagents.len
				var/total_matching_reagents = 0
				var/total_required_catalysts = C.required_catalysts.len
				var/total_matching_catalysts= 0
				var/matching_container = 0
				var/matching_other = 0
				var/list/multipliers = new/list()
				var/required_temp = C.required_temp

				for(var/B in C.required_reagents)
					if(!has_reagent(B, C.required_reagents[B]))	break
					total_matching_reagents++
					multipliers += round(get_reagent_amount(B) / C.required_reagents[B])
				for(var/B in C.required_catalysts)
					if(!has_reagent(B, C.required_catalysts[B]))	break
					total_matching_catalysts++

				if(!C.required_container)
					matching_container = 1

				else
					if(my_atom.type == C.required_container)
						matching_container = 1
				if (isliving(my_atom)) //Makes it so certain chemical reactions don't occur in mobs
					if (C.mob_react)
						return
				if(!C.required_other)
					matching_other = 1

				else if(istype(my_atom, /obj/item/slime_extract))
					var/obj/item/slime_extract/M = my_atom

					if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
						matching_other = 1

				if(required_temp == 0)
					required_temp = chem_temp


				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other && chem_temp >= required_temp)
					var/multiplier = min(multipliers)
					for(var/B in C.required_reagents)
						remove_reagent(B, (multiplier * C.required_reagents[B]), safety = 1)

					var/created_volume = C.result_amount*multiplier
					if(C.result)
						feedback_add_details("chemical_reaction","[C.result]|[C.result_amount*multiplier]")
						multiplier = max(multiplier, 1) //this shouldnt happen ...
						add_reagent(C.result, C.result_amount*multiplier, null, chem_temp)

					var/list/seen = viewers(4, get_turf(my_atom))

					if(!istype(my_atom, /mob)) // No bubbling mobs
						playsound(get_turf(my_atom), 'sound/effects/bubbles.ogg', 80, 1)
						for(var/mob/M in seen)
							M << "<span class='notice'>\icon[my_atom] [C.mix_message]</span>"

					if(istype(my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/ME2 = my_atom
						ME2.Uses--
						if(ME2.Uses <= 0) // give the notification that the slime core is dead
							for(var/mob/M in seen)
								M << "<span class='notice'>\icon[my_atom] \The [my_atom]'s power is consumed in the reaction.</span>"
								ME2.name = "used slime extract"
								ME2.desc = "This extract has been used up."

					C.on_reaction(src, created_volume)
					reaction_occured = 1
					break

	while(reaction_occured)
	update_total()
	return 0

datum/reagents/proc/isolate_reagent(var/reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id != reagent)
			del_reagent(R.id)
			update_total()

datum/reagents/proc/del_reagent(var/reagent)
	for(var/datum/reagent/R in reagent_list)
		if (R.id == reagent)
			if(istype(my_atom, /mob/living))
				var/mob/living/M = my_atom
				R.on_mob_delete(M)
			qdel(R)
			reagent_list -= R
			update_total()
			my_atom.on_reagent_change()
			check_ignoreslow(my_atom)
			check_gofast(my_atom)
			check_goreallyfast(my_atom)
	return 1

datum/reagents/proc/check_ignoreslow(var/mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("morphine")||M.reagents.has_reagent("ephedrine"))
			return 1
		else
			M.status_flags &= ~IGNORESLOWDOWN

datum/reagents/proc/check_gofast(var/mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("unholywater")||M.reagents.has_reagent("nuka_cola"))
			return 1
		else
			M.status_flags &= ~GOTTAGOFAST

datum/reagents/proc/check_goreallyfast(var/mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("methamphetamine"))
			return 1
		else
			M.status_flags &= ~GOTTAGOREALLYFAST

datum/reagents/proc/update_total()
	total_volume = 0
	for(var/datum/reagent/R in reagent_list)
		if(R.volume < 0.1)
			del_reagent(R.id)
		else
			total_volume += R.volume

	return 0

datum/reagents/proc/clear_reagents()
	for(var/datum/reagent/R in reagent_list)
		del_reagent(R.id)
	return 0

datum/reagents/proc/reaction(var/atom/A, var/method=TOUCH, var/volume_modifier=1,var/show_message=1)
	for(var/datum/reagent/R in reagent_list)
		if(ismob(A))
			R.reaction_mob(A, method, R.volume*volume_modifier, show_message)
		if(isturf(A))
			R.reaction_turf(A, R.volume*volume_modifier, show_message)
		if(isobj(A))
			R.reaction_obj(A, R.volume*volume_modifier, show_message)

	return

datum/reagents/proc/add_reagent(var/reagent, var/amount, var/list/data=null, var/reagtemp = 300)
	if(!isnum(amount)) return 1
	update_total()
	if(total_volume + amount > maximum_volume) amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.
	chem_temp = round(((amount * reagtemp) + (total_volume * chem_temp)) / (total_volume + amount)) //equalize with new chems

	for(var/A in reagent_list)

		var/datum/reagent/R = A
		if (R.id == reagent)
			R.volume += amount
			update_total()
			my_atom.on_reagent_change()
			R.on_merge(data)
			handle_reactions()
			return 0

	var/datum/reagent/D = chemical_reagents_list[reagent]
	if(D)

		var/datum/reagent/R = new D.type(data)
		reagent_list += R
		R.holder = src
		R.volume = amount
		if(data)
			R.data = data
			R.on_new(data)

		//debug
		//world << "Adding data"
		//for(var/D in R.data)
		//	world << "Container data: [D] = [R.data[D]]"
		//debug
		update_total()
		my_atom.on_reagent_change()
		handle_reactions()
		return 0
	else
		WARNING("[my_atom] attempted to add a reagent called ' [reagent] ' which doesn't exist. ([usr])")

	handle_reactions()

	return 1

datum/reagents/proc/add_reagent_list(var/list/list_reagents, var/list/data=null) // Like add_reagent but you can enter a list. Format it like this: list("toxin" = 10, "beer" = 15)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)

datum/reagents/proc/remove_reagent(var/reagent, var/amount, var/safety)//Added a safety check for the trans_id_to

	if(!isnum(amount)) return 1

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			my_atom.on_reagent_change()
			return 0

	return 1

datum/reagents/proc/has_reagent(var/reagent, var/amount = -1)

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			if(!amount) return R
			else
				if(R.volume >= amount) return R
				else return 0

	return 0

datum/reagents/proc/get_reagent_amount(var/reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			return R.volume

	return 0

datum/reagents/proc/get_reagents()
	var/res = ""
	for(var/datum/reagent/A in reagent_list)
		if (res != "") res += ","
		res += A.name

	return res

datum/reagents/proc/remove_all_type(var/reagent_type, var/amount, var/strict = 0, var/safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount)) return 1

	var/has_removed_reagent = 0

	for(var/datum/reagent/R in reagent_list)
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.id, amount, safety)

	return has_removed_reagent

			//two helper functions to preserve data across reactions (needed for xenoarch)
datum/reagents/proc/get_data(var/reagent_id)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
			//world << "proffering a data-carrying reagent ([reagent_id])"
			return D.data

datum/reagents/proc/set_data(var/reagent_id, var/new_data)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
			//world << "reagent data set ([reagent_id])"
			D.data = new_data

datum/reagents/proc/copy_data(var/datum/reagent/current_reagent)
	if (!current_reagent || !current_reagent.data) return null
	if (!istype(current_reagent.data, /list)) return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	// We do this so that introducing a virus to a blood sample
	// doesn't automagically infect all other blood samples from
	// the same donor.
	//
	// Technically we should probably copy all data lists, but
	// that could possibly eat up a lot of memory needlessly
	// if most data lists are read-only.
	if (trans_data["viruses"])
		var/list/v = trans_data["viruses"]
		trans_data["viruses"] = v.Copy()

	return trans_data


///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
atom/proc/create_reagents(var/max_vol)
	if(reagents)
		qdel(reagents)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src
