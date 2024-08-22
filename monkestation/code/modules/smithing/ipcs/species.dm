#define SYNTH_CHARGE_MAX 150
#define SYNTH_CHARGE_MIN 50
#define SYNTH_CHARGE_PER_NUTRITION 10
#define SYNTH_CHARGE_DELAY_PER_100 10
#define SYNTH_DRAW_NUTRITION_BUFFER 30
#define SYNTH_APC_MINIMUM_PERCENT 20

/datum/species/ipc
	name = "\improper Integrated Positronic Chassis"
	id = SPECIES_IPC
	inherent_biotypes = MOB_ROBOTIC | MOB_HUMANOID
	sexes = FALSE
	inherent_traits = list(
		TRAIT_ROBOT_CAN_BLEED,
		TRAIT_CAN_STRIP,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_RADIMMUNE,
		TRAIT_NOBREATH,
		TRAIT_TOXIMMUNE,
		TRAIT_GENELESS,
		TRAIT_STABLEHEART,
		TRAIT_LIMBATTACHMENT,
		TRAIT_LITERATE,
		TRAIT_REVIVES_BY_HEALING,
		TRAIT_NOCRITDAMAGE, // We do our own handling of crit damage.
		TRAIT_NO_DNA_COPY,
	)

	species_traits = list(
		NO_DNA_COPY,
		NOTRANSSTING,
		NOHUSK
	)

	mutant_organs = list(
		/obj/item/organ/internal/cyberimp/arm/item_set/power_cord,
		/obj/item/organ/internal/cyberimp/cyberlink/nt_low,

		)
	external_organs = list(
		/obj/item/organ/external/antennae/ipc = "None"
	)

	mutant_bodyparts = list("ipc_screen", "ipc_chassis")

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	reagent_tag = PROCESS_SYNTHETIC

	payday_modifier = 1.0 // Matches the rest of the pay penalties the non-human crew have

	species_language_holder = /datum/language_holder/synthetic
	special_step_sounds = list('sound/effects/servostep.ogg')

	mutantbrain = /obj/item/organ/internal/brain/synth
	mutantstomach = /obj/item/organ/internal/stomach/synth
	mutantears = /obj/item/organ/internal/ears/synth
	mutanttongue = /obj/item/organ/internal/tongue/synth
	mutanteyes = /obj/item/organ/internal/eyes/synth
	mutantlungs = /obj/item/organ/internal/lungs/synth
	mutantheart = /obj/item/organ/internal/heart/synth
	mutantliver = /obj/item/organ/internal/liver/synth
	mutantappendix = null
	exotic_blood = /datum/reagent/fuel/oil

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/robot/ipc,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/robot/ipc,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/robot/ipc,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/robot/ipc,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/robot/ipc,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/robot/ipc,
	)

	coldmod = 1.2
	heatmod = 2 // TWO TIMES DAMAGE FROM BEING TOO HOT?! WHAT?! No wonder lava is literal instant death for us.
	siemens_coeff = 1.4 // Not more because some shocks will outright crit you, which is very unfun
	/// The innate action that synths get, if they've got a screen selected on species being set.
	var/datum/action/innate/change_screen/change_screen
	/// This is the screen that is given to the user after they get revived. On death, their screen is temporarily set to BSOD before it turns off, hence the need for this var.
	var/saved_screen = "Blank"

	var/will_it_blend_timer
	COOLDOWN_DECLARE(blend_cd)
	var/blending

/datum/species/ipc/get_scream_sound(mob/living/carbon/human/human)
	return 'monkestation/sound/voice/screams/silicon/scream_silicon.ogg'

/datum/species/ipc/get_laugh_sound(mob/living/carbon/human/human)
	return pick(
		'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M0.ogg',
		'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M1.ogg',
		'monkestation/sound/voice/laugh/silicon/laugh_siliconM2.ogg',
	)

/datum/species/ipc/get_species_description()
	return "Integrated Positronic Chassis - or IPC for short - \
	 are a race of sentient and unbound humanoid robots."

/datum/species/ipc/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.posibrain_names)]-[rand(100, 999)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)

/datum/species/ipc/on_species_gain(mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/internal/appendix/A = C.get_organ_slot("appendix") //See below.
	if(A)
		A.Remove(C)
		QDEL_NULL(A)
	var/obj/item/organ/internal/lungs/L = C.get_organ_slot("lungs") //Hacky and bad. Will be rewritten entirely in KapuCarbons anyway.
	if(L)
		L.Remove(C)
		QDEL_NULL(L)
	if(ishuman(C) && !change_screen)
		change_screen = new
		change_screen.Grant(C)

	RegisterSignal(C, COMSIG_LIVING_DEATH, PROC_REF(bsod_death)) // screen displays bsod on death, if they have one
	RegisterSignal(C.reagents, COMSIG_REAGENTS_ADD_REAGENT, PROC_REF(will_it_blend))

/datum/species/ipc/proc/will_it_blend(datum/reagents/holder, ...)
	var/mob/living/carbon/carbon = holder.my_atom
	if(!carbon.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment))
		return
	if(blending || !COOLDOWN_FINISHED(src, blend_cd))
		return
	will_it_blend_timer = addtimer(CALLBACK(src, PROC_REF(start_blending), carbon), 4 SECONDS)

/datum/species/ipc/proc/start_blending(mob/living/carbon/carbon)
	blending = TRUE
	carbon.Shake(2, 2, 10 SECONDS)
	playsound(carbon, 'monkestation/code/modules/smithing/sounds/blend.ogg', 50, TRUE, mixer_channel = CHANNEL_MOB_SOUNDS)
	addtimer(CALLBACK(src, PROC_REF(finish_blending), carbon), 10 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)

/datum/species/ipc/proc/finish_blending(mob/living/carbon/human/carbon)
	var/nutri_amount = carbon.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	carbon.reagents.del_reagent(/datum/reagent/consumable/nutriment)
	carbon.nutrition = min(NUTRITION_LEVEL_FULL, carbon.nutrition + (nutri_amount * 5))
	blending = FALSE
	COOLDOWN_START(src, blend_cd, 60 SECONDS)

/**
 * Makes the IPC screen switch to BSOD followed by a blank screen
 *
 * Arguments:
 * * transformer - The human that will be affected by the screen change (read: IPC).
 * * screen_name - The name of the screen to switch the ipc_screen mutant bodypart to. Defaults to BSOD.
 */
/datum/species/ipc/proc/bsod_death(mob/living/carbon/human/transformer, screen_name = "BSOD")
	saved_screen = change_screen // remember the old screen in case of revival
	switch_to_screen(transformer, screen_name)
	addtimer(CALLBACK(src, PROC_REF(switch_to_screen), transformer, "Blank"), 5 SECONDS)


/datum/species/ipc/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(change_screen)
		change_screen.Remove(C)
		UnregisterSignal(C, COMSIG_LIVING_DEATH)

/datum/species/ipc/proc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT //beep

/datum/action/innate/change_screen
	name = "Change Display"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/change_screen/Activate()
	var/screen_choice = tgui_input_list(usr, "Which screen do you want to use?", "Screen Change", GLOB.ipc_screens_list)
	if(!screen_choice)
		return
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.dna.features["ipc_screen"] = screen_choice
	H.update_body()

/datum/species/ipc/spec_revival(mob/living/carbon/human/H)
	H.notify_ghost_cloning("You have been repaired!")
	H.grab_ghost()
	H.dna.features["ipc_screen"] = "BSOD"
	H.update_body()
	playsound(H, 'monkestation/sound/voice/dialup.ogg', 25)
	H.say("Reactivating [pick("core systems", "central subroutines", "key functions")]...")
	sleep(3 SECONDS)
	if(H.stat == DEAD)
		return
	H.say("Reinitializing [pick("personality matrix", "behavior logic", "morality subsystems")]...")
	sleep(3 SECONDS)
	if(H.stat == DEAD)
		return
	H.say("Finalizing setup...")
	sleep(3 SECONDS)
	if(H.stat == DEAD)
		return
	H.say("Unit [H.real_name] is fully functional. Have a nice day.")
	switch_to_screen(H, "Console")
	addtimer(CALLBACK(src, PROC_REF(switch_to_screen), H, saved_screen), 5 SECONDS)
	playsound(H.loc, 'sound/machines/chime.ogg', 50, TRUE)
	H.visible_message(span_notice("[H]'s [change_screen ? "monitor lights up" : "eyes flicker to life"]!"), span_notice("All systems nominal. You're back online!"))
	return

/datum/species/ipc/replace_body(mob/living/carbon/C, datum/species/new_species)
	..()

	var/datum/sprite_accessory/ipc_chassis/chassis_of_choice = GLOB.ipc_chassis_list[C.dna.features["ipc_chassis"]]

	if(!chassis_of_choice)
		chassis_of_choice = GLOB.ipc_chassis_list[pick(GLOB.ipc_chassis_list)]
		C.dna.features["ipc_chassis"] = pick(GLOB.ipc_chassis_list)

	for(var/obj/item/bodypart/BP as() in C.bodyparts) //Override bodypart data as necessary
		BP.limb_id = chassis_of_choice.icon_state
		BP.name = "\improper[chassis_of_choice.name] [parse_zone(BP.body_zone)]"
		BP.update_limb()
		if(chassis_of_choice.color_src == MUTCOLORS)
			BP.should_draw_greyscale = TRUE

/**
 * Simple proc to switch the screen of a monitor-enabled synth, while updating their appearance.
 *
 * Arguments:
 * * transformer - The human that will be affected by the screen change (read: IPC).
 * * screen_name - The name of the screen to switch the ipc_screen mutant bodypart to.
 */
/datum/species/ipc/proc/switch_to_screen(mob/living/carbon/human/transformer, screen_name)
	if(!change_screen)
		return

	transformer.dna.features["ipc_screen"] = screen_name
	transformer.update_body()


/obj/item/apc_powercord
	name = "power cord"
	desc = "An internal power cord hooked up to a battery. Useful if you run on electricity. Not so much otherwise."
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"

/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/machinery/power/apc) || !ishuman(user) || !proximity_flag)
		return ..()

	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/machinery/power/apc/target_apc = target
	var/mob/living/carbon/human/ipc = user
	var/obj/item/organ/internal/stomach/synth/cell = ipc.organs_slot[ORGAN_SLOT_STOMACH]

	if(!cell)
		to_chat(ipc, span_warning("You try to siphon energy from the [target_apc], but you have no stomach! How are you still standing?"))
		return

	if(!istype(cell))
		to_chat(ipc, span_warning("You plug into the APC, but nothing happens! It seems you don't have a cell to charge!"))
		return

	if(target_apc.cell && target_apc.cell.percent() < SYNTH_APC_MINIMUM_PERCENT)
		to_chat(user, span_warning("There is no charge to draw from that APC."))
		return

	if(ipc.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
		to_chat(user, span_warning("You are already fully charged!"))
		return

	powerdraw_loop(target_apc, ipc)

/**
 * Runs a loop to charge a synth cell (stomach) via powercord from an APC.
 *
 * Stops when:
 * - The user is full.
 * - The APC has less than 20% charge.
 * - The APC has machine power turned off.
 * - The APC is unable to provide charge for any other reason.
 * - The user moves, or anything else that can happen to interrupt a do_after.
 *
 * Arguments:
 * * target_apc - The APC to drain.
 * * user - The carbon draining the APC.
 */
/obj/item/apc_powercord/proc/powerdraw_loop(obj/machinery/power/apc/target_apc, mob/living/carbon/human/user)
	user.visible_message(span_notice("[user] inserts a power connector into the [target_apc]."), span_notice("You begin to draw power from the [target_apc]."))

	while(TRUE)
		var/power_needed = NUTRITION_LEVEL_ALMOST_FULL - user.nutrition // How much charge do we need in total?
		// Do we even need anything?
		if(power_needed <= SYNTH_CHARGE_MIN * 2) // Times two to make sure minimum draw is always lower than this margin to prevent potential needless loops.
			to_chat(user, span_notice("You are fully charged."))
			break

		// Is the APC not charging equipment? And yes, synths are gonna be treated as equipment. Deal with it.
		if(target_apc.cell.percent() < SYNTH_APC_MINIMUM_PERCENT) // 20%, to prevent synths from overstepping and murdering power for department machines and potentially doors.
			to_chat(user, span_warning("[target_apc]'s power is too low to charge you."))
			break

		// Calculate how much to draw this cycle
		var/power_use = clamp(power_needed, SYNTH_CHARGE_MIN, SYNTH_CHARGE_MAX)
		power_use = clamp(power_use, 0, target_apc.cell.charge)
		// Are we able to draw anything?
		if(power_use <= 0)
			to_chat(user, span_warning("[target_apc] lacks the power to charge you."))
			break

		// Calculate the delay.
		var/power_delay = (power_use / 100) * SYNTH_CHARGE_DELAY_PER_100
		// Attempt to run a charging cycle.
		if(!do_after(user, power_delay, target = target_apc))
			break

		// Use the power and increase nutrition.
		target_apc.cell.use(power_use)

		user.nutrition += power_use / SYNTH_CHARGE_PER_NUTRITION
		do_sparks(1, FALSE, target_apc)

	if(target_apc.main_status <= APC_HAS_POWER)
		target_apc.charging = APC_CHARGING
		target_apc.update_appearance()
	else
		return
	user.visible_message(span_notice("[user] unplugs from the [target_apc]."), span_notice("You unplug from the [target_apc]."))

#undef SYNTH_CHARGE_MAX
#undef SYNTH_CHARGE_MIN
#undef SYNTH_CHARGE_PER_NUTRITION
#undef SYNTH_CHARGE_DELAY_PER_100

/**
 * Global timer proc used in defib.dm. Removes the temporary trauma caused by being defibbed as a synth.
 *
 * Args:
 * * obj/item/organ/internal/brain/synth_brain: The brain with the trauma on it. Non-nullable.
 * * datum/brain_trauma/trauma: The trauma itself. Non-nullable.
 */
/proc/remove_synth_defib_trauma(obj/item/organ/internal/brain/synth_brain, datum/brain_trauma/trauma)
	if (QDELETED(synth_brain) || QDELETED(trauma))
		return

	QDEL_NULL(trauma)
