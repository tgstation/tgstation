
/obj/item/organ/internal/cyberimp/bci/bcc
	name = "Body control core"
	desc = "A small, self-contained computer that interfaces with the nervous system, allowing for direct control of the body's functions"
	icon_state = "bcc"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/modules = list()
	var/stress = 0 //accumulated level of stress, it has increasing negative effects
	var/remove_amt = 0.5 //amount of medicines removed per tick



/obj/item/organ/internal/cyberimp/bci/bcc/Initialize()
	. = ..()

/obj/item/organ/internal/cyberimp/bci/bcc/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/bcc_module))
		if(add_module(W))
			user.dropItemToGround(W)
			W.forceMove(src)
			to_chat(user, "<span class='notice'>You install [W] into [src].</span>")
		else
			to_chat(user, "<span class='warning'>[W] is already installed in [src].</span>")
	else
		return ..()

/obj/item/organ/internal/cyberimp/bci/bcc/on_life(delta_time, times_fired)
	. = ..()
	for(var/obj/item/bcc_module/module in modules)
		if(module.active)
			module.trigger(delta_time, times_fired, owner)
			module.stress(delta_time, owner, stress)
			stress += module.stress_cost * delta_time
	if(stress > 20)
		owner.adjustStaminaLoss(1*delta_time)
	if(stress > 50)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.1*delta_time)
	if(stress > 100)
		if(prob(15))
			owner.Stun(50)
	for(var/datum/reagent/medicine/R in owner.reagents.reagent_list)
		owner.reagents.remove_reagent(R.type, remove_amt * delta_time)
		stress += remove_amt * delta_time * 0.5
	stress=max(120, stress)



/obj/item/organ/internal/cyberimp/bci/bcc/proc/add_module(module)

	if(module in modules)
		return FALSE
	modules += module
	module.forceMove(src)
	return TRUE

/obj/item/organ/internal/cyberimp/bci/bcc/proc/remove_module(module)

	if(module in modules)
		modules -= module
		return TRUE
	return FALSE

/obj/item/bcc_module
	name = "BCC module"
	desc = "A module for the BCC"
	var/active = FALSE
	var/activation_name = null /// string you need to pass in the bcc activation command to activate this module
	var/stress_cost = 0 /// amount of stress this module adds to the bcc when activated

/obj/item/bcc_module/proc/trigger(delta_time, times_fired, mob)
	return

/obj/item/bcc_module/proc/stress(delta_time, mob, stress)
	return


/obj/item/bcc_module/basic_heal
	name = "Basic healing module"
	desc = "A module that heals the user when activated"
	activation_name = "basicheal"
	stress_cost = 2 //healing is good, but it's not free

/obj/item/bcc_module/basic_heal/trigger(delta_time, times_fired, /mob/living/carbon/human/mob)
	mob.adjustBruteLoss(-1*delta_time)
	mob.adjustFireLoss(-1*delta_time)
	mob.adjustOxyLoss(-1*delta_time)
	mob.adjustToxLoss(-1*delta_time)
	mob.adjustStaminaLoss(-1*delta_time)
	return

/obj/item/bcc_module/basic_heal/stress(delta_time, /mob/living/carbon/human/mob, stress)
	if(stress>40)
		mob.adjustBruteLoss(2*delta_time)
		mob.adjustFireLoss(2*delta_time)
		mob.adjustOxyLoss(2*delta_time)
		mob.adjustToxLoss(2*delta_time)
		mob.adjustStaminaLoss(2*delta_time)
		return


