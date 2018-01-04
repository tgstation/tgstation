/datum/component/cleaning
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/cleaning/Initialize()
	if(!ismovableatom(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("[type] added to a [parent.type]")
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
				to_chat(cleaned_human, "<span class='danger'>[AM] cleans your face!</span>")
