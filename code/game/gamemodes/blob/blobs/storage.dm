/obj/effect/blob/storage
	name = "storage blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	desc = "A huge, smooth mass supported by tendrils."
	health = 60
	maxhealth = 60
	point_return = -1
	var/point_bonus = 50 //How much the overmind's point cap increases from storage blobs


/obj/effect/blob/storage/creation_action()
	if(overmind)
		overmind.max_blob_points += point_bonus

/obj/effect/blob/storage/Destroy()
	if(overmind)
		overmind.max_blob_points -= point_bonus
	return ..()

/obj/effect/blob/storage/PulseAnimation(activate = 0)
	if(activate)
		..()
	return
