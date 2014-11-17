/* Surgery Tools
 * Contains:
 *		Retractor
 *		Hemostat
 *		Cautery
 *		Surgical Drill
 *		Scalpel
 *		Circular Saw
 */

/*
 * Retractor
 */
/obj/item/weapon/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	m_amt = 10000
	g_amt = 5000 // OH COME ON, WHERE THE FUCK IS THERE ANY GLASS IN A GODDAMN RETRACTOR
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is pulling \his eyes out with the [src.name]! It looks like \he's  trying to commit suicide!</b>"
		return (BRUTELOSS)


/*HAHA, SUCK IT, 2000 LINES OF SPAGHETTI CODE!

NOW YOUR JOB IOS DONE BY ONLY 500 LINES OF SPAGHETTI CODE!

LOOK FOR SURGERY.DM*/

/*
/obj/item/weapon/retractor/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

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

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/slime))//Aliens don't have eyes./N
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
						var/datum/organ/external/affecting = M:get_organ("head")
						if(affecting.take_damage(15))
							M:UpdateDamageIcon()
						M.updatehealth()
					else
						M.take_organ_damage(15)

				M:eye_op_stage = 2.0

	else if(user.zone_sel.selecting == "chest")
		switch(M:alien_op_stage)
			if(3.0)
				var/mob/living/carbon/human/H = M
				if(!istype(H))
					return ..()

				if(H.wear_suit || H.w_uniform)
					user << "\red You're going to need to remove that suit/jumpsuit first."
					return

				var/obj/item/alien_embryo/A = locate() in M.contents
				if(!A)
					return ..()
				user.visible_message("\red [user] begins to pull something out of [M]'s chest.", "\red You begin to pull the alien organism out of [M]'s chest.")

				spawn(20 + rand(0,50))
					if(!A || A.loc != M)
						return

					if(M == user && prob(25))
						user << "\red You mess up!"
						if(istype(M, /mob/living/carbon/human))
							var/datum/organ/external/affecting = M:get_organ("chest")
							if(affecting.take_damage(30))
								M:UpdateDamageIcon()
						else
							M.take_organ_damage(30)

					if(A.stage > 3)
						var/chance = 15 + max(0, A.stage - 3) * 10
						if(prob(chance))
							A.AttemptGrow(0)
						M:alien_op_stage = 4.0

					if(M)
						user.visible_message("\red [user] pulls an alien organism out of [M]'s chest.", "\red You pull the alien organism out of [M]'s chest.")
						A.loc = M.loc	//alien embryo handles cleanup

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return
*/

/*
 * Hemostat
 */
/obj/item/weapon/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	m_amt = 5000
	g_amt = 2500
	w_type = RECYK_METAL
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is pulling \his eyes out with the [src.name]! It looks like \he's  trying to commit suicide!</b>"
		return (BRUTELOSS)


/*
/obj/item/weapon/hemostat/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/table/, M.loc) && M.lying && prob(50))))
		return ..()

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
				if(1.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is beginning to clamp bleeders in [M]'s abdomen cut open with [src].", 1)
						M << "\red [user] begins to clamp bleeders in your abdomen with [src]!"
						user << "\red You clamp bleeders in [M]'s abdomen with [src]!"
						M:appendix_op_stage = 2.0
				if(4.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is removing [M]'s appendix with [src].", 1)
						M << "\red [user] begins to remove your appendix with [src]!"
						user << "\red You remove [M]'s appendix with [src]!"
						for(var/datum/disease/D in M.viruses)
							if(istype(D, /datum/disease/appendicitis))
								new /obj/item/weapon/reagent_containers/food/snacks/appendix/inflamed(get_turf(M))
								M:appendix_op_stage = 5.0
								return
						new /obj/item/weapon/reagent_containers/food/snacks/appendix(get_turf(M))
						M:appendix_op_stage = 5.0
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
						var/datum/organ/external/affecting = M:get_organ("head")
						if(affecting.take_damage(15))
							M:UpdateDamageIcon()
						M.updatehealth()
					else
						M.take_organ_damage(15)
				M:eye_op_stage = 3.0

	else if(user.zone_sel.selecting == "chest")
		if(M:alien_op_stage == 2.0 || M:alien_op_stage == 3.0)
			var/mob/living/carbon/human/H = M
			if(!istype(H))
				return ..()

			if(H.wear_suit || H.w_uniform)
				user << "\red You're going to need to remove that suit/jumpsuit first."
				return

			user.visible_message("\red [user] begins to dig around in [M]'s chest.", "\red You begin to dig around in [M]'s chest.")

			spawn(20 + (M:alien_op_stage == 3 ? 0 : rand(0,50)))
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("chest")
						if(affecting.take_damage(30))
							M:UpdateDamageIcon()
					else
						M.take_organ_damage(30)

				var/obj/item/alien_embryo/A = locate() in M.contents
				if(A)
					var/dat = "\blue You found an unknown alien organism in [M]'s chest!"
					if(A.stage < 4)
						dat += " It's small and weak, barely the size of a foetus."
					if(A.stage > 3)
						dat += " It's grown quite large, and writhes slightly as you look at it."
						if(prob(10))
							A.AttemptGrow()
					user << dat
					M:alien_op_stage = 3.0
				else
					user << "\blue You find nothing of interest."

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return
*/

/*
 * Cautery
 */
/obj/item/weapon/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	m_amt = 5000
	g_amt = 2500
	w_type = RECYK_ELECTRONIC
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is burning \his eyes out with the [src.name]! It looks like \he's  trying to commit suicide!</b>"
		return (BRUTELOSS)

/*
/obj/item/weapon/cautery/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/table/, M.loc) && M.lying && prob(50))))
		return ..()

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
						for(var/datum/disease/appendicitis in M.viruses)
							appendicitis.cure()
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
						var/datum/organ/external/affecting = M:get_organ("head")
						if(affecting.take_damage(15))
							M:UpdateDamageIcon()
						M.updatehealth()
					else
						M.take_organ_damage(15)
				M.sdisabilities &= ~BLIND
				M.eye_stat = 0
				M:eye_op_stage = 0.0

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return
*/

/*
 * Surgical Drill
 */
/obj/item/weapon/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	m_amt = 15000
	g_amt = 10000
	w_type = RECYK_ELECTRONIC
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 15.0
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")

	suicide_act(mob/user)
		viewers(user) << pick("\red <b>[user] is pressing the [src.name] to \his temple and activating it! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is pressing [src.name] to \his chest and activating it! It looks like \he's trying to commit suicide.</b>")
		return (BRUTELOSS)

/*
 * Scalpel
 */
/obj/item/weapon/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	hitsound = "sound/weapons/bladeslice.ogg"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 10.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000
	w_type = RECYK_METAL
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		viewers(user) << pick("\red <b>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>")
		return (BRUTELOSS)

/*
/obj/item/weapon/scalpel/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	//if(M.mutations & M_HUSK)	return ..()

	if((M_CLUMSY in user.mutations) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/table/, M.loc) && M.lying && prob(50))))
		return ..()

	src.add_fingerprint(user)

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
				if(0.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M] is beginning to have his abdomen cut open with [src] by [user].", 1)
						M << "\red [user] begins to cut open your abdomen with [src]!"
						user << "\red You cut [M]'s abdomen open with [src]!"
						M:appendix_op_stage = 1.0
				if(3.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M] is beginning to have his appendix seperated with [src] by [user].", 1)
						M << "\red [user] begins to seperate your appendix with [src]!"
						user << "\red You seperate [M]'s appendix with [src]!"
						M:appendix_op_stage = 4.0
		return

	if(user.zone_sel.selecting == "head" || istype(M, /mob/living/carbon/slime))

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
				if(istype(M, /mob/living/carbon/slime))
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
						var/datum/organ/external/affecting = M:get_organ("head")
						if(affecting.take_damage(15))
							M:UpdateDamageIcon()
					else
						M.take_organ_damage(15)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:get_organ("head")
					affecting.take_damage(7)
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 1.0

			if(1)
				if(istype(M, /mob/living/carbon/slime))
					if(M.stat == 2)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M.name] is having its silky innards cut apart with [src] by [user].", 1)
						M << "\red [user] begins to cut apart your innards with [src]!"
						user << "\red You cut [M]'s silky innards apart with [src]!"
						M:brain_op_stage = 2.0
					return
			if(2.0)
				if(istype(M, /mob/living/carbon/slime))
					if(M.stat == 2)
						var/mob/living/carbon/slime/slime = M
						if(slime.cores > 0)
							if(istype(M, /mob/living/carbon/slime))
								user << "\red You attempt to remove [M]'s core, but [src] is ineffective!"
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
						var/datum/organ/external/affecting = M:get_organ("head")
						if(affecting.take_damage(75))
							M:UpdateDamageIcon()
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

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/slime))//Aliens don't have eyes./N
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
						var/datum/organ/external/affecting = M:get_organ("head")
						if(affecting.take_damage(15))
							M:UpdateDamageIcon()
					else
						M.take_organ_damage(15)

				user << "\blue So far so good before."
				M.updatehealth()
				M:eye_op_stage = 1.0
				user << "\blue So far so good after."

	else if(user.zone_sel.selecting == "chest")
		switch(M:alien_op_stage)
			if(0.0)
				var/mob/living/carbon/human/H = M
				if(!istype(H))
					return ..()

				if(H.wear_suit || H.w_uniform)
					user << "\red You're going to need to remove that suit/jumpsuit first."
					return

				user.visible_message("\red [user] begins to slice open [M]'s chest.", "\red You begin to slice open [M]'s chest.")

				spawn(rand(20,50))
					if(M == user && prob(25))
						user << "\red You mess up!"
						if(istype(M, /mob/living/carbon/human))
							var/datum/organ/external/affecting = M:get_organ("chest")
							if(affecting.take_damage(15))
								M:UpdateDamageIcon()
						else
							M.take_organ_damage(15)

					M:alien_op_stage = 1.0
					user << "\blue So far so good."

	else
		return ..()
/* wat
	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()*/
	return
*/

/*

 * Researchable Scalpels

*/
/obj/item/weapon/scalpel/laser1
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks basic and could be improved."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"

/obj/item/weapon/scalpel/laser2
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks somewhat advanced."
	icon_state = "scalpel_laser2_on"
	damtype = "fire"
	force = 12.0

/obj/item/weapon/scalpel/laser3
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser3_on"
	damtype = "fire"
	force = 15.0

/obj/item/weapon/scalpel/manager
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager_on"
	force = 7.5

/*
 * Circular Saw
 */
/obj/item/weapon/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 15.0
	w_class = 1.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	m_amt = 20000
	g_amt = 10000
	w_type = RECYK_ELECTRONIC
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is sawing \his head in two with the [src.name]! It looks like \he's  trying to commit suicide!</b>"
		return (BRUTELOSS)


/*
/obj/item/weapon/circular_saw/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if((M_CLUMSY in user.mutations) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/table/, M.loc) && M.lying && prob(50))))
		return ..()

	src.add_fingerprint(user)

	if(user.zone_sel.selecting == "head" || istype(M, /mob/living/carbon/slime))

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
				if(istype(M, /mob/living/carbon/slime))
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
						var/datum/organ/external/affecting = M:get_organ("head")
						if(affecting.take_damage(40))
							M:UpdateDamageIcon()
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
				if(istype(M, /mob/living/carbon/slime))
					if(M.stat == 2)
						var/mob/living/carbon/slime/slime = M
						if(slime.cores > 0)
							for(var/mob/O in (viewers(M) - user - M))
								O.show_message("\red [M.name] is having one of its cores sawed out with [src] by [user].", 1)

							slime.cores--
							M << "\red [user] begins to remove one of your cores with [src]! ([slime.cores] cores remaining)"
							user << "\red You cut one of [M]'s cores out with [src]! ([slime.cores] cores remaining)"

							new slime.coretype(M.loc)

							if(slime.cores <= 0)
								M.icon_state = "[slime.colour] baby slime dead-nocore"

					return

			if(3.0)
				/*if(M.mind && M.mind.changeling)
					user << "\red The neural tissue regrows before your eyes as you cut it."
					return*/

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

				user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
				M.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"

				log_attack("<font color='red'>[user.name] ([user.ckey]) debrained [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")


				var/obj/item/organ/brain/B = new(M.loc)
				B.transfer_identity(M)

				M:brain_op_stage = 4.0
				M.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.

			else
				..()
		return

	else if(user.zone_sel.selecting == "chest")
		switch(M:alien_op_stage)
			if(1.0)
				var/mob/living/carbon/human/H = M
				if(!istype(H))
					return ..()

				if(H.wear_suit || H.w_uniform)
					user << "\red You're going to need to remove that suit/jumpsuit first."
					return

				user.visible_message("\red [user] begins to slice through the bone of [M]'s chest.", "\red You begin to slice through the bone of [M]'s chest.")

				spawn(20 + rand(0,50))
					if(M == user && prob(25))
						user << "\red You mess up!"
						if(istype(M, /mob/living/carbon/human))
							var/datum/organ/external/affecting = M:get_organ("chest")
							if(affecting.take_damage(15))
								M:UpdateDamageIcon()
						else
							M.take_organ_damage(15)

					M:alien_op_stage = 2.0
					user << "\blue So far so good."

	else
		return ..()
/*
	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()
*/
	return
*/

//misc, formerly from code/defines/weapons.dm
/obj/item/weapon/bonegel
	name = "bone gel"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	force = 0
	throwforce = 1.0

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is eating the [src.name]! It looks like \he's  trying to commit suicide!</b>" //Don't eat glue kids.
		return (TOXLOSS)


/obj/item/weapon/FixOVein
	name = "FixOVein"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0
	origin_tech = "materials=1;biotech=3"
	var/usage_amount = 10

/obj/item/weapon/bonesetter
	name = "bone setter"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	attack_verb = list("attacked", "hit", "bludgeoned")

/*
 * Cyborg Hand
 */
/obj/item/weapon/revivalprod
	name = "revival prod"
	desc = "A revival prod used to awaken sleeping patients."
	//icon = 'icons/obj/surgery.dmi'
	icon_state = "stun baton"
	force = 0


/obj/item/weapon/revivalprod/attack(mob/target,mob/user)
	if(target.lying)
		target.sleeping = max(0,target.sleeping-5)
		if(target.sleeping == 0)
			target.resting = 0
		target.AdjustParalysis(-3)
		target.AdjustStunned(-3)
		target.AdjustWeakened(-3)
		playsound(get_turf(target), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		target.visible_message(
			"<span class='notice'>[user] prods [target] trying to wake \him up!</span>",
			"<span class='notice'>You prod [target] trying to wake \him up!</span>",
			)
		else
			return ..()
