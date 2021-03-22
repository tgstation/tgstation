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
	time_coeff = 2
	instability = 25
	power = /obj/effect/proc_holder/spell/self/thermal_vision_activate

/obj/effect/proc_holder/spell/self/thermal_vision_activate
	name = "Activate thermal vision"
	desc = "You can see thermal signatures, at the cost of your eyesight."
	charge_max = 20 SECONDS
	clothes_req = FALSE

/obj/effect/proc_holder/spell/self/thermal_vision_activate/cast(list/targets, mob/user = usr)
	. = ..()

	if(HAS_TRAIT(user,TRAIT_THERMAL_VISION))
		return

	ADD_TRAIT(user, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	user.update_sight()
	to_chat(user, text("You focus your eyes intensely, as your vision becomes filled with heat signatures."))

	addtimer(CALLBACK(src, .proc/thermal_vision_deactivate), 10 SECONDS)

/obj/effect/proc_holder/spell/self/thermal_vision_activate/proc/thermal_vision_deactivate(mob/user = usr)
	REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	user.update_sight()
	to_chat(user, text("You blink a few times, your vision returning to normal as a dull pain settles in your eyes."))

	var/mob/living/carbon/user_mob = user
	if(!istype(user_mob))
		return

	user_mob.adjustOrganLoss(ORGAN_SLOT_EYES, 10)

///X-ray Vision lets you see through walls.
/datum/mutation/human/thermal/x_ray
	name = "X Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls." //actual x-ray would mean you'd constantly be blasting rads, wich might be fun for later //hmb
	text_gain_indication = "<span class='notice'>The walls suddenly disappear! You blink, and they're back.</span>"
	instability = 35
	power = /obj/effect/proc_holder/spell/self/xray_vision_activate
	locked = TRUE

/obj/effect/proc_holder/spell/self/xray_vision_activate
	name = "Activate xray vision"
	desc = "You can see through walls, at the cost of your brain's health."
	charge_max = 30 SECONDS
	clothes_req = FALSE

/obj/effect/proc_holder/spell/self/xray_vision_activate/cast(list/targets, mob/user = usr)
	. = ..()

	if(HAS_TRAIT(user,TRAIT_XRAY_VISION))
		return

	ADD_TRAIT(user, TRAIT_XRAY_VISION, GENETIC_MUTATION)
	user.update_sight()
	to_chat(user, text("You focus your eyes intensely, as your vision pierces everything around you."))

	addtimer(CALLBACK(src, .proc/xray_vision_deactivate), 10 SECONDS)

/obj/effect/proc_holder/spell/self/xray_vision_activate/proc/xray_vision_deactivate(mob/user = usr)
	REMOVE_TRAIT(user, TRAIT_XRAY_VISION, GENETIC_MUTATION)
	user.update_sight()
	to_chat(user, text("You blink a few times, your vision returning to normal as a dull pain settles in your head."))

	var/mob/living/carbon/user_mob = user
	if(!istype(user_mob))
		return

	user_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50)



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
	to_chat(source, "<span class='warning'>You shoot with your laser eyes!</span>")
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
