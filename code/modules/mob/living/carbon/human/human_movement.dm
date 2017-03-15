/mob/living/carbon/human/movement_delay()
	. = 0
	. += ..()
	. += config.human_delay
	. += dna.species.movement_delay(src)

/mob/living/carbon/human/slip(s_amount, w_amount, obj/O, lube)
	if(isobj(shoes) && (shoes.flags&NOSLIP) && !(lube&GALOSHES_DONT_HELP))
		return 0
	return ..()

/mob/living/carbon/human/experience_pressure_difference()
	playsound(src, 'sound/effects/space_wind.ogg', 50, 1)
	if(shoes && shoes.flags&NOSLIP)
		return 0
	return ..()

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return ((shoes && shoes.negates_gravity()) || dna.species.negates_gravity(src))


/mob/living/carbon/human/Moved(atom/OldLoc)
	..()
	if(buckled_mobs && buckled_mobs.len && riding_datum)
		riding_datum.on_vehicle_move()
	for(var/datum/mutation/human/HM in dna.mutations)
		HM.on_move(src, loc)
	if(w_uniform)
		crewmonitor.queueUpdate(z)
		if(z != OldLoc.z)
			crewmonitor.queueUpdate(OldLoc.z)
	if(shoes && !lying && !buckled && has_gravity(loc) && isturf(loc))
		var/obj/item/clothing/shoes/S = shoes
		S.step_action()
		//Bloody footprints
		if(S.bloody_shoes && S.bloody_shoes[S.blood_state])
			var/obj/effect/decal/cleanable/blood/footprints/oldFP = locate(/obj/effect/decal/cleanable/blood/footprints) in loc
			if(!oldFP || oldFP.blood_state != S.blood_state)
				S.bloody_shoes[S.blood_state] = max(0, S.bloody_shoes[S.blood_state]-BLOOD_LOSS_PER_STEP)
				var/obj/effect/decal/cleanable/blood/footprints/FP = new(loc)
				FP.blood_state = S.blood_state
				FP.entered_dirs |= dir
				FP.bloodiness = S.bloody_shoes[S.blood_state]
				if(S.blood_DNA && S.blood_DNA.len)
					FP.transfer_blood_dna(S.blood_DNA)
				FP.update_icon()
				update_inv_shoes()
		//End bloody footprints

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0) //Temporary laziness thing. Will change to handles by species reee.
	if(..())
		return 1
	return dna.species.space_move(src)
