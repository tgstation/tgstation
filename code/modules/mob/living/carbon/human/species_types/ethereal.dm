#define CRYSTALIZE_COOLDOWN_LENGTH 120 SECONDS
#define CRYSTALIZE_PRE_WAIT_TIME 3 SECONDS
#define CRYSTALIZE_DISARM_WAIT_TIME 120 SECONDS
#define CRYSTALIZE_HEAL_TIME 5 SECONDS

#define CRYSTALIZE_STAGE_ENGULFING 100 //Cant use second defines
#define CRYSTALIZE_STAGE_ENCROACHING 300 //In switches
#define CRYSTALIZE_STAGE_SMALL 600 //Because they're not static

/datum/species/ethereal
	name = "Ethereal"
	id = "ethereal"
	attack_verb = "burn"
	attack_sound = 'sound/weapons/etherealhit.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	meat = /obj/item/food/meat/slab/human/mutant/ethereal
	mutantstomach = /obj/item/organ/stomach/ethereal
	mutanttongue = /obj/item/organ/tongue/ethereal
	exotic_blood = /datum/reagent/consumable/liquidelectricity //Liquid Electricity. fuck you think of something better gamer
	siemens_coeff = 0.5 //They thrive on energy
	brutemod = 1.25 //They're weak to punches
	payday_modifier = 0.75
	attack_type = BURN //burn bish
	damage_overlay_type = "" //We are too cool for regular damage overlays
	species_traits = list(DYNCOLORS, AGENDER, NO_UNDERWEAR, HAIR, HAS_FLESH, HAS_BONE) // i mean i guess they have blood so they can have wounds too
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/ethereal
	inherent_traits = list(TRAIT_ADVANCEDTOOLUSER,TRAIT_NOHUNGER)
	sexes = FALSE //no fetish content allowed
	toxic_food = NONE
	// Body temperature for ethereals is much higher then humans as they like hotter environments
	bodytemp_normal = (BODYTEMP_NORMAL + 50)
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // about 150C
	// Cold temperatures hurt faster as it is harder to move with out the heat energy
	bodytemp_cold_damage_limit = (T20C - 10) // about 10c
	hair_color = "fixedmutcolor"
	hair_alpha = 140
	var/current_color
	var/EMPeffect = FALSE
	var/emageffect = FALSE
	var/r1
	var/g1
	var/b1
	var/static/r2 = 237
	var/static/g2 = 164
	var/static/b2 = 149
	//this is shit but how do i fix it? no clue.
	var/drain_time = 0 //used to keep ethereals from spam draining power sources
	var/obj/effect/dummy/lighting_obj/ethereal_light

	///Cooldown for the next time we can crystalize
	COOLDOWN_DECLARE(crystalize_cooldown)
	///Timer ID for when we will be crystalized, If not preparing this will be null.
	var/crystalize_timer_id
	///The current crystal the ethereal is in, if any
	var/obj/structure/ethereal_crystal/current_crystal

/datum/species/ethereal/Destroy(force)
	if(ethereal_light)
		QDEL_NULL(ethereal_light)
	QDEL_NULL(current_crystal)
	return ..()


/datum/species/ethereal/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/ethereal = C
	default_color = "#[ethereal.dna.features["ethcolor"]]"
	r1 = GETREDPART(default_color)
	g1 = GETGREENPART(default_color)
	b1 = GETBLUEPART(default_color)
	RegisterSignal(ethereal, COMSIG_ATOM_EMAG_ACT, .proc/on_emag_act)
	RegisterSignal(ethereal, COMSIG_ATOM_EMP_ACT, .proc/on_emp_act)
	RegisterSignal(ethereal, COMSIG_LIGHT_EATER_ACT, .proc/on_light_eater)
	ethereal_light = ethereal.mob_light()
	spec_updatehealth(ethereal)
	C.set_safe_hunger_level()

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	UnregisterSignal(C, COMSIG_ATOM_EMAG_ACT)
	UnregisterSignal(C, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(C, COMSIG_LIGHT_EATER_ACT)
	QDEL_NULL(ethereal_light)
	if(current_crystal)
		qdel(current_crystal) //Kicks out the ethereal
	return ..()


/datum/species/ethereal/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_ethereal_name()

	var/randname = ethereal_name()

	return randname


/datum/species/ethereal/spec_updatehealth(mob/living/carbon/human/H)
	. = ..()
	if(H.stat != DEAD && !EMPeffect)
		var/healthpercent = max(H.health, 0) / 100
		if(!emageffect)
			current_color = rgb(r2 + ((r1-r2)*healthpercent), g2 + ((g1-g2)*healthpercent), b2 + ((b1-b2)*healthpercent))
		ethereal_light.set_light_range_power_color(1 + (2 * healthpercent), 1 + (1 * healthpercent), current_color)
		ethereal_light.set_light_on(TRUE)
		fixed_mut_color = copytext_char(current_color, 2)
	else
		ethereal_light.set_light_on(FALSE)
		fixed_mut_color = rgb(128,128,128)
	H.update_body()

/datum/species/ethereal/proc/on_emp_act(mob/living/carbon/human/H, severity)
	EMPeffect = TRUE
	spec_updatehealth(H)
	to_chat(H, "<span class='notice'>You feel the light of your body leave you.</span>")
	switch(severity)
		if(EMP_LIGHT)
			addtimer(CALLBACK(src, .proc/stop_emp, H), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 10 seconds
		if(EMP_HEAVY)
			addtimer(CALLBACK(src, .proc/stop_emp, H), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 20 seconds

/datum/species/ethereal/proc/on_emag_act(mob/living/carbon/human/H, mob/user)
	if(emageffect)
		return
	emageffect = TRUE
	if(user)
		to_chat(user, "<span class='notice'>You tap [H] on the back with your card.</span>")
	H.visible_message("<span class='danger'>[H] starts flickering in an array of colors!</span>")
	handle_emag(H)
	addtimer(CALLBACK(src, .proc/stop_emag, H), 2 MINUTES) //Disco mode for 2 minutes! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.

/// Special handling for getting hit with a light eater
/datum/species/ethereal/proc/on_light_eater(mob/living/carbon/human/source, datum/light_eater)
	SIGNAL_HANDLER
	source.emp_act(EMP_LIGHT)
	return COMPONENT_BLOCK_LIGHT_EATER

/datum/species/ethereal/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	.=..()
	handle_charge(H, delta_time, times_fired)


/datum/species/ethereal/proc/stop_emp(mob/living/carbon/human/H)
	EMPeffect = FALSE
	spec_updatehealth(H)
	to_chat(H, "<span class='notice'>You feel more energized as your shine comes back.</span>")


/datum/species/ethereal/proc/handle_emag(mob/living/carbon/human/H)
	if(!emageffect)
		return
	current_color = pick(GLOB.color_list_ethereal)
	spec_updatehealth(H)
	addtimer(CALLBACK(src, .proc/handle_emag, H), 5) //Call ourselves every 0.5 seconds to change color

/datum/species/ethereal/proc/stop_emag(mob/living/carbon/human/H)
	emageffect = FALSE
	spec_updatehealth(H)
	H.visible_message("<span class='danger'>[H] stops flickering and goes back to their normal state!</span>")

/datum/species/ethereal/proc/handle_charge(mob/living/carbon/human/H, delta_time, times_fired)
	switch(get_charge(H))
		if(-INFINITY to ETHEREAL_CHARGE_NONE)
			H.throw_alert("ethereal_charge", /atom/movable/screen/alert/etherealcharge, 3)
			if(H.health > 10.5)
				apply_damage(0.65, TOX, null, null, H)
		if(ETHEREAL_CHARGE_NONE to ETHEREAL_CHARGE_LOWPOWER)
			H.throw_alert("ethereal_charge", /atom/movable/screen/alert/etherealcharge, 2)
			if(H.health > 10.5)
				apply_damage(0.325 * delta_time, TOX, null, null, H)
		if(ETHEREAL_CHARGE_LOWPOWER to ETHEREAL_CHARGE_NORMAL)
			H.throw_alert("ethereal_charge", /atom/movable/screen/alert/etherealcharge, 1)
		if(ETHEREAL_CHARGE_FULL to ETHEREAL_CHARGE_OVERLOAD)
			H.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 1)
			apply_damage(0.2, TOX, null, null, H)
		if(ETHEREAL_CHARGE_OVERLOAD to ETHEREAL_CHARGE_DANGEROUS)
			H.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 2)
			apply_damage(0.325 * delta_time, TOX, null, null, H)
			if(DT_PROB(5, delta_time)) // 5% each seacond for ethereals to explosively release excess energy if it reaches dangerous levels
				discharge_process(H)
		else
			H.clear_alert("ethereal_charge")
			H.clear_alert("ethereal_overcharge")

/datum/species/ethereal/proc/discharge_process(mob/living/carbon/human/H)
	to_chat(H, "<span class='warning'>You begin to lose control over your charge!</span>")
	H.visible_message("<span class='danger'>[H] begins to spark violently!</span>")
	var/static/mutable_appearance/overcharge //shameless copycode from lightning spell
	overcharge = overcharge || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	H.add_overlay(overcharge)
	if(do_after(H, 5 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED)))
		H.flash_lighting_fx(5, 7, current_color)
		var/obj/item/organ/stomach/ethereal/stomach = H.getorganslot(ORGAN_SLOT_STOMACH)
		playsound(H, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
		H.cut_overlay(overcharge)
		tesla_zap(H, 2, stomach.crystal_charge*2.5, ZAP_OBJ_DAMAGE | ZAP_ALLOW_DUPLICATES)
		if(istype(stomach))
			stomach.adjust_charge(ETHEREAL_CHARGE_FULL - stomach.crystal_charge)
		to_chat(H, "<span class='warning'>You violently discharge energy!</span>")
		H.visible_message("<span class='danger'>[H] violently discharges energy!</span>")
		if(prob(10)) //chance of developing heart disease to dissuade overcharging oneself
			var/datum/disease/D = new /datum/disease/heart_failure
			H.ForceContractDisease(D)
			to_chat(H, "<span class='userdanger'>You're pretty sure you just felt your heart stop for a second there..</span>")
			H.playsound_local(H, 'sound/effects/singlebeat.ogg', 100, 0)
		H.Paralyze(100)


/datum/species/ethereal/proc/get_charge(mob/living/carbon/H) //this feels like it should be somewhere else. Eh?
	var/obj/item/organ/stomach/ethereal/stomach = H.getorganslot(ORGAN_SLOT_STOMACH)
	if(istype(stomach))
		return stomach.crystal_charge
	return ETHEREAL_CHARGE_NONE


/datum/species/ethereal/spec_death(gibbed, mob/living/carbon/human/H)
	. = ..()
	if(gibbed)
		return //lol rip

	if(!COOLDOWN_FINISHED(src, crystalize_cooldown))
		return //lol double rip

	H.visible_message("<span class='notice'>Crystals start forming around [src]</span>", "<span class='nicegreen'>Crystals start forming around your dead body</span>")

	crystalize_timer_id = addtimer(CALLBACK(src, .proc/crystalize, H), CRYSTALIZE_PRE_WAIT_TIME, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE) //Lets us restart the timer on disarm
	RegisterSignal(H, COMSIG_MOB_STATCHANGE, .proc/on_stat_change)
	RegisterSignal(H, COMSIG_HUMAN_DISARM_HIT, .proc/reset_crystalizing)
	RegisterSignal(H, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/species/ethereal/spec_fully_heal(mob/living/carbon/human/H)
	if(current_crystal)
		qdel(current_crystal) //Kicks out the ethereal


#define CRYSTALIZE_STAGE_ENGULFING 10 SECONDS
#define CRYSTALIZE_STAGE_ENCROACHING 30 SECONDS
#define CRYSTALIZE_STAGE_SMALL 60 SECONDS

///Ran when examined while crystalizing
/datum/species/ethereal/proc/on_examine(mob/living/carbon/human/examined_human, mob/user, list/examine_list)
	if(!crystalize_timer_id)
		return

	switch(timeleft(crystalize_timer_id))
		if(0 to CRYSTALIZE_STAGE_ENGULFING)
			examine_list += "<span class='notice'>Crystals are almost engulfing [src] </span>"
		if(CRYSTALIZE_STAGE_ENGULFING to CRYSTALIZE_STAGE_ENCROACHING)
			examine_list += "<span class='notice'>Crystals are starting to cover [src] </span>"
		if(CRYSTALIZE_STAGE_SMALL to INFINITY)
			examine_list += "<span class='notice'>Some crystals are coming out of [src] </span>"

/datum/species/ethereal/proc/on_stat_change(mob/living/victim, new_stat)
	SIGNAL_HANDLER
	if(!crystalize_timer_id && victim.stat == DEAD)
		return
	//We stopped being dead, this means no more crystalizing buddy!
	deltimer(crystalize_timer_id)
	crystalize_timer_id = null
	UnregisterSignal(victim, COMSIG_MOB_STATCHANGE)
	UnregisterSignal(victim, COMSIG_HUMAN_DISARM_HIT)
	UnregisterSignal(victim, COMSIG_PARENT_EXAMINE)

///Ran when disarmed, prevents the ethereal from reviving
/datum/species/ethereal/proc/reset_crystalizing(mob/living/defender, mob/living/attacker, zone)
	SIGNAL_HANDLER
	defender.visible_message("<span class='notice'>The crystals on [src] are broken off</span>", "<span class='warning'>The crystals on your corpse are broken off, and will need some time to recover.</span>")
	crystalize_timer_id = addtimer(CALLBACK(src, .proc/crystalize, defender), CRYSTALIZE_DISARM_WAIT_TIME, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE) //Lets us restart the timer on disarm

/datum/species/ethereal/proc/crystalize(mob/living/ethereal)
	if(!COOLDOWN_FINISHED(src, crystalize_cooldown) || ethereal.stat != DEAD)
		return //Should probably not happen, but lets be safe.
	COOLDOWN_START(src, crystalize_cooldown, INFINITY) //Prevent cheeky double-healing until we get out, this is against stupid admemery
	current_crystal = new(get_turf(ethereal), ethereal)
	UnregisterSignal(ethereal, COMSIG_MOB_STATCHANGE)
	UnregisterSignal(ethereal, COMSIG_HUMAN_DISARM_HIT)
	UnregisterSignal(ethereal, COMSIG_PARENT_EXAMINE)

/obj/structure/ethereal_crystal
	name = "Ethereal Ressurection Crystal"
	desc = "It seems to contain the corpse of an Ethereal mending its wounds."
	icon = 'icons/obj/ethereal_crystal.dmi'
	icon_state = "ethereal_crystal"
	damage_deflection = 0
	max_integrity = 100
	resistance_flags = FIRE_PROOF
	density = TRUE
	anchored = TRUE
	///Reference to the Ethereal in question
	var/mob/living/carbon/human/ethereal
	///Timer for the healing process. Stops if destroyed.
	var/crystal_heal_timer
	///Light effect for the crystal
	var/obj/effect/dummy/lighting_obj/crystal_light

/obj/structure/ethereal_crystal/Initialize(mapload, mob/living/carbon/human/ethereal)
	. = ..()
	src.ethereal = ethereal
	playsound(get_turf(src), 'sound/effects/ethereal_crystalization.ogg', 50)
	ethereal.forceMove(src) //put that ethereal in
	add_atom_colour("#[ethereal.dna.features["ethcolor"]]", FIXED_COLOUR_PRIORITY)
	crystal_heal_timer = addtimer(CALLBACK(src, .proc/heal_ethereal), CRYSTALIZE_HEAL_TIME, TIMER_STOPPABLE)
	crystal_light.set_light_range_power_color(4, 10, "#[ethereal.dna.features["ethcolor"]]")
	crystal_light.set_light_on(TRUE)
	ADD_TRAIT(ethereal, TRAIT_CORPSELOCKED, SPECIES_TRAIT)

/obj/structure/ethereal_crystal/Destroy()
	var/datum/species/ethereal/ethereal_species = ethereal.dna.species
	if(!ethereal_species)
		return ..()
	ethereal_species.current_crystal = null
	COOLDOWN_START(ethereal_species, crystalize_cooldown, CRYSTALIZE_COOLDOWN_LENGTH)
	ethereal.forceMove(get_turf(src))
	REMOVE_TRAIT(ethereal, TRAIT_CORPSELOCKED, SPECIES_TRAIT)
	deltimer(crystal_heal_timer)
	if(crystal_light)
		QDEL_NULL(crystal_light)
	return ..()

/obj/structure/ethereal_crystal/update_overlays()
	. = ..()
	var/mutable_appearance/shine = mutable_appearance(icon, icon_state = "[icon_state]_shine")
	shine.appearance_flags = RESET_COLOR //No color on this, just pure white
	. += shine

/obj/structure/ethereal_crystal/proc/heal_ethereal()
	ethereal.revive(TRUE, FALSE)
	var/datum/brain_trauma/picked_trauma
	if(prob(10)) //10% chance for a severe trauma
		picked_trauma = pick(subtypesof(/datum/brain_trauma/severe))
	else
		picked_trauma = pick(subtypesof(/datum/brain_trauma/mild))
	ethereal.gain_trauma(picked_trauma, TRAUMA_RESILIENCE_ABSOLUTE)
	to_chat(ethereal, "<span class='notice'>You burst out of the crystal with vigour</span><span class='userdanger'>...But at a cost.</span>")
	qdel(src)

