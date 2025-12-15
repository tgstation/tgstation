/// Global list of available atom skins
GLOBAL_LIST_INIT_TYPED(atom_skins, /datum/atom_skin, init_subtypes_w_path_keys(/datum/atom_skin))

/// Sets the atom's varname to newvalue if newvalue is not null, otherwise resets it to its initial value if resetcondition is true
#define APPLY_VAR_OR_RESET_INITIAL(atom, varname, newvalue, resetcondition) \
	if(newvalue) {atom.##varname = (##newvalue) } else if(resetcondition) { atom.##varname = initial(atom.##varname) }

/// Sets the atom's varname to newvalue if newvalue is not null, otherwise sets it to resetvalue if resetcondition is true
#define APPLY_VAR_OR_RESET_TO(atom, varname, newvalue, resetcondition, resetvalue) \
	if(newvalue) {atom.##varname = (##newvalue) } else if(resetcondition) { atom.##varname = (resetvalue) }

/// Resets the atom's varname to its initial value if oldvalue is not null
#define RESET_INITIAL_IF_SET(atom, varname, oldvalue) \
	if(oldvalue) { atom.##varname = initial(atom.##varname) }

/// Sets the atom's varname to resetvalue if oldvalue is not null
#define RESET_TO_IF_SET(atom, varname, oldvalue, resetvalue) \
	if(oldvalue) { atom.##varname = (resetvalue) }
