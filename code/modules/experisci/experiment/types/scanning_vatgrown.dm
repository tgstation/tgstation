/datum/experiment/scanning/cytology/slime
	name = "Cytology Scanning Experiment"
	description = "Seen the slimes in the xenobiology pens? They spawned when our researchers donked a moldy bread slice into the vat. Cultivate another one and report the results."
	performance_hint = "Swab the slime cell lines from a moldy bread or take a biopsy sample of existing slime. And grow it in the vat."
	exp_tag = "Cytology Scan"
	required_atoms = list(/mob/living/basic/slime = 1)

/datum/experiment/scanning/cytology/slime/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	return ..() && HAS_TRAIT(target, TRAIT_VATGROWN)

/datum/experiment/scanning/cytology/slime/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan samples of \a vat-grown [initial(target.name)]", seen_instances.len, required_atoms[target])
