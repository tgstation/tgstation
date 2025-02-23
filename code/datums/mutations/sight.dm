//Nearsightedness restricts your vision by several tiles.
/datum/mutation/human/nearsight
	name = "Near Sightness"
	desc = "The holder of this mutation has poor eyesight."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("You can't see very well.")

/datum/mutation/human/nearsight/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.become_nearsighted(GENETIC_MUTATION)

/datum/mutation/human/nearsight/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.cure_nearsighted(GENETIC_MUTATION)

///Blind makes you blind. Who knew?
/datum/mutation/human/blind
	name = "Blindness"
	desc = "Renders the subject completely blind."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("You can't seem to see anything.")

/datum/mutation/human/blind/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.become_blind(GENETIC_MUTATION)

/datum/mutation/human/blind/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.cure_blind(GENETIC_MUTATION)

///Thermal Vision lets you see mobs through walls
/datum/mutation/human/thermal
	name = "Thermal Vision"
	desc = "The user of this genome can visually perceive the unique human thermal signature."
	quality = POSITIVE
	difficulty = 18
	text_gain_indication = span_notice("You can see the heat rising off of your skin...")
	text_lose_indication = span_notice("You can no longer see the heat rising off of your skin...")
	instability = POSITIVE_INSTABILITY_MAJOR // thermals aren't station equipment
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1
	power_path = /datum/action/cooldown/spell/thermal_vision

/datum/mutation/human/thermal/on_losing(mob/living/carbon/human/owner)
	if(..())
		return

	// Something went wront and we still have the thermal vision from our power, no cheating.
	if(HAS_TRAIT_FROM(owner, TRAIT_THERMAL_VISION, GENETIC_MUTATION))
		REMOVE_TRAIT(owner, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		owner.update_sight()

/datum/mutation/human/thermal/modify()
	. = ..()
	var/datum/action/cooldown/spell/thermal_vision/to_modify = .
	if(!istype(to_modify)) // null or invalid
		return

	to_modify.eye_damage = 10 * GET_MUTATION_SYNCHRONIZER(src)
	to_modify.thermal_duration = 10 SECONDS * GET_MUTATION_POWER(src)

/datum/action/cooldown/spell/thermal_vision
	name = "Activate Thermal Vision"
	desc = "You can see thermal signatures, at the cost of your eyesight."
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "augmented_eyesight"

	cooldown_time = 25 SECONDS
	spell_requirements = NONE

	/// How much eye damage is given on cast
	var/eye_damage = 10
	/// The duration of the thermal vision
	var/thermal_duration = 10 SECONDS

/datum/action/cooldown/spell/thermal_vision/Remove(mob/living/remove_from)
	REMOVE_TRAIT(remove_from, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	remove_from.update_sight()
	return ..()

/datum/action/cooldown/spell/thermal_vision/is_valid_target(atom/cast_on)
	return isliving(cast_on) && !HAS_TRAIT(cast_on, TRAIT_THERMAL_VISION)

/datum/action/cooldown/spell/thermal_vision/cast(mob/living/cast_on)
	. = ..()
	ADD_TRAIT(cast_on, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	cast_on.update_sight()
	to_chat(cast_on, span_info("You focus your eyes intensely, as your vision becomes filled with heat signatures."))
	addtimer(CALLBACK(src, PROC_REF(deactivate), cast_on), thermal_duration)

/datum/action/cooldown/spell/thermal_vision/proc/deactivate(mob/living/cast_on)
	if(QDELETED(cast_on) || !HAS_TRAIT_FROM(cast_on, TRAIT_THERMAL_VISION, GENETIC_MUTATION))
		return

	REMOVE_TRAIT(cast_on, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	cast_on.update_sight()
	to_chat(cast_on, span_info("You blink a few times, your vision returning to normal as a dull pain settles in your eyes."))

	if(iscarbon(cast_on))
		var/mob/living/carbon/carbon_cast_on = cast_on
		carbon_cast_on.adjustOrganLoss(ORGAN_SLOT_EYES, eye_damage)

///X-ray Vision lets you see through walls.
/datum/mutation/human/xray
	name = "X Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls." //actual x-ray would mean you'd constantly be blasting rads, which might be fun for later //hmb
	text_gain_indication = span_notice("The walls suddenly disappear!")
	instability = POSITIVE_INSTABILITY_MAJOR
	locked = TRUE

/datum/mutation/human/xray/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/human/xray/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, GENETIC_MUTATION)
	owner.update_sight()


///Laser Eyes lets you shoot lasers from your eyes!
/datum/mutation/human/laser_eyes
	name = "Laser Eyes"
	desc = "Reflects concentrated light back from the eyes."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = span_notice("You feel pressure building up behind your eyes.")
	layer_used = FRONT_MUTATIONS_LAYER
	limb_req = BODY_ZONE_HEAD

/datum/mutation/human/laser_eyes/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/mob/effects/genetics.dmi', "lasereyes", -FRONT_MUTATIONS_LAYER))

/datum/mutation/human/laser_eyes/on_acquiring(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	RegisterSignal(H, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))

/datum/mutation/human/laser_eyes/on_losing(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	UnregisterSignal(H, COMSIG_MOB_ATTACK_RANGED)

/datum/mutation/human/laser_eyes/get_visual_indicator()
	return visual_indicators[type][1]

///Triggers on COMSIG_MOB_ATTACK_RANGED. Does the projectile shooting.
/datum/mutation/human/laser_eyes/proc/on_ranged_attack(mob/living/carbon/human/source, atom/target, modifiers)
	SIGNAL_HANDLER

	if(!source.combat_mode)
		return
	to_chat(source, span_warning("You shoot with your laser eyes!"))
	source.changeNext_move(CLICK_CD_RANGE)
	source.newtonian_move(get_angle(source, target))
	var/obj/projectile/beam/laser/laser_eyes/LE = new(source.loc)
	LE.firer = source
	LE.def_zone = ran_zone(source.zone_selected)
	LE.aim_projectile(target, source, modifiers)
	INVOKE_ASYNC(LE, TYPE_PROC_REF(/obj/projectile, fire))
	playsound(source, 'sound/items/weapons/taser2.ogg', 75, TRUE)

///Projectile type used by laser eyes
/obj/projectile/beam/laser/laser_eyes
	name = "beam"
	icon = 'icons/mob/effects/genetics.dmi'
	icon_state = "eyelasers"

/datum/mutation/human/illiterate
	name = "Illiterate"
	desc = "Causes a severe case of Aphasia that prevents reading or writing."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("You feel unable to read or write.")
	text_lose_indication = span_danger("You feel able to read and write again.")

/datum/mutation/human/illiterate/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_ILLITERATE, GENETIC_MUTATION)

/datum/mutation/human/illiterate/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_ILLITERATE, GENETIC_MUTATION)

