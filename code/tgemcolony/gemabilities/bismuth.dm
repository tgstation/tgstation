/datum/action/innate/gem/smelt
	name = "Smelt Ores"
	desc = "Ore redemption? You mean the Clod machine. Smelt ores in your active hand better than that old thing can ever do."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "healingtears"
	background_icon_state = "bg_spell"

/datum/action/innate/gem/smelt/Activate()
	if(istype(owner, /mob/living/carbon))
		var/mob/living/carbon/C = owner
		var/obj/item/O = C.get_active_held_item()
		if(O != null)
			if(istype(O,/obj/item/stack/ore)) //LET'S GET SMELTING!
				var/obj/item/stack/ore/smelt = O
				new smelt.refined_type(C.drop_location())
				if(C.gemstatus != "offcolor") //offcolors only get one refined.
					new smelt.refined_type(C.drop_location())
					new smelt.refined_type(C.drop_location())
					if(C.gemstatus == "prime") //primes get 6!
						new smelt.refined_type(C.drop_location())
						new smelt.refined_type(C.drop_location())
						new smelt.refined_type(C.drop_location())
				smelt.use(1)