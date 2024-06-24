

/mob/living/carbon/alien/adult/nova/queen
	name = "alien queen"
	desc = "A hulking beast of an alien, for some reason this one seems more important than the others, you should probably quit staring at it and do something."
	caste = "queen"
	maxHealth = 500
	health = 500
	icon_state = "alienqueen"
	melee_damage_lower = 30
	melee_damage_upper = 35

/mob/living/carbon/alien/adult/nova/queen/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep/hard_throwing,
		/datum/action/cooldown/alien/nova/queen_screech,
	)
	grant_actions_by_list(innate_actions)

	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	add_movespeed_modifier(/datum/movespeed_modifier/alien_big)

/mob/living/carbon/alien/adult/nova/queen/create_internal_organs()
	organs += new /obj/item/organ/internal/alien/plasmavessel/large/queen
	organs += new /obj/item/organ/internal/alien/resinspinner
	organs += new /obj/item/organ/internal/alien/neurotoxin/queen
	organs += new /obj/item/organ/internal/alien/eggsac
	..()

/mob/living/carbon/alien/adult/nova/queen/alien_talk(message, shown_name = name)
	..(message, shown_name, TRUE)

/obj/item/organ/internal/alien/neurotoxin/queen
	name = "neurotoxin gland"
	icon_state = "neurotox"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_NEUROTOXINGLAND
	actions_types = list(
		/datum/action/cooldown/alien/acid/nova,
		/datum/action/cooldown/alien/acid/nova/lethal,
		/datum/action/cooldown/alien/acid/corrosion,
	)

/mob/living/carbon/alien/adult/nova/queen/death(gibbed)
	if(stat == DEAD)
		return

	for(var/mob/living/carbon/carbon_mob in GLOB.alive_mob_list)
		if(carbon_mob == src)
			continue

		var/obj/item/organ/internal/alien/hivenode/node = carbon_mob.get_organ_by_type(/obj/item/organ/internal/alien/hivenode)

		if(istype(node))
			node.queen_death()

	return ..()

/datum/action/cooldown/alien/nova/queen_screech
	name = "Deafening Screech"
	desc = "Let out a screech so deafeningly loud that anything with the ability to hear around you will likely be incapacitated for a short time."
	button_icon_state = "screech"
	cooldown_time = 5 MINUTES

/datum/action/cooldown/alien/nova/queen_screech/Activate()
	. = ..()
	var/mob/living/carbon/alien/adult/nova/queenie = owner
	playsound(queenie, 'monkestation/code/modules/blueshift/sounds/alien_queen_screech.ogg', 100, FALSE, 8, 0.9)
	queenie.create_shriekwave()
	shake_camera(owner, 2, 2)

	for(var/mob/living/carbon/human/screech_target in get_hearers_in_view(7, get_turf(queenie)))
		screech_target.soundbang_act(intensity = 5, stun_pwr = 50, damage_pwr = 10, deafen_pwr = 30) //Only being deaf will save you from the screech
		shake_camera(screech_target, 4, 3)
		to_chat(screech_target, span_doyourjobidiot("[queenie] lets out a deafening screech!"))

	return TRUE

/mob/living/carbon/alien/adult/nova/proc/create_shriekwave()
	remove_overlay(HALO_LAYER)
	overlays_standing[HALO_LAYER] = image("icon" = 'monkestation/code/modules/blueshift/icons/big_xenos.dmi', "icon_state" = "shriek_waves") //Ehh, suit layer's not being used.
	apply_overlay(HALO_LAYER)
	addtimer(CALLBACK(src, PROC_REF(remove_shriekwave)), 3 SECONDS)

/mob/living/carbon/alien/adult/nova/proc/remove_shriekwave()
	remove_overlay(HALO_LAYER)
