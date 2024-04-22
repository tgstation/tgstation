/obj/item/organ/internal/brain/synth
	name = "compact positronic brain"
	slot = ORGAN_SLOT_BRAIN
	zone = BODY_ZONE_HEAD
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It has an IPC serial number engraved on the top. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "posibrain-ipc"
	/// The last time (in ticks) a message about brain damage was sent. Don't touch.
	var/last_message_time = 0

/obj/item/organ/internal/brain/synth/on_insert(mob/living/carbon/brain_owner)
	. = ..()

	if(brain_owner.stat != DEAD || !ishuman(brain_owner))
		return

	var/mob/living/carbon/human/user_human = brain_owner
	if(HAS_TRAIT(user_human, TRAIT_REVIVES_BY_HEALING) && user_human.health > SYNTH_BRAIN_WAKE_THRESHOLD)
		user_human.revive(FALSE)

/obj/item/organ/internal/brain/synth/emp_act(severity) // EMP act against the posi, keep the cap far below the organ health
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("01001001 00100111 01101101 00100000 01100110 01110101 01100011 01101011 01100101 01100100 00101110"))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, SYNTH_EMP_BRAIN_DAMAGE_MAXIMUM, required_organtype = ORGAN_ROBOTIC)
		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Electromagnetic damage taken in central processing unit. Error Code: 401-YT"))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, SYNTH_EMP_BRAIN_DAMAGE_MAXIMUM, required_organtype = ORGAN_ROBOTIC)

/obj/item/organ/internal/brain/synth/apply_organ_damage(damage_amount, maximumm, required_organtype)
	. = ..()

	if(owner && damage > 0 && (world.time - last_message_time) > SYNTH_BRAIN_DAMAGE_MESSAGE_INTERVAL)
		last_message_time = world.time

		if(damage > BRAIN_DAMAGE_SEVERE)
			to_chat(owner, span_warning("Alre: re oumtnin ilir tocorr:pa ni ne:cnrrpiioruloomatt cessingode: P1_1-H"))
			return

		if(damage > BRAIN_DAMAGE_MILD)
			to_chat(owner, span_warning("Alert: Minor corruption in central processing unit. Error Code: 001-HP"))

/*
/obj/item/organ/internal/brain/synth/circuit
	name = "compact AI circuit"
	desc = "A compact and extremely complex circuit, perfectly dimensioned to fit in the same slot as a synthetic-compatible positronic brain. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "circuit-occupied"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
*/

/obj/item/organ/internal/brain/synth/mmi
	name = "compact man-machine interface"
	desc = "A compact man-machine interface, perfectly dimensioned to fit in the same slot as a synthetic-compatible positronic brain. Unfortunately, the brain seems to be permanently attached to the circuitry, and it seems relatively sensitive to it's environment. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "mmi-ipc"

/obj/item/organ/internal/ears/synth
	name = "auditory sensors"
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "ears-ipc"
	desc = "A pair of microphones intended to be installed in an IPC or Synthetics head, that grant the ability to hear."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	gender = PLURAL
	maxHealth = 1 * STANDARD_ORGAN_THRESHOLD
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/ears/synth/emp_act(severity)
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			owner.set_jitter_if_lower(SYNTH_BAD_EFFECT_DURATION * SYNTH_HEAVY_EMP_MULTIPLIER)
			owner.set_dizzy_if_lower(SYNTH_BAD_EFFECT_DURATION * SYNTH_HEAVY_EMP_MULTIPLIER)
			adjustEarDamage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, SYNTH_DEAF_STACKS)
			to_chat(owner, span_warning("Alert: Null feedback from auditory sensors detected, seek maintenance immediately. Error Code: AS-105"))

		if(EMP_LIGHT)
			owner.set_jitter_if_lower(SYNTH_BAD_EFFECT_DURATION)
			owner.set_dizzy_if_lower(SYNTH_BAD_EFFECT_DURATION)
			adjustEarDamage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, SYNTH_DEAF_STACKS)
			to_chat(owner, span_warning("Alert: Anomalous feedback from auditory sensors detected. Error Code: AS-50"))

/datum/design/synth_ears
	name = "Auditory Sensors"
	desc = "A pair of microphones intended to be installed in an IPC or Synthetics head, that grant the ability to hear."
	id = "synth_ears"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/ears/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/obj/item/organ/internal/eyes/synth
	name = "optical sensors"
	icon_state = "cybernetic_eyeballs"
	desc = "A very basic set of optical sensors with no extra vision modes or functions."
	maxHealth = 1 * STANDARD_ORGAN_THRESHOLD
	flash_protect = FLASH_PROTECTION_WELDER
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/eyes/synth/emp_act(severity)
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("Alert:Severe electromagnetic interference clouds your optics with static. Error Code: I-CS6"))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)
		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Mild interference clouds your optics with static. Error Code: I-CS0"))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)

/datum/design/synth_eyes
	name = "Optical Sensors"
	desc = "A very basic set of optical sensors with no extra vision modes or functions."
	id = "synth_eyes"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/eyes/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/obj/item/organ/internal/heart/synth
	name = "hydraulic pump engine"
	desc = "An electronic device that handles the hydraulic pumps, powering one's robotic limbs. Without this, synthetics are unable to move."
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "heart-ipc-on"
	base_icon_state = "heart-ipc"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD // 1.5x due to synthcode.tm being weird
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART
	var/last_message_time = 0

/obj/item/organ/internal/heart/synth/emp_act(severity)
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("Alert: Main hydraulic pump control has taken severe damage, seek maintenance immediately. Error code: HP300-10."))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)
		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Main hydraulic pump control has taken light damage, seek maintenance immediately. Error code: HP300-05."))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)

/datum/design/synth_heart
	name = "Hydraulic Pump Engine"
	desc = "An electronic device that handles the hydraulic pumps, powering one's robotic limbs. Without this, synthetics are unable to move."
	id = "synth_heart"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/heart/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/obj/item/organ/internal/liver/synth
	name = "reagent processing unit"
	desc = "An electronic device that processes the beneficial chemicals for the synthetic user."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "liver-ipc"
	filterToxins = FALSE //We dont filter them, we're immune to them
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	maxHealth = 1 * STANDARD_ORGAN_THRESHOLD
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/liver/synth/emp_act(severity)
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("Alert: Critical! Reagent processing unit failure, seek maintenance immediately. Error Code: DR-1k"))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)

		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Reagent processing unit failure, seek maintenance for diagnostic. Error Code: DR-0k"))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)

/datum/design/synth_liver
	name = "Reagent Processing Unit"
	desc = "An electronic device that processes the beneficial chemicals for the synthetic user."
	id = "synth_liver"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/liver/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/obj/item/organ/internal/lungs/synth
	name = "heatsink"
	desc = "A device that transfers generated heat to a fluid medium to cool it down. Required to keep your synthetics cool-headed. It's shape resembles lungs." //Purposefully left the 'fluid medium' ambigious for interpretation of the character, whether it be air or fluid cooling
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "lungs-ipc"
	safe_nitro_min = 0
	safe_co2_max = 0
	safe_plasma_min = 0
	safe_plasma_max = 0
	safe_oxygen_min = 0	//What are you doing man, dont breathe with those!
	safe_oxygen_max = 0
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/lungs/synth/emp_act(severity)
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("Alert: Critical cooling system failure! Seek maintenance immediately. Error Code: 5H-17"))
			owner.adjust_bodytemperature(SYNTH_HEAVY_EMP_TEMPERATURE_POWER * TEMPERATURE_DAMAGE_COEFFICIENT)

		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Major cooling system failure!"))
			owner.adjust_bodytemperature(SYNTH_LIGHT_EMP_TEMPERATURE_POWER * TEMPERATURE_DAMAGE_COEFFICIENT)

/datum/design/synth_heatsink
	name = "Heatsink"
	desc = "A device that transfers generated heat to a fluid medium to cool it down. Required to keep your synthetics cool-headed. It's shape resembles lungs."
	id = "synth_lungs"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/lungs/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

///IPCS NO LONGER ARE PURE ELECTRICAL BEINGS, any attempts to change this outside of Borbop will be denied. Thanks.
/obj/item/organ/internal/stomach/synth
	name = "synthetic bio-reactor"
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "stomach-ipc"
	w_class = WEIGHT_CLASS_NORMAL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	maxHealth = 1 * STANDARD_ORGAN_THRESHOLD
	zone = "chest"
	slot = "stomach"
	desc = "A specialised mini reactor, for synthetic use only. Has a low-power mode to ensure baseline functions. Without this, synthetics are unable to stay powered."
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/stomach/synth/emp_act(severity)
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			owner.nutrition = max(0, owner.nutrition - SYNTH_STOMACH_HEAVY_EMP_CHARGE_LOSS)
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)
			to_chat(owner, span_warning("Alert: Severe battery discharge!"))

		if(EMP_LIGHT)
			owner.nutrition = max(0, owner.nutrition - SYNTH_STOMACH_LIGHT_EMP_CHARGE_LOSS)
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)
			to_chat(owner, span_warning("Alert: Minor battery discharge!"))

/datum/design/synth_stomach
	name = "Synthetic Bio-Reactor"
	desc = "A specialised mini reactor, for synthetic use only. Has a low-power mode to ensure baseline functions. Without this, synthetics are unable to stay powered."
	id = "synth_stomach"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/stomach/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/obj/item/organ/internal/stomach/synth/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	RegisterSignal(receiver, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))

/obj/item/organ/internal/stomach/synth/Remove(mob/living/carbon/stomach_owner, special)
	. = ..()
	UnregisterSignal(stomach_owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)

///Handles charging the synth from borg chargers
/obj/item/organ/internal/stomach/synth/proc/on_borg_charge(datum/source, amount)
	SIGNAL_HANDLER

	if(owner.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
		return

	amount /= 50 // Lowers the charging amount so it isn't instant
	owner.nutrition = min((owner.nutrition + amount), NUTRITION_LEVEL_ALMOST_FULL) // Makes sure we don't make the synth too full, which would apply the overweight slowdown

/obj/item/organ/internal/tongue/synth
	name = "synthetic voicebox"
	desc = "A fully-functional synthetic tongue, encased in soft silicone. Features include high-resolution vocals and taste receptors."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "cybertongue"
	say_mod = "beeps"
	attack_verb_continuous = list("beeps", "boops")
	attack_verb_simple = list("beep", "boop")
	modifies_speech = TRUE
	taste_sensitivity = 25 // not as good as an organic tongue
	maxHealth = 100 //RoboTongue!
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_TONGUE
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/tongue/synth/can_speak_language(language)
	return TRUE

/obj/item/organ/internal/tongue/synth/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/datum/design/synth_tongue
	name = "Synthetic Tongue"
	desc = "A fully-functional synthetic tongue, encased in soft silicone. Features include high-resolution vocals and taste receptors."
	id = "synth_tongue"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/tongue/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE
