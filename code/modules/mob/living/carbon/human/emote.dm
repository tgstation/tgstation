/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "gives daps to %t."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."

/datum/emote/living/carbon/human/glasses
	key = "glasses"
	key_third_person = "glasses"
	message = "pushes up their glasses."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/glasses/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	var/obj/eyes_slot = user.get_item_by_slot(ITEM_SLOT_EYES)
	if(istype(eyes_slot, /obj/item/clothing/glasses/regular) || istype(eyes_slot, /obj/item/clothing/glasses/sunglasses))
		return ..()
	return FALSE

/datum/emote/living/carbon/human/glasses/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/image/emote_animation = image('icons/mob/human/emote_visuals.dmi', user, "glasses")
	flick_overlay_global(emote_animation, GLOB.clients, 1.6 SECONDS)

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles!"
	message_mime = "grumbles silently!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hands."
	message_param = "shakes hands with %t."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself."
	message_param = "hugs %t."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	message_mime = "mumbles silently!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/screech // basically scream 2.0
	key = "screech"
	key_third_person = "screeches"
	message = "screeches!"
	message_mime = "screeches silently."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	manual_specific_emote_audio_cooldown = 10 SECONDS
	vary = FALSE

/datum/emote/living/carbon/human/screech/get_sound(mob/living/carbon/human/user)
	var/datum/emote/scream_emote = GLOB.emote_list[/datum/emote/living/scream::key][1]
	return scream_emote.get_sound(user)

/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second."

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS
	sound = 'sound/mobs/humanoids/human/salute/salute.ogg'

/datum/emote/living/carbon/human/slit
	key = "slit"
	key_third_person = "slits"
	message = "drags a finger across their neck."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/scratch_h
	key = "scratch_h"
	message = "scratches their head."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/thumb_up
	key = "thumb_u"
	message = "gives a thumbs up."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/thumb_down
	key = "thumb_d"
	message = "gives a thumbs down."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/time
	key = "time"
	message = "checks the time."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/tap
	key = "tap"
	key_third_person = "taps"
	message = "taps their foot impatiently."

/datum/emote/living/carbon/human/halt
	key = "halt"
	key_third_person = "halts"
	message = "holds up their palm, signaling to stop."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/shush
	key = "shush"
	key_third_person = "shushes"
	message = "holds a finger to their lips."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/listen
	key = "listen"
	key_third_person = "listens"
	message = "cups a hand to their ear."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/think
	key = "think"
	key_third_person = "thinks"
	message = "taps their head, thinking."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/beckon
	key = "beckon"
	key_third_person = "beckons"
	message = "waves a hand for someone to come closer."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/airquote
	key = "airquote"
	key_third_person = "airquotes"
	message = "makes air quotes."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/crazy
	key = "crazy"
	message = "twirls a finger next to their head."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/squint
	key = "squint"
	key_third_person = "squints"
	message = "squints."

/datum/emote/living/carbon/human/rub
	key = "rub"
	key_third_person = "rubs"
	message = "rubs their chin."
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "wags"

/datum/emote/living/carbon/human/wag/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/item/organ/tail/oranges_accessory = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	//I am so sorry my son
	//We bypass helpers here cause we already have the tail
	if(oranges_accessory.wag_flags & WAG_WAGGING) //We verified the tail exists in can_run_emote()
		oranges_accessory.stop_wag(user)
	else
		oranges_accessory.start_wag(user)

/datum/emote/living/carbon/human/wag/select_message_type(mob/user, intentional)
	. = ..()
	var/obj/item/organ/tail/oranges_accessory = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(oranges_accessory.wag_flags & WAG_WAGGING)
		. = "stops wagging"
	. += " [user.p_their()] tail."

/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check, intentional, params)
	var/obj/item/organ/tail/tail = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(tail?.wag_flags & WAG_ABLE)
		return ..()
	return FALSE

/datum/emote/living/carbon/human/wing
	key = "wing"
	key_third_person = "wings"
	message = "their wings."

/datum/emote/living/carbon/human/wing/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/item/organ/wings/wings = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(isnull(wings))
		CRASH("[type] ran on a mob that has no wings!")
	if(wings.wings_open)
		wings.close_wings()
	else
		wings.open_wings()

/datum/emote/living/carbon/human/wing/select_message_type(mob/user, intentional)
	var/obj/item/organ/wings/wings = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	var/emote_verb = wings.wings_open ? "closes" : "opens"
	return "[emote_verb] [message]"

/datum/emote/living/carbon/human/wing/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	var/obj/item/organ/wings/wings = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(!istype(wings) || !wings.has_open_sprite)
		return FALSE
	return ..()

/datum/emote/living/carbon/human/clear_throat
	key = "clear"
	key_third_person = "clears throat"
	message = "clears their throat."

/datum/emote/living/carbon/human/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks."

/datum/emote/living/carbon/human/blink/can_run_emote(mob/living/carbon/human/user, status_check, intentional, params)
	if (!ishuman(user) || HAS_TRAIT(user, TRAIT_PREVENT_BLINKING) || HAS_TRAIT(user, TRAIT_NO_EYELIDS))
		return FALSE
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	if (!eyes)
		return FALSE
	return ..()

/datum/emote/living/carbon/human/blink/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	eyes.blink()

/datum/emote/living/carbon/human/blink_r
	key = "blink_r"
	name = "blink (Rapid)"
	message = "blinks rapidly."

/datum/emote/living/carbon/human/blink_r/can_run_emote(mob/living/carbon/human/user, status_check, intentional, params)
	if (!ishuman(user) || HAS_TRAIT(user, TRAIT_PREVENT_BLINKING) || HAS_TRAIT(user, TRAIT_NO_EYELIDS))
		return FALSE
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	if (!eyes)
		return FALSE
	return ..()

/datum/emote/living/carbon/human/blink_r/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	for (var/i in 1 to 3)
		addtimer(CALLBACK(eyes, TYPE_PROC_REF(/obj/item/organ/eyes, blink), 0.1 SECONDS, FALSE), i * 0.2 SECONDS)
	eyes.animate_eyelids(user)

/datum/emote/living/carbon/human/screech/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars!"
	message_mime = "acts out a roar."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/// emotes for glowy goobers
/datum/emote/living/carbon/human/glow
	key = "glow"
	key_third_person = "glows"
	message = "glows brightly!"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/glow/can_run_emote(mob/living/carbon/human/user, status_check = TRUE, intentional, params)
	if(!user.has_status_effect(/datum/status_effect/grouped/bodypart_effect/ethereal_glow))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/glow/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	var/datum/status_effect/grouped/bodypart_effect/ethereal_glow/glow = user.has_status_effect(/datum/status_effect/grouped/bodypart_effect/ethereal_glow)
	glow.handle_glow_emote(1.75, 1.2)

/datum/emote/living/carbon/human/flare
	key = "flare"
	key_third_person = "flares"
	message = "flares up to a dazzling intensity!"
	emote_type = EMOTE_VISIBLE
	sound = 'sound/mobs/humanoids/ethereal/ethereal_hiss.ogg'

/datum/emote/living/carbon/human/flare/can_run_emote(mob/living/carbon/human/user, status_check = TRUE, intentional, params)
	if(!user.has_status_effect(/datum/status_effect/grouped/bodypart_effect/ethereal_glow))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/flare/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	var/datum/status_effect/grouped/bodypart_effect/ethereal_glow/glow = user.has_status_effect(/datum/status_effect/grouped/bodypart_effect/ethereal_glow)
	glow.handle_glow_emote(12, 6, flare = TRUE, duration = 2 SECONDS, flare_time = 10 SECONDS)

/datum/emote/living/carbon/human/flicker
	key = "flicker"
	key_third_person = "flicker"
	message = "flickers."
	emote_type = EMOTE_VISIBLE
	sound = 'sound/effects/sparks/sparks4.ogg'

/datum/emote/living/carbon/human/flicker/can_run_emote(mob/living/carbon/human/user, status_check = TRUE , intentional, params)
	if(!user.has_status_effect(/datum/status_effect/grouped/bodypart_effect/ethereal_glow))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/flicker/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	var/datum/status_effect/grouped/bodypart_effect/ethereal_glow/glow = user.has_status_effect(/datum/status_effect/grouped/bodypart_effect/ethereal_glow)
	glow.start_flicker()
