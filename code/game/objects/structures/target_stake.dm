// Basically they are for the firing range
/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	density = 1
	flags = CONDUCT
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
			density = 0
			W.density = 1
			user.drop_item(src)
			W.loc = loc
			W.layer = 3.1
			pinned_target = W
			user << "You slide the target into the stake."
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
					user << "You take the target out of the stake."
			else
				pinned_target.loc = get_turf_loc(user)
				user << "You take the target out of the stake."

			pinned_target = null