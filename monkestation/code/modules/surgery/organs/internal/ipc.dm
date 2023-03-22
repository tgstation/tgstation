/obj/item/organ/internal/liver/cybernetic/upgraded/ipc
	name = "substance processor"
	icon_state = "substance_processor"
	desc = "A machine component, installed in the chest. This grants the Machine the ability to process chemicals that enter its systems."
	alcohol_tolerance = 0
	toxTolerance = -1
	status = ORGAN_ROBOTIC
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

/obj/item/organ/internal/liver/cybernetic/upgraded/ipc/emp_act(severity)
	to_chat(owner, "<span class='warning'>Alert: Your Substance Processor has been damaged. An internal chemical leak is affecting performance.</span>")
	switch(severity)
		if(1)
			owner.toxloss += 15
		if(2)
			owner.toxloss += 5

/obj/item/organ/internal/stomach/ethereal/battery
	name = "implantable battery"
	icon_state = "implant-power"
	desc = "A battery that stores charge for species that run on electricity."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

/obj/item/organ/internal/stomach/ethereal/battery/ipc
	name = "micro-cell"
	icon_state = "microcell"
	w_class = WEIGHT_CLASS_NORMAL
	desc = "A micro-cell, for IPC use. Do not swallow."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

/obj/item/organ/internal/stomach/ethereal/battery/ipc/emp_act(severity)
	..()
	switch(severity)
		if(1)
			to_chat(owner, "<span class='warning'>Alert: Heavy EMP Detected. Rebooting power cell to prevent damage.</span>")
		if(2)
			to_chat(owner, "<span class='warning'>Alert: EMP Detected. Cycling battery.</span>")

	adjust_charge(-100*severity)

/obj/item/organ/internal/brain/positron
	name = "ipc positronic brain"
	slot = ORGAN_SLOT_BRAIN
	zone = BODY_ZONE_CHEST
	status = ORGAN_ROBOTIC
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It has an IPC serial number engraved on the top. In order for this Posibrain to be used as a newly built Positronic Brain, it must be coupled with an MMI."
	icon = 'monkestation/icons/obj/assemblies.dmi'
	icon_state = "posibrain-ipc"
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/internal/brain/positron/Insert(mob/living/carbon/C, special = FALSE, drop_if_replaced = TRUE, no_id_transfer = FALSE)
	..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.dna?.species)
			if(REVIVESBYHEALING in H.dna.species.species_traits)
				if(H.health > 0)
					H.revive(0)

/obj/item/organ/internal/brain/positron/emp_act(severity)
	switch(severity)
		if(1)
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 75)
			to_chat(owner, "<span class='warning'>Alert: Posibrain heavily damaged.</span>")
		if(2)
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)
			to_chat(owner, "<span class='warning'>Alert: Posibrain damaged.</span>")

/obj/item/organ/internal/ears/robot
	name = "auditory sensors"
	icon_state = "robotic_ears"
	desc = "A pair of microphones intended to be installed in an IPC head, that grant the ability to hear."
	zone = "head"
	slot = "ears"
	gender = PLURAL
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

/obj/item/organ/internal/ears/robot/emp_act(severity)
	switch(severity)
		if(1)
			owner.set_jitter_if_lower(30)
			owner.set_dizzy_if_lower(30)
			owner.Knockdown(200)
			to_chat(owner, "<span class='warning'>Alert: Audio sensors malfunctioning</span>")
			owner.apply_status_effect(/datum/status_effect/ipc/emp)
		if(2)
			owner.set_jitter_if_lower(15)
			owner.set_dizzy_if_lower(15)
			owner.Knockdown(100)
			to_chat(owner, "<span class='warning'>Alert: Audio sensors malfunctioning</span>")
			owner.apply_status_effect(/datum/status_effect/ipc/emp)

/obj/item/organ/internal/heart/cybernetic/ipc
	desc = "An electronic device that appears to mimic the functions of an organic heart."
	dose_available = FALSE

/obj/item/organ/internal/heart/cybernetic/ipc/emp_act()
	. = ..()
	to_chat(owner, "<span class='warning'>Alert: Cybernetic heart failed one heartbeat</span>")
	addtimer(CALLBACK(src, .proc/Restart), 10 SECONDS)

/obj/item/organ/heart/freedom
	name = "heart of freedom"
	desc = "This heart pumps with the passion to give... something freedom."
	organ_flags = ORGAN_SYNTHETIC //the power of freedom prevents heart attacks
	var/min_next_adrenaline = 0

/obj/item/organ/heart/freedom/on_life()
	. = ..()
	if(owner.health < 5 && world.time > min_next_adrenaline)
		min_next_adrenaline = world.time + rand(250, 600) //anywhere from 4.5 to 10 minutes
		to_chat(owner, "<span class='userdanger'>You feel yourself dying, but you refuse to give up!</span>")
		owner.heal_overall_damage(15, 15, 0, BODYTYPE_ORGANIC)
		if(owner.reagents.get_reagent_amount(/datum/reagent/medicine/ephedrine) < 20)
			owner.reagents.add_reagent(/datum/reagent/medicine/ephedrine, 10)
