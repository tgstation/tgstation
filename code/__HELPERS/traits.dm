#define TRAIT_CALLBACK_ADD(target, trait, source) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___TraitAdd), ##target, ##trait, ##source)
#define TRAIT_CALLBACK_REMOVE(target, trait, source) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___TraitRemove), ##target, ##trait, ##source)

///DO NOT USE ___TraitAdd OR ___TraitRemove as a replacement for ADD_TRAIT / REMOVE_TRAIT defines. To be used explicitly for callback.
/proc/___TraitAdd(target,trait,source)
	if(!target || !trait || !source)
		return
	if(islist(target))
		for(var/i in target)
			if(!isatom(i))
				continue
			var/atom/the_atom = i
			ADD_TRAIT(the_atom,trait,source)
	else if(isatom(target))
		var/atom/the_atom2 = target
		ADD_TRAIT(the_atom2,trait,source)

///DO NOT USE ___TraitAdd OR ___TraitRemove as a replacement for ADD_TRAIT / REMOVE_TRAIT defines. To be used explicitly for callback.
/proc/___TraitRemove(target,trait,source)
	if(!target || !trait || !source)
		return
	if(islist(target))
		for(var/i in target)
			if(!isatom(i))
				continue
			var/atom/the_atom = i
			REMOVE_TRAIT(the_atom,trait,source)
	else if(isatom(target))
		var/atom/the_atom2 = target
		REMOVE_TRAIT(the_atom2,trait,source)
