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
		to_chat(user, "<span class='notice'>You slide the target into the stake.</span>")

/obj/structure/target_stake/attack_hand(mob/user)
	if(pinned_target)
		removeTarget(user)

/obj/structure/target_stake/proc/removeTarget(mob/user)
	pinned_target.layer = OBJ_LAYER
	pinned_target.loc = user.loc
	pinned_target.nullPinnedLoc()
	nullPinnedTarget()
	if(ishuman(user))
		if(!user.get_active_held_item())
			user.put_in_hands(pinned_target)
			to_chat(user, "<span class='notice'>You take the target out of the stake.</span>")
	else
		pinned_target.loc = get_turf(user)
		to_chat(user, "<span class='notice'>You take the target out of the stake.</span>")

/obj/structure/target_stake/bullet_act(obj/item/projectile/P)
	if(pinned_target)
		pinned_target.bullet_act(P)
	else
		..()