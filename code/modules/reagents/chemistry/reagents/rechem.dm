
GLOBAL_LIST_EMPTY(bluestreams)

/datum/reagent/quaprotium
	name = "Quanprotium"
	description = "A complex and rare chemical mix that has unique bluespace properties"
	taste_description = "your tongue licking something through other dimensions" //Some memes *_*
	color = "#2b78ed" //RGB: 43, 120, 237
	can_synth = FALSE //Would be too OP
	pH = 11

	metabolization_rate = REAGENTS_METABOLISM * 1.5

/datum/reagent/quaprotium/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume > 5 && !locate(/obj/effect/bluespace_stream) in exposed_turf)
		new /obj/effect/bluespace_stream(exposed_turf)

/datum/reagent/quaprotium/on_mob_life(mob/living/carbon/M) //Affects living beings in a same way as bluespace crystals
	if(current_cycle > 10 && prob(15))
		to_chat(M, "<span class='warning'>You feel unstable...</span>")
		M.Jitter(2)
		current_cycle = 1
		addtimer(CALLBACK(M, /mob/living/proc/bluespace_shuffle), 30)
	. = ..()

/obj/effect/bluespace_stream
	name = "bluespace stream"
	desc = "A strange, previously hidden portal through bluespace. It might be a bad idea."
	icon = 'icons/effects/effects.dmi'
	icon_state = "bluestream"
	layer = ABOVE_MOB_LAYER

/obj/effect/bluespace_stream/Initialize()
	. = ..()
	GLOB.bluestreams.Add(src)
	new /obj/effect/temp_visual/bluespace_fissure(get_turf(src))

/obj/effect/bluespace_stream/attack_hand(mob/user)
	var/obj/effect/bluespace_stream/linked = pick(GLOB.bluestreams - src)
	if(!linked)
		return
	var/slip_in_message = pick("slides into [src] sideways", "touches [src] and suddenly gets sucked in", "walks into [src]", "unzips [src] and jumps into it")
	var/slip_out_message = pick("leaps out of [src]", "falls to the ground from [src] along with some bluespace junk", "walks out of [src]", "slides out of [src]")
	to_chat(user, "<span class='notice'>You try to align with the bluespace stream...</span>")
	if(do_after(user, 20, target = src))
		new /obj/effect/temp_visual/bluespace_fissure(get_turf(src))
		new /obj/effect/temp_visual/bluespace_fissure(get_turf(linked))
		user.forceMove(get_turf(linked))
		user.visible_message("<span class='warning'>[user] [slip_in_message].</span>", null, null, null, user)
		user.visible_message("<span class='warning'>[user] [slip_out_message].</span>", "<span class='notice'>...and find your way to the other side.</span>")

/datum/reagent/zeolites
	name = "Synthetic Zeolites"
	description = "A liquid chemical with crystalline structure that can absorb radiation and convert it into healing."
	taste_description = "sand"
	color = "#4bc986" //RGB: 75, 201, 134
	pH = 3.6

	metabolization_rate = REAGENTS_METABOLISM * 3 //Fast boi

/datum/reagent/zeolites/expose_obj(obj/exposed_obj, reac_volume)
	var/datum/component/radioactive/contamination = exposed_obj.GetComponent(/datum/component/radioactive)
	if(contamination && reac_volume >= 15)
		qdel(contamination)
		return
	else if(contamination)
		contamination.strength -= min(contamination.strength, round(reac_volume * pH * 8, 0.1)) //You actually can make it more efficient by using basic buffer on it

/datum/reagent/zeolites/on_mob_life(mob/living/carbon/M)
	. = ..()
	var/datum/component/radioactive/contamination = M.GetComponent(/datum/component/radioactive)
	if(M.radiation > 0) //Purges around
		var/rad_to_remove = clamp(round((M.radiation / 150) * (15 * pH), 0.1), 0, M.radiation)
		M.radiation -= rad_to_remove
		var/power = 0.0075 * rad_to_remove
		M.adjustOxyLoss(-3 * power, 0)
		M.adjustBruteLoss(-power, 0)
		M.adjustFireLoss(-power, 0)
		M.adjustToxLoss(-power, 0, TRUE) //heals TOXINLOVERs
		M.adjustCloneLoss(-power, 0)
		for(var/i in M.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(power)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)

	if(contamination && contamination.strength > 0)
		contamination.strength -= min(contamination.strength, round(25 * pH, 0.1))

/datum/reagent/nanite_b_gone
	name = "Nanite bane"
	description = "A stablised EMP that is highly volatile, shocking small nano machines that will kill them off at a rapid rate in a patient's system."
	color = "#708f8f" //RBG: 112, 143, 143
	overdose_threshold = 15
	taste_description = "what can only be described as licking a battery."
	pH = 9
	can_synth = FALSE
	metabolization_rate = REAGENTS_METABOLISM * 0.5

/datum/reagent/nanite_b_gone/on_mob_life(mob/living/carbon/C)
	var/datum/component/nanites/N = C.GetComponent(/datum/component/nanites)
	if(isnull(N))
		return ..()
	N.adjust_nanites(-volume) //0.5 seems to be the default to me, so it'll neuter them.
	..()

/datum/reagent/nanite_b_gone/overdose_process(mob/living/carbon/C)
	var/datum/component/nanites/N = C.GetComponent(/datum/component/nanites)
	if(prob(5))
		to_chat(C, "<span class='warning'>The residual voltage from the nanites causes you to seize up!</b></span>")
		C.electrocute_act(10, (get_turf(C)), 1, SHOCK_ILLUSION)
	if(prob(10))
		C.emp_act(80)
		to_chat(C, "<span class='warning'>You feel a strange tingling sensation come from your core.</b></span>")
	if(isnull(N))
		return ..()
	N.adjust_nanites(-10*cached_purity)
	..()

/datum/reagent/toxin/noxagenium //Nothing really special, just nobreath chemical. Just a better salbutamol basically
	name = "Noxagenium"
	description = "A complicated mixture, containing oxygen and nitryl mix that negates need to breath for a short period of time."
	color = "#976fd9" //RBG: 151, 111, 217
	taste_description = "very bitter mix that stings your tongue."
	pH = 13 //Basic! You will need a special beaker for that
	can_synth = FALSE
	metabolization_rate = REAGENTS_METABOLISM * 0.25
	toxpwr = 0.1 //A tiiiny bit of toxloss cuz it contains nitryl.

/datum/reagent/toxin/noxagenium/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_NOBREATH, type)

/datum/reagent/toxin/noxagenium/on_mob_end_metabolize(mob/living/L)
	. = ..()
	REMOVE_TRAIT(L, TRAIT_NOBREATH, type)

/datum/reagent/toxin/noxagenium/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-4 * REM, 0)
	if(M.losebreath >= 2)
		M.losebreath -= 2
	..()
	. = 1
