//An incredibly invasive procedure to remove antagonists


/datum/surgery/lobotomy
	name = "lobotomy"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/lobotomise_brain)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "head"


/datum/surgery_step/lobotomise_brain
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/kitchenknife = 50, /obj/item/weapon/wirecutters = 35)
	time = 64
	var/obj/item/organ/brain/B = null


/datum/surgery_step/lobotomise_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	B = target.getorgan(/obj/item/organ/brain)
	if(B)
		user.visible_message("<span class='notice'>[user] begins to sever the connections between the frontal lobe and thalamus of [target]'s brain</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for a brain in [target].</span>")


/datum/surgery_step/lobotomise_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(B)
		user.visible_message("<span class='notice'>[user] successfully severs the connections between the frontal lobe and thalamus in [target]'ts brain!</span>")
		target.emote("drool")
		if(target.mind)
			target << "<span class='userdanger'>Something snaps in your brain... you feel incredibly docile...</span>"
			target.mind.remove_all_antag()
			target.mind.store_memory("You were lobotomised, all objectives above this line are void and considered Failed")
			target.mind.show_memory(target)
		add_logs(user, target, "lobotomised", addition = "INTENT: [uppertext(user.a_intent)]")
	else
		user.visible_message("<span class='notice'>[user] can't find a brain in [target]!</span>")
	return 1


//designed to look the same as success() so there's no meta
/datum/surgery_step/lobotomise_brain/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(B)
		user.visible_message("<span class='notice'>[user] successfully severs the connections between the frontal lobe and thalamus in [target]'ts brain!</span>")
		target.emote("drool")
		if(user.mind && target.mind)
			var/datum/objective/assassinate/revenge = new
			revenge.owner = target.mind
			revenge.target = user.mind
			revenge.explanation_text = "Kill [revenge.target.name]"
			target.mind.special_role = "Lobotomy-induced Psycho"
			target.mind.objectives += revenge
			target << "<span class='userdanger'>Something snaps in your brain... [user.name] tried to lobotomise you but instead filled you with a lust to kill them!</span>"
		add_logs(user, target, "failed to lobotomise", addition = "INTENT: [uppertext(user.a_intent)]")
	else
		user.visible_message("<span class='notice'>[user] can't find a brain in [target]!</span>")
	return 1

