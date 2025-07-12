/// Element that blood reagents use to apply their data (not blood regen!) to mobs
/// Only added to blood drawn *from* someone, so don't put behavior that should work with any reagent onto this
/datum/element/blood_reagent
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 3
	/// Blood type associated with this element
	var/datum/blood_type/blood_type

/*
 * Arguments:
 * * blood_source - mob this blood came from, can be null
 * * blood_type - blood type datum we grab data and behavior from, cannot be null
 */
/datum/element/blood_reagent/Attach(datum/reagent/target, mob/living/blood_source, datum/blood_type/blood_type)
	. = ..()
	if (!istype(target) || !istype(blood_type))
		return ELEMENT_INCOMPATIBLE

	src.blood_type = blood_type
	RegisterSignal(target, COMSIG_REAGENT_EXPOSE_MOB, PROC_REF(on_mob_expose))
	RegisterSignal(target, COMSIG_REAGENT_EXPOSE_TURF, PROC_REF(on_turf_expose))
	RegisterSignal(target, COMSIG_REAGENT_EXPOSE_OBJ, PROC_REF(on_obj_expose))
	RegisterSignal(target, COMSIG_REAGENT_ON_MERGE, PROC_REF(on_merge))
	RegisterSignal(target, COMSIG_REAGENT_ON_TRANSFER, PROC_REF(on_transfer))

	if (!target.data)
		target.data = list()

	target.data["blood_type"] = blood_type
	if (blood_type.desc)
		target.description = blood_type.desc
	target.color = blood_type.get_color()


	if (!blood_source)
		target.material = GET_MATERIAL_REF(/datum/material/meat/blood_meat, target)
		return

	target.material = GET_MATERIAL_REF(/datum/material/meat/mob_meat, blood_source)

	var/list/blood_data = blood_source.get_blood_data()
	if(blood_data["viruses"])
		var/list/to_preserve = list()
		for (var/datum/disease/disease in blood_data["viruses"])
			to_preserve += disease.Copy()
		blood_data["viruses"] = to_preserve

	for (var/key in blood_data)
		if (!islist(blood_data[key]))
			target.data[key] = blood_data[key]
			continue

		var/list/data_list = blood_data[key]
		var/list/target_data = target.data[key]
		if (!target_data)
			target.data[key] = data_list.Copy()
		else
			// Concat viruses, resistances, etc
			target_data |= data_list

// Shouldn't realistically happen but just in case
/datum/element/blood_reagent/Detach(datum/reagent/target)
	. = ..()
	UnregisterSignal(target, list(
		COMSIG_REAGENT_EXPOSE_MOB,
		COMSIG_REAGENT_EXPOSE_TURF,
		COMSIG_REAGENT_EXPOSE_OBJ,
		COMSIG_REAGENT_ON_MERGE,
		COMSIG_REAGENT_ON_TRANSFER,
	))

/// Cover the mob in blood and transfer our viruses and resistances to them
/datum/element/blood_reagent/proc/on_mob_expose(
	datum/reagent/source,
	mob/living/exposed_mob,
	methods = TOUCH,
	reac_volume,
	show_message = TRUE,
	touch_protection = 0,
)
	SIGNAL_HANDLER

	if ((methods & (TOUCH | VAPOR)) && reac_volume >= 3 && (blood_type.blood_flags & (BLOOD_ADD_DNA | BLOOD_COVER_MOBS)))
		exposed_mob.add_blood_DNA(list("[source.data?["blood_DNA"] || blood_type.dna_string]" = blood_type))

	// Somehow got a no-data reagent, probably artificially created blood
	if (!source.data)
		return

	if (!(blood_type.blood_flags & BLOOD_TRANSFER_VIRAL_DATA))
		return

	for(var/datum/disease/strain as anything in source.data["viruses"])
		if ((strain.spread_flags & DISEASE_SPREAD_SPECIAL) || (strain.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
			continue

		if (methods & INGEST)
			if (!strain.has_required_infectious_organ(exposed_mob, ORGAN_SLOT_STOMACH))
				continue
			exposed_mob.ForceContractDisease(strain)

		else if (methods & (INJECT|PATCH))
			if (!strain.has_required_infectious_organ(exposed_mob, ORGAN_SLOT_HEART))
				continue
			exposed_mob.ForceContractDisease(strain)

		else if ((methods & (VAPOR|INHALE)) && (strain.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
			if (!strain.has_required_infectious_organ(exposed_mob, ORGAN_SLOT_LUNGS))
				continue
			exposed_mob.ContactContractDisease(strain)

		else if ((methods & TOUCH) && (strain.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
			exposed_mob.ContactContractDisease(strain)

	/// Have to inject, inhale or ingest it. No curefoam/cheap curesprays
	if (source.data["resistances"] && (methods & (INGEST|INJECT|INHALE)))
		for(var/datum/disease/infection in exposed_mob.diseases)
			if (!infection.bypasses_immunity && (infection.GetDiseaseID() in source.data["resistances"]))
				infection.cure(add_resistance = FALSE)

/// Create or mix in a blood splatter and transfer our diseases to it
/datum/element/blood_reagent/proc/on_turf_expose(datum/reagent/source, turf/exposed_turf, reac_volume)
	SIGNAL_HANDLER

	if (reac_volume < 3 || !(blood_type.blood_flags & (BLOOD_ADD_DNA | BLOOD_COVER_TURFS)))
		return

	var/dna_list = list("[source.data?["blood_DNA"] || blood_type.dna_string]" = blood_type)
	var/obj/effect/decal/cleanable/blood/splatter = locate() in exposed_turf
	if (!splatter)
		if (!(blood_type.blood_flags & BLOOD_COVER_TURFS))
			return
		splatter = new(exposed_turf, (blood_type.blood_flags & BLOOD_TRANSFER_VIRAL_DATA) ? source.data?["viruses"] : null, dna_list)
		splatter.adjust_bloodiness(-splatter.bloodiness + reac_volume / BLOOD_TO_UNITS_MULTIPLIER)
		return

	splatter.add_blood_DNA(dna_list)
	if (blood_type.blood_flags & BLOOD_COVER_TURFS)
		splatter.adjust_bloodiness(reac_volume / BLOOD_TO_UNITS_MULTIPLIER)

	if (!(blood_type.blood_flags & BLOOD_TRANSFER_VIRAL_DATA) || !source.data?["viruses"])
		return

	var/list/viruses_to_add = list()
	for(var/datum/disease/virus in source.data["viruses"])
		if (virus.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
			viruses_to_add += virus

	if (length(viruses_to_add))
		splatter.AddComponent(/datum/component/infective, viruses_to_add)

/datum/element/blood_reagent/proc/on_obj_expose(datum/reagent/source, obj/exposed_obj, reac_volume, methods = TOUCH, show_message = TRUE)
	SIGNAL_HANDLER

	if (reac_volume < 3 || !(methods & (VAPOR | TOUCH)))
		return

	if (blood_type.blood_flags & (BLOOD_ADD_DNA | BLOOD_COVER_ITEMS))
		exposed_obj.add_blood_DNA(list(list("[source.data?["blood_DNA"] || blood_type.dna_string]" = blood_type) = blood_type))

	if (!(blood_type.blood_flags & BLOOD_TRANSFER_VIRAL_DATA) || !source.data?["viruses"])
		return

	var/list/viruses_to_add = list()
	for (var/datum/disease/virus in source.data["viruses"])
		if (virus.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
			viruses_to_add += virus

	if (length(viruses_to_add))
		exposed_obj.AddComponent(/datum/component/infective, viruses_to_add)

/datum/element/blood_reagent/proc/on_merge(datum/reagent/source, list/mix_data, amount)
	SIGNAL_HANDLER

	// Presumably artificially generated blood
	if (!source.data || !mix_data)
		return

	// Mixed blood cannot be used for cloning
	if (source.data["blood_DNA"] != mix_data["blood_DNA"])
		source.data["cloneable"] = FALSE

	var/list/source_viruses = source.data["viruses"]
	var/list/mix_viruses = mix_data["viruses"]
	if (source_viruses && mix_viruses)
		var/list/mix_target = list()
		var/list/to_preserve = list()
		for (var/datum/disease/disease as anything in source_viruses)
			if (istype(disease, /datum/disease/advance))
				mix_target += disease
			else
				to_preserve += disease

		for (var/datum/disease/disease as anything in mix_viruses)
			if (istype(disease, /datum/disease/advance))
				mix_target += disease
			else
				to_preserve += disease

		var/datum/disease/advance/disease = Advance_Mix(mix_target)
		if (disease)
			to_preserve += disease
		source.data["viruses"] = to_preserve
	else if (mix_viruses)
		source.data["viruses"] = mix_viruses.Copy()

	if (mix_data["resistances"])
		if (!source.data["resistances"])
			source.data["resistances"] = list()
		source.data["resistances"] |= mix_data["resistances"]

	// Features are randomly recombinated based on amount mixed in
	var/list/source_features = source.data["features"]
	var/list/mix_features = mix_data["features"]
	if (source_features && mix_features)
		for (var/feature_key in mix_features)
			if (!source_features[feature_key] || prob(amount / (source.volume + amount) * 100))
				source_features[feature_key] = mix_features[feature_key]

	if (mix_data["trace_chem"])
		if (!source.data["trace_chem"])
			source.data["trace_chem"] = mix_data["trace_chem"]
		else
			source.data["trace_chem"] = list2params(params2list(source.data["trace_chem"]) | params2list(mix_data["trace_chem"]))

/datum/element/blood_reagent/proc/on_transfer(datum/reagent/reagent, datum/reagents/target_holder, datum/reagent/new_reagent)
	SIGNAL_HANDLER
	new_reagent.AddElement(/datum/element/blood_reagent, null, blood_type)
