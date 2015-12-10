/datum/surgery/tail_removal
	name = "tail removal"
	steps = list(/datum/surgery_step/sever_tail, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human)
	possible_locs = list("groin")

/datum/surgery/lipoplasty/can_start(mob/user, mob/living/carbon/target)
	var/mob/living/carbon/human/L = target
	if(("tail_lizard" in L.dna.species.mutant_bodyparts) || ("waggingtail_lizard" in L.dna.species.mutant_bodyparts))
		return 1
	return 0

/datum/surgery_step/sever_tail
	name = "sever tail"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/circular_saw = 100, /obj/item/weapon/melee/energy/sword/cyborg/saw = 100, /obj/item/weapon/melee/arm_blade = 75, /obj/item/weapon/mounted_chainsaw = 65, /obj/item/weapon/twohanded/fireaxe = 50, /obj/item/weapon/twohanded/required/chainsaw = 50, /obj/item/weapon/hatchet = 40, /obj/item/weapon/kitchen/knife/butcher = 25)
	time = 64

/datum/surgery_step/sever_tail/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to sever [target]'s tail!", "<span class='notice'>You begin to sever [target]'s tail...</span>")

/datum/surgery_step/sever_tail/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/L = target
	user.visible_message("[user] severs [L]'s tail!", "<span class='notice'>You sever [L]'s tail.</span>")
	if("tail_lizard" in L.dna.species.mutant_bodyparts)
		L.dna.species.mutant_bodyparts -= "tail_lizard"
	else if("waggingtail_lizard" in L.dna.species.mutant_bodyparts)
		L.dna.species.mutant_bodyparts -= "waggingtail_lizard"
	if("spines" in L.dna.features)
		L.dna.features -= "spines"
	new /obj/item/organ/severedtail(src)
	L.update_body()
	return 1