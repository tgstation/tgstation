//does massive brute and burn damage, but can only expand manually
/datum/blobstrain/reagent/networked_fibers
	name = "Networked Fibers"
	description = "will do high brute and burn damage and will generate resources quicker, but can only expand manually using the core or nodes."
	shortdesc = "will do high brute and burn damage."
	effectdesc = "will move your core or node when manually expanding near it."
	analyzerdescdamage = "Does high brute and burn damage."
	analyzerdesceffect = "Is highly mobile and generates resources rapidly."
	color = "#4F4441"
	complementary_color = "#414C4F"
	reagent = /datum/reagent/blob/networked_fibers
	core_regen_bonus = 5

/datum/blobstrain/reagent/networked_fibers/expand_reaction(obj/structure/blob/spawning_blob, obj/structure/blob/new_blob, turf/chosen_turf, mob/camera/blob/overmind)
	if(!overmind && new_blob.overmind)
		new_blob.overmind.add_points(1)
		qdel(new_blob)
		return
	if(isspaceturf(chosen_turf))
		return
	for(var/obj/structure/blob/possible_expander in range(1, new_blob))
		if(possible_expander.overmind == overmind && (istype(possible_expander, /obj/structure/blob/special/core) || istype(possible_expander, /obj/structure/blob/special/node)))
			new_blob.forceMove(get_turf(possible_expander))
			possible_expander.forceMove(chosen_turf)
			possible_expander.setDir(get_dir(new_blob, possible_expander))
			return
	overmind.add_points(4)
	qdel(new_blob)

//does massive brute and burn damage, but can only expand manually
/datum/reagent/blob/networked_fibers
	name = "Networked Fibers"
	taste_description = "efficiency"
	color = "#4F4441"

/datum/reagent/blob/networked_fibers/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.6*reac_volume, BRUTE, wound_bonus=CANT_WOUND)
	if(!QDELETED(exposed_mob))
		exposed_mob.apply_damage(0.6*reac_volume, BURN, wound_bonus=CANT_WOUND)
