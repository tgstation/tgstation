/**
	The rename component.

	This component is used to manage names and descriptions changed with the pen on objects with the UNIQUE_RENAME obj_flag.

	Atoms can only have one instance of this component, and therefore only one rename at a time.

	When a player renames or changes the description of a UNIQUE_RENAME atom with a pen, this component gets applied to it.
	If the player uses a pen to reset the name and description, the component will be removed from it, and the name and description will be reverted.
 */
/datum/component/rename
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///The name the player is applying to the parent
	var/player_name
	///The desc the player is applying to the parent
	var/player_desc
	///The name before the player changed it
	var/original_name
	///The desc before the player changed it
	var/original_desc

/datum/component/rename/Initialize(_player_name, _player_desc)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	player_name = _player_name
	player_desc = _player_desc
	apply_rename()

/datum/component/rename/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_PLAYER_RENAME, .proc/apply_rename)
	RegisterSignal(parent, COMSIG_ATOM_RESET_PLAYER_RENAME, .proc/remove_rename)

/datum/component/rename/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_PLAYER_RENAME, COMSIG_ATOM_RESET_PLAYER_RENAME))

/**
	This proc will fire after the parent's name or desc is changed with a pen, which is trying to apply another rename component.
	Since the parent already has a rename component, it will remove the old one from the parent's name, and apply the new one.
*/
/datum/component/rename/InheritComponent(datum/component/rename/new_comp , i_am_original, _player_name, _player_desc)
	remove_rename()
	if(new_comp)
		player_name = new_comp.player_name
		player_desc = new_comp.player_desc
	else
		player_name = _player_name
		player_desc = _player_desc
	apply_rename()

///Saves the current name and description before changing them to the player's inputs
/datum/component/rename/proc/apply_rename()
	var/atom/owner = parent
	if(!original_name)
		original_name = owner.name
	if(!original_desc)
		original_desc = owner.desc
	owner.name = player_name
	owner.desc = player_desc

///Reverts the
/datum/component/rename/proc/remove_rename()
	var/atom/owner = parent
	owner.name = original_name
	owner.desc = original_desc
	qdel(src)

