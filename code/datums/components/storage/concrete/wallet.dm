/datum/component/storage/concrete/wallet/on_right_click(datum/source, mob/user)
	if(!isliving(user) || !user.CanReach(parent) || user.incapacitated())
		return
	if(locked)
		to_chat(user, "<span class='warning'>[parent] seems to be locked!</span>")
		return

	var/obj/item/storage/wallet/A = parent
	if(istype(A) && A.front_id && !issilicon(user) && !(A.item_flags & IN_STORAGE)) //if it's a wallet in storage seeing the full inventory is more useful
		var/obj/item/I = A.front_id
		A.add_fingerprint(user)
		remove_from_storage(I, get_turf(user))
		INVOKE_ASYNC(src, .proc/quickdraw.quickdraw, user, I)
		return
	..()
