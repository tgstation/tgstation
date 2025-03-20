/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/dap
	key = "dap" // Что это блять?
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "gives daps to %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	name = "Поднять бровь"
	message = "приподнимает бровь."

/datum/emote/living/carbon/human/glasses
	key = "glasses"
	key_third_person = "glasses"
	name = "Тост"
	message = "поднимает бокал."
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
	name = "Ворчать"
	message = "ворчит.."
	message_mime = "grumbles silently!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	name = "Рукопожатие"
	message = "пожимает руку."
	message_param = "shakes hands with %t."
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	name = "Обнять себя"
	message = "обнимает себя."
	message_param = "hugs %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	name = "Бормотать"
	message = "бормочет.."
	message_mime = "mumbles silently!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	name = "Кричать"
	message = "кричит!"
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
	name = "Орать"
	message = "орёт!"
	message_mime = "screeches silently."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	vary = FALSE

/datum/emote/living/carbon/human/scream/screech/should_play_sound(mob/user, intentional)
	if(ismonkey(user))
		return TRUE
	return ..()

/datum/emote/living/carbon/human/pale
	key = "pale"
	name = "Бледнеть"
	message = "на секунду бледнеет."

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	name = "Поднять руку"
	message = "поднимает руку."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	name = "Воинское"
	message = "отдаёт воинское приветствие."
	message_param = "salutes to %t."
	hands_use_check = TRUE
	sound = 'sound/mobs/humanoids/human/salute/salute.ogg'

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	name = "Пожать плечами"
	message = "пожимает плечами."

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
	name = "Прокашляться"
	message = "прокашливается."

/datum/emote/living/carbon/human/blink
	key = "blink"
	key_third_person = "blinks"
	name = "Моргнуть"
	message = "моргает."

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
	name = "Моргнуть ()"
	message = "быстро моргает."

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
	name = "Оскал"
	message = "скалится и показывает зубы..."
	message_mime = "gnarls silently, baring its teeth..."

/datum/emote/living/carbon/human/monkey/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/scratch
	key = "scratch"
	key_third_person = "scratches"
	name = "Царапать"
	message = "царапает."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/screech/roar
	key = "roar"
	key_third_person = "roars"
	name = "Рычать"
	message = "рычит!"
	message_mime = "acts out a roar."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/monkey/tail
	key = "tail"
	name = "Вилять хвостом"
	message = "машет хвостом."

/datum/emote/living/carbon/human/monkey/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	hands_use_check = TRUE
