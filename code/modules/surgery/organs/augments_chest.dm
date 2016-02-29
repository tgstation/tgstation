/obj/item/organ/internal/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "implants for the organs in your torso"
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	zone = "chest"

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	slot = "stomach"
	origin_tech = "materials=5;programming=3;biotech=4"

/obj/item/organ/internal/cyberimp/chest/nutriment/on_life()
	if(synthesizing)
		return

	if(owner.nutrition <= hunger_threshold)
		synthesizing = 1
		owner << "<span class='notice'>You feel less hungry...</span>"
		owner.nutrition += 50
		spawn(50)
			synthesizing = 0

/obj/item/organ/internal/cyberimp/chest/nutriment/emp_act(severity)
	if(!owner)
		return
	owner.reagents.add_reagent("????",poison_amount / severity) //food poisoning
	owner << "<span class='warning'>You feel like your insides are burning.</span>"


/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10
	origin_tech = "materials=5;programming=3;biotech=5"



/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	origin_tech = "materials=6;programming=3;biotech=6;syndicate=4"
	slot = "heartdrive"
	var/revive_cost = 0
	var/reviving = 0
	var/cooldown = 0

/obj/item/organ/internal/cyberimp/chest/reviver/on_life()
	if(reviving)
		if(owner.stat == UNCONSCIOUS)
			spawn(30)
				if(prob(90) && owner.getOxyLoss())
					owner.adjustOxyLoss(-3)
					revive_cost += 5
				if(prob(75) && owner.getBruteLoss())
					owner.adjustBruteLoss(-1)
					revive_cost += 20
				if(prob(75) && owner.getFireLoss())
					owner.adjustFireLoss(-1)
					revive_cost += 20
				if(prob(40) && owner.getToxLoss())
					owner.adjustToxLoss(-1)
					revive_cost += 50
		else
			cooldown = revive_cost + world.time
			reviving = 0
		return

	if(cooldown > world.time)
		return
	if(owner.stat != UNCONSCIOUS)
		return
	if(owner.suiciding)
		return

	revive_cost = 0
	reviving = 1

/obj/item/organ/internal/cyberimp/chest/reviver/emp_act(severity)
	if(!owner)
		return

	if(reviving)
		revive_cost += 200
	else
		cooldown += 200

	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity))
			H.heart_attack = 1
			spawn(600 / severity)
				H.heart_attack = 0
				if(H.stat == CONSCIOUS)
					H << "<span class='notice'>You feel your heart beating again!</span>"