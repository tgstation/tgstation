/datum/surgery/lobotomy
	name = "lobotomy"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/dig_around, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "head"


/datum/surgery_step/extract_brain
	implements = list(/obj/item/weapon/screwdriver = 100, /obj/item/weapon/scalpel = 100, /obj/item/weapon/pickaxe = 25, /obj/item/weapon/fork = 55, /obj/item/weapon/spoon = 15, /obj/item/weapon/hemostat 85, /obj/item/weapon/shard = 10)
	time = 64


/datum/surgery_step/extract_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	B = getbrain(target)
	if(B)
		user.visible_message("<span class='notice'>[user] begins to dig around in [target]'s brain.</span>")
	else
		user.visible_message("<span class='notice'>[user] pokes about in [target]'s skull.</span>")

/datum/surgery_step/extract_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(B)
		user.visible_message("<span class='notice'>[user] lobotomizes [target]!</span>")
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.update_hair(0)
			H.hallucination -= rand(50,75)
			H.adjustBrainLoss += rand(15, 25)
			H.confused += 25
			H.take_organ_damage(10, 0)
			H.stuttering += 25
			if(prob(10)) H.emote(pick("twitch","drool","moan","groan", "blink_r"))
	else //would make surgery 'failing' have disastrous consequences if I knew how, would appreciate help on that front
		user.visible_message("<span class='notice'>[user] digs around uselessly in [target]'s brain.</span>")
	return 1