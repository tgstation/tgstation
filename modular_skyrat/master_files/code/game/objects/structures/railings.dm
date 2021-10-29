/obj/structure/railing/singularity_pull(S, current_size)
	..()
	if(anchored && current_size >= STAGE_FIVE)
		set_anchored(FALSE)
