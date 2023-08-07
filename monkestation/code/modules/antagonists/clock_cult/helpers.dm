///check if an atom is on the reebe z level, will also return FALSE if the atom has no z level
/proc/on_reebe(atom/checked_atom)
	if(!checked_atom.z || !is_reebe_level(checked_atom.z))
		return FALSE
	return TRUE

/proc/gods_battle()
	if(GLOB.cult_narsie && GLOB.cult_ratvar)
		var/datum/component/singularity/narsie_singularity_component = GLOB.cult_narsie.singularity?.resolve()
		var/datum/component/singularity/ratvar_singularity_component = GLOB.cult_ratvar.singularity?.resolve()
		if(!narsie_singularity_component || !ratvar_singularity_component)
			message_admins("gods_battle() called without a singularity component on of of the 2 main gods.")
			return FALSE

		narsie_singularity_component.target = GLOB.cult_ratvar
		ratvar_singularity_component.target = GLOB.cult_narsie
		return TRUE
	return FALSE
