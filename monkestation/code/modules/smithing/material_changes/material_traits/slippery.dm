/datum/material_trait/slippery
	name = "Slippery"
	desc = "Item will randomly fall to the ground regardless of where its stored."
	reforges = 2

/datum/material_trait/slippery/on_process(atom/movable/parent, datum/material_stats/host)
	. = ..()
	if(prob(50))
		return
	var/atom/parent_source = parent.loc
	if(!parent_source)
		if(isbodypart(parent))
			var/obj/item/bodypart/bodypart = parent
			bodypart.drop_limb()
			return

		if(isorgan(parent))
			var/obj/item/organ/organ = parent
			var/mob/living/parent_host = organ.owner
			organ.Remove(organ.owner)
			organ.forceMove(get_turf(parent_host))
			return

	if(istype(parent_source, /obj/machinery/electroplater))
		return
	if(ismob(parent_source))
		var/mob/mob = parent_source
		mob.dropItemToGround(parent, TRUE)

	parent_source.slipped_out(parent)
	parent.forceMove(get_turf(parent))


/atom/proc/slipped_out(atom/movable/slipped)
	return

/obj/machinery/power/thermoelectric_generator/slipped_out(atom/movable/slipped)
	if(slipped == conductor)
		remove_teg_state(/datum/thermoelectric_state/worked_material)
		conductor = null
