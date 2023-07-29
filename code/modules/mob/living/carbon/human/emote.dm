/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	message_mime = "sobs silently."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	stat_allowed = SOFT_CRIT

/datum/emote/living/carbon/human/cry/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	QDEL_IN(human_user.give_emote_overlay(/datum/bodypart_overlay/simple/emote/cry), 12.8 SECONDS)

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "give daps to %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."

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
	vary = TRUE

/datum/emote/living/carbon/human/scream/get_sound(mob/living/carbon/human/user)
	if(!istype(user))
		return

	// MonkeStation Edit Start
	// Alternative Scream Hook
	if(user.alternative_screams.len)
		return pick(user.alternative_screams)
	// MonkeStation Edit End

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
	if(!.)
		return
	var/obj/item/organ/external/tail/oranges_accessory = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(oranges_accessory.wag_flags & WAG_WAGGING) //We verified the tail exists in can_run_emote()
		SEND_SIGNAL(user, COMSIG_ORGAN_WAG_TAIL, FALSE)
	else
		SEND_SIGNAL(user, COMSIG_ORGAN_WAG_TAIL, TRUE)

/datum/emote/living/carbon/human/wag/select_message_type(mob/user, intentional)
	. = ..()
	var/obj/item/organ/external/tail/oranges_accessory = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(oranges_accessory.wag_flags & WAG_WAGGING)
		. = "stops wagging " + message
	else
		. = "wags " + message

/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check, intentional)
	var/obj/item/organ/external/tail/tail = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(tail?.wag_flags & WAG_ABLE)
		return ..()
	return FALSE

/datum/emote/living/carbon/human/wing
	key = "wing"
	key_third_person = "wings"
	message = "their wings."

/datum/emote/living/carbon/human/wing/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/wings/functional/wings = H.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
		if(wings && findtext(select_message_type(user,intentional), "open"))
			wings.open_wings()
		else
			wings.close_wings()

/datum/emote/living/carbon/human/wing/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(H.dna.species.mutant_bodyparts["wings"])
		. = "opens " + message
	else
		. = "closes " + message

/datum/emote/living/carbon/human/wing/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.dna && H.dna.species && (H.dna.features["wings"] != "None"))
		return TRUE

/datum/emote/living/carbon/human/clear_throat
	key = "clear"
	key_third_person = "clears throat"
	message = "clears their throat."

///Snowflake emotes only for le epic chimp
/datum/emote/living/carbon/human/monkey

/datum/emote/living/carbon/human/monkey/can_run_emote(mob/user, status_check = TRUE, intentional)
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

/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"

/datum/emote/living/click
	key = "click"
	key_third_person = "clicks their tongue"
	message = "clicks their tongue"
	message_ipc = "makes a click sound"
	message_insect = "clicks their mandibles"

/datum/emote/living/click/get_sound(mob/living/user)
	if(ismoth(user))
		return 'sound/creatures/rattle.ogg'
	else if(isipc(user))
		return 'sound/machines/click.ogg'
	else
		return FALSE

/datum/emote/living/zap
	key = "zap"
	key_third_person = "zaps"
	message = "zaps"
	message_param = "zaps %t"

/datum/emote/living/zap/can_run_emote(mob/user, status_check = TRUE , intentional)
	. = ..()
	if(isethereal(user))
		return TRUE
	else
		return FALSE

/datum/emote/living/zap/get_sound(mob/living/user)
	if(isethereal(user))
		return 'sound/machines/defib_zap.ogg'

/datum/emote/living/hum
	key = "hum"
	key_third_person = "hums"
	message = "hums"
	message_robot = "lets out a droning hum"
	message_AI = "lets out a droning hum"
	message_ipc = "lets out a droning hum"
	message_mime = "silently hums"

/datum/emote/living/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "lets out a hiss"
	message_robot = "plays a hissing noise"
	message_AI = "plays a hissing noise"
	message_ipc = "plays a hissing noise"
	message_mime = "acts out a hiss"
	message_param = "hisses at %t"

/datum/emote/living/hiss/get_sound(mob/living/user)
	if(islizard(user) || isipc(user) || isAI(user) || iscyborg(user))
		return pick('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg', 'sound/voice/hiss5.ogg', 'sound/voice/hiss6.ogg')

/datum/emote/living/thumbs_up
	key = "thumbsup"
	key_third_person = "thumbsup"
	message = "flashes a thumbs up"
	message_robot = "makes a crude thumbs up with their 'hands'"
	message_AI = "flashes a quick hologram of a thumbs up"
	message_ipc = "flashes a thumbs up icon"
	message_animal_or_basic = "attempts a thumbs up"
	message_param = "flashes a thumbs up at %t"
	hands_use_check = TRUE

/datum/emote/living/thumbs_down
	key = "thumbsdown"
	key_third_person = "thumbsdown"
	message = "flashes a thumbs down"
	message_robot = "makes a crude thumbs down with their 'hands'"
	message_AI = "flashes a quick hologram of a thumbs down"
	message_ipc = "flashes a thumbs down icon"
	message_animal_or_basic = "attempts a thumbs down"
	message_param = "flashes a thumbs down at %t"
	hands_use_check = TRUE

/datum/emote/living/whistle
	key="whistle"
	key_third_person="whistle"
	message = "whistles a few notes"
	message_robot = "whistles a few synthesized notes"
	message_AI = "whistles a synthesized song"
	message_ipc = "whistles a few synthesized notes"
	message_param = "whistles at %t"

//MonkeStation Edit Start
//Butt-Based Farts
/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(user.stat == CONSCIOUS)
		if(!user.get_organ_by_type(/obj/item/organ/internal/butt) || !ishuman(user))
			to_chat(user, "<span class='warning'>You don't have a butt!</span>")
			return
		var/obj/item/organ/internal/butt/booty = user.get_organ_by_type(/obj/item/organ/internal/butt)
		if(!booty.cooling_down)
			booty.On_Fart(user)
