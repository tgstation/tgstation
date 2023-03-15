/obj/effect/proc_holder/spell/aoe_turf/mutagenic_pulse
	name = "Mutagenic Pulse"
	desc = "This spell gives everyone around you random, mostly negative mutations."
	invocation = "RAD'EA'TION"
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "transformslime"
	invocation_type = "shout"
	charge_max = 90 SECONDS
	range = 4
	cooldown_min = 20 SECONDS

/obj/effect/proc_holder/spell/aoe_turf/mutagenic_pulse/cast(list/targets, mob/user)
	var/list/mutated = list()
	for(var/turf/turfs in targets)
		for(var/mob/living/carbon/TG in turfs)
			mutated += TG

	for(var/mob/living/carbon/target in mutated)
		playsound(get_turf(target), 'sound/weapons/emitter2.ogg', 50,1)
		if(target == user || !target.dna)
			continue
		if(target.anti_magic_check())
			to_chat(target, "<span class='warning'>You feel your body changing but it quickly stops.</span>")
			continue
		target.randmuti()
		if(prob(90))
			target.easy_randmut(NEGATIVE+MINOR_NEGATIVE)
		else
			target.easy_randmut(POSITIVE)
		target.domutcheck()
		to_chat(target, "<span class='warning'>You feel yourself mutating!</span>")
