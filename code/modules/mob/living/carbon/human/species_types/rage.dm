/*Result of the rage serum, turning players into what is essentially a walking tank that exists solely to smash those weaker than them. Extremely durable
but essentially loses their ability to interact in any meaningful way that doesn't involve slamming their fists against it. */

/datum/species/rage
	name = "Walking Mass of Muscle and Testosterone."
	id = "buff_hulk"
	say_mod = "grunts"
	blacklisted = TRUE
	default_color = "34AF10"
	fixed_mut_color = "34AF10"
	species_traits = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,LIPS,PIERCEIMMUNE,NODISMEMBER,RADIMMUNE)
	use_skintones = 0
	mutant_bodyparts = list("tail_human", "ears", "wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	siemens_coeff = 0
	limbs_id = "human"
	no_equip = list(slot_head, slot_gloves, slot_wear_suit) //keeps user from wearing most types of armor to prevent additional resistance stacking.
	brutemod = 0.20
	burnmod = 0.35
	heatmod = 1.8
	stunmod = 0.15

/datum/species/rage/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	if(H.has_dna())
		if(H.dna.check_mutation(HULK)) //hulk along with this would be hilariously overpowered, probably
			H.visible_message("<span class='danger'>[H]'s body twists and contorts violently as their own muscle-mass caves in on them!</span>", \
							 "<span class='userdanger'>You cry out in agony as you feel your body tighten and concort inward on itself,\
				 			 the immense amount of muscle practically tearing you apart! Your body can't handle this much power!</span>")
			H.say("AAAAAARGGHH!!!")
			H.gib()
			return
	for(var/V in H.held_items)
		var/obj/item/I = V
		if(istype(I))
			if(H.dropItemToGround(I))
				var/obj/item/weapon/melee/buff_arm/h = new /obj/item/weapon/melee/buff_arm()
				H.put_in_hands(h)
		else
			var/obj/item/weapon/melee/buff_arm/h = new /obj/item/weapon/melee/buff_arm()
			H.put_in_hands(h)
	H.visible_message("<span class='danger'>[H]'s arms rapidly expand and contort into throbbing masses of muscle, their faces contorting into that of some wild, bloodlusting beast!</span>")
	H.AddSpell(new /obj/effect/proc_holder/spell/aimed/groundpound)
	H.resize = 1.25
	H.mind.objectives += new/datum/objective("<span class='userdanger'>CRUSH. KILL. DESTROY. FEAST UPON THE BLOOD OF THE WEAK.</span>") //unstable war machine, kill or be killed
	H.mind.announce_objectives()

/datum/species/rage/on_species_loss(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] convulses and contorts violently as their body rapidly changes, exploding into a shower of gibs!</span>")
	H.gib()

/datum/species/rage/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	H.visible_message("<span class='danger'>[H] collapses in on themselves, exploding into a violent shower of gibs!</span>")
	H.gib()