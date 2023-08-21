/datum/species/ipc
	name = "\improper Integrated Positronic Chassis"
	id = SPECIES_IPC
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	sexes = FALSE

	species_traits = list(
		NO_DNA_COPY,
		EYECOLOR,
		LIPS,
		HAIR,
		NOEYESPRITES,
		NOTRANSSTING,
		NOHUSK
	)

	inherent_traits = list(
		TRAIT_ROBOT_CAN_BLEED,
		TRAIT_CAN_STRIP,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOBREATH,
		TRAIT_TOXIMMUNE,
		TRAIT_NOCLONELOSS,
		TRAIT_GENELESS,
		TRAIT_STABLEHEART,
		TRAIT_LIMBATTACHMENT,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_EASYDISMEMBER,
	)

	inherent_biotypes = MOB_ROBOTIC | MOB_HUMANOID
	mutantbrain = /obj/item/organ/internal/brain/positron
	mutanteyes = /obj/item/organ/internal/eyes/robotic
	mutanttongue = /obj/item/organ/internal/tongue/robot
	mutantliver = /obj/item/organ/internal/liver/cybernetic/upgraded/ipc
	mutantbutt = /obj/item/organ/internal/butt/cyber //MonkeStation Edit
	mutantstomach = /obj/item/organ/internal/stomach/ethereal/battery/ipc
	mutantears = /obj/item/organ/internal/ears/robot
	mutantheart = /obj/item/organ/internal/heart/cybernetic/ipc

	mutant_organs = list(
		/obj/item/organ/internal/cyberimp/arm/power_cord,
		)
	external_organs = list(
		/obj/item/organ/external/antennae/ipc = "None"
	)

	mutant_bodyparts = list("ipc_screen", "ipc_chassis")
	meat = /obj/item/stack/sheet/plasteel{amount = 5}
	skinned_type = /obj/item/stack/sheet/iron{amount = 10}
	exotic_blood = /datum/reagent/fuel/oil
	burnmod = 1.5	//Default was 2 //Monkestation Edit
	heatmod = 1.5
	brutemod = 1
	stunmod = 0.8
	siemens_coeff = 1.5
	species_gibs = GIB_TYPE_ROBOTIC
	reagent_tag = PROCESS_SYNTHETIC
	//attack_sound = 'sound/items/trayhit1.ogg'
	//deathsound = "sound/voice/borg_deathsound.ogg"
	species_language_holder = /datum/language_holder/synthetic
	special_step_sounds = list('sound/effects/servostep.ogg')

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ipc,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ipc,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ipc,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ipc,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ipc,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ipc,
	)


	var/saved_screen //for saving the screen when they die
	var/datum/action/innate/change_screen/change_screen

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
	var /obj/item/organ/internal/appendix/A = C.get_organ_slot("appendix") //See below.
	if(A)
		A.Remove(C)
		QDEL_NULL(A)
	var /obj/item/organ/internal/lungs/L = C.get_organ_slot("lungs") //Hacky and bad. Will be rewritten entirely in KapuCarbons anyway.
	if(L)
		L.Remove(C)
		QDEL_NULL(L)
	if(ishuman(C) && !change_screen)
		change_screen = new
		change_screen.Grant(C)


/datum/species/ipc/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(change_screen)
		change_screen.Remove(C)

/datum/species/ipc/proc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT //beep

/datum/species/ipc/spec_death(gibbed, mob/living/carbon/C)
	saved_screen = C.dna.features["ipc_screen"]
	C.dna.features["ipc_screen"] = "BSOD"
	C.update_body()
	addtimer(CALLBACK(src, PROC_REF(post_death), C), 5 SECONDS)

/datum/species/ipc/proc/post_death(mob/living/carbon/C)
	if(C.stat < DEAD)
		return
	C.dna.features["ipc_screen"] = null //Turns off screen on death
	C.update_body()

/datum/action/innate/change_screen
	name = "Change Display"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/change_screen/Activate()
	var/screen_choice = input(usr, "Which screen do you want to use?", "Screen Change") as null | anything in GLOB.ipc_screens_list
	if(!screen_choice)
		return
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.dna.features["ipc_screen"] = screen_choice
	H.update_body()

/obj/item/apc_powercord
	name = "power cord"
	desc = "An internal power cord hooked up to a battery. Useful if you run on electricity. Not so much otherwise."
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"

/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if((!istype(target, /obj/machinery/power/apc) && !isethereal(target)) || !ishuman(user) || !proximity_flag)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/carbon/human/H = user
	var /obj/item/organ/internal/stomach/ethereal/battery/battery = H.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!battery)
		to_chat(H, "<span class='warning'>You try to siphon energy from \the [target], but your power cell is gone!</span>")
		return

	if(istype(H) && H.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
		to_chat(user, "<span class='warning'>You are already fully charged!</span>")
		return

	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.cell && A.cell.charge > A.cell.maxcharge/4)
			powerdraw_loop(A, H, TRUE)
			return
		else
			to_chat(user, "<span class='warning'>There is not enough charge to draw from that APC.</span>")
			return

	if(isethereal(target))
		var/mob/living/carbon/human/target_ethereal = target
		var /obj/item/organ/internal/stomach/ethereal/battery/target_battery = target_ethereal.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(target_ethereal.nutrition > 0 && target_battery)
			powerdraw_loop(target_battery, H, FALSE)
			return
		else
			to_chat(user, "<span class='warning'>There is not enough charge to draw from that being!</span>")
			return
/obj/item/apc_powercord/proc/powerdraw_loop(atom/target, mob/living/carbon/human/H, apc_target)
	H.visible_message("<span class='notice'>[H] inserts a power connector into [target].</span>", "<span class='notice'>You begin to draw power from the [target].</span>")
	var/obj/item/organ/internal/stomach/ethereal/battery/battery = H.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(apc_target)
		var/obj/machinery/power/apc/A = target
		if(!istype(A))
			return
		while(do_after(H, 10, target = A))
			if(!battery)
				to_chat(H, "<span class='warning'>You need a battery to recharge!</span>")
				break
			if(loc != H)
				to_chat(H, "<span class='warning'>You must keep your connector out while charging!</span>")
				break
			if(A.cell.charge <= A.cell.maxcharge/4)
				to_chat(H, "<span class='warning'>The [A] doesn't have enough charge to spare.</span>")
				break
			A.charging = 1
			if(A.cell.charge > A.cell.maxcharge/4 + 250)
				battery.adjust_charge(250)
				A.cell.charge -= 250
				to_chat(H, "<span class='notice'>You siphon off some of the stored charge for your own use.</span>")
			else
				battery.adjust_charge(A.cell.charge - A.cell.maxcharge/4)
				A.cell.charge = A.cell.maxcharge/4
				to_chat(H, "<span class='notice'>You siphon off as much as the [A] can spare.</span>")
				break
			if(battery.crystal_charge >= ETHEREAL_CHARGE_FULL)
				to_chat(H, "<span class='notice'>You are now fully charged.</span>")
				break
	else
		var /obj/item/organ/internal/stomach/ethereal/battery/A = target
		if(!istype(A))
			return
		var/charge_amt
		while(do_after(H, 10, target = A.owner))
			if(!battery)
				to_chat(H, "<span class='warning'>You need a battery to recharge!</span>")
				break
			if(loc != H)
				to_chat(H, "<span class='warning'>You must keep your connector out while charging!</span>")
				break
			if(A.crystal_charge == 0)
				to_chat(H, "<span class='warning'>[A] is completely drained!</span>")
				break
			charge_amt = A.crystal_charge <= 50 ? A.crystal_charge : 50
			A.adjust_charge(-1 * charge_amt)
			battery.adjust_charge(charge_amt)
			if(battery.crystal_charge >= ETHEREAL_CHARGE_FULL)
				to_chat(H, "<span class='notice'>You are now fully charged.</span>")
				break

	H.visible_message("<span class='notice'>[H] unplugs from the [target].</span>", "<span class='notice'>You unplug from the [target].</span>")
	return

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
	H.dna.features["ipc_screen"] = saved_screen
	H.update_body()
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
