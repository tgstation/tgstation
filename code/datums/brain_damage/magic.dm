//Magical traumas, caused by spells and curses.
//Blurs the line between the victim's imagination and reality
//Unlike regular traumas this can affect the victim's body and surroundings

/datum/brain_trauma/magic
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	
/datum/brain_trauma/magic/lumiphobia
	name = "Lumiphobia"
	desc = "Patient has an inexplicable adverse reaction to light."
	scan_desc = "light hypersensitivity"
	gain_text = "<span class='warning'>You feel a craving for darkness.</span>"
	lose_text = "<span class='notice'>Light no longer bothers you.</span>"
	var/next_damage_warning = 0

/datum/brain_trauma/magic/lumiphobia/on_life()
	..()
	var/turf/T = owner.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying
			if(world.time > next_damage_warning)
				to_chat(owner, "<span class='warning'><b>The light burns you!</b></span>")
				next_damage_warning = world.time + 100 //Avoid spamming
			owner.take_overall_damage(0,3)
			
/datum/brain_trauma/magic/poltergeist
	name = "Poltergeist"
	desc = "Patient appears to be targeted by a violent invisible entity."
	scan_desc = "paranormal activity"
	gain_text = "<span class='warning'>You feel a hateful presence close to you.</span>"
	lose_text = "<span class='notice'>You feel the hateful presence fade away.</span>"

/datum/brain_trauma/magic/poltergeist/on_life()
	..()
	if(prob(4))
		var/most_violent = -1 //So it can pick up items with 0 throwforce if there's nothing else
		var/obj/item/throwing
		for(var/obj/item/I in owner.view(5, get_turf(owner))
			if(I.anchored)
				continue
			if(I.throwforce > most_violent)
				most_violent = I.throwforce
				throwing = I
		if(throwing)
			throwing.throw_at(owner, 8, 2)
			
/datum/brain_trauma/magic/antimagic
	name = "Athaumasia"
	desc = "Patient is completely inert to magical forces."
	scan_desc = "thaumic blank"
	gain_text = "<span class='notice'>You realize that magic cannot be real.</span>"
	lose_text = "<span class='notice'>You realize that magic might be real.</span>"

/datum/brain_trauma/magic/antimagic/on_gain()
	owner.add_trait(TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/magic/antimagic/on_lose()
	owner.remove_trait(TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	..()