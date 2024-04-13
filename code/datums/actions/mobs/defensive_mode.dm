/// An ability that allows the viper spider to get in an defensive mode at the cost of speed.
/datum/action/cooldown/mob_cooldown/defensive_mode
	name = "Change Mode"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "defensive_mode"
	desc = "Activates a defensive mode to reduce damage but will make you slower."
	cooldown_time = 5 SECONDS
	click_to_activate = FALSE
	/// If the defensive mode is activated or not.
	var/defense_active = FALSE
	/// Movement speed modifier used.
	var/datum/movespeed_modifier/modifier_type = /datum/movespeed_modifier/viper_defensive

/datum/action/cooldown/mob_cooldown/defensive_mode/Remove(mob/living/remove_from)
	var/mob/living/basic/owner_mob = owner
	if(defense_active && istype(owner_mob))
		offence(owner_mob)

	return ..()

/datum/action/cooldown/mob_cooldown/defensive_mode/Activate(atom/target_atom)
	disable_cooldown_actions()
	activate_defence(owner)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/defensive_mode/proc/activate_defence(mob/living/basic/owner_mob)
	if(!istype(owner_mob))
		return
	if(defense_active)
		offence(owner_mob)
		return
	defence(owner_mob)

/datum/action/cooldown/mob_cooldown/defensive_mode/proc/offence(mob/living/basic/owner_mob)
	owner_mob.damage_coeff = list(BRUTE = 1, BURN = 1.25, TOX = 1, STAMINA = 1, OXY = 1)
	owner_mob.icon_state = initial(owner_mob.icon_state)
	owner_mob.icon_living = initial(owner_mob.icon_living)
	owner_mob.icon_dead = initial(owner_mob.icon_dead)
	owner_mob.remove_movespeed_modifier(modifier_type)
	defense_active = FALSE

/datum/action/cooldown/mob_cooldown/defensive_mode/proc/defence(mob/living/basic/owner_mob)
	owner_mob.damage_coeff = list(BRUTE = 0.4, BURN = 0.5, TOX = 1, STAMINA = 1, OXY = 1)
	owner_mob.icon_dead = "[owner_mob.icon_state]_d_dead"
	owner_mob.icon_state = "[owner_mob.icon_state]_d"
	owner_mob.icon_living = "[owner_mob.icon_living]_d"
	owner_mob.add_movespeed_modifier(modifier_type)
	defense_active = TRUE
