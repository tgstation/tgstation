/datum/component/bloody_spreader
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	// How many bloodening instances are left. Deleted on zero.
	var/blood_left
	// We will spread this blood DNA to targets!
	var/list/blood_dna
	// Blood splashed around everywhere will carry these diseases. Oh no...
	var/list/diseases

/datum/component/bloody_spreader/Initialize(blood_left = INFINITY, list/blood_dna, list/diseases)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/list/signals_to_add = list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_BLOB_ACT, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACKBY)
	if(ismovable(parent))
		signals_to_add += list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_IMPACT)
		if(isitem(parent))
			signals_to_add += list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_ATOM, COMSIG_ITEM_HIT_REACT, COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED)
		var/atom/atom_parent = parent
		if(atom_parent.atom_storage)
			signals_to_add += list(COMSIG_ATOM_STORED_ITEM)
		else if(isstructure(parent))
			signals_to_add += list(COMSIG_ATOM_ATTACK_HAND)

	RegisterSignals(parent, signals_to_add, PROC_REF(spread_yucky_blood))

	if(isclothing(parent))
		parent.AddComponent(/datum/component/bloodysoles)

	src.blood_left = blood_left
	src.blood_dna = blood_dna
	src.diseases = diseases

/datum/component/bloody_spreader/proc/spread_yucky_blood(atom/parent, atom/bloody_fool)
	SIGNAL_HANDLER
	if(ishuman(bloody_fool))
		var/mob/living/carbon/human/bloody_fool_human = bloody_fool
		bloody_fool_human.add_blood_DNA_to_items(blood_dna, ITEM_SLOT_GLOVES)
		blood_left -= 3
	else
		bloody_fool.add_blood_DNA(blood_dna, diseases)
		blood_left -= 1
	if(blood_left <= 0)
		qdel(src)

/datum/component/bloody_spreader/InheritComponent(/datum/component/new_comp, i_am_original, blood_left = 0)

	if(!i_am_original)
		return

	if(src.blood_left >= INFINITY)
		return

	src.blood_left += blood_left
