/*

	A component designed to log and count who has suicided with the attached item.
	If view_mode is HOLY, then only those spiritual enough are able to detect the ghosts' spirits.
	If it's ALL, any old folk can come and examine for the suicide information.
	Forensics scanners can always detect an item's suicide counts. (not implemented yet todo)
	You may also specify a on_die callback, which could be used to update various other aspects with the number of suicides.

*/

/datum/component/suicide_count
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/view_mode
	var/last_person
	var/count = 0
	var/datum/callback/on_die

/datum/component/suicide_count/Initialize(view_mode = SUICIDE_VIS_HOLY, datum/callback/on_die)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.view_mode = view_mode
	src.on_die = on_die

/datum/component/suicide_count/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HUMAN_SUICIDE_COMPLETE, .proc/on_suicide)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/suicide_count/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HUMAN_SUICIDE_COMPLETE, COMSIG_PARENT_EXAMINE))

/datum/component/suicide_count/on_suicide(mob/living/source)
	SIGNAL_HANDLER
	if(!istype(source))
		return

	last_person = source.real_name
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
