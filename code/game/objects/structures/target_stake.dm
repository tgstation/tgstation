// Basically they are for the firing range
/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	density = 1
	flags = CONDUCT
	var/obj/item/target/pinned_target // the current pinned target

/obj/structure/target_stake/Move()
	..()
	// Move the pinned target along with the stake
	if(pinned_target in view(3, src))
		pinned_target.loc = loc

	else // Sanity check: if the pinned target can't be found in immediate view
		pinned_target = null
		density = 1

/obj/structure/target_stake/attackby(obj/item/W as obj, mob/user as mob, params)
	// Putting objects on the stake. Most importantly, targets
	if(pinned_target)
		return // get rid of that pinned target first!

	if(istype(W, /obj/item/target))
		density = 0
		W.density = 1
		user.drop_item()
		W.loc = loc
		W.layer = 3.1
		pinned_target = W
		user << "<span class='notice'>You slide the target into the stake.</span>"
	return

/obj/structure/target_stake/attack_hand(mob/user as mob)
	// taking pinned targets off!
	if(pinned_target)
		density = 1
		pinned_target.density = 0
		pinned_target.layer = OBJ_LAYER

		pinned_target.loc = user.loc
		if(ishuman(user))
			if(!user.get_active_hand())
				user.put_in_hands(pinned_target)
				user << "<span class='notice'>You take the target out of the stake.</span>"
		else
			pinned_target.loc = get_turf(user)
			user << "<span class='notice'>You take the target out of the stake.</span>"

		pinned_target = null
