//Programs specifically engineered to cause harm to either the user or its surroundings (as opposed to ones that only do it due to broken programming)
//Very dangerous!

/datum/nanite_program/aggressive_replication
	name = "Aggressive Replication"
	desc = "Nanites will consume organic matter to improve their replication rate, damaging the host."
	use_rate = -1 //bonus nanites
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/aggressive_replication/active_effect()
	host_mob.adjustBruteLoss(1, TRUE)

/datum/nanite_program/meltdown
	name = "Meltdown"
	desc = "Causes an internal meltdown inside the nanites, causing internal burns inside the host as well as rapidly destroying the nanite population.\
			Sets the nanites' safety threshold to 0 when activated."
	use_rate = 10
	rogue_types = list(/datum/nanite_program/glitch)

/datum/nanite_program/meltdown/active_effect()
	host_mob.adjustFireLoss(3.5)

/datum/nanite_program/meltdown/enable_passive_effect()
	..()
	to_chat(host_mob, "<span class='userdanger'>Your blood is burning!</span>")
	nanites.safety_threshold = 0

/datum/nanite_program/meltdown/disable_passive_effect()
	..()
	to_chat(host_mob, "<span class='warning'>Your blood cools down, and the pain gradually fades.</span>")

/datum/nanite_program/triggered/explosive
	name = "Chain Detonation"
	desc = "Detonates all the nanites inside the host in a chain reaction when triggered."
	trigger_cost = 25 //plus every idle nanite left afterwards
	trigger_cooldown = 100 //Just to avoid double-triggering
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/triggered/explosive/trigger()
	if(!..())
		return
	host_mob.visible_message("<span class='warning'>[host_mob] starts emitting a high-pitched buzzing, and [host_mob.p_their()] skin begins to glow...</span>",\
							"<span class='userdanger'>You start emitting a high-pitched buzzing, and your skin begins to glow...</span>")
	addtimer(CALLBACK(src, .proc/boom), CLAMP((nanites.nanite_volume * 0.35), 25, 150))

/datum/nanite_program/triggered/explosive/proc/boom()
	var/nanite_amount = nanites.nanite_volume
	var/dev_range = FLOOR(nanite_amount/200, 1) - 1
	var/heavy_range = FLOOR(nanite_amount/100, 1) - 1
	var/light_range = FLOOR(nanite_amount/50, 1) - 1
	explosion(host_mob, dev_range, heavy_range, light_range)
	qdel(nanites)

//TODO make it defuse if triggered again

/datum/nanite_program/triggered/heart_stop
	name = "Heart-Stopper"
	desc = "Stops the host's heart when triggered; restarts it if triggered again."
	trigger_cost = 12
	trigger_cooldown = 10
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/triggered/heart_stop/trigger()
	if(!..())
		return
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		var/obj/item/organ/heart/heart = C.getorganslot(ORGAN_SLOT_HEART)
		if(heart)
			if(heart.beating)
				heart.Stop()
			else
				heart.Restart()

/datum/nanite_program/triggered/emp
	name = "Electromagnetic Resonance"
	desc = "The nanites cause an elctromagnetic pulse around the host when triggered. Will corrupt other nanite programs!"
	trigger_cost = 10
	program_flags = NANITE_EMP_IMMUNE
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/triggered/emp/trigger()
	if(!..())
		return
	empulse(host_mob, 1, 2)

/datum/nanite_program/pyro/active_effect()
	host_mob.fire_stacks += 1
	host_mob.IgniteMob()

/datum/nanite_program/pyro
	name = "Sub-Dermal Combustion"
	desc = "The nanites cause buildup of flammable fluids under the host's skin, then ignites them."
	use_rate = 4
	rogue_types = list(/datum/nanite_program/skin_decay, /datum/nanite_program/cryo)

/datum/nanite_program/pyro/check_conditions()
	if(host_mob.fire_stacks >= 10 && host_mob.on_fire)
		return FALSE
	. = ..()

/datum/nanite_program/pyro/active_effect()
	host_mob.fire_stacks += 1
	host_mob.IgniteMob()

/datum/nanite_program/cryo
	name = "Cryogenic Treatment"
	desc = "The nanites rapidly skin heat through the host's skin, lowering their temperature."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/skin_decay, /datum/nanite_program/pyro)

/datum/nanite_program/cryo/check_conditions()
	if(host_mob.bodytemperature <= 70)
		return FALSE
	. = ..()

/datum/nanite_program/cryo/active_effect()
	host_mob.adjust_bodytemperature(-rand(15,25), 50)
	
/datum/nanite_program/mind_control
	name = "Mind Control"
	desc = "The nanites imprint an absolute directive onto the host's brain while they're active."
	use_rate = 5
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)
	
	extra_settings = list("Directive")
	var/directive = "..."

/datum/nanite_program/mind_control/set_extra_setting(user, setting)
	if(setting == "Directive")
		var/new_directive = stripped_input(user, "Choose the directive to imprint with mind control.", "Directive", directive, MAX_MESSAGE_LEN)
		if(!new_directive)
			return
		directive = new_directive
		
/datum/nanite_program/mind_control/get_extra_setting(setting)
	if(setting == "Directive")
		return directive
	
/datum/nanite_program/mind_control/enable_passive_effect()
	..()
	brainwash(host_mob, directive)
	log_game("A mind control nanite program brainwashed [key_name(target)] with the objective '[directive]'.")

/datum/nanite_program/mind_control/disable_passive_effect()
	..()
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/brainwashed))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	log_game("[key_name(target)] is no longer brainwashed by nanites.")