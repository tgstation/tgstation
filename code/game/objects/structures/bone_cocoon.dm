/obj/structure/bone_cocoon
	name = "bone cocoon"
	desc = "A large cocoon that appears to be made of solid bone."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bone_cocoon"
	density = 1
	anchored = 0
	var/mob/living/simple_animal/borer/parent_borer = null

/obj/structure/bone_cocoon/ex_act(var/severity)
	// same explosion invulnerability as the freezer
	var/list/bombs = search_contents_for(/obj/item/device/transfer_valve)
	if(!isemptylist(bombs))
		..(severity)
	return 0

/obj/structure/bone_cocoon/New(turf/T, var/p_borer = null)
	..(T)
	if(istype(p_borer, /mob/living/simple_animal/borer))
		parent_borer = p_borer
	if(!parent_borer)
		qdel(src)
	else
		processing_objects.Add(src)

/obj/structure/bone_cocoon/Destroy()
	if(parent_borer)
		if(parent_borer.channeling_bone_cocoon)
			parent_borer.channeling_bone_cocoon = 0
		if(parent_borer.channeling)
			parent_borer.channeling = 0
		parent_borer = null
	processing_objects.Remove(src)
	for(var/atom/movable/I in contents)
		I.forceMove(get_turf(src))
	src.visible_message("<span class='notice'>\The [src] crumbles into nothing.</span>")
	..()

/obj/structure/bone_cocoon/process()
	set waitfor = 0
	if(!parent_borer)
		return
	if(!parent_borer.channeling_bone_cocoon) //the borer has stopped sustaining the cocoon
		qdel(src)
	if(parent_borer.chemicals < 10) //the parent borer no longer has the chemicals required to sustain the cocoon
		qdel(src)
	else
		parent_borer.chemicals -= 10
		sleep(10)