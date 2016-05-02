/mob/living/carbon/death(gibbed)
	silent = 0
	losebreath = 0
	med_hud_set_health()
	med_hud_set_status()
	..()

/mob/living/carbon/gib(no_brain, no_organs)
	for(var/mob/M in src)
		if(M in stomach_contents)
			stomach_contents.Remove(M)
		M.loc = loc
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")
	..()

/mob/living/carbon/spill_organs(no_brain)
	for(var/obj/item/organ/internal/I in internal_organs)
		if(no_brain && istype(I, /obj/item/organ/internal/brain))
			continue
		if(I)
			I.Remove(src)
			I.loc = get_turf(src)
			I.throw_at_fast(get_edge_target_turf(src,pick(alldirs)),rand(1,3),5)
