/obj/item/organ/alcoholvessel //essentially the opposite of the xeno's plasmavessel, but with alcohol
	name = "adamantine infused lungs"
	icon_state = "plasma"
	origin_tech = "biotech=5"
	w_class = WEIGHT_CLASS_NORMAL
	zone = "chest"
	slot = "dwarf_organ"
	var/stored_alcohol = 250
	var/max_alcohol = 500
	var/heal_rate = 0.5
	var/alcohol_rate = 10
	var/cooldown = 35
	var/current_cooldown = 0
/obj/item/organ/alcoholvessel/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("ethanol", stored_alcohol/10)
	return S


/obj/item/organ/alcoholvessel/on_life()
	//BEARD SENSE
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		mineral_scan_pulse(get_turf(owner))
	// MIASMA HANDLING
	var/miasma_counter = 0
	for(var/fuck in view(owner,7))
		if(istype(fuck, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = fuck
			if(H.stat == DEAD)
				miasma_counter += 10
		if(istype(fuck, /obj/effect/decal/cleanable/blood))
			if(istype(fuck, /obj/effect/decal/cleanable/blood/gibs))
				miasma_counter += 1
			else
				miasma_counter += 0.1
	switch(miasma_counter)
		if(11 to 25)
			if(prob(5))
				to_chat(owner, "<span class = 'danger'>Someone should really clean up in here!</span>")
		if(26 to 50)
			if(prob(5))
				to_chat(owner, "<span class = 'danger'>The stench makes you queasy.</span>")
				if(prob(5))
					owner.vomit(20)
		if(51 to 75)
			if(prob(10))
				to_chat(owner, "<span class = 'danger'>By Armok! You won't be able to keep ale down at all!</span>")
				if(prob(10))
					owner.vomit(20)
		if(76 to 100)
			if(prob(15))
				to_chat(owner, "<span class = 'userdanger'>You can't live in such filth!</span>")
				if(prob(15))
					owner.adjustToxLoss(6)
					owner.vomit(20)

	// BOOZE HANDLING
	for(var/datum/reagent/R in owner.reagents.reagent_list)
		if(istype(R, /datum/reagent/consumable/ethanol))
			var/datum/reagent/consumable/ethanol/E = R
			stored_alcohol += (E.boozepwr / 50)
			if(stored_alcohol > max_alcohol)
				stored_alcohol = max_alcohol
	var/heal_amt = heal_rate
	stored_alcohol -= alcohol_rate * 0.025
	if(stored_alcohol > 400)
		owner.adjustBruteLoss(-heal_amt)
		owner.adjustFireLoss(-heal_amt)
		owner.adjustOxyLoss(-heal_amt)
		owner.adjustCloneLoss(-heal_amt)
	if(prob(5))
		switch(stored_alcohol)
			if(0 to 24)
				to_chat(owner, "<span class='userdanger'>DAMNATION INCARNATE, WHY AM I CURSED WITH THIS DRY-SPELL? I MUST DRINK.</span>")
				owner.adjustToxLoss(35)
			if(25 to 50)
				to_chat(owner, "<span class='danger'>Oh Armok, I need some brew!</span>")
			if(51 to 75)
				to_chat(owner, "<span class='warning'>Your body aches, you need to get ahold of some booze...</span>")
			if(76 to 100)
				to_chat(owner, "<span class='notice'>A pint of ale would really hit the spot right now.</span>")
			if(101 to 150)
				to_chat(owner, "<span class='notice'>You feel like you could use a good brew.</span>")

