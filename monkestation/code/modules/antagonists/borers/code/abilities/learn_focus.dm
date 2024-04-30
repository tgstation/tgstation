/datum/action/cooldown/borer/learn_focus
	name = "Learn Focus"
	button_icon_state = "getfocus"
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Lets you evolve strong passive modifiers into the hosts you inhabit\n\
	Your focuses will follow you when you leave your host\n\
	"

/datum/action/cooldown/borer/learn_focus/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(!length(cortical_owner.possible_focuses))
		owner.balloon_alert(owner, "all focuses already learned")
		return
	var/list/fancy_list = list()
	for(var/datum/borer_focus/foci as anything in cortical_owner.possible_focuses)
		if(foci in cortical_owner.body_focuses)
			continue
		fancy_list["[foci.name] ([foci.cost] points)"] = foci
	var/focus_choice = tgui_input_list(cortical_owner, "Learn a focus!", "Focus Choice", fancy_list)
	if(!focus_choice)
		owner.balloon_alert(owner, "focus not chosen")
		return
	var/datum/borer_focus/picked_focus = fancy_list[focus_choice]
	if(cortical_owner.stat_evolution < picked_focus.cost)
		owner.balloon_alert(owner, "[picked_focus.cost] points required")
		return
	cortical_owner.stat_evolution -= picked_focus.cost
	cortical_owner.body_focuses += picked_focus
	picked_focus.on_add(cortical_owner.human_host, owner)
	owner.balloon_alert(owner, "focus learned successfully")
	StartCooldown()
