#define DRONE_MINIMUM_AGE 14

///////////////////
//DRONES AS ITEMS//
///////////////////
//Drone shells
//Drones as hats


//DRONE SHELL
/obj/item/drone_shell
	name = "drone shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_hat"//yes reuse the _hat state.
	origin_tech = "programming=2;biotech=4"
	var/drone_type = /mob/living/simple_animal/drone //Type of drone that will be spawned

/obj/item/drone_shell/New()
	..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A drone shell has been created in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)
	GLOB.poi_list |= src

/obj/item/drone_shell/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/item/drone_shell/attack_ghost(mob/user)
	if(jobban_isbanned(user,"drone"))
		return
	if(config.use_age_restriction_for_jobs)
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
	D.admin_spawned = admin_spawned
	D.key = user.key
	qdel(src)


//DRONE HOLDER
/obj/item/clothing/head/drone_holder//Only exists in someones hand.or on their head
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_hat"
	var/mob/living/simple_animal/drone/drone //stored drone

/obj/item/clothing/head/drone_holder/proc/uncurl()
	if(!drone)
		return

	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, "<span class='warning'>[drone] is trying to escape!</span>")
		if(!do_after(drone, 50, target = L))
			return
		L.dropItemToGround(src)

	contents -= drone
	drone.loc = get_turf(src)
	drone.reset_perspective()
	drone.setDir(SOUTH )//Looks better
	drone.visible_message("<span class='warning'>[drone] uncurls!</span>")
	drone = null
	qdel(src)


/obj/item/clothing/head/drone_holder/relaymove()
	uncurl()

/obj/item/clothing/head/drone_holder/container_resist(mob/living/user)
	uncurl()


/obj/item/clothing/head/drone_holder/proc/updateVisualAppearence(mob/living/simple_animal/drone/D)
	if(!D)
		return
	icon_state = "[D.visualAppearence]_hat"
	. = icon_state
