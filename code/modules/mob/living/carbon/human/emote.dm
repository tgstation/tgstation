/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "gives daps to %t."
	hands_use_check = TRUE

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
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself."
	message_param = "hugs %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	message_mime = "mumbles silently!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_mime = "acts out a scream!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	specific_emote_audio_cooldown = 10 SECONDS
	vary = TRUE

/datum/emote/living/carbon/human/scream/can_run_emote(mob/user, status_check = TRUE , intentional, params)
	if(!intentional && HAS_TRAIT(user, TRAIT_ANALGESIA))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/scream/get_sound(mob/living/carbon/human/user)
	if(!istype(user))
		return
	return user.dna.species.get_scream_sound(user)

/datum/emote/living/carbon/human/scream/screech //If a human tries to screech it'll just scream.
	key = "screech"
	key_third_person = "screeches"
	message = "screeches!"
	message_mime = "screeches silently."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = FALSE

/datum/emote/living/carbon/human/scream/screech/should_play_sound(mob/user, intentional)
	if(ismonkey(user))
		return TRUE
	return ..()

/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second."

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	hands_use_check = TRUE
	sound = 'sound/mobs/humanoids/human/salute/salute.ogg'

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "their tail."

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
		. = "stops wagging " + message
	else
		. = "wags " + message

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
	var/obj/item/organ/wings/functional/wings = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(isnull(wings))
		CRASH("[type] ran on a mob that has no wings!")
	if(wings.wings_open)
		wings.close_wings()
	else
		wings.open_wings()

/datum/emote/living/carbon/human/wing/select_message_type(mob/user, intentional)
	var/obj/item/organ/wings/functional/wings = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	var/emote_verb = wings.wings_open ? "closes" : "opens"
	return "[emote_verb] [message]"

/datum/emote/living/carbon/human/wing/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	if(!istype(user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS), /obj/item/organ/wings/functional))
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

///Snowflake emotes only for le epic chimp
/datum/emote/living/carbon/human/monkey

/datum/emote/living/carbon/human/monkey/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	if(ismonkey(user))
		return ..()
	return FALSE

/datum/emote/living/carbon/human/monkey/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth..."
	message_mime = "gnarls silently, baring its teeth..."

/datum/emote/living/carbon/human/monkey/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/screech/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars!"
	message_mime = "acts out a roar."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/monkey/tail
	key = "tail"
	message = "waves their tail."

/datum/emote/living/carbon/human/monkey/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	hands_use_check = TRUE

/atom/movable/proc/display_image_in_bubble(image/displayed_image)
	var/mutable_appearance/display_bubble = mutable_appearance(
		'icons/effects/effects.dmi',
		"thought_bubble",
		offset_spokesman = src,
		plane = BALLOON_CHAT_PLANE,
		appearance_flags = KEEP_APART,
	)

	var/mutable_appearance/pointed_atom_appearance = new(displayed_image.appearance)
	pointed_atom_appearance.blend_mode = BLEND_INSET_OVERLAY
	pointed_atom_appearance.plane = FLOAT_PLANE
	pointed_atom_appearance.layer = FLOAT_LAYER
	pointed_atom_appearance.pixel_x = 0
	pointed_atom_appearance.pixel_y = 0
	display_bubble.overlays += pointed_atom_appearance

	display_bubble.pixel_w = 16
	display_bubble.pixel_z = 32
	display_bubble.alpha = 200

	add_overlay(display_bubble)
	LAZYADD(update_overlays_on_z, display_bubble)
	addtimer(CALLBACK(src, PROC_REF(clear_display_bubble), display_bubble), 3 SECONDS)

/atom/movable/proc/clear_display_bubble(mutable_appearance/display_bubble)
	LAZYREMOVE(update_overlays_on_z, display_bubble)
	cut_overlay(display_bubble)

/datum/emote/living/carbon/human/aprilfools
	var/emote_icon = 'icons/mob/human/aprilfools_emotes.dmi'
	var/emote_icon_state = null

	cooldown = 60 SECONDS
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/aprilfools/run_emote(mob/user)
	. = ..()
	var/image/emote_image = image(emote_icon, user, emote_icon_state)
	user.display_image_in_bubble(emote_image)

/datum/emote/living/carbon/human/aprilfools/clueless
	key = "clueless"
	message = "looks clueless."
	emote_icon_state = "clueless"

/datum/emote/living/carbon/human/aprilfools/hmm
	key = "hmm"
	message = "squints their eyes."
	emote_icon_state = "hmm"

/datum/emote/living/carbon/human/aprilfools/troll
	key = "lmao"
	message = "is laughing their ass off!"
	emote_icon_state = "troll"

/datum/emote/living/carbon/human/aprilfools/reallymad
	key = "reallymad"
	message = "looks really mad about something!"
	emote_icon_state = "reallymad"
	sound = 'sound/effects/aprilfools/angry.ogg'

/datum/emote/living/carbon/human/aprilfools/zorp
	key = "zorp"
	message = "feels their impending doom approaching."
	emote_icon_state = "zorp"
	sound = 'sound/effects/aprilfools/bell.ogg'

/datum/emote/living/carbon/human/aprilfools/uncanny
	key = "uncanny"
	message = "looks really uncanny."
	emote_icon_state = "uncanny"
	sound = 'sound/effects/aprilfools/bell.ogg'

/datum/emote/living/carbon/human/aprilfools/xdd
	key = "xdd"
	message = "laughs."
	emote_icon_state = "xdd"

/datum/emote/living/carbon/human/aprilfools/xdd/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	playsound(user, pick('sound/effects/aprilfools/goofylaugh.ogg', 'sound/effects/aprilfools/goofylaugh.ogg', 'sound/effects/aprilfools/goofylaugh.ogg', 'sound/effects/aprilfools/goofylaugh.ogg', 'sound/effects/aprilfools/goofylaugh2.ogg'), 50)

/datum/emote/living/carbon/human/aprilfools/taa
	key = "taa"
	message = "smokes an imaginary cigar."
	emote_icon_state = "taa"
	sound = 'sound/effects/aprilfools/rizz.ogg'

/datum/emote/living/carbon/human/aprilfools/noway
	key = "noway"
	message = "looks shocked!"
	emote_icon_state = "noway"
	sound = 'sound/effects/aprilfools/rizz.ogg'

/datum/emote/living/carbon/human/aprilfools/tuh
	key = "tuh"
	message = "gasps in shock!"
	emote_icon_state = "tuh"
	sound = 'sound/effects/aprilfools/vineboom.ogg'

/datum/emote/living/carbon/human/aprilfools/jokerge
	key = "jokerge"
	message = "grins."
	emote_icon_state = "jokerge"

/datum/emote/living/carbon/human/aprilfools/fuckingdies
	key = "fuckingdies"
	message = "fucking dies."
	emote_icon_state = "die"
	sound = 'sound/effects/aprilfools/rpdeath.ogg'
