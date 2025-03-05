#define HACKERMAN_DECK_TEMPERATURE_INCREASE 450
#define HACKERMAN_DECK_EMP_TEMPERATURE_INCREASE 2250

#define HACKING_FORENSICS_SUCCESS_MESSAGE "Damages reported by the internal diagnostics system suggest a digital attack by a wireless hacking implant."

// An implant that injects you with twitch on demand, acting like a bootleg sandevistan

/obj/item/organ/cyberimp/sensory_enhancer
	name = "\improper Qani-Laaca sensory computer"
	desc = "An experimental implant replacing the spine of organics. When activated, it can give a temporary boost to mental processing speed, \
		Which many users percieve as a slowing of time and quickening of their ability to act. Due to its nature, it is incompatible with \
		systems that heavily influence the user's nervous system, like the central nervous system rebooter."
	icon = 'modular_doppler/cool_implants/icons/implants.dmi'
	icon_state = "sandy"
	slot = ORGAN_SLOT_BRAIN_CNS
	zone = BODY_ZONE_HEAD
	actions_types = list(
		/datum/action/cooldown/sensory_enhancer,
		/datum/action/cooldown/sensory_enhancer/overcharge,
	)
	w_class = WEIGHT_CLASS_SMALL
	/// The bodypart overlay datum we should apply to whatever mob we are put into
	var/datum/bodypart_overlay/simple/sensory_enhancer/da_bodypart_overlay

/obj/item/organ/cyberimp/sensory_enhancer/proc/vomit_blood()
	owner.spray_blood(owner.dir, 2)
	owner.emote("cough")
	owner.visible_message(
		span_danger("[owner] suddenly coughs up a mouthful of blood, clutching at their chest!"),
		span_danger("You feel your chest seize up, a worrying amount of blood flying out of your mouth as you cough uncontrollably.")
	)

/obj/item/organ/cyberimp/sensory_enhancer/on_bodypart_insert(obj/item/bodypart/limb, movement_flags)
	da_bodypart_overlay = new()
	limb.add_bodypart_overlay(da_bodypart_overlay)
	owner.update_body_parts()
	return ..()

/obj/item/organ/cyberimp/sensory_enhancer/on_bodypart_remove(obj/item/bodypart/limb, movement_flags)
	limb.remove_bodypart_overlay(da_bodypart_overlay)
	QDEL_NULL(da_bodypart_overlay)
	owner?.update_body_parts()
	return ..()

/obj/item/autosurgeon/syndicate/sandy
	name = "\improper Qani-Laaca sensory computer autosurgeon"
	starting_organ = /obj/item/organ/cyberimp/sensory_enhancer

/datum/bodypart_overlay/simple/sensory_enhancer
	icon = 'modular_doppler/cool_implants/icons/implants_onmob.dmi'
	icon_state = "sandy"
	layers = EXTERNAL_ADJACENT

/datum/action/cooldown/sensory_enhancer
	name = "Activate Qani-Laaca System"
	desc = "Activates your Qani-Laaca computer and grants you its powers. This will give you a 'safe' dose."
	button_icon = 'modular_doppler/cool_implants/icons/implants.dmi'
	button_icon_state = "sandy"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 5 MINUTES
	text_cooldown = TRUE
	// This makes it so both the regular and overcharge versions of the abilities share a cooldown
	shared_cooldown = MOB_SHARED_COOLDOWN_3
	/// Keeps track of how much twitch we inject into people on activation
	var/injection_amount = 10

/datum/action/cooldown/sensory_enhancer/Activate(atom/target)
	. = ..()

	var/mob/living/carbon/human/human_owner = owner

	owner.log_message("triggered their qani-laaca implant in [(injection_amount > 10) ? "overdose" : "normal"] mode", LOG_ATTACK)

	human_owner.reagents.add_reagent(/datum/reagent/drug/twitch, injection_amount)

	owner.visible_message(span_danger("[owner.name] jolts suddenly as two small glass vials are fired from ports in the implant on their spine, shattering as they land."), \
			span_userdanger("You jolt suddenly as your Qani-Laaca system ejects two empty glass vials rearward, shattering as they land."))
	playsound(human_owner, 'sound/items/hypospray.ogg', 50, TRUE)

	var/obj/item/telegraph_vial = new /obj/item/qani_laaca_telegraph(get_turf(owner))
	var/turf/turf_we_throw_at = get_step(owner, REVERSE_DIR(owner.dir))
	telegraph_vial.throw_at(turf_we_throw_at, 1, 3, gentle = FALSE, quickstart = TRUE)

/obj/item/qani_laaca_telegraph
	name = "spent Qani-Laaca cartridge"
	desc = "A small glass vial, usually kept in a large stack inside a Qani-Laaca implant, that is broken open and ejected \
		each time the implant is used. If you're looking at one long enough to think about it this long, you either have fast eyes \
		or were lucky enough to catch one before it broke."
	icon = 'icons/obj/medical/drugs.dmi'
	icon_state = "blastoff_ampoule_empty"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/qani_laaca_telegraph/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/can_shatter, /obj/effect/decal/cleanable/glass, 1, SFX_SHATTER)
	transform = transform.Scale(0.75, 0.75)

/datum/action/cooldown/sensory_enhancer/overcharge
	name = "Overcharge Qani-Laaca System"
	desc = "Activates your Qani-Laaca computer and grants you its powers. This will overdose you on the computer's effects, giving you \
		more powerful abilities at cost of your well-being."
	button_icon_state = "sandy_overcharge"
	injection_amount = 20

/obj/item/organ/cyberimp/sensory_enhancer/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/mob/living/carbon/human/human_owner = owner

	to_chat(owner, span_warning("Sensory overload! Your body can't handle this much neural input!"))

	human_owner.Knockdown(6 SECONDS)
	human_owner.Stun(4 SECONDS)
	human_owner.do_jitter_animation(18 SECONDS)
	human_owner.blood_volume -= 90
	addtimer(CALLBACK(src, PROC_REF(vomit_blood)), 3 SECONDS)

// Makes you interact with things really quick. Incompatible with sandevistan

/obj/item/organ/cyberimp/interaction_speeder
	name = "\improper Hogelun micromanipulator computer"
	desc = "A powerful neural computer interface that allows significantly faster processing of actions, and \
		sending nervous instructions to the fingers to do those actions at a similar speed. Finally, you can \
		work your hands as fast you think of things to do with them."
	icon = 'modular_doppler/cool_implants/icons/implants.dmi'
	icon_state = "hackerman_two"
	slot = ORGAN_SLOT_BRAIN_CNS
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_SMALL
	/// The bodypart overlay datum we should apply to whatever mob we are put into
	var/datum/bodypart_overlay/simple/hackerman/da_bodypart_overlay

/datum/actionspeed_modifier/micromanipulator
	multiplicative_slowdown = -0.5

/obj/item/organ/cyberimp/interaction_speeder/on_bodypart_insert(obj/item/bodypart/limb, movement_flags)
	da_bodypart_overlay = new()
	limb.add_bodypart_overlay(da_bodypart_overlay)
	owner.update_body_parts()
	ADD_TRAIT(owner, TRAIT_STIMULATED, IMPLANT_TRAIT)
	ADD_TRAIT(owner, TRAIT_STIMMED, IMPLANT_TRAIT)
	ADD_TRAIT(owner, TRAIT_CATLIKE_GRACE, IMPLANT_TRAIT)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/micromanipulator)
	return ..()

/obj/item/organ/cyberimp/interaction_speeder/on_bodypart_remove(obj/item/bodypart/limb, movement_flags)
	limb.remove_bodypart_overlay(da_bodypart_overlay)
	QDEL_NULL(da_bodypart_overlay)
	owner?.update_body_parts()
	return ..()

/obj/item/organ/cyberimp/interaction_speeder/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	if(organ_owner)
		REMOVE_TRAIT(organ_owner, TRAIT_STIMULATED, IMPLANT_TRAIT)
		REMOVE_TRAIT(organ_owner, TRAIT_STIMMED, IMPLANT_TRAIT)
		REMOVE_TRAIT(organ_owner, TRAIT_CATLIKE_GRACE, IMPLANT_TRAIT)
		organ_owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/micromanipulator)
	return ..()

/obj/item/organ/cyberimp/interaction_speeder/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/mob/living/carbon/human/human_owner = owner

	to_chat(owner, span_warning("You feel an awful buzzing in the back of your head as your Hogelun implant goes into overdrive! You can't keep up!"))

	human_owner.Knockdown(6 SECONDS)
	human_owner.Stun(4 SECONDS)
	human_owner.do_jitter_animation(18 SECONDS)
	human_owner.apply_status_effect(/datum/status_effect/seizure)

/datum/bodypart_overlay/simple/hackerman
	icon = 'modular_doppler/cool_implants/icons/implants_onmob.dmi'
	icon_state = "hackerman"
	layers = EXTERNAL_ADJACENT

/obj/item/autosurgeon/syndicate/hackerman
	name = "\improper Hogelun micromanipulator computer autosurgeon"
	starting_organ = /obj/item/organ/cyberimp/interaction_speeder

// Finally, aimbot

/obj/item/organ/cyberimp/trickshotter
	name = "\improper RICOCHOT 9000 combat computer"
	desc = "A neural computer with terrible branding, allowing the user to perform precise ballistic calculations \
		in real time. Doesn't do too much to improve hand-eye coordination of course, but it can make you a pretty nice shot."
	icon = 'modular_doppler/cool_implants/icons/implants.dmi'
	icon_state = "hackerman_three"
	slot = ORGAN_SLOT_BRAIN_CNS
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_SMALL
	/// The bodypart overlay datum we should apply to whatever mob we are put into
	var/datum/bodypart_overlay/simple/hackerman/da_bodypart_overlay

/obj/item/organ/cyberimp/trickshotter/on_bodypart_insert(obj/item/bodypart/limb, movement_flags)
	da_bodypart_overlay = new()
	limb.add_bodypart_overlay(da_bodypart_overlay)
	owner.update_body_parts()
	ADD_TRAIT(owner, TRAIT_NICE_SHOT, IMPLANT_TRAIT)
	ADD_TRAIT(owner, TRAIT_GUNFLIP, IMPLANT_TRAIT)
	ADD_TRAIT(owner, TRAIT_GUN_NATURAL, IMPLANT_TRAIT)
	return ..()

/obj/item/organ/cyberimp/trickshotter/on_bodypart_remove(obj/item/bodypart/limb, movement_flags)
	limb.remove_bodypart_overlay(da_bodypart_overlay)
	QDEL_NULL(da_bodypart_overlay)
	owner?.update_body_parts()
	return ..()

/obj/item/organ/cyberimp/trickshotter/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	if(organ_owner)
		REMOVE_TRAIT(organ_owner, TRAIT_NICE_SHOT, IMPLANT_TRAIT)
		REMOVE_TRAIT(organ_owner, TRAIT_GUNFLIP, IMPLANT_TRAIT)
		REMOVE_TRAIT(organ_owner, TRAIT_GUN_NATURAL, IMPLANT_TRAIT)
	return ..()

/obj/item/organ/cyberimp/trickshotter/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/mob/living/carbon/human/human_owner = owner

	to_chat(owner, span_warning("You feel an awful buzzing in the back of your head as your trickshot implant overloads! You should never have trusted that cheap Marsian webpage!"))

	human_owner.Knockdown(6 SECONDS)
	human_owner.Stun(4 SECONDS)
	human_owner.do_jitter_animation(18 SECONDS)
	human_owner.apply_status_effect(/datum/status_effect/seizure)

/obj/item/autosurgeon/syndicate/trickshot
	name = "\improper RICOCHOT 9000 combat computer autosurgeon"
	starting_organ = /obj/item/organ/cyberimp/trickshotter

#undef HACKERMAN_DECK_TEMPERATURE_INCREASE
#undef HACKERMAN_DECK_EMP_TEMPERATURE_INCREASE
