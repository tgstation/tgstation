#define LIVER_DEFAULT_HEALTH 100
/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	origin_tech = "biotech=3"
	w_class = WEIGHT_CLASS_NORMAL
	zone = "chest"
	slot = "liver"
	desc = "Pairing suggestion: chianti and fava beans."
	var/damage = 0 //liver damage, 0 is no damage, 100 causes liver failure
	var/alcohol_tolerance = ALCOHOL_RATE
	var/failing //is this liver failing?
	var/maxHealth = LIVER_DEFAULT_HEALTH

/obj/item/organ/liver/on_life()
	var/mob/living/carbon/C = owner

	//slowly heal liver damage
	if(damage > 0)
		damage -= 0.01//in most cases the pure toxin damage from too much alcohol will kill you first.
	if(damage > maxHealth)//cap liver damage
		damage = maxHealth-1

	if(istype(C))
		if(!failing)//can't process reagents with a failing liver
			if(C.reagents)
				C.reagents.metabolize(C, can_overdose=1)

			if(damage > 10 && prob(damage/3))//the higher the damage the higher the probability
				to_chat(C, "<span = 'notice'>[pick("You feel nauseous.", "You feel a dull pain in your lower body.", "You feel confused.")]</span>")

/obj/item/organ/liver/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("iron", 5)
	return S

/obj/item/organ/liver/fly
	name = "insectoid liver"
	icon_state = "liver-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant liver designed to handle the unique diet of a flyperson."
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!
