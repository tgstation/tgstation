//Nearsightedness restricts your vision by several tiles.
/datum/mutation/human/nearsight
	name = "Near Sightness"
	desc = "The holder of this mutation has poor eyesight."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You can't see very well.</span>"

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
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You can't seem to see anything.</span>"

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
	text_gain_indication = "<span class='notice'>You can see the heat rising off of your skin...</span>"
	text_lose_indication = "<span class='notice'>You can no longer see the heat rising off of your skin...</span>"
	instability = 25
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1
	power = /obj/effect/proc_holder/spell/self/thermal_vision_activate

/datum/mutation/human/thermal/modify()
	if(!power)
		return FALSE
	var/obj/effect/proc_holder/spell/self/thermal_vision_activate/modified_power = power
	modified_power.eye_damage = 10 * GET_MUTATION_SYNCHRONIZER(src)
	modified_power.thermal_duration = 10 * GET_MUTATION_POWER(src)
	modified_power.charge_max = (25 * GET_MUTATION_ENERGY(src)) SECONDS

/obj/effect/proc_holder/spell/self/thermal_vision_activate
	name = "Activate Thermal Vision"
	desc = "You can see thermal signatures, at the cost of your eyesight."
	charge_max = 25 SECONDS
	var/eye_damage = 10
	var/thermal_duration = 10
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "augmented_eyesight"

/obj/effect/proc_holder/spell/self/thermal_vision_activate/cast(list/targets, mob/user = usr)
	. = ..()

	if(HAS_TRAIT(user,TRAIT_THERMAL_VISION))
		return

	ADD_TRAIT(user, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	user.update_sight()
	to_chat(user, text("You focus your eyes intensely, as your vision becomes filled with heat signatures."))

	addtimer(CALLBACK(src, .proc/thermal_vision_deactivate), thermal_duration SECONDS)

/obj/effect/proc_holder/spell/self/thermal_vision_activate/proc/thermal_vision_deactivate(mob/user = usr)
	if(!HAS_TRAIT_FROM(user,TRAIT_THERMAL_VISION, GENETIC_MUTATION))
		return

	REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	user.update_sight()
	to_chat(user, text("You blink a few times, your vision returning to normal as a dull pain settles in your eyes."))

	var/mob/living/carbon/user_mob = user
	if(!istype(user_mob))
		return

	user_mob.adjustOrganLoss(ORGAN_SLOT_EYES, eye_damage)

/datum/mutation/human/thermal/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	owner.update_sight()

///X-ray Vision lets you see through walls.
/datum/mutation/human/xray
	name = "X Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls." //actual x-ray would mean you'd constantly be blasting rads, wich might be fun for later //hmb
	text_gain_indication = "<span class='notice'>The walls suddenly disappear!</span>"
	instability = 35
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
	text_gain_indication = "<span class='notice'>You feel pressure building up behind your eyes.</span>"
	layer_used = FRONT_MUTATIONS_LAYER
	limb_req = BODY_ZONE_HEAD

/datum/mutation/human/laser_eyes/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "lasereyes", -FRONT_MUTATIONS_LAYER))

/datum/mutation/human/laser_eyes/on_acquiring(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	RegisterSignal(H, COMSIG_MOB_ATTACK_RANGED, .proc/on_ranged_attack)

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
	source.newtonian_move(get_dir(target, source))
	var/obj/projectile/beam/laser_eyes/LE = new(source.loc)
	LE.firer = source
	LE.def_zone = ran_zone(source.zone_selected)
	LE.preparePixelProjectile(target, source, modifiers)
	INVOKE_ASYNC(LE, /obj/projectile.proc/fire)
	playsound(source, 'sound/weapons/taser2.ogg', 75, TRUE)

///Projectile type used by laser eyes
/obj/projectile/beam/laser_eyes
	name = "beam"
	icon = 'icons/effects/genetics.dmi'
	icon_state = "eyelasers"

/datum/mutation/human/illiterate
	name = "Illiterate"
	desc = "Causes a severe case of Aphasia that prevents reading or writing."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You feel unable to read or write.</span>"
	text_lose_indication = "<span class='danger'>You feel able to read and write again.</span>"

/datum/mutation/human/illiterate/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_ILLITERATE, GENETIC_MUTATION)

/datum/mutation/human/illiterate/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_ILLITERATE, GENETIC_MUTATION)
