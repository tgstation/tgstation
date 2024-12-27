/datum/experiment/scanning/cytology
	name = "Cytology Scanning Experiment"
	exp_tag = "Cytology Scan"

/datum/experiment/scanning/cytology/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	return ..() && HAS_TRAIT(target, TRAIT_VATGROWN)

/datum/experiment/scanning/cytology/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan samples of \a vat-grown [initial(target.name)]", seen_instances.len, required_atoms[target])

/datum/experiment/scanning/cytology/slime
	name = "Vat-Grown Slime Scan"
	description = "Seen the slimes in the xenobiology pens? They spawned when our researchers donked a moldy bread slice into the vat. Cultivate another one and report the results."
	performance_hint = "Swab the slime cell lines from a moldy bread or take a biopsy sample of existing slime. And grow it in the vat."
	required_atoms = list(/mob/living/basic/slime = 1)


