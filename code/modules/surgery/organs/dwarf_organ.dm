/obj/item/organ/alcoholvessel //essentially the opposite of the xeno's plasmavessel, but with alcohol
	name = "alcoholvessel"
	icon_state = "plasma"
	origin_tech = "biotech=5;plasmatech=4"
	w_class = WEIGHT_CLASS_NORMAL
	zone = "chest"
	slot = "dwarf_organ"
	var/stored_alcohol = 250
	var/max_alcohol = 500
	var/heal_rate = 0.5
	var/alcohol_rate = 10

/obj/item/organ/alcoholvessel/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("ethonal", stored_alcohol/10)
	return S


/obj/item/organ/alcoholvessel/on_life()//alcohol usage
	var/heal_amt = heal_rate
	stored_alcohol -= alcohol_rate * 0.025
	if(stored_alcohol > 400)
		owner.adjustBruteLoss(-heal_amt)
		owner.adjustFireLoss(-heal_amt)
		owner.adjustOxyLoss(-heal_amt)
		owner.adjustCloneLoss(-heal_amt)
	if(stored_alcohol < 150 > 100 && prob(5))
		to_chat(owner, "<span class='notice'>You feel like you could use a good brew.</span>")
	if(stored_alcohol < 100 > 75 && prob(5))
		to_chat(owner, "<span class='notice'>A pint of ale would really hit hit the spot right now..</span>")
	if(stored_alcohol < 75 > 50 && prob(5))
		to_chat(owner, "<span class='warning'>Your body aches, you need to get ahold of some booze...</span>")
	if(stored_alcohol < 50 > 25 && prob(5))
		to_chat(owner, "<span class='danger'>Oh Armok, I need some brew!</span>")
	if(stored_alcohol < 25 && prob(5))
		to_chat(owner, "<span class='userdanger'>DAMNATION INCARNATE, WHY AM I CURSED WITH THIS DRY-SPELL? I MUST DRINK..</span>")
		owner.adjustToxLoss(35)

