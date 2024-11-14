
// **** Security gas mask ****

// Cooldown times
#define PHRASE_COOLDOWN (3 SECONDS)
#define OVERUSE_COOLDOWN (18 SECONDS)

// Aggression levels
#define AGGR_GOOD_COP 1
#define AGGR_BAD_COP 2
#define AGGR_SHIT_COP 3
#define AGGR_BROKEN 4

// Phrase list index markers
#define EMAG_PHRASE 1 // index of emagged phrase
#define GOOD_COP_PHRASES 6 // final index of good cop phrases
#define BAD_COP_PHRASES 12 // final index of bad cop phrases
#define BROKE_PHRASES 13 // starting index of broken phrases
#define ALL_PHRASES 19 // total phrases

// All possible hailer phrases
// Remember to modify above index markers if changing contents
GLOBAL_LIST_INIT(hailer_phrases, list(
	/datum/hailer_phrase/emag,
	/datum/hailer_phrase/halt,
	/datum/hailer_phrase/bobby,
	/datum/hailer_phrase/compliance,
	/datum/hailer_phrase/justice,
	/datum/hailer_phrase/running,
	/datum/hailer_phrase/dontmove,
	/datum/hailer_phrase/floor,
	/datum/hailer_phrase/robocop,
	/datum/hailer_phrase/god,
	/datum/hailer_phrase/freeze,
	/datum/hailer_phrase/imperial,
	/datum/hailer_phrase/bash,
	/datum/hailer_phrase/harry,
	/datum/hailer_phrase/asshole,
	/datum/hailer_phrase/stfu,
	/datum/hailer_phrase/shutup,
	/datum/hailer_phrase/super,
	/datum/hailer_phrase/dredd
))

/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device. Plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you tase them. Do not tamper with the device."
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/adjust)
	icon_state = "sechailer"
	inhand_icon_state = "sechailer"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS | GAS_FILTERING
	flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	tint = 0
	fishing_modifier = 0
	unique_death = 'sound/items/sec_hailer/sec_death.ogg'
	COOLDOWN_DECLARE(hailer_cooldown)
	///Decides the phrases available for use; defines used are the last index of a category of available phrases
	var/aggressiveness = AGGR_BAD_COP
	///Whether the hailer has been broken due to overuse or not
	var/broken_hailer = FALSE
	///Whether the hailer is currently in cooldown for resetting recent_uses
	var/overuse_cooldown = FALSE
	///How many times was the hailer used in the last OVERUSE_COOLDOWN seconds
	var/recent_uses = 0
	///Whether the hailer is emagged or not
	var/safety = TRUE
	voice_filter = @{"[0:a] asetrate=%SAMPLE_RATE%*0.7,aresample=16000,atempo=1/0.7,lowshelf=g=-20:f=500,highpass=f=500,aphaser=in_gain=1:out_gain=1:delay=3.0:decay=0.4:speed=0.5:type=t [out]; [out]atempo=1.2,volume=15dB [final]; anoisesrc=a=0.01:d=60 [noise]; [final][noise] amix=duration=shortest"}
	use_radio_beeps_tts = TRUE

/obj/item/clothing/mask/gas/sechailer/plasmaman
	starting_filter_type = /obj/item/gas_filter/plasmaman

/obj/item/clothing/mask/gas/sechailer/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000."
	actions_types = list(/datum/action/item_action/halt)
	icon_state = "swat"
	inhand_icon_state = "swat"
	aggressiveness = AGGR_SHIT_COP
	flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDEEYES | HIDEEARS | HIDEHAIR | HIDESNOUT
	visor_flags_inv = 0
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES | PEPPERPROOF
	visor_flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES | PEPPERPROOF
	fishing_modifier = 2
	pepper_tint = FALSE

/obj/item/clothing/mask/gas/sechailer/swat/spacepol
	name = "spacepol mask"
	desc = "A close-fitting tactical mask created in cooperation with a certain megacorporation, comes with an especially aggressive Compli-o-nator 3000."
	icon_state = "spacepol"
	inhand_icon_state = "spacepol_mask"
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES | PEPPERPROOF
	visor_flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES | PEPPERPROOF

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "security hailer"
	desc = "A set of recognizable pre-recorded messages for cyborgs to use when apprehending criminals."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "taperecorder_idle"
	slot_flags = null
	aggressiveness = AGGR_GOOD_COP // Borgs are nicecurity!
	actions_types = list(/datum/action/item_action/halt)
	fishing_modifier = 0

/obj/item/clothing/mask/gas/sechailer/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(aggressiveness == AGGR_BROKEN)
		to_chat(user, span_danger("You adjust the restrictor but nothing happens, probably because it's broken."))
		return
	var/position = aggressiveness == AGGR_GOOD_COP ? "middle" : aggressiveness == AGGR_BAD_COP ? "last" : "first"
	to_chat(user, span_notice("You set the restrictor to the [position] position."))
	aggressiveness = aggressiveness % 3 + 1 // loop AGGR_GOOD_COP -> AGGR_SHIT_COP

/obj/item/clothing/mask/gas/sechailer/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(aggressiveness != AGGR_BROKEN)
		to_chat(user, span_danger("You broke the restrictor!"))
		aggressiveness = AGGR_BROKEN
		return

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/halt))
		halt()
	else
		adjust_visor(user)

/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()

/obj/item/clothing/mask/gas/sechailer/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(safety)
		safety = FALSE
		balloon_alert(user, "vocal circuit fried")
		return TRUE
	return FALSE

/obj/item/clothing/mask/gas/sechailer/verb/halt()
	set category = "Object"
	set name = "HALT"
	set src in usr
	if(!isliving(usr) || !can_use(usr) || !COOLDOWN_FINISHED(src, hailer_cooldown))
		return
	if(broken_hailer)
		to_chat(usr, span_warning("\The [src]'s hailing system is broken."))
		return

	// handle recent uses for overuse
	recent_uses++
	if(!overuse_cooldown) // check if we can reset recent uses
		recent_uses = 0
		overuse_cooldown = TRUE
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/clothing/mask/gas/sechailer, reset_overuse_cooldown)), OVERUSE_COOLDOWN)

	switch(recent_uses)
		if(3)
			to_chat(usr, span_warning("\The [src] is starting to heat up."))
		if(4)
			to_chat(usr, span_userdanger("\The [src] is heating up dangerously from overuse!"))
		if(5) // overload
			broken_hailer = TRUE
			to_chat(usr, span_userdanger("\The [src]'s power modulator overloads and breaks."))
			return

	// select phrase to play
	play_phrase(usr, GLOB.hailer_phrases[select_phrase()])

/obj/item/clothing/mask/gas/sechailer/proc/select_phrase()
	if(!safety)
		return EMAG_PHRASE
	else
		var/upper_limit
		switch (aggressiveness)
			if (AGGR_GOOD_COP)
				upper_limit = GOOD_COP_PHRASES
			if (AGGR_BAD_COP)
				upper_limit = BAD_COP_PHRASES
			else
				upper_limit = ALL_PHRASES
		return rand(aggressiveness == AGGR_BROKEN ? BROKE_PHRASES : EMAG_PHRASE + 1, upper_limit)

/obj/item/clothing/mask/gas/sechailer/proc/play_phrase(mob/user, datum/hailer_phrase/phrase)
	if(!COOLDOWN_FINISHED(src, hailer_cooldown))
		return
	COOLDOWN_START(src, hailer_cooldown, PHRASE_COOLDOWN)
	user.audible_message("[user]'s Compli-o-Nator: <font color='red' size='4'><b>[initial(phrase.phrase_text)]</b></font>")
	playsound(src, "sound/runtime/complionator/[initial(phrase.phrase_sound)].ogg", 100, FALSE, 4)
	return TRUE

/obj/item/clothing/mask/gas/sechailer/proc/reset_overuse_cooldown()
	overuse_cooldown = FALSE

/obj/item/clothing/mask/whistle
	name = "police whistle"
	desc = "A police whistle for when you need to make sure the criminals hear you."
	icon_state = "whistle"
	inhand_icon_state = null
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_NECK
	custom_price = PAYCHECK_COMMAND * 1.5
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/halt)
	COOLDOWN_DECLARE(whistle_cooldown)

/obj/item/clothing/mask/whistle/ui_action_click(mob/user, action)
	if(!COOLDOWN_FINISHED(src, whistle_cooldown))
		return
	COOLDOWN_START(src, whistle_cooldown, 10 SECONDS)
	user.audible_message("<font color='red' size='5'><b>HALT!</b></font>")
	playsound(src, 'sound/items/whistle/whistle.ogg', 50, FALSE, 4)

/datum/action/item_action/halt
	name = "HALT!"

/obj/item/clothing/mask/party_horn
	name = "party horn"
	desc = "A paper tube used at parties that makes a noise when blown into."
	icon_state = "party_horn"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/toot)
	COOLDOWN_DECLARE(horn_cooldown)

/obj/item/clothing/mask/party_horn/ui_action_click(mob/user, action)
	if(!COOLDOWN_FINISHED(src, horn_cooldown))
		return
	COOLDOWN_START(src, horn_cooldown, 10 SECONDS)
	playsound(src, 'sound/items/party_horn.ogg', 75, FALSE)
	flick("party_horn_animated", src)

/datum/action/item_action/toot
	name = "TOOT!"

#undef PHRASE_COOLDOWN
#undef OVERUSE_COOLDOWN
#undef AGGR_GOOD_COP
#undef AGGR_BAD_COP
#undef AGGR_SHIT_COP
#undef AGGR_BROKEN
#undef EMAG_PHRASE
#undef GOOD_COP_PHRASES
#undef BAD_COP_PHRASES
#undef BROKE_PHRASES
#undef ALL_PHRASES
