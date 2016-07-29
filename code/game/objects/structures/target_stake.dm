<<<<<<< HEAD
/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	density = 1
	flags = CONDUCT
	var/obj/item/target/pinned_target

/obj/structure/target_stake/Destroy()
	if(pinned_target)
		pinned_target.nullPinnedLoc()
	return ..()

/obj/structure/target_stake/proc/nullPinnedTarget()
	pinned_target = null

/obj/structure/target_stake/Move()
	..()
	if(pinned_target)
		pinned_target.loc = loc

/obj/structure/target_stake/attackby(obj/item/target/T, mob/user)
	if(pinned_target)
		return
	if(istype(T) && user.drop_item())
		pinned_target = T
		T.pinnedLoc = src
		T.density = 1
		T.layer = OBJ_LAYER + 0.01
		T.loc = loc
		user << "<span class='notice'>You slide the target into the stake.</span>"

/obj/structure/target_stake/attack_hand(mob/user)
	if(pinned_target)
		removeTarget(user)

/obj/structure/target_stake/proc/removeTarget(mob/user)
	pinned_target.layer = OBJ_LAYER
	pinned_target.loc = user.loc
	pinned_target.nullPinnedLoc()
	nullPinnedTarget()
	if(ishuman(user))
		if(!user.get_active_hand())
			user.put_in_hands(pinned_target)
			user << "<span class='notice'>You take the target out of the stake.</span>"
	else
		pinned_target.loc = get_turf(user)
		user << "<span class='notice'>You take the target out of the stake.</span>"

/obj/structure/target_stake/bullet_act(obj/item/projectile/P)
	if(pinned_target)
		pinned_target.bullet_act(P)
	else
		..()
=======
// Basically they are for the firing range
/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	density = 1
	flags = 0
	siemens_coefficient = 1
	var/obj/item/target/pinned_target // the current pinned target

	Move()
		..()
		// Move the pinned target along with the stake
		if(pinned_target in view(3, src))
			pinned_target.loc = loc

		else // Sanity check: if the pinned target can't be found in immediate view
			pinned_target = null
			density = 1

	attackby(obj/item/W as obj, mob/user as mob)
		// Putting objects on the stake. Most importantly, targets
		if(pinned_target)
			return // get rid of that pinned target first!

		if(istype(W, /obj/item/target))
			if(user.drop_item(W, src.loc))
				density = 0
				W.density = 1
				W.layer = 3.1
				pinned_target = W
				to_chat(user, "You slide the target into the stake.")
		return

	attack_hand(mob/user as mob)
		// taking pinned targets off!
		if(pinned_target)
			density = 1
			pinned_target.density = 0
			pinned_target.layer = OBJ_LAYER

			pinned_target.loc = user.loc
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(pinned_target)
					to_chat(user, "You take the target out of the stake.")
			else
				pinned_target.loc = get_turf(user)
				to_chat(user, "You take the target out of the stake.")

			pinned_target = null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
