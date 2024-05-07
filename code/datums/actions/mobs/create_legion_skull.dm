/datum/action/cooldown/mob_cooldown/create_legion_skull
	name = "Create Legion Skull"
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "legion_head"
	desc = "Create a legion skull to chase down a targeted enemy"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/mob_cooldown/create_legion_skull/Activate(atom/target_atom)
	disable_cooldown_actions()
	create(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/// Creates a new skull assigned to the owner of this action
/datum/action/cooldown/mob_cooldown/create_legion_skull/proc/create(atom/target)
	var/mob/living/basic/legion_brood/minion = new(owner.loc)
	minion.assign_creator(owner)
	minion.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = target
