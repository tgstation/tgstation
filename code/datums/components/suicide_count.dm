/*

	A component designed to log and count who has suicided with the attached item.
	It can either be attached to an item like usual, or will be added automatically with NONE when someone suicides.
	If view_mode is HOLY, then only those spiritual enough are able to detect the ghosts' spirits.
	If it's ALL, any old folk can come and examine for the suicide information.
	Forensics scanners can always detect an item's suicide counts. (not implemented yet todo)
*/

/datum/component/suicide_count
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/view_mode
	var/last_person
	var/count = 0

/datum/component/suicide_count/Initialize(view_mode = SUICIDE_VIS_ALL)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.view_mode = view_mode

/datum/component/suicide_count/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HUMAN_SUICIDE_COMPLETE, .proc/on_suicide)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/suicide_count/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HUMAN_SUICIDE_COMPLETE, COMSIG_PARENT_EXAMINE))

/datum/component/suicide_count/InheritComponent(datum/component/C, i_am_original, view_mode)
	if(view_mode >= src.view_mode)  // upgrading it
		src.view_mode = view_mode

/datum/component/suicide_count/on_suicide(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(!istype(user))
		return

	last_person = user.real_name
	count++

/datum/component/suicide_count/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/is_holy = user.mind?.holy_role

	if(view_mode <= SUICIDE_VIS_NONE)
		return
	if(view_mode == SUICIDE_VIS_HOLY && !is_holy)
		return

	if(last_person)
		examine_list += span_notice(
			is_holy \
				? "You can sense a lost spirit, [last_person], who took their life with this." \
				: "Looking at this somehow reminds you of [last_person]."
		)

	if(count)
		var/wrong_guess = max(2, count + rand(-2, 2))
		examine_list += span_notice(
			is_holy \
				? "You can sense a collective of [count] lost souls who met the same fate." \
				: "This item reminds you of [wrong_guess] others, you'd guess."
		)
