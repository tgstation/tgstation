/obj/effect/blob/storage
	name = "storage blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	desc = "A huge, smooth mass supported by tendrils."
	health = 60
	maxhealth = 60
	point_return = -1
	var/point_bonus = 50 //How much the overmind's point cap increases from storage blobs


/obj/effect/blob/storage/creation_action()
	if(overmind)
		overmind.max_blob_points += point_bonus
		overmind.storage_blobs++

/obj/effect/blob/storage/Destroy()
	if(overmind && overmind.storage_blobs) //if the overmind doesn't have any recorded storage blobs, don't TAKE ALL THE POINTS THEY HAVE
		overmind.max_blob_points -= point_bonus
		overmind.storage_blobs--
	return ..()
