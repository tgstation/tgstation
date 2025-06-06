//works similar to the experiment machine (experiment.dm) except it just holds more and more prisoners

/obj/machinery/fugitive_capture
	name = "bluespace capture machine"
	desc = "Much, MUCH bigger on the inside to transport prisoners safely."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "bluespace-prison"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //ha ha no getting out!!
	interaction_flags_mouse_drop = NEED_DEXTERITY

/obj/machinery/fugitive_capture/examine(mob/user)
	. = ..()
	. += span_notice("Add a prisoner by dragging them into the machine.")

/obj/machinery/fugitive_capture/mouse_drop_receive(mob/target, mob/user, params)
	var/mob/living/fugitive_hunter = user
	if(!isliving(fugitive_hunter) || !ishuman(target))
		return
	var/mob/living/carbon/human/fugitive = target
	var/datum/antagonist/fugitive/fug_antag = fugitive.mind.has_antag_datum(/datum/antagonist/fugitive)
	if(!fug_antag)
		to_chat(fugitive_hunter, span_warning("This is not a wanted fugitive!"))
		return
	if(do_after(fugitive_hunter, 5 SECONDS, target = fugitive))
		add_prisoner(fugitive, fug_antag)

/obj/machinery/fugitive_capture/proc/add_prisoner(mob/living/carbon/human/fugitive, datum/antagonist/fugitive/antag)
	fugitive.forceMove(src)
	antag.is_captured = TRUE
	to_chat(fugitive, span_userdanger("You are thrown into a vast void of bluespace, and as you fall further into oblivion the comparatively small entrance to reality gets smaller and smaller until you cannot see it anymore. You have failed to avoid capture."))
	fugitive.ghostize(TRUE) //so they cannot suicide, round end stuff.
	use_energy(active_power_usage)

/obj/machinery/computer/shuttle/hunter
	name = "shuttle console"
	shuttleId = "huntership"
	possible_destinations = "huntership_home;huntership_custom;whiteship_home;syndicate_nw"
	req_access = list(ACCESS_HUNTER)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/hunter
	name = "shuttle navigation computer"
	desc = "Used to designate a precise transit location to travel to."
	shuttleId = "huntership"
	lock_override = CAMERA_LOCK_STATION
	shuttlePortId = "huntership_custom"
	see_hidden = FALSE
	jump_to_ports = list("huntership_home" = 1, "whiteship_home" = 1, "syndicate_nw" = 1)
	view_range = 4.5

/obj/structure/closet/crate/eva
	name = "EVA crate"
	icon_state = "o2crate"
	base_icon_state = "o2crate"

/obj/structure/closet/crate/eva/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/space/eva(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/helmet/space/eva(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/mask/breath(src)
	for(var/i in 1 to 3)
		new /obj/item/tank/internals/oxygen(src)

///Psyker-friendly shuttle gear!

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/hunter/psyker
	name = "psyker navigation warper"
	desc = "Uses amplified brainwaves to designate and map a precise transit location for the psyker shuttle."
	icon_screen = "recharge_comp_on"
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON //blind friendly
	x_offset = 0
	y_offset = 11

/obj/machinery/fugitive_capture/psyker
	name = "psyker recreation cell"
	desc = "A repurposed recreation chamber frequently used by psykers, which soothes its user by bombarding them with loud noises and painful stimuli. Repurposed for the storage of prisoners, and should have no (lasting) side effects on non-psykers forced into it."

/obj/machinery/fugitive_capture/psyker/process() //I have no fucking idea how to make click-dragging work for psykers so this one just sucks them in.
	for(var/mob/living/carbon/human/potential_victim in range(1, get_turf(src)))
		var/datum/antagonist/fugitive/fug_antag = potential_victim.mind.has_antag_datum(/datum/antagonist/fugitive)
		if(fug_antag)
			potential_victim.visible_message(span_alert("[potential_victim] is violently sucked into the [src]!"))
			add_prisoner(potential_victim, fug_antag)

/// Psyker gear
/obj/item/reagent_containers/hypospray/medipen/gore
	name = "gore autoinjector"
	desc = "A ghetto-looking autoinjector filled with gore, aka dirty kronkaine. You probably shouldn't take this while on the job, but it is a super-stimulant. Don't take two at once."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/drug/kronkaine/gore = 15)
	icon_state = "maintenance"
	base_icon_state = "maintenance"
	label_examine = FALSE

//Captain's special mental recharge gear

/obj/item/clothing/suit/armor/reactive/psykerboost
	name = "reactive psykerboost armor"
	desc = "An experimental suit of armor psykers use to push their mind further. Reacts to hostiles by powering up the wearer's psychic abilities."
	cooldown_message = span_danger("The psykerboost armor's mental coils are still cooling down!")
	emp_message = span_danger("The psykerboost armor's mental coils recalibrate for a moment with a soft whine.")
	color = "#d6ad8b"

/obj/item/clothing/suit/armor/reactive/psykerboost/cooldown_activation(mob/living/carbon/human/owner)
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	return ..()

/obj/item/clothing/suit/armor/reactive/psykerboost/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], psykerboosting [owner]'s mental powers!"))
	for(var/datum/action/cooldown/spell/psychic_ability in owner.actions)
		if(psychic_ability.school == SCHOOL_PSYCHIC)
			psychic_ability.reset_spell_cooldown()
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/psykerboost/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], draining [owner]'s mental powers!"))
	for(var/datum/action/cooldown/spell/psychic_ability in owner.actions)
		if(psychic_ability.school == SCHOOL_PSYCHIC)
			psychic_ability.StartCooldown()
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/structure/bouncy_castle
	name = "bouncy castle"
	desc = "And if you do drugs, you go to hell before you die. Please."
	icon = 'icons/obj/toys/bouncy_castle.dmi'
	icon_state = "bouncy_castle"
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER

/obj/structure/bouncy_castle/Initialize(mapload, mob/gored)
	. = ..()
	if(gored)
		name = gored.real_name

	AddComponent(
		/datum/component/blood_walk,\
		blood_type = /obj/effect/decal/cleanable/blood,\
		blood_spawn_chance = 66.6,\
		max_blood = INFINITY,\
	)

	AddComponent(/datum/component/bloody_spreader)

/obj/structure/bouncy_castle/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/blob/attackblob.ogg', 50, TRUE)
			else
				playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/item/paper/crumpled/fluff/fortune_teller
	name = "scribbled note"
	default_raw_text = "<b>Remember!</b> The customers love that gumball we have as a crystal ball. \
		Even if it's completely useless to us, resist the urge to chew it."

/**
 * # Bounty Locator
 *
 * Locates a random, living fugitive and reports their name/location on a 40 second cooldown.
 *
 * Locates a random fugitive antagonist via the GLOB.antagonists list, and reads out their real name and area name.
 * Captured or dead fugitives are not reported.
 */
/obj/machinery/fugitive_locator
	name = "Bounty Locator"
	desc = "Tracks the signatures of bounty targets in your sector. Nobody actually knows what mechanism this thing uses to track its targets. \
		Whether it be bluespace entanglement or a simple RFID implant, this machine will find you who you're looking for no matter where they're hiding."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator-Purple"
	density = TRUE
	/// Cooldown on locating a fugitive.
	COOLDOWN_DECLARE(locate_cooldown)

/obj/machinery/fugitive_locator/interact(mob/user)
	if(!COOLDOWN_FINISHED(src, locate_cooldown))
		balloon_alert_to_viewers("locator recharging!", vision_distance = 3)
		return
	var/mob/living/bounty = locate_fugitive()
	if(!bounty)
		say("No bounty targets detected.")
	else
		say("Bounty Target Located. Bounty ID: [bounty.real_name]. Location: [get_area_name(bounty)]")

	COOLDOWN_START(src, locate_cooldown, 40 SECONDS)

///Locates a random fugitive via their antag datum and returns them.
/obj/machinery/fugitive_locator/proc/locate_fugitive()
	var/list/datum_list = shuffle(GLOB.antagonists)
	for(var/datum/antagonist/fugitive/fugitive_datum in datum_list)
		if(!fugitive_datum.owner)
			stack_trace("Fugitive locator tried to locate a fugitive antag datum with no owner.")
			continue
		if(fugitive_datum.is_captured)
			continue
		var/mob/living/found_fugitive = fugitive_datum.owner.current
		if(found_fugitive.stat == DEAD)
			continue

		return found_fugitive

/obj/item/radio/headset/psyker
	name = "psychic headset"
	desc = "A headset designed to boost psychic waves. Protects ears from flashbangs."
	icon_state = "psyker_headset"
	worn_icon_state = "syndie_headset"

/obj/item/radio/headset/psyker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/psyker/equipped(mob/living/user, slot)
	. = ..()
	if(slot_flags & slot)
		ADD_CLOTHING_TRAIT(user, TRAIT_ECHOLOCATION_EXTRA_RANGE)

/obj/item/radio/headset/psyker/dropped(mob/user, silent)
	. = ..()
	REMOVE_CLOTHING_TRAIT(user, TRAIT_ECHOLOCATION_EXTRA_RANGE)
