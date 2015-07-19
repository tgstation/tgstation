
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

/obj/item/drone_shell/attack_ghost(mob/user)
	if(jobban_isbanned(user,"drone"))
		return

	var/be_drone = alert("Become a drone? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_drone == "No" || gc_destroyed)
		return
	var/mob/living/simple_animal/drone/D = new drone_type(get_turf(loc))
	D.key = user.key
	qdel(src)


//DRONE HOLDER
/obj/item/clothing/head/drone_holder//Only exists in someones hand.or on their head
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball"
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_hat"
	var/mob/living/simple_animal/drone/drone //stored drone

/obj/item/clothing/head/drone_holder/proc/uncurl()
	if(!drone)
		return

	if(istype(loc, /mob/living))
		var/mob/living/L = loc
		L.show_message("<span class='notice'>[drone] is trying to escape!</span>")
		if(!do_after(L, 50, target = L) || loc != L)
			return
		L.unEquip(src)

	contents -= drone
	drone.loc = get_turf(src)
	drone.reset_view()
	drone.dir = SOUTH //Looks better
	drone.visible_message("<span class='notice'>[drone] uncurls!</span>")
	drone = null
	qdel(src)


/obj/item/clothing/head/drone_holder/relaymove()
	uncurl()

/obj/item/clothing/head/drone_holder/container_resist()
	uncurl()


/obj/item/clothing/head/drone_holder/proc/updateVisualAppearence(mob/living/simple_animal/drone/D)
	if(!D)
		return
	icon_state = "[D.visualAppearence]_hat"
	. = icon_state