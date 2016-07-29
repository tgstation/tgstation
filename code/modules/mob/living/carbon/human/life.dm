//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

<<<<<<< HEAD
//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!


#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 3 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 10 //Amount of damage applied when your body temperature passes the 460K point and you are on fire

#define COLD_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 3 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 3 //Amount of damage applied when the current breath's temperature passes the 120K point

#define BRAIN_DAMAGE_FILE "brain_damage_lines.json"

/mob/living/carbon/human/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return

	if(..())
		for(var/datum/mutation/human/HM in dna.mutations)
			HM.on_life(src)

		//heart attack stuff
		handle_heart()

		//Stuff jammed in your limbs hurts
		handle_embedded_objects()
	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	dna.species.spec_life(src) // for mutantraces


/mob/living/carbon/human/calculate_affecting_pressure(pressure)
	if((wear_suit && (wear_suit.flags & STOPSPRESSUREDMAGE)) && (head && (head.flags & STOPSPRESSUREDMAGE)))
		return ONE_ATMOSPHERE
	else
		return pressure


/mob/living/carbon/human/handle_disabilities()
	if(eye_blind)			//blindness, heals slowly over time
		if(tinttotal >= TINT_BLIND) //covering your eyes heals blurry eyes faster
			adjust_blindness(-3)
		else
			adjust_blindness(-1)
	else if(eye_blurry)			//blurry eyes heal slowly
		adjust_blurriness(-1)

	//Ears
	if(disabilities & DEAF)		//disabled-deaf, doesn't get better on its own
		setEarDamage(-1, max(ear_deaf, 1))
	else
		if(istype(ears, /obj/item/clothing/ears/earmuffs)) // earmuffs rest your ears, healing ear_deaf faster and ear_damage, but keeping you deaf.
			setEarDamage(max(ear_damage-0.10, 0), max(ear_deaf - 1, 1))
		// deafness heals slowly over time, unless ear_damage is over 100
		if(ear_damage < 100)
			adjustEarDamage(-0.05,-1)

	if (getBrainLoss() >= 60 && stat != DEAD)
		if (prob(3))
			if(prob(25))
				emote("drool")
			else
				say(pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage"))


/mob/living/carbon/human/handle_mutations_and_radiation()
	if(!dna || !dna.species.handle_mutations_and_radiation(src))
		..()

/mob/living/carbon/human/breathe()
	if(!dna.species.breathe(src))
		..()

/mob/living/carbon/human/check_breath(datum/gas_mixture/breath)
	dna.species.check_breath(breath, src)

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	dna.species.handle_environment(environment, src)

///FIRE CODE
/mob/living/carbon/human/handle_fire()
	if(!dna || !dna.species.handle_fire(src))
		..()
	if(on_fire)
		var/thermal_protection = get_thermal_protection()

		if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
			return
		if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT)
			bodytemperature += 11
		else
			bodytemperature += (BODYTEMP_HEATING_MAX + (fire_stacks * 12))

/mob/living/carbon/human/proc/get_thermal_protection()
	var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			thermal_protection += (wear_suit.max_heat_protection_temperature*0.7)
	if(head)
		if(head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT)
			thermal_protection += (head.max_heat_protection_temperature*THERMAL_PROTECTION_HEAD)
	thermal_protection = round(thermal_protection)
	return thermal_protection

/mob/living/carbon/human/IgniteMob()
	//If have no DNA or can be Ignited, call parent handling to light user
	//If firestacks are high enough
	if(!dna || dna.species.CanIgniteMob(src))
		return ..()
	. = FALSE //No ignition

/mob/living/carbon/human/ExtinguishMob()
	if(!dna || !dna.species.ExtinguishMob(src))
		..()
//END FIRE CODE


//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, CHEST, GROIN, etc. See setup.dm for the full list)
/mob/living/carbon/human/proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = 0
	//Handle normal clothing
	if(head)
		if(head.max_heat_protection_temperature && head.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= head.heat_protection
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature && wear_suit.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_suit.heat_protection
	if(w_uniform)
		if(w_uniform.max_heat_protection_temperature && w_uniform.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= w_uniform.heat_protection
	if(shoes)
		if(shoes.max_heat_protection_temperature && shoes.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= shoes.heat_protection
	if(gloves)
		if(gloves.max_heat_protection_temperature && gloves.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= gloves.heat_protection
	if(wear_mask)
		if(wear_mask.max_heat_protection_temperature && wear_mask.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_mask.heat_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = get_heat_protection_flags(temperature)

	var/thermal_protection = 0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & CHEST)
			thermal_protection += THERMAL_PROTECTION_CHEST
		if(thermal_protection_flags & GROIN)
			thermal_protection += THERMAL_PROTECTION_GROIN
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT


	return min(1,thermal_protection)

//See proc/get_heat_protection_flags(temperature) for the description of this proc.
/mob/living/carbon/human/proc/get_cold_protection_flags(temperature)
	var/thermal_protection_flags = 0
	//Handle normal clothing

	if(head)
		if(head.min_cold_protection_temperature && head.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= head.cold_protection
	if(wear_suit)
		if(wear_suit.min_cold_protection_temperature && wear_suit.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_suit.cold_protection
	if(w_uniform)
		if(w_uniform.min_cold_protection_temperature && w_uniform.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= w_uniform.cold_protection
	if(shoes)
		if(shoes.min_cold_protection_temperature && shoes.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= shoes.cold_protection
	if(gloves)
		if(gloves.min_cold_protection_temperature && gloves.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= gloves.cold_protection
	if(wear_mask)
		if(wear_mask.min_cold_protection_temperature && wear_mask.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_mask.cold_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_cold_protection(temperature)

	if(dna.check_mutation(COLDRES))
		return 1 //Fully protected from the cold.

	if(dna && (RESISTTEMP in dna.species.specflags))
		return 1

	temperature = max(temperature, 2.7) //There is an occasional bug where the temperature is miscalculated in ares with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	var/thermal_protection_flags = get_cold_protection_flags(temperature)

	var/thermal_protection = 0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & CHEST)
			thermal_protection += THERMAL_PROTECTION_CHEST
		if(thermal_protection_flags & GROIN)
			thermal_protection += THERMAL_PROTECTION_GROIN
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT

	return min(1,thermal_protection)


/mob/living/carbon/human/handle_chemicals_in_body()
	if(reagents)
		reagents.metabolize(src, can_overdose=1)
	dna.species.handle_chemicals_in_body(src)


/mob/living/carbon/human/handle_random_events()
	//Puke if toxloss is too high
	if(!stat)
		if(getToxLoss() >= 45 && nutrition > 20)
			lastpuke ++
			if(lastpuke >= 25) // about 25 second delay I guess
				vomit(20, 0, 1, 0, 1, 1)
				lastpuke = 0


/mob/living/carbon/human/has_smoke_protection()
	if(wear_mask)
		if(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
			. = 1
	if(glasses)
		if(glasses.flags & BLOCK_GAS_SMOKE_EFFECT)
			. = 1
	if(head)
		if(head.flags & BLOCK_GAS_SMOKE_EFFECT)
			. = 1
	if(NOBREATH in dna.species.specflags)
		. = 1
	return .


/mob/living/carbon/human/proc/handle_embedded_objects()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		for(var/obj/item/I in BP.embedded_objects)
			if(prob(I.embedded_pain_chance))
				BP.take_damage(I.w_class*I.embedded_pain_multiplier)
				src << "<span class='userdanger'>\the [I] embedded in your [BP.name] hurts!</span>"

			if(prob(I.embedded_fall_chance))
				BP.take_damage(I.w_class*I.embedded_fall_pain_multiplier)
				BP.embedded_objects -= I
				I.loc = get_turf(src)
				visible_message("<span class='danger'>\the [I] falls out of [name]'s [BP.name]!</span>","<span class='userdanger'>\the [I] falls out of your [BP.name]!</span>")
				if(!has_embedded_objects())
					clear_alert("embeddedobject")


/mob/living/carbon/human/proc/handle_heart()
	CHECK_DNA_AND_SPECIES(src)
	var/needs_heart = (!(NOBLOOD in dna.species.specflags))
	var/we_breath = (!(NOBREATH in dna.species.specflags))

	if(heart_attack)
		if(!needs_heart)
			heart_attack = FALSE
		else if(we_breath)
			if(losebreath < 3)
				losebreath += 2
			adjustOxyLoss(5)
			adjustBruteLoss(1)
		else
			// even though we don't require oxygen, our blood still needs
			// circulation, and without it, our tissues die and start
			// gaining toxins
			adjustBruteLoss(3)
			if(src.reagents)
				src.reagents.add_reagent("toxin", 2)

/*
Alcohol Poisoning Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance

0: Non-alcoholic
1-10: Barely classifiable as alcohol - occassional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - light brain damage, passing out
91-100: Dangerously toxic - swift death
*/

/mob/living/carbon/human/handle_status_effects()
	..()
	if(drunkenness)
		if(sleeping)
			drunkenness = max(drunkenness - (drunkenness / 10), 0)
		else
			drunkenness = max(drunkenness - (drunkenness / 25), 0)

		if(drunkenness >= 6)
			if(prob(25))
				slurring += 2
			jitteriness = max(jitteriness - 3, 0)

		if(drunkenness >= 11 && slurring < 5)
			slurring += 1.2

		if(drunkenness >= 41)
			if(prob(25))
				confused += 2
			Dizzy(10)

		if(drunkenness >= 51)
			if(prob(5))
				confused += 10
				vomit()
			Dizzy(25)

		if(drunkenness >= 61)
			if(prob(50))
				blur_eyes(5)

		if(drunkenness >= 71)
			blur_eyes(5)

		if(drunkenness >= 81)
			adjustToxLoss(0.2)
			if(prob(5) && !stat)
				src << "<span class='warning'>Maybe you should lie down for a bit...</span>"

		if(drunkenness >= 91)
			adjustBrainLoss(0.4)
			if(prob(20) && !stat)
				if(SSshuttle.emergency.mode == SHUTTLE_DOCKED && z == ZLEVEL_STATION) //QoL mainly
					src << "<span class='warning'>You're so tired... but you can't miss that shuttle...</span>"
				else
					src << "<span class='warning'>Just a quick nap...</span>"
					Sleeping(45)

		if(drunkenness >= 101)
			adjustToxLoss(4) //Let's be honest you shouldn't be alive by now

#undef HUMAN_MAX_OXYLOSS
=======
//#define DEBUG_LIFE
//#define PROFILE_LIFE

#define OXYCONCEN_PLASMEN_IGNITION 0.01 //1% is all it takes.
var/global/list/unconscious_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage6"),\
	"7" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage7"),\
	"8" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage8"),\
	"9" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage9"),\
	"10" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage10"))
var/global/list/oxyloss_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay6"),\
	"7" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay7"))
var/global/list/brutefireloss_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay6"))
var/global/list/organ_damage_overlays = list(
	"l_hand_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_min", "layer" = 21),\
	"l_hand_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_mid", "layer" = 21),\
	"l_hand_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_max", "layer" = 21),\
	"l_hand_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_gone", "layer" = 21),\
	"r_hand_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_min", "layer" = 21),\
	"r_hand_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_mid", "layer" = 21),\
	"r_hand_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_max", "layer" = 21),\
	"r_hand_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_hand_gone", "layer" = 21),\
	"l_arm_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_arm_min", "layer" = 21),\
	"l_arm_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_hand_mid", "layer" = 21),\
	"l_arm_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_arm_max", "layer" = 21),\
	"l_arm_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_arm_gone", "layer" = 21),\
	"r_arm_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_min", "layer" = 21),\
	"r_arm_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_mid", "layer" = 21),\
	"r_arm_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_max", "layer" = 21),\
	"r_arm_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_arm_gone", "layer" = 21),\
	"l_leg_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_min", "layer" = 21),\
	"l_leg_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_mid", "layer" = 21),\
	"l_leg_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_max", "layer" = 21),\
	"l_leg_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_leg_gone", "layer" = 21),\
	"r_leg_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_min", "layer" = 21),\
	"r_leg_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_mid", "layer" = 21),\
	"r_leg_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_max", "layer" = 21),\
	"r_leg_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_leg_gone", "layer" = 21),\
	"r_foot_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_min", "layer" = 21),\
	"r_foot_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_mid", "layer" = 21),\
	"r_foot_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_max", "layer" = 21),\
	"r_foot_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "r_foot_gone", "layer" = 21),\
	"l_foot_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_min", "layer" = 21),\
	"l_foot_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_mid", "layer" = 21),\
	"l_foot_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_max", "layer" = 21),\
	"l_foot_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "l_foot_gone", "layer" = 21),\
	"chest_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_min", "layer" = 21),\
	"chest_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_mid", "layer" = 21),\
	"chest_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_max", "layer" = 21),\
	"chest_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "chest_gone", "layer" = 21),\
	"head_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_min", "layer" = 21),\
	"head_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_mid", "layer" = 21),\
	"head_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_max", "layer" = 21),\
	"head_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "head_gone", "layer" = 21),\
	"groin_min" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_min", "layer" = 21),\
	"groin_mid" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_mid", "layer" = 21),\
	"groin_max" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_max", "layer" = 21),\
	"groin_gone" = image("icon" = 'icons/mob/organdmg.dmi', "icon_state" = "groin_gone", "layer" = 21))
/mob/living/carbon/human
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/prev_gender = null // Debug for plural genders
	var/temperature_alert = 0
	var/in_stasis = 0
	var/do_deferred_species_setup=0
	var/exposedtimenow = 0
	var/firstexposed = 0
	var/cycle = 0
	var/last_processed = ""

// Doing this during species init breaks shit.
/mob/living/carbon/human/proc/DeferredSpeciesSetup()
	var/mut_update=0
	if(species.default_mutations.len>0)
		for(var/mutation in species.default_mutations)
			if(!(mutation in mutations))
				mutations.Add(mutation)
				mut_update=1
	if(species.default_blocks.len>0)
		for(var/block in species.default_blocks)
			if(!dna.GetSEState(block))
				dna.SetSEState(block,1)
				mut_update=1
	if(mut_update)
		domutcheck(src,null,MUTCHK_FORCED)
		update_mutations()

/mob/living/carbon/human/Life()

	set invisibility = 0
	//set background = 1
	if(timestopped) return 0 //under effects of time magick
	if(monkeyizing)
		return
	if(!loc)
		return	//Fixing a null error that occurs when the mob isn't found in the world -- TLE
	if(do_deferred_species_setup)
		DeferredSpeciesSetup()
		do_deferred_species_setup=0
	//Apparently, the person who wrote this code designed it so that blinded
	//get reset each cycle and then get activated later in the code.
	//Very ugly. I dont care. Moving this stuff here so its easy to find it.
	blinded = null
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//TODO: seperate this out
	//Update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++

	var/datum/gas_mixture/environment = loc.return_air()
	in_stasis = istype(loc, /obj/structure/closet/body_bag/cryobag) && loc:opened == 0 //Nice runtime operator

	if(in_stasis)
		loc:used++ //Ditto above

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD && !in_stasis)

		if(air_master.current_cycle % 4 == 2 || failed_last_breath) //First, resolve location and get a breath
			breathe() //Only try to take a breath every 4 ticks, unless suffocating
			last_processed = "Breathe"

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)
				last_processed = "Interacted with our container"
		if(check_mutations)
			testing("Updating [src.real_name]'s mutations: "+english_list(mutations))
			domutcheck(src,null,MUTCHK_FORCED)
			update_mutations()
			check_mutations = 0
		//Updates the number of stored chemicals for powers
		handle_changeling()
		//Mutations and radiation
		handle_mutations_and_radiation()
		//Chemicals in the body
		handle_chemicals_in_body()
		//Disabilities
		handle_disabilities()
		//??? debug_life("Handle organs", "Successfully handled organs")
		//Random events (vomiting etc)
		handle_random_events()
		handle_virus_updates()
		//Stuff in the stomach
		handle_stomach()
		handle_shock()
		handle_pain()
		handle_medical_side_effects()
		handle_equipment()
	handle_stasis_bag()
	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000)) //We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
		cycle = "DEAD"
		return //We go ahead and process them 5 times for HUD images and other stuff though.
	handle_environment(environment)
	handle_fire()
	handle_regular_status_updates()	//Optimized a bit
	update_canmove()
	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()
	handle_regular_hud_updates()
	pulse = handle_pulse()
	for(var/obj/item/weapon/grab/G in src)
		G.process()
	if(mind && mind.vampire)
		handle_vampire()
	handle_alpha()
	if(update_overlays)
		update_overlays = 0
		UpdateDamageIcon()
	cycle++
	..()

//Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
