
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
		notify_ghosts("A drone shell has been created in \the [A.name].", source = src, attack_not_jump = 1)

/obj/item/drone_shell/attack_ghost(mob/user)
	if(jobban_isbanned(user,"drone"))
		return
	if(!ticker.mode)
		user << "Can't become a drone before the game has started."
		return
	var/be_drone = alert("Become a drone? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_drone == "No" || gc_destroyed)
		return
	var/mob/living/simple_animal/drone/D = new drone_type(get_turf(loc))
	D.key = user.key
	qdel(src)


//DRONE HAT

/obj/item/weapon/holder/drone/proc/updateVisualAppearence(mob/living/simple_animal/drone/D)
	if(!D)
		return
	icon_state = "[D.visualAppearence]_hat"
	. = icon_state