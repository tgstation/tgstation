/datum/symptom/invisible
	name = "Waiting Syndrome"
	desc = "A self-defeating symptom that doesn't seem to do anything in particular."
	stage = 1
	badness = EFFECT_DANGER_HELPFUL

/datum/symptom/invisible/activate(mob/living/mob)
	return

/datum/symptom/sneeze
	name = "Coldingtons Effect"
	desc = "Makes the infected sneeze every so often, leaving some infected mucus on the floor."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING

/datum/symptom/sneeze/activate(mob/living/mob)
	mob.emote("sneeze")
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/host = mob
	if (prob(50) && isturf(mob.loc))
		if(istype(host.wear_mask, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/ciggie = host.get_item_by_slot(ITEM_SLOT_MASK)
			if(prob(20))
				var/turf/startLocation = get_turf(mob)
				var/turf/endLocation
				var/spitForce = pick(0,1,2,3)
				endLocation = get_ranged_target_turf(startLocation, mob.dir, spitForce)
				to_chat(mob, "<span class ='warning'>You sneezed \the [host.wear_mask] out of your mouth!</span>")
				host.dropItemToGround(ciggie)
				ciggie.throw_at(endLocation,spitForce,1)

/datum/symptom/gunck
	name = "Flemmingtons"
	desc = "Causes a sensation of mucous running down the infected's throat."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/gunck/activate(mob/living/mob)
	to_chat(mob, "<span class = 'notice'> Mucus runs down the back of your throat.</span>")

/datum/symptom/drool
	name = "Saliva Effect"
	desc = "Causes the infected to drool."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/drool/activate(mob/living/mob)
	mob.emote("drool")


/datum/symptom/twitch
	name = "Twitcher"
	desc = "Causes the infected to twitch."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/twitch/activate(mob/living/mob)
	mob.emote("twitch")

/datum/symptom/headache
	name = "Headache"
	desc = "Gives the infected a light headache."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/headache/activate(mob/living/mob)
	to_chat(mob, "<span class = 'notice'>Your head hurts a bit.</span>")

/datum/symptom/drained
	name = "Drained Feeling"
	desc = "Gives the infected a drained sensation."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/drained/activate(mob/living/mob)
	to_chat(mob, span_warning("You feel drained."))


/datum/symptom/eyewater
	name = "Watery Eyes"
	desc = "Causes the infected's tear ducts to overact."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/eyewater/activate(mob/living/mob)
	to_chat(mob, span_warning("Your eyes sting and water!"))
	mob.emote("cry")


/datum/symptom/wheeze
	name = "Wheezing"
	desc = "Inhibits the infected's ability to breathe slightly, causing them to wheeze."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/wheeze/activate(mob/living/mob)
	mob.emote("me",1,"wheezes.")

/datum/symptom/bee_vomit
	name = "Melisso-Emeto Syndrome"
	desc = "Converts the lungs of the infected into a bee-hive."
	encyclopedia = "Giving the infected a steady drip of honey in exchange of coughing up a bee every so often. The higher the symptom strength, the more honey is generated, and the more bees will be coughed up and more often as well. While Honey is a great healing reagent, it is also high on nutrients. Expect to become fat quickly.."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	max_multiplier = 4

/datum/symptom/bee_vomit/activate(mob/living/mob)
	if(!ismouse(mob))
		if ((mob.reagents.get_reagent_amount(/datum/reagent/consumable/sugar) < 5 + multiplier * 0.5) && prob(multiplier * 8)) //honey quickly decays into sugar
			mob.reagents.add_reagent(/datum/reagent/consumable/honey, multiplier)
			if(prob(25))
				to_chat(mob, span_notice("You taste someting sweet"))

	if(prob(20 + 20 * multiplier))
		to_chat(mob, span_warning("You feel a buzzing in your throat"))

		spawn(5 SECONDS)
			var/turf/open/T = get_turf(mob)
			if(prob(40 + 10 * multiplier))
				mob.visible_message(span_warning("[mob] coughs out a bee!"),span_danger("You cough up a bee!"))
				var/bee_type = pick(
					100;/mob/living/basic/bee/friendly,
					10;/mob/living/basic/bee,
					5;/mob/living/basic/bee/toxin,
					)
				var/mob/living/basic/bee/bee = new bee_type(T)
				if(multiplier < 4)
					addtimer(CALLBACK(src, PROC_REF(kill_bee), bee), 20 SECONDS * multiplier)

/datum/symptom/bee_vomit/proc/kill_bee(mob/living/basic/bee/bee)
	bee.visible_message(span_warning("The bee falls apart!"), span_warning("You fall apart"))
	bee.death()
	sleep(0.1 SECONDS)
	qdel(bee)

/datum/symptom/soreness
	name = "Myalgia Syndrome"
	desc = "Makes the infected more perceptive of their aches and pains."
	stage = 1
	chance = 5
	max_chance = 30
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/soreness/activate(mob/living/mob)
	to_chat(mob, span_notice("You feel a little sore."))
	if(iscarbon(mob))
		var/mob/living/carbon/host = mob
		host.stamina.adjust(-10)

/datum/symptom/wendigo_warning
	name = "Fullness Syndrome"
	desc = "An unsual symptom that causes the infected to feel hungry, even after eating."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	var/list/host_messages = list(
		"Your stomach grumbles.",
		"You feel peckish.",
		"So hungry...",
		"Your stomach feels empty.",
		"Hunger...",
		"Who are we...?",
		"Our mind hurts...",
		"You feel... different...",
		"There's something wrong."
	)

/datum/symptom/wendigo_warning/activate(mob/living/mob)
	to_chat(mob, span_warning("[pick(host_messages)]"))
	mob.adjust_nutrition(-25)


/datum/symptom/cult_hallucination
	name = "Visions of the End-Times"
	desc = "UNKNOWN"
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	max_multiplier = 2.5
	var/list/rune_words_rune = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")

/datum/symptom/cult_hallucination/activate(mob/living/mob)
	if(IS_CULTIST(mob))
		return
	if(istype(get_area(mob), /area/station/service/chapel))
		return
	var/client/C = mob.client
	if(!C)
		return
	mob.whisper("...[pick(rune_words_rune)]...")

	var/list/turf_list = list()
	for(var/turf/T in spiral_block(get_turf(mob), 40))
		if(locate(/obj/structure/grille) in T.contents)
			continue
		if(istype(get_area(T), /area/station/service/chapel))
			continue
		if(prob(2*multiplier))
			turf_list += T
	if(turf_list.len)
		for(var/turf/open/T in turf_list)
			var/delay = rand(0, 50) // so the runes don't all appear at once
			spawn(delay)

				var/runenum = rand(1,2)
				var/image/rune_holder = image('monkestation/code/modules/virology/icons/deityrunes.dmi',T,"")
				var/image/rune_render = image('monkestation/code/modules/virology/icons/deityrunes.dmi',T,"fullrune-[runenum]")
				rune_render.color = LIGHT_COLOR_BLOOD_MAGIC

				C.images += rune_holder

		//		anim(target = T, a_icon = 'monkestation/code/modules/virology/icons/deityrunes.dmi', flick_anim = "fullrune-[runenum]-write", col = DEFAULT_BLOOD, sleeptime = 36)

				spawn(30)

					rune_render.icon_state = "fullrune-[runenum]"
					rune_holder.overlays += rune_render
					AnimateFakeRune(rune_holder)

				var/duration = rand(20 SECONDS, 40 SECONDS)
				spawn(duration)
					if(C)
						rune_holder.overlays -= rune_render
		//				anim(target = T, a_icon = 'icons/effects/deityrunes.dmi', flick_anim = "fullrune-[runenum]-erase", col = DEFAULT_BLOOD)
						spawn(12)
							C.images -= rune_holder


/datum/symptom/cult_hallucination/proc/AnimateFakeRune(var/image/rune)
	animate(rune, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)//1
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)//2
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)//3
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)//4
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)//5
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)//9
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)//5
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)//4
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)//3
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)//2

/proc/spiral_block(turf/epicenter, range, draw_red=FALSE)
	if(!epicenter)
		return list()

	if(!range)
		return list(epicenter)

	. = list()

	var/turf/T
	var/y
	var/x
	var/c_dist = 1
	. += epicenter

	while( c_dist <= range )
		y = epicenter.y + c_dist
		x = epicenter.x - c_dist + 1
		//bottom
		for(x in x to epicenter.x+c_dist)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)

		y = epicenter.y + c_dist - 1
		x = epicenter.x + c_dist
		for(y in y to epicenter.y-c_dist step -1)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)

		y = epicenter.y - c_dist
		x = epicenter.x + c_dist - 1
		for(x in  x to epicenter.x-c_dist step -1)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)

		y = epicenter.y - c_dist + 1
		x = epicenter.x - c_dist
		for(y in y to epicenter.y+c_dist)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)
		c_dist++

	if(draw_red)
		sleep(30)
		for(var/turf/Q in .)
			Q.color = null

/datum/symptom/itching
	name = "Itching"
	desc = "Makes you Itch!"
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	var/scratch = FALSE
	///emote cooldowns
	COOLDOWN_DECLARE(itching_cooldown)
	///if FALSE, there is a percentage chance that the mob will emote scratching while itching_cooldown is on cooldown. If TRUE, won't emote again until after the off cooldown scratch occurs.
	var/off_cooldown_scratched = FALSE

/datum/symptom/itching/activate(mob/living/mob)
	if(!iscarbon(mob))
		return
	var/mob/living/carbon/affected_mob = mob
	var/obj/item/bodypart/bodypart = affected_mob.get_bodypart(affected_mob.get_random_valid_zone(even_weights = TRUE))
	if(bodypart && IS_ORGANIC_LIMB(bodypart) && !(bodypart.bodypart_flags & BODYPART_PSEUDOPART))  //robotic limbs will mean less scratching overall (why are golems able to damage themselves with self-scratching, but not androids? the world may never know)
		var/can_scratch = scratch && !affected_mob.incapacitated()
		if(can_scratch)
			bodypart.receive_damage(0.5)
		//below handles emotes, limiting the emote of emotes passed to chat
		if(COOLDOWN_FINISHED(src, itching_cooldown) || !COOLDOWN_FINISHED(src, itching_cooldown) && prob(60) && !off_cooldown_scratched)
			affected_mob.visible_message("[can_scratch ? span_warning("[affected_mob] scratches [affected_mob.p_their()] [bodypart.plaintext_zone].") : ""]", span_warning("Your [bodypart.plaintext_zone] itches. [can_scratch ? " You scratch it." : ""]"))
			COOLDOWN_START(src, itching_cooldown, 5 SECONDS)
			if(!off_cooldown_scratched && !COOLDOWN_FINISHED(src, itching_cooldown))
				off_cooldown_scratched = TRUE
			else
				off_cooldown_scratched = FALSE

/datum/symptom/water_heal
	name = "Tissue Hydration"
	desc = "The virus uses excess water inside and outside the body to repair damaged tissue cells. More effective when using holy water and against burns."

	stage = 1
	max_multiplier = 5
	max_chance = 45

	var/passive_message = span_notice("Your skin feels oddly dry...")
	var/absorption_coeff = 1


/datum/symptom/water_heal/activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	. = ..()
	var/effectiveness = CanHeal(mob)
	if(!effectiveness)
		return
	if(passive_message_condition(mob))
		to_chat(mob, passive_message)
	Heal(mob, effectiveness)

/datum/symptom/water_heal/proc/CanHeal(mob/living/M)
	var/base = 0
	if(M.fire_stacks < 0)
		M.adjust_fire_stacks(min(absorption_coeff, -M.fire_stacks))
		base += multiplier
	if(M.reagents?.has_reagent(/datum/reagent/water/holywater, needs_metabolizing = FALSE))
		M.reagents.remove_reagent(/datum/reagent/water/holywater, 0.5 * absorption_coeff)
		base += multiplier * 0.75
	else if(M.reagents?.has_reagent(/datum/reagent/water, needs_metabolizing = FALSE))
		M.reagents.remove_reagent(/datum/reagent/water, 0.5 * absorption_coeff)
		base += multiplier * 0.5
	return base

/datum/symptom/water_heal/proc/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/symptom/water_heal/proc/Heal(mob/living/carbon/M, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1, BODYTYPE_ORGANIC) //more effective on burns

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, span_notice("You feel yourself absorbing the water around you to soothe your damaged skin."))

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len * 0.5, heal_amt/parts.len, BODYTYPE_ORGANIC))
			M.update_damage_overlays()

	return 1


/// Determines the rate at which Plasma Fixation heals based on the amount of plasma in the air
#define HEALING_PER_MOL 1.1
/// Determines the rate at which Plasma Fixation heals based on the amount of plasma being breathed through internals
#define HEALING_PER_BREATH_PRESSURE 0.05
/// Determines the highest amount you can be healed for when breathing plasma from internals
#define MAX_HEAL_COEFFICIENT_INTERNALS 0.75
/// Determines the highest amount you can be healed for from pulling plasma from the environment
#define MAX_HEAL_COEFFICIENT_ENVIRONMENT 0.5
/// Determines the highest amount you can be healed for when there is plasma in the bloodstream
#define MAX_HEAL_COEFFICIENT_BLOODSTREAM 0.75
/// This is the base heal amount before being multiplied by the healing coefficients
#define BASE_HEAL_PLASMA_FIXATION 4

/datum/symptom/plasma_heal
	name = "Plasma Fixation"
	desc = "The virus draws plasma from the atmosphere and from inside the body to heal and stabilize body temperature."

	stage = 1
	max_multiplier = 5
	max_chance = 45

	var/passive_message = span_notice("You feel an odd attraction to plasma.")
	var/temp_rate = 1

/datum/symptom/plasma_heal/first_activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	. = ..()
	ADD_TRAIT(mob, TRAIT_PLASMA_LOVER_METABOLISM, type)
	to_chat(mob, span_notice("You suddenly love plasma."))

/datum/symptom/plasma_heal/side_effect(mob/living/mob)
	. = ..()
	REMOVE_TRAIT(mob, TRAIT_PLASMA_LOVER_METABOLISM, type)

/datum/symptom/plasma_heal/activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	. = ..()
	var/effectiveness = CanHeal(mob)
	if(!effectiveness)
		return
	if(passive_message_condition(mob))
		to_chat(mob, passive_message)
	Heal(mob, effectiveness)

/datum/symptom/plasma_heal/proc/CanHeal(mob/living/diseased_mob)
	var/datum/gas_mixture/environment
	var/list/gases

	var/base = 0

	// Check internals
	///  the amount of mols in a breath is significantly lower than in the environment so we are just going to use the tank's
	///  distribution pressure as an abstraction rather than calculate it using the ideal gas equation.
	///  balanced around a tank set to 4kpa = about 0.2 healing power. maxes out at 0.75 healing power, or 15kpa.
	if(iscarbon(diseased_mob))
		var/mob/living/carbon/breather = diseased_mob
		var/obj/item/tank/internals/internals_tank = breather.internal
		if(internals_tank)
			var/datum/gas_mixture/tank_contents = internals_tank.return_air()
			if(tank_contents && round(tank_contents.return_pressure())) // make sure the tank is not empty or 0 pressure
				if(tank_contents.gases[/datum/gas/plasma])
					// higher tank distribution pressure leads to more healing, but once you get to about 15kpa you reach the max
					base += power * min(MAX_HEAL_COEFFICIENT_INTERNALS, internals_tank.distribute_pressure * HEALING_PER_BREATH_PRESSURE)
	// Check environment
	if(diseased_mob.loc)
		environment = diseased_mob.loc.return_air()
	if(environment)
		gases = environment.gases
		if(gases[/datum/gas/plasma])
			base += power * min(MAX_HEAL_COEFFICIENT_INTERNALS, gases[/datum/gas/plasma][MOLES] * HEALING_PER_MOL)
	// Check for reagents in bloodstream
	if(diseased_mob.reagents?.has_reagent(/datum/reagent/toxin/plasma, needs_metabolizing = TRUE))
		base += power * MAX_HEAL_COEFFICIENT_BLOODSTREAM //Determines how much the symptom heals if injected or ingested
	return base

/datum/symptom/plasma_heal/proc/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/symptom/plasma_heal/proc/Heal(mob/living/carbon/M, actual_power)
	var/heal_amt = BASE_HEAL_PLASMA_FIXATION * actual_power

	if(prob(5))
		to_chat(M, span_notice("You feel yourself absorbing plasma inside and around you..."))

	var/target_temp = M.get_body_temp_normal()
	if(M.bodytemperature > target_temp)
		M.adjust_bodytemperature(-20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT, target_temp)
		if(prob(5))
			to_chat(M, span_notice("You feel less hot."))
	else if(M.bodytemperature < (M.get_body_temp_normal() + 1))
		M.adjust_bodytemperature(20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT, 0, target_temp)
		if(prob(5))
			to_chat(M, span_notice("You feel warmer."))

	M.adjustToxLoss(-heal_amt)

	var/list/parts = M.get_damaged_bodyparts(1,1, BODYTYPE_ORGANIC)
	if(!parts.len)
		return
	if(prob(5))
		to_chat(M, span_notice("The pain from your wounds fades rapidly."))
	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, BODYTYPE_ORGANIC))
			M.update_damage_overlays()
	return 1

///Plasma End
#undef HEALING_PER_MOL
#undef HEALING_PER_BREATH_PRESSURE
#undef MAX_HEAL_COEFFICIENT_INTERNALS
#undef MAX_HEAL_COEFFICIENT_ENVIRONMENT
#undef MAX_HEAL_COEFFICIENT_BLOODSTREAM
#undef BASE_HEAL_PLASMA_FIXATION
