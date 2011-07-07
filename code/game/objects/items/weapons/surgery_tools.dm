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

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(50))))
		return ..()

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
						O.show_message("\red [M] is having his eyes retracted by [user].", 1)
					M << "\red [user] begins to seperate your eyes with [src]!"
					user << "\red You seperate [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to have his eyes retracted.", \
						"\red You begin to pry open your eyes with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)

				M:eye_op_stage = 2.0

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return

////////////
//Hemostat//
////////////

/obj/item/weapon/hemostat/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && M.lying && prob(50))))
		return ..()

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
			if(2.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] is having his eyes mended by [user].", 1)
					M << "\red [user] begins to mend your eyes with [src]!"
					user << "\red You mend [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to have his eyes mended.", \
						"\red You begin to mend your eyes with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
				M:eye_op_stage = 3.0

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return

///////////
//Cautery//
///////////

/obj/item/weapon/cautery/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && M.lying && prob(50))))
		return ..()

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
						O.show_message("\red [M] is having his eyes cauterized by [user].", 1)
					M << "\red [user] begins to cauterize your eyes!"
					user << "\red You cauterize [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to have his eyes cauterized.", \
						"\red You begin to cauterize your eyes!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
				M.sdisabilities &= ~1
				M:eye_op_stage = 0.0

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return


//obj/item/weapon/surgicaldrill


///////////
//SCALPEL//
///////////
/obj/item/weapon/scalpel/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if((user.mutations & CLOWN) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && M.lying && prob(50))))
		return ..()

	src.add_fingerprint(user)

	if(user.zone_sel.selecting == "head")

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
			if(0.0)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M.name] is beginning to have its flesh cut open with [src] by [user].", 1)
						M << "\red [user] begins to cut open your flesh with [src]!"
						user << "\red You cut [M]'s flesh open with [src]!"
						M:brain_op_stage = 1.0
						return

				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] is beginning to have his head cut open with [src] by [user].", 1)
					M << "\red [user] begins to cut open your head with [src]!"
					user << "\red You cut [M]'s head open with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to cut open his skull with [src]!", \
						"\red You begin to cut open your head with [src]!" \
					)

				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(15)
					else
						M.take_organ_damage(15)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:organs["head"]
					affecting.take_damage(7)
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 1.0

			if(1)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M.name] is having its silky inndards cut apart with [src] by [user].", 1)
						M << "\red [user] begins to cut apart your innards with [src]!"
						user << "\red You cut [M]'s silky innards apart with [src]!"
						M:brain_op_stage = 2.0
						return
			if(2.0)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						var/mob/living/carbon/metroid/Metroid = M
						if(Metroid.cores > 0)
							if(istype(M, /mob/living/carbon/metroid))
								user << "\red You attempt to remove [M]'s core, but your [src] is ineffective!"
								return

				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] is having his connections to the brain delicately severed with [src] by [user].", 1)
					M << "\red [user] begins to cut open your head with [src]!"
					user << "\red You cut [M]'s head open with [src]!"
				else
					user.visible_message( \
						"\red [user] begin to delicately remove the connections to his brain with [src]!", \
						"\red You begin to cut open your head with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You nick an artery!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(75)
					else
						M.take_organ_damage(75)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:organs["head"]
					affecting.take_damage(7)
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 3.0
			else
				..()
		return

	else if(user.zone_sel.selecting == "eyes")
		user << "\blue So far so good."

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
						O.show_message("\red [M] is beginning to have his eyes incised with [src] by [user].", 1)
					M << "\red [user] begins to cut open your eyes with [src]!"
					user << "\red You make an incision around [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to cut around his eyes with [src]!", \
						"\red You begin to cut open your eyes with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(15)
					else
						M.take_organ_damage(15)

				user << "\blue So far so good before."
				M.updatehealth()
				M:eye_op_stage = 1.0
				user << "\blue So far so good after."
	else
		return ..()
/* wat
	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()
*/
	return


////////////////
//CIRCULAR SAW//
////////////////
/obj/item/weapon/circular_saw/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if((user.mutations & CLOWN) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && M.lying && prob(50))))
		return ..()

	src.add_fingerprint(user)

	if(user.zone_sel.selecting == "head")

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
			if(1.0)
				if(istype(M, /mob/living/carbon/metroid))
					return
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has his skull sawed open with [src] by [user].", 1)
					M << "\red [user] begins to saw open your head with [src]!"
					user << "\red You saw [M]'s head open with [src]!"
				else
					user.visible_message( \
						"\red [user] saws open his skull with [src]!", \
						"\red You begin to saw open your head with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(40)
						M.updatehealth()
					else
						M.take_organ_damage(40)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:organs["head"]
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
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has his spine's connection to the brain severed with [src] by [user].", 1)
					M << "\red [user] severs your brain's connection to the spine with [src]!"
					user << "\red You sever [M]'s brain's connection to the spine with [src]!"
				else
					user.visible_message( \
						"\red [user] severs his brain's connection to the spine with [src]!", \
						"\red You sever your brain's connection to the spine with [src]!" \
					)

				var/obj/item/brain/B = new(M.loc)
				B.transfer_identity(M)

				M:brain_op_stage = 4.0
				M.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.

			else
				..()
		return

	else
		return ..()
/*
	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()
*/
	return
