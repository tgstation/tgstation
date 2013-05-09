/datum/surgery/lobotomy
	name = "lobotomy"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/dig_around, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "head"


/datum/surgery_step/dig_around
	implements = list(/obj/item/weapon/screwdriver = 100, /obj/item/weapon/scalpel = 100, /obj/item/weapon/pickaxe = 25, /obj/item/weapon/fork = 55, /obj/item/weapon/spoon = 15, /obj/item/weapon/hemostat = 85, /obj/item/weapon/shard = 10)
	time = 25


/datum/surgery_step/dig_around/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	B = getbrain(target)
	if(B)
		user.visible_message("<span class='notice'>[user] begins to dig around in [target]'s brain.</span>")
	else
		user.visible_message("<span class='notice'>[user] pokes about in [target]'s skull.</span>")

/datum/surgery_step/dig_around/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
		if(B)
		user.visible_message("<span class='notice'>[user] lobotomizes [target]!</span>")
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
				H.hallucination -= rand(25,50)
				H.adjustBrainLoss += rand(15, 25)
				H.confused += 25
				H.take_organ_damage(10, 0)
				if((H.mind in ticker.mode.cult))
					H << "<span class='notice'>Your knowledge of the true nature of reality is ripped from your head.</span>"
					sible_message("<span class='notice'>[H]'s eyes become milky and dulled, like he lost vast amounts of knowledge</span>")
					ticker.mode.remove_cultist(H.mind)
				if(H.mind in ticker.mode:revolutionaries)
					ticker.mode:remove_revolutionary(H.mind)
					H << "<span class='notice'>You feel your anger at Nanotrasen fade.</span>"
					sible_message("<span class='notice'>[H]'s eyes glaze over.</span>")
					H.mutations.Add(CLUMSY)
				for(var/datum/diseases/brainrot/BR in H.viruses) //BR? BR?
					if(istype(BR)) // i repot yu
					del(BR) //HUEHUEHUEHUEHUEHUEHUE
	else
		user.visible_message("<span class='notice'>[user] digs around uselessly in [target]'s brain.</span>")
	return 0

/datum/surgery_step/dig_around/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(prob(50))
		target.adjustBrainLoss += 15
		user.visible_message("<span class='warning'>[user] accidentally pokes too far into [target]'s brain!</span>")
	else
		target.adjustBruteLoss(30)
		user.visible_message("<span class='warning'>[user] accidentally pokes [target] in the skull!</span>")
	return 1