/**
	The rename component.

	This component is used to manage names and descriptions changed with the pen.

	Atoms can only have one instance of this component at a time.

	When a player renames or changes the description of an atom with a pen, this component gets applied to it.
	If a player resets the name and description, they will be reverted to their state before being changed and the component will be removed.
 */
/datum/component/rename
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///The name the player is applying to the parent.
	var/custom_name
	///The desc the player is applying to the parent.
	var/custom_desc
	///The name before the player changed it.
	var/original_name
	///The desc before the player changed it.
	var/original_desc

/datum/component/rename/Initialize(_custom_name, _custom_desc)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	custom_name = _custom_name
	custom_desc = _custom_desc
	apply_rename()

/datum/component/rename/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_RESET_PLAYER_RENAME, .proc/remove_component)

/datum/component/rename/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_RESET_PLAYER_RENAME)

/**
	This proc will fire after the parent's name or desc is changed with a pen, which is trying to apply another rename component.
	Since the parent already has a rename component, it will remove the old one and apply the new one.
	The name and description changes will be merged or overwritten.
*/
/datum/component/rename/InheritComponent(datum/component/rename/new_comp , i_am_original, _custom_name, _custom_desc)
	revert_rename()
	if(new_comp)
		custom_name = new_comp.custom_name
		custom_desc = new_comp.custom_desc
	else
		custom_name = _custom_name
		custom_desc = _custom_desc
	apply_rename()

///Saves the current name and description before changing them to the player's inputs.
/datum/component/rename/proc/apply_rename()
	var/atom/owner = parent
	original_name = owner.name
	original_desc = owner.desc
	owner.name = custom_name
	owner.desc = custom_desc

///Reverts the name and description to the state before they were changed.
/datum/component/rename/proc/revert_rename()
	var/atom/owner = parent
	owner.name = original_name
	owner.desc = original_desc

/datum/component/rename/proc/remove_component()
	revert_rename()
	qdel(src)

/datum/component/rename/Destroy()
	revert_rename()
	return ..()
