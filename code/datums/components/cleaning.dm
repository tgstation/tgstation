/datum/component/cleaning
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/cleaning/Initialize()
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(list(COMSIG_MOVABLE_MOVED), .proc/Clean)

/datum/component/cleaning/proc/Clean()
	var/atom/movable/AM = parent
	var/turf/tile = AM.loc
	if(!isturf(tile))
		return

	tile.SendSignal(COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	for(var/A in tile)
		if(is_cleanable(A))
			qdel(A)
		else if(istype(A, /obj/item))
			var/obj/item/I = A
			I.SendSignal(COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
			if(ismob(I.loc))
				var/mob/M = I.loc
				M.regenerate_icons()
		else if(ishuman(A))
			var/mob/living/carbon/human/cleaned_human = A
			if(cleaned_human.lying)
				if(cleaned_human.head)
					cleaned_human.head.SendSignal(COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				if(cleaned_human.wear_suit)
					cleaned_human.wear_suit.SendSignal(COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				else if(cleaned_human.w_uniform)
					cleaned_human.w_uniform.SendSignal(COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				if(cleaned_human.shoes)
					cleaned_human.shoes.SendSignal(COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				cleaned_human.SendSignal(COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				cleaned_human.wash_cream()
				cleaned_human.regenerate_icons()
				to_chat(cleaned_human, "<span class='danger'>[AM] cleans your face!</span>")
