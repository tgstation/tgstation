#define BOMB_COOLDOWN 20 SECONDS
/obj/item/minebot_remote_control
	name = "Remote Control"
	desc = "Requesting stratagem!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "minebot_bomb_control"
	item_flags = NOBLUDGEON
	///are we currently primed to drop a bomb?
	var/primed = FALSE
	///our last user
	var/datum/weakref/last_user
	///cooldown till we can drop the next bomb
	COOLDOWN_DECLARE(bomb_timer)

/obj/item/minebot_remote_control/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	clear_priming()

/obj/item/minebot_remote_control/proc/clear_priming()
	var/mob/living/living_user = last_user?.resolve()
	last_user = null
	primed = FALSE
	if(isnull(living_user))
		return
	living_user.client?.mouse_override_icon = initial(living_user.client?.mouse_override_icon)
	living_user.update_mouse_pointer()

/obj/item/minebot_remote_control/attack_self(mob/user)
	. = ..()
	if(.)
		return .

	if(!COOLDOWN_FINISHED(src, bomb_timer))
		balloon_alert(user, "on cooldown!")
		return TRUE

	prime_bomb(user)
	return TRUE

/obj/item/minebot_remote_control/proc/prime_bomb(mob/user)
	primed = TRUE
	last_user = WEAKREF(user)
	user.client?.mouse_override_icon = 'icons/effects/mouse_pointers/weapon_pointer.dmi'
	user.update_mouse_pointer()

/obj/item/minebot_remote_control/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/minebot_remote_control/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!primed)
		user.balloon_alert(user, "not primed!")
		return ITEM_INTERACT_BLOCKING
	var/turf/target_turf = get_turf(interacting_with)
	if(isnull(target_turf) || isclosedturf(target_turf) || isgroundlessturf(target_turf))
		user.balloon_alert(user, "invalid target!")
		return ITEM_INTERACT_BLOCKING
	playsound(src, 'sound/machines/beep.ogg', 30)
	clear_priming()
	new /obj/effect/temp_visual/minebot_target(target_turf)
	COOLDOWN_START(src, bomb_timer, BOMB_COOLDOWN)
	return ITEM_INTERACT_SUCCESS

/obj/effect/temp_visual/minebot_target
	name = "Rocket Target"
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	light_range = 2
	duration = 5 SECONDS

#undef BOMB_COOLDOWN
