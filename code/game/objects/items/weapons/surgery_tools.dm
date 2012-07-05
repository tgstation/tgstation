//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

/*
CONTAINS:
RETRACTOR
HEMOSTAT
CAUTERY
SURGICAL DRILL
SCALPEL
CIRCULAR SAW

*/

/////////////
//RETRACTOR//
/////////////
/obj/item/weapon/retractor/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
		if(user.zone_sel.selecting == "mouth" || user.zone_sel.selecting == "eyes")
			S = H.organs["head"]
		if(S.status & DESTROYED)
			if(S.status & BLEEDING)
				user << "\red There's too much blood here!"
				return 0
			if(!(S.status & CUT_AWAY))
				user << "\red The flesh hasn't been cleanly cut!"
				return 0
			if(M != user)
				M.visible_message( \
					"\red [user] is beginning reposition flesh and nerve endings where [H]'s [S.display_name] used to be with [src].", \
					"\red [user] begins to reposition flesh and nerve endings where [S.display_name] used to be with [src]!")
			else
				M.visible_message( \
					"\red [user] begins to reposition flesh and nerve endings where \his [S.display_name]  used to be with [src]!", \
					"\red You begin to reposition flesh and nerve endings where your [S.display_name] used to be with [src]!")

			if(do_mob(user, H, 100))
				if(M != user)
					M.visible_message( \
						"\red [user] finishes repositioning flesh and nerve endings where [H]'s [S.display_name] used to be with [src]!", \
						"\red [user] finishes repositioning flesh and nerve endings where your [S.display_name] used to be with [src]!")
				else
					M.visible_message( \
						"\red [user] finishes repositioning flesh and nerve endings where \his [S.display_name] used to be with [src]!", \
						"\red You finish repositioning flesh and nerve endings where your [S.display_name] used to be with [src]!")

				if(H == user && prob(25))
					user << "\red You mess up!"
					S.take_damage(15)

				S.open = 3
				M.updatehealth()
				M.UpdateDamageIcon()

				return 1

	if(user.zone_sel.selecting == "chest")
		if(istype(M, /mob/living/carbon/human))
			switch(M:embryo_op_stage)
				if(2.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] retracts the flap in [M]'s cut open torso with [src].", 1)
						M << "\red [user] begins to retracts the flap in your chest with [src]!"
						user << "\red You retract the flap in [M]'s torso with [src]!"
						M:embryo_op_stage = 3.0
						return
				if(4.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] rips the larva out of [M]'s torso!", 1)
						M << "\red [user] begins to rip the larva out of [M]'s torso!"
						user << "\red You rip the larva out of [M]'s torso!"
						var/mob/living/carbon/alien/larva/stupid = new(M.loc)
						stupid.death(0)
						//Make a larva and kill it. -- SkyMarshal
						M:embryo_op_stage = 5.0
						for(var/datum/disease/alien_embryo in M.viruses)
							alien_embryo.cure()
						return

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
				if(2.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] retracts the flap in [M]'s abdomen cut open with [src].", 1)
						M << "\red [user] begins to retract the flap in your abdomen with [src]!"
						user << "\red You retract the flap in [M]'s abdomen with [src]!"
						M:appendix_op_stage = 3.0
						return

	if (user.zone_sel.selecting == "eyes")

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M.eye_op_stage)
			if(1.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] is having \his eyes retracted by [user].", 1)
					M << "\red [user] begins to seperate your eyes with [src]!"
					user << "\red You seperate [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to have \his eyes retracted.", \
						"\red You begin to pry open your eyes with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)

				M:eye_op_stage = 2.0
				return

	if(user.zone_sel.selecting == "mouth")

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M:face_op_stage)
			if(2.0)
				if(M != user)
					M.visible_message( \
						"\red [user] is beginning to retract the skin on [M]'s face and neck with [src].", \
						"\red [user] begins to retract the flap on your face and neck with [src]!")
				else
					M.visible_message( \
						"\red [user] begins to retract the skin on their face and neck with [src]!", \
						"\red You begin to retract the skin on your face and neck with [src]!")

				if(do_mob(user, M, 60))
					if(M != user)
						M.visible_message( \
							"\red [user] retracts the skin on [M]'s face and neck with [src]!", \
							"\red [user] retracts the skin on your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] retracts the skin on their face and neck with [src]!", \
							"\red You retract the skin on your face and neck with [src]!")

					if(M == user && prob(25))
						user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
					M.face_op_stage = 3.0

				M.updatehealth()
				M.UpdateDamageIcon()
				return
			if(4.0)
				if(M != user)
					M.visible_message( \
						"\red [user] is beginning to pull skin back into place on [M]'s face with [src].", \
						"\red [user] begins to pull skin back into place on your face with [src]!")
				else
					M.visible_message( \
						"\red [user] begins to pull skin back into place on their face with [src]!", \
						"\red You begin to pull skin back into place on your face with [src]!")

				if(do_mob(user, M, 90))
					if(M != user)
						M.visible_message( \
							"\red [user] pulls the skin back into place on [M]'s face with [src]!", \
							"\red [user] pulls the skin back into place on your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] pulls the skin back into place on their face and neck with [src]!", \
							"\red You pull the skin back into place on your face and neck with [src]!")

					if(M == user && prob(25))
						user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
					M.face_op_stage = 5.0

				M.updatehealth()
				M.UpdateDamageIcon()
				return

// Retractor Bone Surgery
	// bone surgery doable?
	if(!try_bone_surgery(M, user))
		return ..()

/obj/item/weapon/retractor/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if(!S || !istype(S))
		return 0

	if(S.status & DESTROYED)
		return ..()

	if(S.status & ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good..."
		return

	if(!S.open)
		user << "\red There is skin in the way!"
		return 0
	if(S.status & BLEEDING)
		user << "\red [H] is profusely bleeding in \his [S.display_name]!"
		return 0

	if(H != user)
		H.visible_message( \
			"\red [user] is beginning to retract the flap in the wound in [H]'s [S.display_name] with [src].", \
			"\red [user] begins to retract the flap in the wound in your [S.display_name] with [src]!")
	else
		H.visible_message( \
			"\red [user] begins to retract the flap in the wound in \his [S.display_name] with [src]!", \
			"\red You begin to retract the flap in the wound in your [S.display_name] with [src]!")

	if(do_mob(user, H, 30))
		if(H != user)
			H.visible_message( \
				"\red [user] retracts the flap in the wound in [H]'s [S.display_name] with [src]!", \
				"\red [user] retracts the flap in the wound in your [S.display_name] with [src]!")
		else
			H.visible_message( \
				"\red [user] retracts the flap in the wound in \his [S.display_name] with [src]!", \
				"\red You retract the flap in the wound in your [S.display_name] with [src]!")

		if(H == user && prob(25))
			user << "\red You mess up!"
			S.take_damage(15)

		S.open = 2

		H.updatehealth()
		H.UpdateDamageIcon()

	return 1

////////////
//Hemostat//
////////////

/obj/item/weapon/hemostat/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	var/mob/living/carbon/human/H = M
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
		if(S.status & DESTROYED)
			if(!(S.status & BLEEDING))
				user << "\red There is nothing bleeding here!"
				return 0
			if(!(S.status & CUT_AWAY))
				user << "\red The flesh hasn't been cleanly cut!"
				return 0
			if(M != user)
				M.visible_message( \
					"\red [user] is beginning to clamp bleeders in the stump where [H]'s [S.display_name] used to be with [src].", \
					"\red [user] begins to clamp bleeders in the stump where [S.display_name] used to be with [src]!")
			else
				M.visible_message( \
					"\red [user] begins to clamp bleeders in the stump where \his [S.display_name]  used to be with [src]!", \
					"\red You begin to clamp bleeders in the stump where your [S.display_name] used to be with [src]!")

			if(do_mob(user, H, 100))
				if(M != user)
					M.visible_message( \
						"\red [user] finishes clamping bleeders in the stump where [H]'s [S.display_name] used to be with [src]!", \
						"\red [user] finishes clamping bleeders in the stump where your [S.display_name] used to be with [src]!")
				else
					M.visible_message( \
						"\red [user] finishes clamping bleeders in the stump where \his [S.display_name] used to be with [src]!", \
						"\red You finish clamping bleeders in the stump where your [S.display_name] used to be with [src]!")

				if(H == user && prob(25))
					user << "\red You mess up!"
					S.take_damage(15)

				S.status &= ~BLEEDING
				M.updatehealth()
				M.UpdateDamageIcon()

			return 1

	if(user.zone_sel.selecting == "chest")
		if(istype(M, /mob/living/carbon/human))
			switch(M:embryo_op_stage)
				if(1.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is beginning to clamp bleeders in [M]'s cut open torso with [src].", 1)
						M << "\red [user] begins to clamp bleeders in your chest with [src]!"
						user << "\red You clamp bleeders in [M]'s torso with [src]!"
						M:embryo_op_stage = 2.0

						S.status &= ~BLEEDING
						M.updatehealth()
						M.UpdateDamageIcon()

						return
				if(5.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] cleans out the debris from [M]'s cut open torso with [src].", 1)
						M << "\red [user] begins to clean out the debris in your torso with [src]!"
						user << "\red You clean out the debris from in [M]'s torso with [src]!"
						M:embryo_op_stage = 6.0
						return

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
				if(1.0)
					if(M != user)
						world << "Beep"
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is beginning to clamp bleeders in [M]'s abdomen cut open with [src].", 1)
						M << "\red [user] begins to clamp bleeders in your abdomen with [src]!"
						user << "\red You clamp bleeders in [M]'s abdomen with [src]!"
						M:appendix_op_stage = 2.0

						S.status &= ~BLEEDING
						M.updatehealth()
						M.UpdateDamageIcon()

						return
				if(4.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is removing [M]'s appendix with [src].", 1)
						M << "\red [user] begins to remove your appendix with [src]!"
						user << "\red You remove [M]'s appendix with [src]!"
						for(var/datum/disease/D in M.viruses)
							if(istype(D, /datum/disease/appendicitis))
								new /obj/item/weapon/appendixinflamed(get_turf(M))
								M:appendix_op_stage = 5.0
								return
						new /obj/item/weapon/appendix(get_turf(M))
						M:appendix_op_stage = 5.0
						return

	if (user.zone_sel.selecting == "eyes")
		S = H.organs["head"]
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M.eye_op_stage)
			if(2.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] is having \his eyes mended by [user].", 1)
					M << "\red [user] begins to mend your eyes with [src]!"
					user << "\red You mend [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to have \his eyes mended.", \
						"\red You begin to mend your eyes with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
				M:eye_op_stage = 3.0
				return
	if(user.zone_sel.selecting == "head")
		if(istype(M, /mob/living/carbon/human) && M:brain_op_stage == 1)
			M:brain_op_stage = 0
			if(!S || !istype(S))
				return ..()
			M:brain_op_stage = 0
			S.open = 1
			if(!try_bone_surgery(M, user))
				return ..()
		else
			return ..()

	if(user.zone_sel.selecting == "mouth")
		S = H.organs["head"]
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien))//Aliens don't have mouths either.
			user << "\red You cannot locate any mouth on this creature!"
			return

		if(istype(M, /mob/living/carbon/human))
			switch(M:face_op_stage)
				if(1.0)
					if(M != user)
						M.visible_message( \
							"\red [user] is beginning is beginning to clamp bleeders in [M]'s face and neck with [src].", \
							"\red [user] begins to clamp bleeders on your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] begins to clamp bleeders on their face and neck with [src]!", \
							"\red You begin to clamp bleeders on your face and neck with [src]!")

					if(do_mob(user, M, 50))
						if(M != user)
							M.visible_message( \
								"\red [user] stops the bleeding on [M]'s face and neck with [src]!", \
								"\red [user] stops the bleeding on your face and neck with [src]!")
						else
							M.visible_message( \
								"\red [user] stops the bleeding on their face and neck with [src]!", \
								"\red You stop the bleeding on your face and neck with [src]!")

						if(M == user && prob(25))
							user << "\red You mess up!"
							if(istype(M, /mob/living/carbon/human))
								var/datum/organ/external/affecting = M:get_organ("head")
								affecting.take_damage(15)
								M.updatehealth()
							else
								M.take_organ_damage(15)

						M.face_op_stage = 2.0

						S.status &= ~BLEEDING
						M.updatehealth()
						M.UpdateDamageIcon()
						return
				if(3.0)
					if(M != user)
						M.visible_message( \
							"\red [user] is beginning to reshape [M]'s vocal cords and face with [src].", \
							"\red [user] begins to reshape your vocal chords and face [src]!")
					else
						M.visible_message( \
							"\red [user] begins to reshape their vocal cords and face and face with [src]!", \
							"\red You begin to reshape your vocal cords and face with [src]!")

					if(do_mob(user, M, 120))
						if(M != user)
							M.visible_message( \
								"\red Halfway there...", \
								"\red Halfway there...")
						else
							M.visible_message( \
								"\red Halfway there...", \
								"\red Halfway there...")

					if(do_mob(user, M, 120))
						if(M != user)
							M.visible_message( \
								"\red [user] reshapes [M]'s vocal cords and face with [src]!", \
								"\red [user] reshapes your vocal cords and face with [src]!")
						else
							M.visible_message( \
								"\red [user] reshapes their vocal cords and face with [src]!", \
								"\red You reshape your vocal cords and face with [src]!")

						if(M == user && prob(25))
							user << "\red You mess up!"
							if(istype(M, /mob/living/carbon/human))
								var/datum/organ/external/affecting = M:get_organ("head")
								affecting.take_damage(15)
								M.updatehealth()
							else
								M.take_organ_damage(15)

						M.face_op_stage = 4.0

						M.updatehealth()
						M.UpdateDamageIcon()
						return

// Hemostat Bone Surgery
	// bone surgery doable?
	if(!try_bone_surgery(M, user))
		return ..()


/obj/item/weapon/hemostat/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]

	if(!S || !istype(S))
		return 0

	if(S.status & DESTROYED)
		return ..()

	if(S.status & ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good?"
		return

	if(!S.open)
		user << "\red There is skin in the way!"
		return 0

	if(!(S.status & BLEEDING))
		if(S.implant)
			if(H != user)
				H.visible_message( \
					"\red [user] is attempting to remove the implant in [H]'s [S.display_name] with \the [src].", \
					"\red [user] attempts to remove the implant in your [S.display_name] with \the [src]!")
			else
				H.visible_message( \
					"\red [user] attempts to remove the implant in \his [S.display_name] with \the [src]!", \
					"\red You attempt to remove the implant in your [S.display_name] with \the [src]!")

			do
				if(do_mob(user, H, 50))
					if(prob(50))
						if(H != user)
							H.visible_message( \
								"\red [user] successfully removes the implant in [H]'s [S.display_name] with \a [src]!", \
								"\red [user] successfully removes the implant in your [S.display_name] with \the [src]!")
						else
							H.visible_message( \
								"\red [user] successfully removes the implant in \his [S.display_name] with \a [src]!", \
								"\red You successfully remove the implant in your [S.display_name] with \the [src]!")
						var/obj/item/weapon/implant/implant = pick(S.implant)
						implant.loc = (get_turf(H))
						implant.implanted = 0
						S.implant.Remove(implant)
						playsound(user, 'squelch1.ogg', 50, 1)
						if(istype(implant, /obj/item/weapon/implant/explosive) || istype(implant, /obj/item/weapon/implant/uplink) || istype(implant, /obj/item/weapon/implant/dexplosive) || istype(implant, /obj/item/weapon/implant/explosive) || istype(implant, /obj/item/weapon/implant/compressed))
							usr << "The implant disintegrates into nothing..."
							del(implant)
						if(!S.implant.len)
							del S.implant
					else
						H.visible_message( \
							"\red [user] fails to remove the implant!", \
							"\red You fail to remove the implant!")
				else
					break
			while (S.implant && S.implant.len)

			return 1
		else
			user << "\red [H] is not bleeding in \his [S.display_name]!"
			return 0
	world << "Boop"
	if(H != user)
		H.visible_message( \
			"\red [user] is beginning to clamp bleeders in the wound in [H]'s [S.display_name] with [src].", \
			"\red [user] begins to clamp bleeders in the wound in your [S.display_name] with [src]!")
	else
		H.visible_message( \
			"\red [user] begins to clamp bleeders in the wound in \his [S.display_name] with [src]!", \
			"\red You begin to clamp bleeders in the wound in your [S.display_name] with [src]!")

	if(do_mob(user, H, 50))
		if(H != user)
			H.visible_message( \
				"\red [user] clamps bleeders in the wound in [H]'s [S.display_name] with [src]!", \
				"\red [user] clamps bleeders in the wound in your [S.display_name] with [src]!")
		else
			H.visible_message( \
				"\red [user] clamps bleeders in the wound in \his [S.display_name] with [src]!", \
				"\red You clamp bleeders in the wound in your [S.display_name] with [src]!")

		if(H == user && prob(25))
			user << "\red You mess up!"
			S.take_damage(15)

		S.status &= ~BLEEDING

		H.updatehealth()
		H.UpdateDamageIcon()

	return 1

///////////////////
//AUTOPSY SCANNER//
///////////////////
/obj/item/weapon/autopsy_scanner/var/list/datum/autopsy_data_data/wdata = list()
/obj/item/weapon/autopsy_scanner/var/list/datum/autopsy_data_data/chemtraces = list()
/obj/item/weapon/autopsy_scanner/var/target_name = null
/obj/item/weapon/autopsy_scanner/var/timeofdeath = null

/datum/autopsy_data_data
	var/weapon = null // this is the DEFINITE weapon type that was used
	var/list/organs_scanned = list() // this maps a number of scanned organs to
		                             // the wounds to those organs with this data's weapon type
	var/organ_names = ""

/obj/item/weapon/autopsy_scanner/proc/add_data(var/datum/organ/external/O)
	if(!O.autopsy_data.len && !O.trace_chemicals.len) return

	for(var/V in O.autopsy_data)
		var/datum/autopsy_data/W = O.autopsy_data[V]

		if(!W.pretend_weapon)
			// the more hits, the more likely it is that we get the right weapon type
			if(prob(50 + W.hits * 10 + W.damage))
				W.pretend_weapon = W.weapon
			else
				W.pretend_weapon = pick("mechanical toolbox", "wirecutters", "revolver", "crowbar", "fire extinguisher", "tomato soup", "oxygen tank", "emergency oxygen tank", "laser", "bullet")


		var/datum/autopsy_data_data/D = wdata[V]
		if(!D)
			D = new()
			D.weapon = W.weapon
			wdata[V] = D

		if(!D.organs_scanned[O.name])
			if(D.organ_names == "")
				D.organ_names = O.display_name
			else
				D.organ_names += ", [O.display_name]"

		del D.organs_scanned[O.name]
		D.organs_scanned[O.name] = W.copy()

	for(var/V in O.trace_chemicals)
		if(O.trace_chemicals[V] > 0 && !chemtraces.Find(V))
			chemtraces += V

/obj/item/weapon/autopsy_scanner/verb/print_data()
	set src in view(usr, 1)
	set name = "Print Data"
	if(usr.stat)
		usr << "No."
		return

	if(wdata.len == 0 && chemtraces.len == 0)
		usr << "<b>* There is no data about any wounds in the scanner's database. You may have to scan more bodyparts, or otherwise this wound type may not be in the scanner's database."
		return

	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Time since death:</b> [round((world.time - timeofdeath) / (60*10))] minutes<br><br>"

	var/n = 1
	for(var/wdata_idx in wdata)
		var/datum/autopsy_data_data/D = wdata[wdata_idx]
		var/total_hits = 0
		var/total_score = 0
		var/list/weapon_chances = list() // maps weapon names to a score
		var/age = 0

		for(var/wound_idx in D.organs_scanned)
			var/datum/autopsy_data/W = D.organs_scanned[wound_idx]
			total_hits += W.hits

			var/wname = W.pretend_weapon

			if(wname in weapon_chances) weapon_chances[wname] += W.damage
			else weapon_chances[wname] = max(W.damage, 1)
			total_score+=W.damage


			var/wound_age = world.time - W.time_inflicted
			age = max(age, wound_age)

		var/damage_desc

		var/damaging_weapon = (total_score != 0)

		// total score happens to be the total damage
		switch(total_score)
			if(0)
				damage_desc = "Unknown"
			if(1 to 5)
				damage_desc = "<font color='green'>negligible</font>"
			if(5 to 15)
				damage_desc = "<font color='green'>light</font>"
			if(15 to 30)
				damage_desc = "<font color='orange'>moderate</font>"
			if(30 to 1000)
				damage_desc = "<font color='red'>severe</font>"

		if(!total_score) total_score = D.organs_scanned.len

		scan_data += "<b>Weapon #[n]</b><br>"
		if(damaging_weapon)
			scan_data += "Severity: [damage_desc]<br>"
			scan_data += "Hits by weapon: [total_hits]<br>"
		scan_data += "Age of wound: [round(age / (60*10))] minutes<br>"
		scan_data += "Affected limbs: [D.organ_names]<br>"
		scan_data += "Possible weapons:<br>"
		for(var/weapon_name in weapon_chances)
			scan_data += "\t[100*weapon_chances[weapon_name]/total_score]% [weapon_name]<br>"

		scan_data += "<br>"

		n++

	if(chemtraces.len)
		scan_data += "<b>Trace Chemicals: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"

	for(var/mob/O in viewers(usr))
		O.show_message("\red \the [src] rattles and prints out a sheet of paper.", 1)

	sleep(10)

	var/obj/item/weapon/paper/P = new(usr.loc)
	P.name = "Autopsy Data ([target_name])"
	P.info = "<tt>[scan_data]</tt>"
	P.overlays += "paper_words"

	if(istype(usr,/mob/living/carbon))
		// place the item in the usr's hand if possible
		if(!usr.r_hand)
			P.loc = usr
			usr.r_hand = P
			P.layer = 20
		else if(!usr.l_hand)
			P.loc = usr
			usr.l_hand = P
			P.layer = 20

	usr.update_clothing()

/obj/item/weapon/autopsy_scanner/attack(mob/living/carbon/human/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	if(target_name != M.name)
		target_name = M.name
		for(var/V in src.wdata)
			del src.wdata[V]
		src.wdata = list()

	src.timeofdeath = M.timeofdeath

	var/datum/organ/external/S = M.organs[user.zone_sel.selecting]
	if(!S)
		usr << "<b>You can't scan this body part.</b>"
		return
	if(!S.open)
		usr << "<b>You have to cut the limb open first!</b>"
		return
	if(S.status & ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good?"
		return
	for(var/mob/O in viewers(M))
		O.show_message("\red [user.name] scans the wounds on [M.name]'s [S.display_name] with \the [src.name]", 1)

	src.add_data(S)

	return 1

///////////
//Cautery//
///////////

/obj/item/weapon/cautery/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
		if(S.status & DESTROYED)
			if(S.status & BLEEDING)
				user << "\red There's too much blood here!"
				return 0
			if(!(S.status & CUT_AWAY))
				user << "\red The flesh hasn't been cleanly cut!"
				return 0
			if(S.open != 3)
				user << "\red The wound hasn't been prepared yet!"
				return 0
			if(M != user)
				M.visible_message( \
					"\red [user] is adjusting the area around [H]'s [S.display_name] for reattachment with [src].", \
					"\red [user] is adjusting the area around your [S.display_name] for reattachment with [src]!")
			else
				M.visible_message( \
					"\red [user] begins adjusting the area around \his [S.display_name] for reattachment with [src]!", \
					"\red You begin adjusting the area around your [S.display_name] for reattachment with [src]!")

			if(do_mob(user, H, 100))
				if(M != user)
					M.visible_message( \
						"\red [user] finishes adjusting the area around [H]'s [S.display_name]!", \
						"\red [user] finishes adjusting the area around your [S.display_name]!")
				else
					M.visible_message( \
						"\red [user] finishes adjusting the area around \his [S.display_name]!", \
						"\red You finish adjusting the area around your [S.display_name]!")

				if(H == user && prob(25))
					user << "\red You mess up!"
					S.take_damage(15)

				S.open = 0
				S.stage = 0
				S.status |= ATTACHABLE
				M.updatehealth()
				M.UpdateDamageIcon()

			return 1

	if(user.zone_sel.selecting == "chest")
		if(istype(M, /mob/living/carbon/human))
			if(M:embryo_op_stage == 6.0 || M:embryo_op_stage ==  3.0 || M:embryo_op_stage ==  7.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [user] is beginning to cauterize the incision in [M]'s torso with [src].", 1)
					M << "\red [user] begins to cauterize the incision in your torso with [src]!"
					user << "\red You cauterize the incision in [M]'s torso with [src]!"
					M:embryo_op_stage = 0.0
					return

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
				if(5.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is beginning to cauterize the incision in [M]'s abdomen with [src].", 1)
						M << "\red [user] begins to cauterize the incision in your abdomen with [src]!"
						user << "\red You cauterize the incision in [M]'s abdomen with [src]!"
						M:appendix_op_stage = 6.0
						for(var/datum/disease/appendicitis/appendicitis in M.viruses)
							appendicitis.cure()
							M.resistances += appendicitis
						return

	if (user.zone_sel.selecting == "eyes")

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M.eye_op_stage)
			if(3.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] is having \his eyes cauterized by [user].", 1)
					M << "\red [user] begins to cauterize your eyes!"
					user << "\red You cauterize [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to have \his eyes cauterized.", \
						"\red You begin to cauterize your eyes!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
				M.disabilities &= ~128
				M.eye_stat = 0
				M:eye_op_stage = 0.0
				return

	if (user.zone_sel.selecting == "mouth")


		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M.face_op_stage)
			if(5.0)
				if(M != user)
					M.visible_message( \
						"\red [user] is beginning is cauterize [M]'s face and neck with [src].", \
						"\red [user] begins cauterize your face and neck with [src]!")
				else
					M.visible_message( \
						"\red [user] begins to cauterize their face and neck with [src]!", \
						"\red You begin to cauterize your face and neck with [src]!")

				if(do_mob(user, M, 50))
					if(M != user)
						M.visible_message( \
							"\red [user] cauterizes [M]'s face and neck with [src]!", \
							"\red [user] cauterizes your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] cauterizes their face and neck with [src]!", \
							"\red You cauterize your face and neck with [src]!")

					if(M == user && prob(25))
						user << "\red You mess up!"
						if(istype(M, /mob/living/carbon/human))
							var/datum/organ/external/affecting = M:get_organ("head")
							affecting.take_damage(15)
							M.updatehealth()
						else
							M.take_organ_damage(15)

					for(var/datum/organ/external/head/head)
						if(head && head.disfigured)
							head.disfigured = 0
					M.real_name = "[M.original_name]"
					M.name = "[M.original_name]"
					M << "\blue Your face feels better."
					M.warn_flavor_changed()
					M:face_op_stage = 0.0
					M.updatehealth()
					M.UpdateDamageIcon()
					return

//Cautery Bone Surgery

	if(!try_bone_surgery(M, user))
		return ..()

/obj/item/weapon/cautery/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if(!S || !istype(S))
		return 0

	if(S.status & DESTROYED)
		user << "What [S.display_name]?"

	if(S.status & ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good..."
		return
	if(!S.open)
		user << "\red There is no wound to close up!"
		return 0

	if(H != user)
		H.visible_message( \
			"\red [user] is beginning to cauterize the incision in [H]'s [S.display_name] with [src].", \
			"\red [user] begins to cut open the wound in your [S.display_name] with [src]!")
	else
		H.visible_message( \
			"\red [user] begins to cauterize the incision in \his [S.display_name] with [src]!", \
			"\red You begin to cauterize the incision in your [S.display_name] with [src]!")

	if(do_mob(user, H, rand(70,100)))
		if(H != user)
			H.visible_message( \
				"\red [user] cauterizes the incision in [H]'s [S.display_name] with [src]!", \
				"\red [user] cauterizes the incision in your [S.display_name] with [src]!")
		else
			H.visible_message( \
				"\red [user] cauterizes the incision in \his [S.display_name] with [src]!", \
				"\red You cauterize the incision in your [S.display_name] with [src]!")

		if(H == user && prob(25))
			user << "\red You mess up!"
			S.take_damage(15)

		S.open = 0
		if(S.display_name == "chest" && H:embryo_op_stage == 1.0)
			H:embryo_op_stage = 0.0
		if(S.display_name == "groin" && H:appendix_op_stage == 1.0)
			H:appendix_op_stage = 0.0

		H.updatehealth()
		H.UpdateDamageIcon()

	return 1

//obj/item/weapon/surgicaldrill


///////////
//SCALPEL//
///////////
/obj/item/weapon/scalpel/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	//if(NOCLONE in M.mutations)	return ..()

	if((CLUMSY in user.mutations) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	src.add_fingerprint(user)

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
		if(S.status & DESTROYED)
			if(M != user)
				M.visible_message( \
					"\red [user] is beginning to cut away at the flesh where [H]'s [S.display_name] used to be with [src].", \
					"\red [user] begins to cut away at the flesh where [S.display_name] used to be with [src]!")
			else
				M.visible_message( \
					"\red [user] begins to cut away at the flesh where \his [S.display_name]  used to be with [src]!", \
					"\red You begin to cut away at the flesh where your [S.display_name] used to be with [src]!")

			if(do_mob(user, H, 100))
				if(M != user)
					M.visible_message( \
						"\red [user] finishes cutting where [H]'s [S.display_name] used to be with [src]!", \
						"\red [user] finishes cutting where your [S.display_name] used to be with [src]!")
				else
					M.visible_message( \
						"\red [user] finishes cutting where \his [S.display_name] used to be with [src]!", \
						"\red You finish cutting where your [S.display_name] used to be with [src]!")

				S.status |= BLEEDING|CUT_AWAY
				M.updatehealth()
				M.UpdateDamageIcon()
			else
				var/a = pick(1,2,3)
				var/msg
				if(a == 1)
					msg = "\red [user]'s move slices open [H]'s wound, causing massive bleeding"
					S.brute_dam += 35
					S.createwound(rand(1,3))
				else if(a == 2)
					msg = "\red [user]'s move slices open [H]'s wound, and causes \him to accidentally stab himself"
					S.brute_dam += 35
					var/datum/organ/external/userorgan = user:organs["chest"]
					if(userorgan)
						userorgan.brute_dam += 35
					else
						user.take_organ_damage(35)
				else if(a == 3)
					msg = "\red [user] quickly stops the surgery"
				for(var/mob/O in viewers(H))
					O.show_message(msg, 1)

	if(user.zone_sel.selecting == "chest")
		if(istype(M, /mob/living/carbon/human))
			switch(M:embryo_op_stage)
//				if(0.0)
//					if(M != user)
//						for(var/mob/O in (viewers(M) - user - M))
//							O.show_message("\red [M] is beginning to have \his torso cut open with [src] by [user].", 1)
//						M << "\red [user] begins to cut open your torso with [src]!"
//						user << "\red You cut [M]'s torso open with [src]!"
//						M:embryo_op_stage = 1.0
//						return
				if(3.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M] has \his stomach cut open with [src] by [user].", 1)
						M << "\red [user] cuts open your stomach with [src]!"
						user << "\red You cut [M]'s stomach open with [src]!"
						for(var/datum/disease/D in M.viruses)
							if(istype(D, /datum/disease/alien_embryo))
								user << "\blue There's something wiggling in there!"
								M:embryo_op_stage = 4.0
						if(M:embryo_op_stage == 3.0)
							M:embryo_op_stage = 7.0 //Make it not cut their stomach open again and again if no larvae.
						return

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
//				if(0.0)
//					if(M != user)
//						for(var/mob/O in (viewers(M) - user - M))
//							O.show_message("\red [M] is beginning to have \his abdomen cut open with [src] by [user].", 1)
//						M << "\red [user] begins to cut open your abdomen with [src]!"
//						user << "\red You cut [M]'s abdomen open with [src]!"
//						M:appendix_op_stage = 1.0
				if(3.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M] has \his appendix seperated with [src] by [user].", 1)
						M << "\red [user] seperates your appendix with [src]!"
						user << "\red You seperate [M]'s appendix with [src]!"
						M:appendix_op_stage = 4.0
						return

	if(user.zone_sel.selecting == "head" || istype(M, /mob/living/carbon/metroid))

		var/mob/living/carbon/human/H = M

		if(istype(H) && H.organs["head"])
			var/datum/organ/external/affecting = H.organs["head"]
			if(affecting.status & DESTROYED)
				return ..()

		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M:brain_op_stage)
			if(0.0)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M.name] has its flesh cut open with [src] by [user].", 1)
						M << "\red [user] cuts open your flesh with [src]!"
						user << "\red You cut [M]'s flesh open with [src]!"
						M:brain_op_stage = 1.0

					return

				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his head cut open with [src] by [user].", 1)
					M << "\red [user] cuts open your head with [src]!"
					user << "\red You cut [M]'s head open with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to cuts open \his skull with [src]!", \
						"\red You begin to cut open your head with [src]!" \
					)

				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
					else
						M.take_organ_damage(15)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:get_organ("head")
					affecting.take_damage(7)
					affecting.open = 1
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 1.0
				return

			if(1)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M.name] has its silky inndards cut apart with [src] by [user].", 1)
						M << "\red [user] cuts apart your innards with [src]!"
						user << "\red You cut [M]'s silky innards apart with [src]!"
						M:brain_op_stage = 2.0
					return
			if(2.0)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						var/mob/living/carbon/metroid/Metroid = M
						if(Metroid.cores > 0)
							if(istype(M, /mob/living/carbon/metroid))
								user << "\red You attempt to remove [M]'s core, but [src] is ineffective!"
					return

				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his connections to the brain delicately severed with [src] by [user].", 1)
					M << "\red [user] delicately severes your brain with [src]!"
					user << "\red You severe [M]'s brain with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to delicately remove the connections to \his brain with [src]!", \
						"\red You begin to cut open your head with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You nick an artery!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(75)
					else
						M.take_organ_damage(75)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:get_organ("head")
					affecting.take_damage(7)
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 3.0
			else
				..()
			return

	if(user.zone_sel.selecting == "eyes")

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M:eye_op_stage)
			if(0.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his eyes incised with [src] by [user].", 1)
					M << "\red [user] cuts open your eyes with [src]!"
					user << "\red You make an incision around [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to cut around \his eyes with [src]!", \
						"\red You begin to cut open your eyes with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
					else
						M.take_organ_damage(15)

				M.updatehealth()
				M:eye_op_stage = 1.0
				return

	if(user.zone_sel.selecting == "mouth")

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N
			user << "\red You cannot locate any face on this creature!"
			return

		switch(M:face_op_stage)
			if(0.0)
				if(M != user)
					M.visible_message( \
						"\red [user] is beginning is cut open [M]'s face and neck with [src].", \
						"\red [user] begins to cut open your face and neck with [src]!")
				else
					M.visible_message( \
						"\red [user] begins to cut open their face and neck with [src]!", \
						"\red You begin to cut open your face and neck with [src]!")

				if(do_mob(user, M, 50))
					if(M != user)
						M.visible_message( \
							"\red [user] cuts open [M]'s face and neck with [src]!", \
							"\red [user] cuts open your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] cuts open their face and neck with [src]!", \
							"\red You cut open your face and neck with [src]!")

					if(M == user && prob(25))
						user << "\red You mess up!"
						if(istype(M, /mob/living/carbon/human))
							var/datum/organ/external/affecting = M:get_organ("head")
							affecting.take_damage(15)
							M.updatehealth()
						else
							M.take_organ_damage(15)

					M.face_op_stage = 1.0

					M.updatehealth()
					M.UpdateDamageIcon()
					return

// Scalpel Bone Surgery

	if(!try_bone_surgery(M, user) && user.a_intent == "hurt") // if we call ..(), we'll attack them, so require a hurt intent
		return ..()
/* wat
	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()
*/
	return

/obj/item/weapon/scalpel/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]

	if(!S || !istype(S))
		return 0

	if(S.status & DESTROYED)
		return ..()

	if(S.status & ROBOT)
		user << "Medical equipment for a robot arm?  How would that do any good..."
		return

	if(S.open)
		user << "\red The wound is already open!"
		return 0

	if(H != user)
		H.visible_message( \
			"\red [user] is beginning to cut open the wound in [H]'s [S.display_name] with [src].", \
			"\red [user] begins to cut open the wound in your [S.display_name] with [src]!")
	else
		H.visible_message( \
			"\red [user] begins to cut open the wound in \his [S.display_name] with [src]!", \
			"\red You begin to cut open the wound in your [S.display_name] with [src]!")

	if(do_mob(user, H, 100))
		if(H != user)
			H.visible_message( \
				"\red [user] cuts open the wound in [H]'s [S.display_name] with [src]!", \
				"\red [user] cuts open the wound in your [S.display_name] with [src]!")
		else
			H.visible_message( \
				"\red [user] cuts open the wound in \his [S.display_name] with [src]!", \
				"\red You cut open the wound in your [S.display_name] with [src]!")

		if(H == user && prob(25))
			user << "\red You mess up!"
			S.take_damage(15)

		S.status |= BLEEDING
		S.open = 1
		if(S.display_name == "chest")
			H:embryo_op_stage = 1.0
		if(S.display_name == "groin")
			H:appendix_op_stage = 1.0
		H.updatehealth()
		H.UpdateDamageIcon()
	else
		var/a = pick(1,2,3)
		var/msg
		if(a == 1)
			msg = "\red [user]'s move slices open [H]'s wound, causing massive bleeding"
			S.take_damage(35, 0, 1, "Malpractice")
		else if(a == 2)
			msg = "\red [user]'s move slices open [H]'s wound, and causes \him to accidentally stab himself"
			S.take_damage(35, 0, 1, "Malpractice")
			var/datum/organ/external/userorgan = user:organs["chest"]
			if(userorgan)
				userorgan.take_damage(35, 0, 1, "Malpractice")
			else
				user.take_organ_damage(35)
		else if(a == 3)
			msg = "\red [user] quickly stops the surgery"
		for(var/mob/O in viewers(H))
			O.show_message(msg, 1)

	return 1


////////////////
//CIRCULAR SAW//
////////////////
/obj/item/weapon/circular_saw/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if((CLUMSY in user.mutations) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	src.add_fingerprint(user)

	if(user.zone_sel.selecting == "head" || istype(M, /mob/living/carbon/metroid))

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M:brain_op_stage)
			if(0)
				if(!hasorgans(M))
					return ..()
				var/datum/organ/external/S = M:organs["head"]
				if(S.status & DESTROYED)
					return
				for(var/mob/O in viewers(M, null))
					O.show_message(text("\red [M] gets \his [S.display_name] sawed at with [src] by [user].... It looks like [user] is trying to cut it off!"), 1)
				if(!do_after(user,rand(50,70)))
					for(var/mob/O in viewers(M, null))
						O.show_message(text("\red [user] tried to cut [M]'s [S.display_name] off with [src], but failed."), 1)
					return
				for(var/mob/O in viewers(M, null))
					O.show_message(text("\red [M] gets \his [S.display_name] sawed off with [src] by [user]."), 1)
				S.status |= DESTROYED
				S.droplimb()
				M:update_body()
			if(1.0)
				if(istype(M, /mob/living/carbon/metroid))
					return
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his skull sawed open with [src] by [user].", 1)
					M << "\red [user] begins to saw open your head with [src]!"
					user << "\red You saw [M]'s head open with [src]!"
				else
					user.visible_message( \
						"\red [user] saws open \his skull with [src]!", \
						"\red You begin to saw open your head with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(40)
						M.updatehealth()
					else
						M.take_organ_damage(40)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:get_organ("head")
					affecting.take_damage(7)
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 2.0

			if(2.0)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						var/mob/living/carbon/metroid/Metroid = M
						if(Metroid.cores > 0)
							for(var/mob/O in (viewers(M) - user - M))
								O.show_message("\red [M.name] is having one of its cores sawed out with [src] by [user].", 1)

							Metroid.cores--
							M << "\red [user] begins to remove one of your cores with [src]! ([Metroid.cores] cores remaining)"
							user << "\red You cut one of [M]'s cores out with [src]! ([Metroid.cores] cores remaining)"

							new/obj/item/metroid_core(M.loc)

							if(Metroid.cores <= 0)
								M.icon_state = "baby metroid dead-nocore"

					return

			if(3.0)
				if(M.changeling && M.changeling.changeling_fakedeath)
					user << "\red The neural tissue regrows before your eyes as you cut it."
					return

				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his spine's connection to the brain severed with [src] by [user].", 1)
					M << "\red [user] severs your brain's connection to the spine with [src]!"
					user << "\red You sever [M]'s brain's connection to the spine with [src]!"
				else
					user.visible_message( \
						"\red [user] severs \his brain's connection to the spine with [src]!", \
						"\red You sever your brain's connection to the spine with [src]!" \
						)

				user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
				M.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"

				log_admin("ATTACK: [user] ([user.ckey]) debrained [M] ([M.ckey]) with [src].")
				message_admins("ATTACK: [user] ([user.ckey]) debrained [M] ([M.ckey]) with [src].")
				log_attack("<font color='red'>[user.name] ([user.ckey]) debrained [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")


				var/obj/item/brain/B = new(M.loc)
				B.transfer_identity(M)

				M:brain_op_stage = 4.0
				M.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.

			else
				..()
		return

	else if(user.zone_sel.selecting != "chest" && hasorgans(M))
		var/mob/living/carbon/H = M
		var/datum/organ/external/S = H:organs[user.zone_sel.selecting]
		if(S.status & DESTROYED)
			return

		if(S.status & ROBOT)
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, M)
			spark_system.attach(M)
			spark_system.start()
			spawn(10)
				del(spark_system)
		for(var/mob/O in viewers(H, null))
			O.show_message(text("\red [H] gets \his [S.display_name] sawed at with [src] by [user]... It looks like [user] is trying to cut it off!"), 1)
		if(!do_after(user, rand(20,80)))
			for(var/mob/O in viewers(H, null))
				O.show_message(text("\red [user] tried to cut [H]'s [S.display_name] off with [src], but failed."), 1)
			return
		for(var/mob/O in viewers(H, null))
			O.show_message(text("\red [H] gets \his [S.display_name] sawed off with [src] by [user]."), 1)
		S.droplimb(1)
		H:update_body()
	else
		return ..()
/*
	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()
*/
	return

//////////////////////////////
// Bone Gel and Bone Setter //
//////////////////////////////

/obj/item/weapon/surgical_tool
	name = "surgical tool"
	var/list/stage = list() //Stage to act on
	var/time = 50 //Time it takes to use
	var/list/wound = list()//Wound type to act on

	proc/get_message(var/mnumber,var/M,var/user,var/datum/organ/external/organ)//=Start,2=finish,3=walk away,4=screw up, 5 = closed wound
	proc/screw_up(mob/living/carbon/M as mob,mob/living/carbon/user as mob,var/datum/organ/external/organ)
		organ.brute_dam += 30
/obj/item/weapon/surgical_tool/proc/IsFinalStage(var/stage)
	var/a = 3
	return stage == a

/obj/item/weapon/surgical_tool/attack(mob/living/carbon/human/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return
	if((CLUMSY in user.mutations) && prob(50))
		M << "\red You stab yourself in the eye."
		M.disabilities |= 128
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	var/zone = user.zone_sel.selecting
	if (istype(M.organs[zone], /datum/organ/external))
		var/datum/organ/external/temp = M.organs[zone]
		var/msg

		if(temp.status & DESTROYED)
			return ..()

        // quickly convert embryo removal to bone surgery
		if(zone == "chest" && M.embryo_op_stage == 3)
			M.embryo_op_stage = 0
			temp.open = 2
			temp.status &= ~BLEEDING

		// quickly convert appendectomy to bone surgery
		if(zone == "groin" && M.appendix_op_stage == 3)
			M.appendix_op_stage = 0
			temp.open = 2
			temp.status &= ~BLEEDING

		msg = get_message(1,M,user,temp)
		for(var/mob/O in viewers(M,null))
			O.show_message("\red [msg]",1)
		if(do_mob(user,M,time))
			if(temp.open == 2 && !(temp.status & BLEEDING))
				if(temp.broken_description in wound)
					if(temp.stage in stage)
						temp.stage += 1

						if(IsFinalStage(temp.stage))
							temp.status &= ~BROKEN
							temp.status &= ~SPLINTED
							temp.stage = 0
							temp.perma_injury = 0
							temp.brute_dam = temp.min_broken_damage -1
						msg = get_message(2,M,user,temp)
					else
						msg = get_message(4,M,user,temp)
						screw_up(M,user,temp)
				else
					msg = get_message(5,M,user,temp)
		else
			msg = get_message(3,M,user,temp)

		for(var/mob/O in viewers(M,null))
			O.show_message("\red [msg]",1)


/*Broken bone
 Basic:
 Open -> Clean -> Bone-gel -> pop-into-place -> Bone-gel -> close -> glue -> clean

 Split:
 Open -> Clean -> Tweasers -> bone-glue -> close -> glue -> clean

 The above might not apply anymore.

*/

/obj/item/weapon/surgical_tool/bonegel
	name = "bone gel"
	icon = 'surgery.dmi'
	icon_state = "bone gel"

/obj/item/weapon/surgical_tool/bonegel/New()
	stage += 0
	stage += 2
	wound += "broken"
	wound += "fracture"
	wound += "hairline fracture"
/obj/item/weapon/surgical_tool/bonegel/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts applying bone gel to [m]'s [organ.display_name]"
		if(2)
			z="[usr] finishes applying bone gel to [m]'s [organ.display_name]"
		if(3)
			z="[usr] stops applying bone gel to [m]'s [organ.display_name]"
		if(4)
			z="[usr] applies bone gel incorrectly to [m]'s [organ.display_name]"
		if(5)
			z="[usr] lubricates [m]'s [organ.display_name]"
	return z

/obj/item/weapon/surgical_tool/bonesetter
	name = "bone setter"
	icon = 'surgery.dmi'
	icon_state = "bone setter"

/obj/item/weapon/surgical_tool/bonesetter/New()
	stage += 1
	wound += "broken"
	wound += "fracture"
	wound += "hairline fracture"
/obj/item/weapon/surgical_tool/bonesetter/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts popping [m]'s [organ.display_name] bone into place"
		if(2)
			z="[usr] finishes popping [m]'s [organ.display_name] bone into place"
		if(3)
			z="[usr] stops popping [m]'s [organ.display_name] bone into place"
		if(4)
			z="[usr] pops [m]'s [organ.display_name] bone into the wrong place"
		if(5)
			z="[usr] performs chiropractice on [m]'s [organ.display_name]"
	return z


/obj/item/weapon/boneinjector
	name = "Bone-repairing Nanites Injector"
	desc = "This injects the person with nanites that repair bones."
	icon = 'items.dmi'
	icon_state = "implanter1"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/uses = 5

/obj/item/weapon/boneinjector/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/weapon/boneinjector/proc/inject(mob/M as mob)
	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		for(var/name in H.organs)
			var/datum/organ/external/e = H.organs[name]
			if(e.status & DESTROYED) // this is nanites, not space magic
				continue
			e.brute_dam = 0.0
			e.burn_dam = 0.0
			e.status &= ~BANDAGED
			e.max_damage = initial(e.max_damage)
			e.status &= ~BLEEDING
			e.open = 0
			e.status &= ~BROKEN
			e.status &= ~DESTROYED
			e.status &= ~SPLINTED
			e.perma_injury = 0
			e.update_icon()
		H.update_body()
		H.update_face()
		H.UpdateDamageIcon()

	uses--
	if(uses == 0)
		spawn(0)//this prevents the collapse of space-time continuum
			del(src)
	return uses

/obj/item/weapon/boneinjector/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [M.name] ([M.ckey])</font>")
	log_admin("ATTACK: [user] ([user.ckey]) injected [M] ([M.ckey]) with [src].")

	if (user)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [] has been injected with [] by [].", M, src, user), 1)
			//Foreach goto(192)
		if (!(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey)))
			user << "\red Apparently it didn't work."
			return
		inject(M)//Now we actually do the heavy lifting.

		if(!isnull(user))//If the user still exists. Their mob may not.
			user.show_message(text("\red You inject [M]"))
	return
