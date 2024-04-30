// Parent of all borer actions
/datum/action/cooldown/borer
	button_icon = 'monkestation/code/modules/antagonists/borers/icons/actions.dmi'
	cooldown_time = 0
	/// Text used to explain the ability more closelly in the antagonist TGUI panel
	var/ability_explanation = ""

	/// How many chemicals this costs
	var/chemical_cost = 0
	/// How many chem evo points are needed to use this ability
	var/chemical_evo_points = 0
	/// How many stat evo points are needed to use this ability
	var/stat_evo_points = 0

	/// Does this ability need a human host to be triggered?
	var/requires_host = FALSE
	/// Can this ability function within a living host?
	var/needs_living_host = FALSE
	/// Can this ability function within a dead host?
	var/needs_dead_host = FALSE
	/// Does this ability stop working when the host has sugar?
	var/sugar_restricted = FALSE

/datum/action/cooldown/borer/New(Target, original)
	. = ..()
	var/compiled_string = ""
	if(chemical_cost)
		compiled_string += "([chemical_cost] chemical[chemical_cost == 1 ? "" : "s"])"
	if(stat_evo_points)
		compiled_string += " ([stat_evo_points] stat point[stat_evo_points == 1 ? "" : "s"])"
	if(chemical_evo_points)
		compiled_string += " ([chemical_evo_points] chemical point[chemical_evo_points == 1 ? "" : "s"])"
	name = "[initial(name)][compiled_string]"

/datum/action/cooldown/borer/Trigger(trigger_flags, atom/target)
	. = ..()

	// Safety checks
	if(!iscorticalborer(owner))
		to_chat(owner, span_warning("You must be a cortical borer to use this action!"))
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner

	// Status Requirements
	if(requires_host == TRUE && !cortical_owner.inside_human())
		owner.balloon_alert(owner, "host required")
		return FALSE
	if(needs_living_host == TRUE && cortical_owner.human_host.stat == DEAD)
		owner.balloon_alert(owner, "Alive host required")
		return FALSE
	if(needs_dead_host == TRUE && cortical_owner.human_host.stat != DEAD)
		owner.balloon_alert(owner, "Dead host required")
		return FALSE
	if(sugar_restricted == TRUE && cortical_owner.host_sugar())
		owner.balloon_alert(owner, "cannot function with sugar in host")
		return FALSE

	// Resource costs
	if(cortical_owner.chemical_storage < chemical_cost)
		cortical_owner.balloon_alert(cortical_owner, "need [chemical_cost] chemicals")
		return FALSE
	if(cortical_owner.chemical_evolution < chemical_evo_points)
		cortical_owner.balloon_alert(cortical_owner, "need [chemical_evo_points] chemical points")
		return FALSE
	if(cortical_owner.stat_evolution < stat_evo_points)
		cortical_owner.balloon_alert(cortical_owner, "need [stat_evo_points] stat points")
		return FALSE

	return . == FALSE ? FALSE : TRUE //. can be null, true, or false. There's a difference between null and false here

/datum/asset/simple/borer_icons

/datum/asset/simple/borer_icons/register()
	for(var/datum/action/cooldown/borer/ability as anything in subtypesof(/datum/action/cooldown/borer))
		add_borer_icon(initial(ability.button_icon), initial(ability.button_icon_state))
	return ..()

/datum/asset/simple/borer_icons/proc/add_borer_icon(borer_icon, borer_icon_state)
	assets[SANITIZE_FILENAME("borer.[borer_icon_state].png")] = icon(borer_icon, borer_icon_state)
