// no extra data displayed (exclusively using callback)
#define SUICIDE_VIS_NONE 0
// displays suicide data to holyroles (chaplain)
#define SUICIDE_VIS_HOLY 1
// displays suicide data to everyone
#define SUICIDE_VIS_ALL 2

/datum/component/suicide_count
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/view_mode
	var/last_person
	var/count = 0
	var/datum/callback/ondie

/datum/component/suicide_count/Initialize(_view_mode = SUICIDE_VIS_HOLY, datum/callback/_ondie)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	view_mode = _view_mode
	ondie = _ondie

/datum/component/suicide_count/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HUMAN_SUICIDE_COMPLETE, .proc/on_suicide)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/suicide_count/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_HUMAN_SUICIDE_COMPLETE, COMSIG_PARENT_EXAMINE))

/datum/component/suicide_count/on_suicide(mob/living/user)
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
		var/wrong_guess = max(2, collective + rand(-3, 3))
		examine_list += span_notice(
			is_holy ? "You can sense a collective of [collective] lost souls who met the same fate." : \
			"This item reminds you of [wrong_guess] others, you'd guess."
		)
