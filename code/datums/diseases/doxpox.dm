/datum/disease/doxpox
	name = "Medicus Dox Pox"
	max_stages = 14
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Virus will cure itself, or medium dosage of spaceacillin and diphenhydramine"
	cures = list("spaceacillin","diphenhydramine")
	agent = "Gratias Doccus Poxviridae"
	viable_mobtypes = list(/mob/living/carbon/human,/mob/living/carbon/monkey)
	cure_chance = 15
	desc = "Causes outbreak of fragile pox on the skin, preventing the subject from wearing outer clothing. Touching the infected will pop the pox and injure them. Subject immune system will cure virus by itself over time."
	severity = DANGEROUS

/datum/disease/doxpox/stage_act()
	..()
	switch(stage)
		if(1)
			affected_mob.unEquip(SLOT_OCLOTHING)
			affected_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/reactive/pox/first(affected_mob), slot_wear_suit)
			affected_mob.visible_message("<span class='danger'>[affected_mob] removes their outer clothing, revealing their pox covered torso!</span>")
			affected_mob.say( pick( list("Arrrggh!", "It hurts!", "Don't touch me!", "Stay back! Don't touch me!") ) )
		if(7)
			affected_mob.unEquip(SLOT_OCLOTHING)
			affected_mob.visible_message("<span class='danger'>[affected_mob] poxes get worse, and looks even more painful!</span>")
			affected_mob.say( pick( list("ARRRRRRGHHHHH!", "The pain! IT SPEAKS TO ME", "STAY BACK!.", "EVERYTHING HURTS", "MAKE IT STOP") ) )
			qdel(src)
			affected_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/reactive/pox/last(affected_mob), slot_wear_suit)
		if(14)
			affected_mob.unEquip(SLOT_OCLOTHING)
			affected_mob.visible_message("<span class='danger'>[affected_mob]'s poxes quickly vanish.</span>")
			affected_mob << "<span class='notice'>Your poxes quickly heal, and you feel much better.</span>"
			qdel(src)
			cure()