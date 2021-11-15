/datum/reagent/reaction_agent
	name = "Reaction Agent"
	description = "Hello! I am a bugged reagent. Please report me for my crimes. Thank you!!"

/datum/reagent/reaction_agent/intercept_reagents_transfer(datum/reagents/target, amount)
	if(!target)
		return FALSE
	if(target.flags & NO_REACT)
		return FALSE
	if(target.has_reagent(/datum/reagent/stabilizing_agent))
		return FALSE
	if(LAZYLEN(target.reagent_list) == 0)
		return FALSE
	if(LAZYLEN(target.reagent_list) == 1)
		if(target.has_reagent(type)) //Allow dispensing into self
			return FALSE
	return TRUE

/datum/reagent/reaction_agent/acidic_buffer
	name = "Strong Acidic Buffer"
	description = "This reagent will consume itself and move the pH of a beaker towards acidity when added to another."
	color = "#fbc314"
	ph = 0
	impure_chem = null
	inverse_chem = null
	failed_chem = null
	fallback_icon_state = "acid_buffer_fallback"
	///The strength of the buffer where (volume/holder.total_volume)*strength. So for 1u added to 50u the ph will decrease by 0.4
	var/strength = 30

//Consumes self on addition and shifts ph
/datum/reagent/reaction_agent/acidic_buffer/intercept_reagents_transfer(datum/reagents/target, amount)
	. = ..()
	if(!.)
		return
	if(target.ph <= ph)
		target.my_atom.audible_message(span_warning("The beaker froths as the buffer is added, to no effect."))
		playsound(target.my_atom, 'sound/chemistry/bufferadd.ogg', 50, TRUE)
		holder.remove_reagent(type, amount)//Remove from holder because it's not transfered
		return
	var/ph_change = -((amount/target.total_volume)*strength)
	target.adjust_all_reagents_ph(ph_change, ph, 14)
	target.my_atom.audible_message(span_warning("The beaker fizzes as the ph changes!"))
	playsound(target.my_atom, 'sound/chemistry/bufferadd.ogg', 50, TRUE)
	holder.remove_reagent(type, amount)

/datum/reagent/reaction_agent/basic_buffer
	name = "Strong Basic Buffer"
	description = "This reagent will consume itself and move the pH of a beaker towards alkalinity when added to another."
	color = "#3853a4"
	ph = 14
	impure_chem = null
	inverse_chem = null
	failed_chem = null
	fallback_icon_state = "base_buffer_fallback"
	///The strength of the buffer where (volume/holder.total_volume)*strength. So for 1u added to 50u the ph will increase by 0.4
	var/strength = 30

/datum/reagent/reaction_agent/basic_buffer/intercept_reagents_transfer(datum/reagents/target, amount)
	. = ..()
	if(!.)
		return
	if(target.ph >= ph)
		target.my_atom.audible_message(span_warning("The beaker froths as the buffer is added, to no effect."))
		playsound(target.my_atom, 'sound/chemistry/bufferadd.ogg', 50, TRUE)
		holder.remove_reagent(type, amount)//Remove from holder because it's not transfered
		return
	var/ph_change = (amount/target.total_volume)*strength
	target.adjust_all_reagents_ph(ph_change, 0, ph)
	target.my_atom.audible_message(span_warning("The beaker froths as the ph changes!"))
	playsound(target.my_atom, 'sound/chemistry/bufferadd.ogg', 50, TRUE)
	holder.remove_reagent(type, amount)

//purity testor/reaction agent prefactors

/datum/reagent/prefactor_a
	name = "Interim Product Alpha"
	description = "This reagent is a prefactor to the purity tester reagent, and will react with stable plasma to create it"
	color = "#bafa69"

/datum/reagent/prefactor_b
	name = "Interim Product Beta"
	description = "This reagent is a prefactor to the reaction speed agent reagent, and will react with stable plasma to create it"
	color = "#8a3aa9"

/datum/reagent/reaction_agent/purity_tester
	name = "Purity Tester"
	description = "This reagent will consume itself and violently react if there is a highly impure reagent in the beaker."
	ph = 3
	color = "#ffffff"

/datum/reagent/reaction_agent/purity_tester/intercept_reagents_transfer(datum/reagents/target, amount)
	. = ..()
	if(!.)
		return
	var/is_inverse = FALSE
	for(var/_reagent in target.reagent_list)
		var/datum/reagent/reaction_agent/reagent = _reagent
		if(reagent.purity <= reagent.inverse_chem_val)
			is_inverse = TRUE
	if(is_inverse)
		target.my_atom.audible_message(span_warning("The beaker bubbles violently as the reagent is added!"))
		playsound(target.my_atom, 'sound/chemistry/bufferadd.ogg', 50, TRUE)
	else
		target.my_atom.audible_message(span_warning("The added reagent doesn't seem to do much."))
	holder.remove_reagent(type, amount)

/datum/reagent/reaction_agent/speed_agent
	name = "Tempomyocin"
	description = "This reagent will consume itself and speed up an ongoing reaction, modifying the current reaction's purity by it's own."
	ph = 10
	color = "#e61f82"
	///How much the reaction speed is sped up by - for 5u added to 100u, an additional step of 1 will be done up to a max of 2x
	var/strength = 20


/datum/reagent/reaction_agent/speed_agent/intercept_reagents_transfer(datum/reagents/target, amount)
	. = ..()
	if(!.)
		return FALSE
	if(!length(target.reaction_list))//you can add this reagent to a beaker with no ongoing reactions, so this prevents it from being used up.
		return FALSE
	amount /= target.reaction_list.len
	for(var/_reaction in target.reaction_list)
		var/datum/equilibrium/reaction = _reaction
		if(!reaction)
			CRASH("[_reaction] is in the reaction list, but is not an equilibrium")
		var/power = (amount/reaction.target_vol)*strength
		power *= creation_purity
		power = clamp(power, 0, 2)
		reaction.react_timestep(power, creation_purity)
	holder.remove_reagent(type, amount)
