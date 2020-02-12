/obj/item/implant/blocker
	name = "blocker implant"
	desc = "Injects things."
	icon_state = "reagents"
	var/block_mode = 0
	var/block_arg = list("Assistant")
	activated = FALSE
	var/datum/component/C

/obj/item/implant/blocker/implant(mob/living/target)
	. = ..()
	C = target.AddComponent(/datum/component/blocker, block_mode, block_arg) // i know this probably isn't the right way to do this, i'll fix it tomorrow

/obj/item/implant/blocker/removed()
	QDEL_NULL(C)
	return ..()

/obj/item/implant/blocker/Destroy()
	QDEL_NULL(C)
	return ..()

/obj/item/implantcase/blocker
	name = "implant case - 'Social Blocker'"
	desc = "A glass case containing a neural blocking."
	imp_type = /obj/item/implant/blocker

// 2do: actually set up how to set these, and make this all better, this is slapdash
