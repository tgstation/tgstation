#define LIVER_DEFAULT_HEALTH 100 //amount of damage required for liver failure
#define LIVER_DEFAULT_TOX_TOLERANCE 3 //amount of toxins the liver can filter out
#define LIVER_DEFAULT_TOX_LETHALITY 0.5 //lower values lower how harmful toxins are to the liver

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	origin_tech = "biotech=3"
	w_class = WEIGHT_CLASS_NORMAL
	zone = "chest"
	slot = "liver"
	desc = "Pairing suggestion: chianti and fava beans."
	var/damage = 0 //liver damage, 0 is no damage, damage=maxHealth causes liver failure
	var/alcohol_tolerance = ALCOHOL_RATE//affects how much damage the liver takes from alcohol
	var/failing //is this liver failing?
	var/maxHealth = LIVER_DEFAULT_HEALTH
	var/toxTolerance = LIVER_DEFAULT_TOX_TOLERANCE//maximum amount of toxins the liver can just shrug off
	var/toxLethality = LIVER_DEFAULT_TOX_LETHALITY//affects how much damage toxins do to the liver
	var/filterToxins = TRUE //whether to filter toxins

/obj/item/organ/liver/on_life()
	var/mob/living/carbon/C = owner

	//slowly heal liver damage
	damage = max(0, damage - 0.1)
	if(damage > maxHealth)//cap liver damage
		damage = maxHealth

	if(istype(C))
		if(!failing)//can't process reagents with a failing liver
			if(filterToxins)
				//handle liver toxin filtration
				var/toxamount
				var/static/list/listOfToxinsInThisBitch = typesof(/datum/reagent/toxin)
				for(var/datum/reagent/toxin/toxin in listOfToxinsInThisBitch)
					toxamount += C.reagents.get_reagent_amount(initial(toxin.id))

				if(toxamount <= toxTolerance && toxamount > 0)
					for(var/datum/reagent/toxin/toxin in listOfToxinsInThisBitch)
						C.reagents.remove_reagent(initial(toxin.id), 1)
				else if(toxamount > toxTolerance)
					damage += toxamount*toxLethality


			//metabolize reagents
			C.reagents.metabolize(C, can_overdose=TRUE)

			if(damage > 10 && prob(damage/3))//the higher the damage the higher the probability
				to_chat(C, "<span class='notice'>You feel [pick("nauseous", "dull pain in your lower body", "confused")].</span>")

/obj/item/organ/liver/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("iron", 5)
	return S

/obj/item/organ/liver/fly
	name = "insectoid liver"
	icon_state = "liver-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant liver designed to handle the unique diet of a flyperson."
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/liver/plasmaman
	name = "reagent processing crystal"
	icon_state = "pliver"
	desc = "A large crystal that is somehow capable of metabolizing chemicals, these are found in plasmamen."

/obj/item/organ/liver/cybernetic
	name = "cybernetic liver"
	icon_state = "liver-c"
	desc = "An electronic device designed to mimic the functions of a human liver. It has no benefits over an organic liver, but is easy to produce."
	origin_tech = "biotech=4"

/obj/item/organ/liver/cybernetic/upgraded
	name = "upgraded cybernetic liver"
	icon_state = "liver-c-u"
	desc = "An upgraded version of the cybernetic liver, designed to improve upon organic livers. It is resistant to alcohol poisoning and is very robust at filtering toxins."
	origin_tech = "biotech=6"
	alcohol_tolerance = 0.001
	maxHealth = 200 //double the health of a normal liver
	toxTolerance = 15 //can shrug off up to 15u of toxins
	toxLethality = 0.3 //20% less damage than a normal liver

/obj/item/organ/liver/cybernetic/emp_act(severity)
	switch(severity)
		if(1)
			damage+=100
		if(2)
			damage+=50
