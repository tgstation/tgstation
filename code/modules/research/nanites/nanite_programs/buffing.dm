//Programs that buff the host in generally passive ways.

/datum/nanite_program/nervous
	name = "Nerve Support"
	desc = "The nanites act as a secondary nervous system, reducing the amount of time the host is stunned."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/nervous/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 0.5

/datum/nanite_program/nervous/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 2

/datum/nanite_program/triggered/adrenaline
	name = "Adrenaline Burst"
	desc = "The nanites cause a burst of adrenaline when triggered, waking the host from stuns and temporarily increasing their speed."
	trigger_cost = 25
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/toxic, /datum/nanite_program/nerve_decay)

/datum/nanite_program/triggered/adrenaline/trigger()
	if(!..())
		return
	to_chat(host_mob, "<span class='notice'>You feel a sudden surge of energy!</span>")
	host_mob.SetStun(0)
	host_mob.SetKnockdown(0)
	host_mob.SetUnconscious(0)
	host_mob.adjustStaminaLoss(-75)
	host_mob.lying = 0
	host_mob.update_canmove()
	host_mob.reagents.add_reagent("stimulants", 1.5)

/datum/nanite_program/hardening
	name = "Dermal Hardening"
	desc = "The nanites form a mesh under the host's skin, protecting them from melee and bullet impacts."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/skin_decay)

/datum/nanite_program/hardening/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.melee += 50
		H.physiology.armor.bullet += 35

/datum/nanite_program/hardening/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.melee -= 50
		H.physiology.armor.bullet -= 35
	
/datum/nanite_program/refractive
	name = "Dermal Refractive Surface"
	desc = "The nanites form a membrane above the host's skin, reducing the effect of laser and energy impacts."
	use_rate = 0.50
	rogue_types = list(/datum/nanite_program/skin_decay)

/datum/nanite_program/refractive/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.laser += 50
		H.physiology.armor.energy += 35

/datum/nanite_program/refractive/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.laser -= 50
		H.physiology.armor.energy -= 35
	
/datum/nanite_program/triggered/reactive_hardening
	name = "Reactive Hardening"
	desc = "The nanites form a mesh under the host's skin that reacts to physical damage, becoming extremely durable for a limited time. Can be triggered to activate the effect manually."
	use_rate = 0.25
	trigger_cost = 10
	trigger_cooldown = 100
	rogue_types = list(/datum/nanite_program/skin_decay)
	extra_settings = list("Hardening Duration","Damage Threshold")
	var/hardened = FALSE
	var/harden_duration = 50
	var/trigger_threshold = 10
	var/timer_id
	
/datum/nanite_program/triggered/reactive_hardening/on_damage(damage_type, amount)
	if(!trigger_threshold)
		return
	if(!hardened && (damage_type == BRUTE || damage_type == BURN) && amount >= trigger_threshold)
		trigger()
	
/datum/nanite_program/triggered/reactive_hardening/trigger()
	if(hardened) //turning it off is free
		son()
		return
	if(!..())
		return
	nanomachines()
	timer_id = addtimer(CALLBACK(src, .proc/son), harden_duration)

/datum/nanite_program/triggered/reactive_hardening/disable_passive_effect()
	. = ..()
	son() //you ran out of nanomachines son
	
/datum/nanite_program/triggered/reactive_hardening/proc/nanomachines()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		hardened = TRUE
		H.visible_message("<span class='warning'>[H]'s skin is suddenly covered in metal!</span>", "<span class='notice'>Your skin hardens and becomes metallic as nanites cover it!</span>")
		H.physiology.brute_mod *= 0.1
		H.physiology.burn_mod *= 0.1
		H.add_trait(TRAIT_PIERCEIMMUNE, "reactive_hardening")
		H.add_trait(TRAIT_NODISMEMBER, "reactive_hardening")
		use_rate = 7

/datum/nanite_program/triggered/reactive_hardening/proc/son()
	if(ishuman(host_mob) && hardened)
		var/mob/living/carbon/human/H = host_mob
		hardened = FALSE
		if(timer_id)
			deltimer(timer_id)
		timer_id = null
		H.visible_message("<span class='warning'>The metal covering [H] is reabsorbed into [H.p_their()] skin.</span>", "<span class='notice'>You feel your skin return to normal.</span>")
		H.physiology.brute_mod /= 0.1
		H.physiology.burn_mod /= 0.1
		H.remove_trait(TRAIT_PIERCEIMMUNE, "reactive_hardening")
		H.remove_trait(TRAIT_NODISMEMBER, "reactive_hardening")
		use_rate = initial(use_rate)

/datum/nanite_program/triggered/reactive_hardening/set_extra_setting(user, setting)
	if(setting == "Hardening Duration")
		var/new_duration = input(user, "Choose the duration of the hardening effect in deciseconds.", name, harden_duration) as null|num
		if(isnull(new_duration))
			return
		new_duration = CLAMP(round(new_duration, 1), 20, 6000)

	if(setting == "Damage Threshold")
		var/new_threshold = input(user, "Choose the amount of damage that will trigger the program. Set to 0 to disable reactive triggering.", name, trigger_threshold) as null|num
		if(isnull(new_threshold))
			return
		new_threshold = CLAMP(round(new_threshold, 1), 0, 200)

/datum/nanite_program/triggered/reactive_hardening/get_extra_setting(setting)
	if(setting == "Hardening Duration")
		return harden_duration
	if(setting == "Damage Threshold")
		return trigger_threshold

/datum/nanite_program/triggered/reactive_hardening/copy_extra_settings_to(datum/nanite_program/triggered/reactive_hardening/target)
	target.harden_duration = harden_duration
	target.trigger_threshold = trigger_threshold

/datum/nanite_program/coagulating
	name = "Rapid Coagulation"
	desc = "The nanites induce rapid coagulation when the host is wounded, dramatically reducing bleeding rate."
	use_rate = 0.10
	rogue_types = list(/datum/nanite_program/suffocating)

/datum/nanite_program/coagulating/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 0.1

/datum/nanite_program/coagulating/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 10

/datum/nanite_program/conductive
	name = "Electric Conduction"
	desc = "The nanites act as a grounding rod for electric shocks, protecting the host. Shocks can still damage the nanites themselves."
	use_rate = 0.20
	program_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/conductive/enable_passive_effect()
	. = ..()
	host_mob.add_trait(TRAIT_SHOCKIMMUNE, "nanites")

/datum/nanite_program/conductive/disable_passive_effect()
	. = ..()
	host_mob.remove_trait(TRAIT_SHOCKIMMUNE, "nanites")

/datum/nanite_program/mindshield
	name = "Mental Barrier"
	desc = "The nanites form a protective membrane around the host's brain, shielding them from abnormal influences while they're active."
	use_rate = 0.40
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/mindshield/enable_passive_effect()
	. = ..()
	if(!host_mob.mind.has_antag_datum(/datum/antagonist/rev)) //won't work if on a rev, to avoid having implanted revs
		host_mob.add_trait(TRAIT_MINDSHIELD, "nanites")
		host_mob.sec_hud_set_implants()

/datum/nanite_program/mindshield/disable_passive_effect()
	. = ..()
	host_mob.remove_trait(TRAIT_MINDSHIELD, "nanites")
	host_mob.sec_hud_set_implants()