//Pop-out cake!
//A huge cake that can fit a person inside
//You can cut the cake up to 16 times to receive a cake slice. After that the cake is destroyed and a large cardboard box is left

//LOCKING CATEGORY FOR OBJECTS THAT ARE CLIMBING OUT OF THE CAKE
/datum/locking_category/popout_cake
	pixel_y_offset = 1 //First row of pixels on the cake is transparent :^

	var/pixel_y_offset_max = 24

/datum/locking_category/popout_cake/lock(atom/movable/AM)
	pixel_y_offset -= AM.pixel_y
	pixel_x_offset -= AM.pixel_x

	//AM.pixel_y = 0
	//AM.pixel_x = 0

	..()

	owner.plane = AM.plane
	owner.layer = AM.layer + 0.1
	animate(AM, pixel_y = pixel_y_offset_max + AM.pixel_y, 40) //Increase pixel_y over 4 seconds

/datum/locking_category/popout_cake/unlock(atom/movable/AM)
	..()

	animate(AM) //Stop the animation
	AM.pixel_y -= pixel_y_offset_max

	owner.plane = initial(owner.plane)
	owner.layer = initial(owner.layer)

/obj/structure/popout_cake
	name = "large cake"
	desc = "An enormous multi-tiered cake."

	icon_state = "popout_cake"

	anchored = 0
	opacity = 0
	density = 1

	var/slices_amount = 16
	var/string_pulled = 0

/obj/structure/popout_cake/Destroy()
	for(var/mob/living/L in locked_atoms + contents) //Release all mobs inside
		relaymove(L, NORTH)

	..()

/obj/structure/popout_cake/examine(mob/user)
	.=..()

	user.show_message("<span class='info'>There are [slices_amount] slices remaining.</span>", MESSAGE_SEE)

/obj/structure/popout_cake/attack_hand(mob/living/user)
	if(user.loc == src) //Clicked from inside the cake
		pull_string()
		return
	else if(locate(/mob/living) in contents)
		to_chat(user, "<span class='info'>There appears to be something inside of \the [src]!</span>")
		return

	user.visible_message("<span class='notice'>[user] starts climbing into \the [src]!</span>")
	if(do_after(user, src, 60))
		user.forceMove(src)
		to_chat(user, "<span class='info'>You are now inside the cake! When you're ready to emerge from the cake in a blaze of confetti and party horns, pull on the string by clicking on \the [src] (<b>this can only be done once</b>). If you wish to leave without setting off the confetti, just attempt to move out of the cake!</span>")

/obj/structure/popout_cake/attack_slime(mob/user)
	return attack_hand(user)

/obj/structure/popout_cake/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/popout_cake/attackby(obj/item/W, mob/user)
	if(W.is_sharp())
		user.visible_message("<span class='notice'>[user] starts cutting a slice from \the [src].</span>")

		spawn() //So that the proc can return 1, delaying the next attack
			if(do_after(user, src, 10))
				drop_slice()
				check_slices()

		return 1

/obj/structure/popout_cake/proc/drop_slice()
	slices_amount--

	return new /obj/item/weapon/reagent_containers/food/snacks/plaincakeslice/full(get_turf(src))

/obj/structure/popout_cake/proc/check_slices()
	if(slices_amount <= 0)
		new /obj/item/weapon/storage/box/large(get_turf(src))

		qdel(src)

/obj/structure/popout_cake/proc/pull_string()
	set name = "Pull Party String"
	set desc = "Activate a simple mechanism that lifts you out of the cake. This can only be done once!"
	set category = "Object"
	set src = usr.loc

	if(!isturf(loc))
		return

	var/mob/living/L = usr
	if(!istype(L))
		return

	if(L.incapacitated())
		return

	if(string_pulled)
		to_chat(L, "<span class='info'>The string has already been pulled!</span>")
		return

	visible_message("<span class='notice'>All of a sudden, something emerges from \the [src]!</span>")
	to_chat(L, "<span class='info'>You pull on the party string!</span>")

	lock_atom(L, /datum/locking_category/popout_cake)

	spawn(10)
		playsound(get_turf(src), 'sound/effects/party_horn.ogg', 50, 1)

		sleep(10)

		//Idea for the future: put actual confetti here
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(6, 0, get_turf(src)) //6 sparks in all directions
		s.start()

	string_pulled = 1

/obj/structure/popout_cake/relaymove(mob/living/L, direction)
	if(!istype(L))
		return

	if(locked_atoms.Find(L))
		unlock_atom(L)
	else if(contents.Find(L))
		L.forceMove(get_turf(src))

/obj/structure/popout_cake/kick_act(mob/user)
	.=..()

	slices_amount -= rand(1,3) //Deal some damage
	check_slices()

/obj/structure/popout_cake/bite_act(mob/user)
	var/obj/item/I = drop_slice()
	I.bite_act(user)

	check_slices()

/obj/structure/popout_cake/bullet_act(var/obj/item/projectile/Proj)
	slices_amount -= Clamp(round(Proj.damage / 3), 1, 4)

	check_slices()
