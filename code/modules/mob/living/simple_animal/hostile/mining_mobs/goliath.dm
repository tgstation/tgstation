/*
/mob/living/simple_animal/hostile/asteroid/goliath/beast/attackby(obj/item/O, mob/user, params)
	if(!istype(O, /obj/item/saddle) || saddled)
		return ..()

	if(can_saddle && do_after(user,55,target=src))
		user.visible_message(span_notice("You manage to put [O] on [src], you can now ride [p_them()]."))
		qdel(O)
		saddled = TRUE
		buckle_lying = 0
		add_overlay("goliath_saddled")
		AddElement(/datum/element/ridable, /datum/component/riding/creature/goliath)
	else
		user.visible_message(span_warning("[src] is rocking around! You can't put the saddle on!"))
	..()

/mob/living/simple_animal/hostile/asteroid/goliath/beast/random/Initialize(mapload)
	. = ..()
	if(prob(1))
		new /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient(loc)
		return INITIALIZE_HINT_QDEL
		*/

/mob/living/simple_animal/hostile/asteroid/goliath/beast/random
/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril

/obj/item/saddle
	name = "saddle"
	desc = "This saddle will solve all your problems with being killed by lava beasts!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_saddle"
