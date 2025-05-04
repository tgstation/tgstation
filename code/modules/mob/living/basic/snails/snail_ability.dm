/datum/action/cooldown/mob_cooldown/shell_retreat
	name = "Shell Retreat"
	desc = "Retreat to your shell!"
	cooldown_time = 5 SECONDS
	click_to_activate = FALSE
	button_icon = 'icons/mob/simple/pets.dmi'
	button_icon_state = "snail_shell"

/datum/action/cooldown/mob_cooldown/shell_retreat/Activate(atom/target)
	. = ..()
	HAS_TRAIT(owner, TRAIT_SHELL_RETREATED) ? unretreat_from_shell() : retreat_into_shell()

/datum/action/cooldown/mob_cooldown/shell_retreat/proc/unretreat_from_shell()
	SIGNAL_HANDLER

	owner.visible_message(
		span_danger("[owner] Slowly pops its head out of its shell!"),
		span_userdanger("You pop your head out of your shell."),
	)
	REMOVE_TRAIT(owner, TRAIT_SHELL_RETREATED, REF(src))
	owner.update_appearance(UPDATE_ICON_STATE)
	UnregisterSignal(owner, list(COMSIG_ATOM_UPDATE_ICON_STATE, COMSIG_MOVABLE_ATTEMPTED_MOVE))

/datum/action/cooldown/mob_cooldown/shell_retreat/proc/retreat_into_shell()
	owner.visible_message(
		span_danger("[owner] quickly escapes into its shell!"),
		span_userdanger("You hide in your shell.."),
	)
	RegisterSignal(owner, COMSIG_MOVABLE_ATTEMPTED_MOVE, PROC_REF(unretreat_from_shell))
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_icon_update))
	ADD_TRAIT(owner, TRAIT_SHELL_RETREATED, REF(src))
	owner.update_appearance(UPDATE_ICON_STATE)

/datum/action/cooldown/mob_cooldown/shell_retreat/proc/on_icon_update(atom/source)
	SIGNAL_HANDLER

	source.icon_state = HAS_TRAIT(owner, TRAIT_SHELL_RETREATED) ? "[owner.base_icon_state]_shell" : "[owner.base_icon_state][(owner.faction.Find(FACTION_RAT)) ? "_maints" : ""]"
