
/datum/reagent/thermite
	name = "Thermite"
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	color = "#550000"
	taste_description = "sweet tasting metal"

/datum/reagent/thermite/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume >= 1)
		exposed_turf.AddComponent(/datum/component/thermite, reac_volume)

/datum/reagent/thermite/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustFireLoss(1 * REM * seconds_per_tick, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	description = "Nitroglycerin is a heavy, colorless, oily liquid obtained by nitrating glycerol. \
		It is commonly used to treat heart conditions, but also in the creation of explosives."
	color = COLOR_GRAY
	taste_description = "oil"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/nitroglycerin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, -1 * REM * seconds_per_tick * normalise_creation_purity(), required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/stabilizing_agent
	name = "Stabilizing Agent"
	description = "Keeps unstable chemicals stable. This does not work on everything."
	color = COLOR_YELLOW
	taste_description = "metal"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//It has stable IN THE NAME. IT WAS MADE FOR THIS MOMENT.
/datum/reagent/stabilizing_agent/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.myseed?.adjust_instability(-round(volume))

/datum/reagent/clf3
	name = "Chlorine Trifluoride"
	description = "Makes a temporary 3x3 fireball when it comes into existence, so be careful when mixing. ClF3 applied to a surface burns things that wouldn't otherwise burn, sometimes through the very floors of the station and exposing it to the vacuum of space."
	color = "#FFC8C8"
	metabolization_rate = 10 * REAGENTS_METABOLISM
	taste_description = "burning"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/clf3/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_fire_stacks(2 * REM * seconds_per_tick)
	if(affected_mob.adjustFireLoss(0.3 * max(affected_mob.fire_stacks, 1) * REM * seconds_per_tick, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/clf3/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(isplatingturf(exposed_turf))
		var/turf/open/floor/plating/target_plating = exposed_turf
		if(prob(10 + target_plating.burnt + 5*target_plating.broken)) //broken or burnt plating is more susceptible to being destroyed
			target_plating.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	if(isfloorturf(exposed_turf) && prob(reac_volume))
		var/turf/open/floor/target_floor = exposed_turf
		target_floor.make_plating()
	else if(prob(reac_volume))
		exposed_turf.burn_tile()
	if(isfloorturf(exposed_turf))
		for(var/turf/nearby_turf in RANGE_TURFS(1, exposed_turf))
			if(!locate(/obj/effect/hotspot) in nearby_turf)
				new /obj/effect/hotspot(nearby_turf)

/datum/reagent/clf3/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	exposed_mob.adjust_fire_stacks(min(reac_volume/5, 10))
	exposed_mob.ignite_mob()
	if(!locate(/obj/effect/hotspot) in exposed_mob.loc)
		new /obj/effect/hotspot(exposed_mob.loc)

/datum/reagent/sorium
	name = "Sorium"
	description = "Sends everything flying from the detonation point."
	color = "#5A64C8"
	taste_description = "air and bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/liquid_dark_matter
	name = "Liquid Dark Matter"
	description = "Sucks everything into the detonation point."
	color = "#210021"
	taste_description = "compressed bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/gunpowder
	name = "Gunpowder"
	description = "Explodes. Violently."
	color = COLOR_BLACK
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	taste_description = "salt"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/gunpowder/on_new(data)
	. = ..()
	if(holder?.my_atom)
		RegisterSignal(holder.my_atom, COMSIG_ATOM_EX_ACT, PROC_REF(on_ex_act))

/datum/reagent/gunpowder/Destroy()
	if(holder?.my_atom)
		UnregisterSignal(holder.my_atom, COMSIG_ATOM_EX_ACT)
	return ..()

/datum/reagent/gunpowder/proc/on_ex_act(atom/source, severity, target)
	SIGNAL_HANDLER
	if(source.flags_1 & PREVENT_CONTENTS_EXPLOSION_1)
		return
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(1 + round(volume/6, 1), location, 0, 0, message = 0)
	e.start(holder.my_atom)
	holder.clear_reagents()

/datum/reagent/rdx
	name = "RDX"
	description = "Military grade explosive"
	color = COLOR_WHITE
	taste_description = "salt"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/tatp
	name = "TaTP"
	description = "Suicide grade explosive"
	color = COLOR_WHITE
	taste_description = "death"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/flash_powder
	name = "Flash Powder"
	description = "Makes a very bright flash."
	color = "#C8C8C8"
	taste_description = "salt"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/smoke_powder
	name = "Smoke Powder"
	description = "Makes a large cloud of smoke that can carry reagents."
	color = "#C8C8C8"
	taste_description = "smoke"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/sonic_powder
	name = "Sonic Powder"
	description = "Makes a deafening noise."
	color = "#C8C8C8"
	taste_description = "loud noises"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/phlogiston
	name = "Phlogiston"
	description = "Catches you on fire and makes you ignite."
	color = "#FA00AF"
	taste_description = "burning"
	self_consuming = TRUE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/phlogiston/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	exposed_mob.adjust_fire_stacks(1)
	var/burndmg = max(0.3*exposed_mob.fire_stacks * (1 - touch_protection), 0.3)
	if(burndmg)
		exposed_mob.adjustFireLoss(burndmg, 0)
	exposed_mob.ignite_mob()

/datum/reagent/phlogiston/on_mob_life(mob/living/carbon/metabolizer, seconds_per_tick, times_fired)
	. = ..()
	metabolizer.adjust_fire_stacks(1 * REM * seconds_per_tick)
	if(metabolizer.adjustFireLoss(0.3 * max(metabolizer.fire_stacks, 0.15) * REM * seconds_per_tick, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/napalm
	name = "Napalm"
	description = "Very flammable."
	color = "#FA00AF"
	taste_description = "burning"
	self_consuming = TRUE
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// why, just why
/datum/reagent/napalm/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	if(!(mytray.myseed?.resistance_flags & FIRE_PROOF))
		mytray.adjust_plant_health(-round(volume * 6))
		mytray.adjust_toxic(round(volume * 7))

	mytray.adjust_weedlevel(-rand(5,9)) //At least give them a small reward if they bother.

/datum/reagent/napalm/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_fire_stacks(1 * REM * seconds_per_tick)

/datum/reagent/napalm/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(istype(exposed_mob) && (methods & (TOUCH|VAPOR|PATCH)))
		exposed_mob.adjust_fire_stacks(min(reac_volume/4, 20))

#define CRYO_SPEED_PREFACTOR 0.4
#define CRYO_SPEED_CONSTANT 0.1

/datum/reagent/cryostylane
	name = "Cryostylane"
	description = "Induces a cryostasis like state in a patient's organs, preventing them from decaying while dead. Slows down surgery while in a patient however. When reacted with oxygen, it will slowly consume it and reduce a container's temperature to 0K. Also damages slime simplemobs when 5u is sprayed."
	color = "#0000DC"
	ph = 8.6
	metabolization_rate = 0.05 * REAGENTS_METABOLISM
	taste_description = "icy bitterness"
	purity = REAGENT_STANDARD_PURITY
	self_consuming = TRUE
	inverse_chem_val = 0.5
	inverse_chem = /datum/reagent/inverse/cryostylane
	burning_volume = 0.05
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED | REAGENT_DEAD_PROCESS

/datum/reagent/cryostylane/burn(datum/reagents/holder)
	if(holder.has_reagent(/datum/reagent/oxygen))
		burning_temperature = 0//king chilly
		return
	burning_temperature = null

/datum/reagent/cryostylane/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	affected_mob.mob_surgery_speed_mod = 1-((CRYO_SPEED_PREFACTOR * (1 - creation_purity))+CRYO_SPEED_CONSTANT) //10% - 30% slower
	affected_mob.color = COLOR_CYAN

/datum/reagent/cryostylane/on_mob_delete(mob/living/affected_mob)
	. = ..()
	affected_mob.mob_surgery_speed_mod = 1
	affected_mob.color = COLOR_WHITE

//Pauses decay! Does do something, I promise.
/datum/reagent/cryostylane/on_mob_dead(mob/living/carbon/affected_mob, seconds_per_tick)
	. = ..()
	metabolization_rate = 0.05 * REM //slower consumption when dead

/datum/reagent/cryostylane/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	metabolization_rate = 0.25 * REM//faster consumption when alive
	if(affected_mob.reagents.has_reagent(/datum/reagent/oxygen))
		affected_mob.reagents.remove_reagent(/datum/reagent/oxygen, 0.5 * REM * seconds_per_tick)
		affected_mob.adjust_bodytemperature(-15 * REM * seconds_per_tick)
		if(ishuman(affected_mob))
			var/mob/living/carbon/human/humi = affected_mob
			humi.adjust_coretemperature(-15 * REM * seconds_per_tick)

/datum/reagent/cryostylane/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume < 5)
		return
	for(var/mob/living/basic/slime/exposed_slime in exposed_turf)
		exposed_slime.adjustToxLoss(rand(15,30))

#undef CRYO_SPEED_PREFACTOR
#undef CRYO_SPEED_CONSTANT

/datum/reagent/pyrosium
	name = "Pyrosium"
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Pyrosium slowly heats all other reagents in the container."
	color = "#64FAC8"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	self_consuming = TRUE
	burning_temperature = null
	burning_volume = 0.05
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/pyrosium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(holder.has_reagent(/datum/reagent/oxygen))
		holder.remove_reagent(/datum/reagent/oxygen, 0.5 * REM * seconds_per_tick)
		affected_mob.adjust_bodytemperature(15 * REM * seconds_per_tick)
		if(ishuman(affected_mob))
			var/mob/living/carbon/human/affected_human = affected_mob
			affected_human.adjust_coretemperature(15 * REM * seconds_per_tick)

/datum/reagent/pyrosium/burn(datum/reagents/holder)
	if(holder.has_reagent(/datum/reagent/oxygen))
		burning_temperature = 3500
		return
	burning_temperature = null

/datum/reagent/teslium //Teslium. Causes periodic shocks, and makes shocks against the target much more effective.
	name = "Teslium"
	description = "An unstable, electrically-charged metallic slurry. Periodically electrocutes its victim, and makes electrocutions against them more deadly. Excessively heating teslium results in dangerous destabilization. Do not allow it to come into contact with water."
	color = "#20324D" //RGB: 32, 50, 77
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "charged metal"
	self_consuming = TRUE
	var/shock_timer = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/teslium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	shock_timer++
	if(shock_timer >= rand(5, 30)) //Random shocks are wildly unpredictable
		shock_timer = 0
		affected_mob.electrocute_act(rand(5, 20), "Teslium in their body", 1, SHOCK_NOGLOVES) //SHOCK_NOGLOVES because it's caused from INSIDE of you
		playsound(affected_mob, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/datum/reagent/teslium/used_on_fish(obj/item/fish/fish)
	if(HAS_TRAIT_FROM(fish, TRAIT_FISH_ELECTROGENESIS, FISH_TRAIT_DATUM))
		return FALSE
	fish.add_traits(list(TRAIT_FISH_ON_TESLIUM, TRAIT_FISH_ELECTROGENESIS), type)
	addtimer(TRAIT_CALLBACK_REMOVE(fish, TRAIT_FISH_ON_TESLIUM, type), fish.feeding_frequency * 0.75, TIMER_UNIQUE|TIMER_OVERRIDE)
	addtimer(TRAIT_CALLBACK_REMOVE(fish, TRAIT_FISH_ELECTROGENESIS, type), fish.feeding_frequency * 0.75, TIMER_UNIQUE|TIMER_OVERRIDE)
	return TRUE

/datum/reagent/teslium/on_mob_metabolize(mob/living/carbon/human/affected_mob)
	. = ..()
	if(!istype(affected_mob))
		return
	affected_mob.physiology.siemens_coeff *= 2

/datum/reagent/teslium/on_mob_end_metabolize(mob/living/carbon/human/affected_mob)
	. = ..()
	if(!istype(affected_mob))
		return
	affected_mob.physiology.siemens_coeff *= 0.5

/datum/reagent/teslium/energized_jelly
	name = "Energized Jelly"
	description = "Electrically-charged jelly. Boosts jellypeople's nervous system, but only shocks other lifeforms."
	color = "#CAFF43"
	taste_description = "jelly"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/teslium/energized_jelly/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(!isjellyperson(affected_mob)) //everyone but jellypeople get shocked as normal.
		return ..()
	affected_mob.AdjustAllImmobility(-40  *REM * seconds_per_tick)
	if(affected_mob.adjustStaminaLoss(-10 * REM * seconds_per_tick, updating_stamina = FALSE))
		. = UPDATE_MOB_HEALTH
	if(is_species(affected_mob, /datum/species/jelly/luminescent))
		var/mob/living/carbon/human/affected_human = affected_mob
		var/datum/species/jelly/luminescent/slime_species = affected_human.dna.species
		slime_species.extract_cooldown = max(slime_species.extract_cooldown - (2 SECONDS * REM * seconds_per_tick), 0)

/datum/reagent/firefighting_foam
	name = "Firefighting Foam"
	description = "A historical fire suppressant. Originally believed to simply displace oxygen to starve fires, it actually interferes with the combustion reaction itself. Vastly superior to the cheap water-based extinguishers found on NT vessels."
	color = "#A6FAFF55"
	taste_description = "the inside of a fire extinguisher"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/firefighting_foam/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if (!istype(exposed_turf))
		return

	if(reac_volume >= 1)
		var/obj/effect/particle_effect/fluid/foam/firefighting/foam = (locate(/obj/effect/particle_effect/fluid/foam) in exposed_turf)
		if(!foam)
			foam = new(exposed_turf)
		else if(istype(foam))
			foam.lifetime = initial(foam.lifetime) //reduce object churn a little bit when using smoke by keeping existing foam alive a bit longer

	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in exposed_turf)
	if(hotspot && !isspaceturf(exposed_turf) && exposed_turf.air)
		var/datum/gas_mixture/air = exposed_turf.air
		if(air.temperature > T20C)
			air.temperature = max(air.temperature/2,T20C)
		air.react(src)
		qdel(hotspot)

/datum/reagent/firefighting_foam/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	exposed_obj.extinguish()

/datum/reagent/firefighting_foam/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(methods & (TOUCH|VAPOR))
		exposed_mob.extinguish_mob() //All stacks are removed
