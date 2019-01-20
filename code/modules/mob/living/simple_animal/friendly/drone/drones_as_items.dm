#define DRONE_MINIMUM_AGE 14

///////////////////
//DRONES AS ITEMS//
///////////////////
//Drone shells

//DRONE SHELL
/obj/item/drone_shell
	name = "drone shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_hat"//yes reuse the _hat state.
	layer = BELOW_MOB_LAYER

	var/drone_type = /mob/living/simple_animal/drone //Type of drone that will be spawned
	var/seasonal_hats = TRUE //If TRUE, and there are no default hats, different holidays will grant different hats
	var/static/list/possible_seasonal_hats //This is built automatically in build_seasonal_hats() but can also be edited by admins!

/obj/item/drone_shell/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A drone shell has been created in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_DRONE)
	GLOB.poi_list |= src
	if(isnull(possible_seasonal_hats))
		build_seasonal_hats()

/obj/item/drone_shell/proc/build_seasonal_hats()
	possible_seasonal_hats = list()
	if(!length(SSevents.holidays))
		return //no holidays, no hats; we'll keep the empty list so we never call this proc again
	for(var/V in SSevents.holidays)
		var/datum/holiday/holiday = SSevents.holidays[V]
		if(holiday.drone_hat)
			possible_seasonal_hats += holiday.drone_hat

/obj/item/drone_shell/Destroy()
	GLOB.poi_list -= src
	. = ..()

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/item/drone_shell/attack_ghost(mob/user)
	if(is_banned_from(user.ckey, ROLE_DRONE) || QDELETED(src) || QDELETED(user))
		return
	if(CONFIG_GET(flag/use_age_restriction_for_jobs))
		if(!isnum(user.client.player_age)) //apparently what happens when there's no DB connected. just don't let anybody be a drone without admin intervention
			return
		if(user.client.player_age < DRONE_MINIMUM_AGE)
			to_chat(user, "<span class='danger'>You're too new to play as a drone! Please try again in [DRONE_MINIMUM_AGE - user.client.player_age] days.</span>")
			return
	if(!SSticker.mode)
		to_chat(user, "Can't become a drone before the game has started.")
		return
	var/be_drone = alert("Become a drone? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_drone == "No" || QDELETED(src) || !isobserver(user))
		return
	var/mob/living/simple_animal/drone/D = new drone_type(get_turf(loc))
	if(!D.default_hatmask && seasonal_hats && possible_seasonal_hats.len)
		var/hat_type = pick(possible_seasonal_hats)
		var/obj/item/new_hat = new hat_type(D)
		D.equip_to_slot_or_del(new_hat, SLOT_HEAD)
	D.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	D.key = user.key
	qdel(src)
