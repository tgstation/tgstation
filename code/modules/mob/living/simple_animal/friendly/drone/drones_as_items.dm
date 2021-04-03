#define DRONE_MINIMUM_AGE 14

///////////////////
//DRONES AS ITEMS//
///////////////////
//Drone shells

/** Drone Shell: Ghost role item for drones
 *
 * A simple mob spawner item that transforms into a maintenance drone
 * Resepcts drone minimum age
 */

/obj/effect/mob_spawn/drone
	name = "drone shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_hat" //yes reuse the _hat state.
	layer = BELOW_MOB_LAYER
	density = FALSE
	death = FALSE
	roundstart = FALSE
	///Type of drone that will be spawned
	mob_type = /mob/living/simple_animal/drone

/obj/effect/mob_spawn/drone/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A drone shell has been created in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_DRONE, notify_suiciders = FALSE)
	AddElement(/datum/element/point_of_interest)

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/effect/mob_spawn/drone/attack_ghost(mob/user)
	if(CONFIG_GET(flag/use_age_restriction_for_jobs))
		if(!isnum(user.client.player_age)) //apparently what happens when there's no DB connected. just don't let anybody be a drone without admin intervention
			return
		if(user.client.player_age < DRONE_MINIMUM_AGE)
			to_chat(user, "<span class='danger'>You're too new to play as a drone! Please try again in [DRONE_MINIMUM_AGE - user.client.player_age] days.</span>")
			return
	. = ..()
