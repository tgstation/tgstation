/datum/antagonist/voidwalker/proc/generate_voidwalker_upgrades()
	var/free_branches_we_can_give = rand(4,6)
	for(var/just_a_path in subtypesof(/datum/voidwalker_upgrades_tree))
		var/datum/voidwalker_upgrades_tree/box_with_upgrades = new just_a_path
		box_with_upgrades.owner_mind = owner
		for(var/datum/voidwalker_upgrade_branch/local_branch in box_with_upgrades.all_branches)
			local_branch.owner_mind = owner
			if(free_branches_we_can_give > 0 && prob(15))
				local_branch.for_free = TRUE
				free_branches_we_can_give--
		all_upgrades += box_with_upgrades

/// Containers in which upgrades themselves are located.
/// Sort upgrades by their types so that user has a little understanding of the direction in which upgrades will take place in a given tree.
/datum/voidwalker_upgrades_tree
	/// Tree name.
	var/name
	/// Description that should explain what direction of upgrades this three will give you.
	var/desc
	/// Where we take icon.
	var/icon = 'icons/mob/actions/actions_voidwalker.dmi'
	/// Beautiful sprite that will not let the user understand anything about what this tree upgrades.
	var/icon_state
	/// What clan does your tree belong to?
	/// Tree type and branch type need to be same so ui can create upgrade buttons in the correct tree.
	var/tree_type
	/// Is tree unlocked on start or you need spend 2 points to unlock it.
	var/unlocked = TRUE
	/// What spell we recive when unlock new tree.
	var/datum/action/spell_to_give_on_unlock
	/// Our voidwalker that who wants to receive upgrades.
	var/datum/mind/owner_mind
	/// List of all branches buttons that we have. We will sort it when create ui.
	var/list/all_branches = list()

/datum/voidwalker_upgrades_tree/New()
	. = ..()
	for(var/upgrade_path in subtypesof(/datum/voidwalker_upgrade_branch))
		var/datum/voidwalker_upgrade_branch/upgrade = upgrade_path
		if(isnull(upgrade.name) || isnull(upgrade.desc))
			continue
		if(upgrade.branch_type != tree_type)
			continue
		upgrade = new upgrade
		all_branches += upgrade

/// Check if we can unlock this tree.
/datum/voidwalker_upgrades_tree/proc/try_unlock()
	var/datum/antagonist/voidwalker/owner_datum = locate() in owner_mind?.antag_datums
	if(unlocked)
		to_chat(owner_datum.owner, span_warning("Already unlocked!"))
		return
	if(owner_datum.points < 2)
		to_chat(owner_datum.owner, span_warning("Not enough points!"))
		return
	unlock()

/// Unlock this tree if [try_unlock] allowed it.
/datum/voidwalker_upgrades_tree/proc/unlock()
	var/datum/antagonist/voidwalker/owner_datum = locate() in owner_mind?.antag_datums
	owner_datum.points -= 2
	unlocked = TRUE
	spell_to_give_on_unlock = new spell_to_give_on_unlock(owner_mind?.current)
	spell_to_give_on_unlock.Grant(owner_mind?.current)
	owner_datum.researched_spells += spell_to_give_on_unlock
	to_chat(owner_datum.owner, span_purple("You unlocked [src]."))

/// Upgrade itself that responsible for giving us improvements.
/datum/voidwalker_upgrade_branch
	/// My name is
	var/name
	/// Small description that should definitely make it clear what it will give when research.
	var/desc
	/// Like tree_type but for our branch.
	var/branch_type
	/// 1-2-3 tiers <- Logically, you need to open upgrades in this order
	/// But in fact tier only affects in which column our button will be located in the ui. We need also use upgrade_before var.
	var/tier = 1
	/// Does not allow us to upgrade this upgrade until we open the upgrade whose name we write in this var!
	var/upgrade_before
	/// This brunch will be free
	var/for_free = FALSE
	/// Our voidwalker mind.
	var/datum/mind/owner_mind

/// Check if we reached this branch. Result goes to ui.
/datum/voidwalker_upgrade_branch/proc/can_research()
	if(isnull(upgrade_before))
		return TRUE
	var/datum/antagonist/voidwalker/owner_datum = locate() in owner_mind?.antag_datums
	for(var/datum/voidwalker_upgrade_branch/upgrade in owner_datum.upgrades_we_have)
		if(upgrade_before == upgrade.name)
			return TRUE
	return FALSE

/// Check if we can research this branch when press on this upgrade button.
/// We need 1 point to research any upgrades.
/datum/voidwalker_upgrade_branch/proc/try_research()
	var/datum/antagonist/voidwalker/owner_datum = locate() in owner_mind?.antag_datums
	if(is_type_in_list(src, owner_datum.upgrades_we_have))
		to_chat(owner_datum.owner, span_warning("You already learned [src]!"))
		return
	if(owner_datum.points < 1 && !for_free)
		to_chat(owner_datum.owner, span_warning("Not enough skills to upgrade!"))
		return
	research_upgrade()

/// [try_research] allowed as to research this upgrade and we happily write it down in our researched upgrades.
/datum/voidwalker_upgrade_branch/proc/research_upgrade()
	var/datum/antagonist/voidwalker/owner_datum = locate() in owner_mind?.antag_datums
	owner_datum.points -= for_free ? 0 : 1
	owner_datum.upgrades_we_have += src
	var/gain_text = for_free ? "You learned [src] for free." : "You learned [src]."
	to_chat(owner_datum.owner, span_purple(gain_text))
	upgrade_effect()
	return TRUE

/// What this upgrade is actually do.
/datum/voidwalker_upgrade_branch/proc/upgrade_effect()
	return TRUE
