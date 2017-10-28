/obj/effect/proc_holder/spell/aoe_turf/conjure/bees
	name = "Conjure Bees"
	desc = "Summon a horde of killer bees with random toxins to sting your foes!"
	invocation = "WI'KA MAHN" //Geddit?
	invocation_type = "shout"
	charge_max = 300
	cooldown_min = 100
	action_icon = 'icons/mob/bees.dmi'
	action_icon_state = "queen_item"
	summon_type = list(/mob/living/simple_animal/hostile/poison/bees/toxin)
	summon_amt = 4
	range = 1

/obj/effect/proc_holder/spell/aoe_turf/conjure/cast(list/targets,mob/user = usr)
	summon_amt = (4 + spell_level * 2) //Two extra bees per spell level, max level spell is a lot of bees.
	..()

/obj/effect/proc_holder/spell/aoe_turf/conjure/bees/post_summon(mob/living/simple_animal/hostile/poison/bees/toxin/B, mob/user)
	var/list/factions = user.faction.Copy()
	for(var/F in factions)
		if(F == "neutral")
			factions -= F
	B.faction = factions