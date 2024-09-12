//copy pasta of the space piano, don't hurt me -Pete
/obj/item/instrument
	name = "generic instrument"
	force = 10
	max_integrity = 100
	resistance_flags = FLAMMABLE
	icon = 'icons/obj/art/musician.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/instruments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/instruments_righthand.dmi'
	/// Our song datum.
	var/datum/song/handheld/song
	/// Our allowed list of instrument ids. This is nulled on initialize.
	var/list/allowed_instrument_ids
	/// How far away our song datum can be heard.
	var/instrument_range = 15

/obj/item/instrument/Initialize(mapload)
	. = ..()
	song = new(src, allowed_instrument_ids, instrument_range)
	allowed_instrument_ids = null //We don't need this clogging memory after its used.

/obj/item/instrument/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/item/instrument/proc/should_stop_playing(atom/music_player)
	if(!ismob(music_player))
		return STOP_PLAYING
	var/mob/user = music_player
	if(user.incapacitated || !((loc == user) || (isturf(loc) && Adjacent(user)))) // sorry, no more TK playing.
		return STOP_PLAYING

/obj/item/instrument/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins to play 'Gloomy Sunday'! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/instrument/ui_interact(mob/user, datum/tgui/ui)
	song.ui_interact(user)

/obj/item/instrument/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "violin"
	inhand_icon_state = "violin"
	hitsound = SFX_SWING_HIT
	allowed_instrument_ids = "violin"

/obj/item/instrument/violin/golden
	name = "golden violin"
	desc = "A golden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "golden_violin"
	inhand_icon_state = "golden_violin"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/instrument/banjo
	name = "banjo"
	desc = "A 'Mura' brand banjo. It's pretty much just a drum with a neck and strings."
	icon_state = "banjo"
	inhand_icon_state = "banjo"
	attack_verb_continuous = list("scruggs-styles", "hum-diggitys", "shin-digs", "clawhammers")
	attack_verb_simple = list("scruggs-style", "hum-diggity", "shin-dig", "clawhammer")
	hitsound = 'sound/weapons/banjoslap.ogg'
	allowed_instrument_ids = "banjo"

/obj/item/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	inhand_icon_state = "guitar"
	attack_verb_continuous = list("plays metal on", "serenades", "crashes", "smashes")
	attack_verb_simple = list("play metal on", "serenade", "crash", "smash")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("guitar","csteelgt","cnylongt", "ccleangt", "cmutedgt")

/obj/item/instrument/eguitar
	name = "electric guitar"
	desc = "Makes all your shredding needs possible."
	icon_state = "eguitar"
	inhand_icon_state = "eguitar"
	force = 12
	attack_verb_continuous = list("plays metal on", "shreds", "crashes", "smashes")
	attack_verb_simple = list("play metal on", "shred", "crash", "smash")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = "eguitar"

/obj/item/instrument/glockenspiel
	name = "glockenspiel"
	desc = "Smooth metal bars perfect for any marching band."
	icon_state = "glockenspiel"
	allowed_instrument_ids = list("glockenspiel","crvibr", "sgmmbox", "r3celeste")
	inhand_icon_state = "glockenspiel"

/obj/item/instrument/accordion
	name = "accordion"
	desc = "Pun-Pun not included."
	icon_state = "accordion"
	allowed_instrument_ids = list("crack", "crtango", "accordion")
	inhand_icon_state = "accordion"

/obj/item/instrument/trumpet
	name = "trumpet"
	desc = "To announce the arrival of the king!"
	icon_state = "trumpet"
	allowed_instrument_ids = "crtrumpet"
	inhand_icon_state = "trumpet"

/obj/item/instrument/trumpet/spectral
	name = "spectral trumpet"
	desc = "Things are about to get spooky!"
	icon_state = "spectral_trumpet"
	inhand_icon_state = "spectral_trumpet"
	force = 0
	attack_verb_continuous = list("plays", "jazzes", "trumpets", "mourns", "doots", "spooks")
	attack_verb_simple = list("play", "jazz", "trumpet", "mourn", "doot", "spook")

/obj/item/instrument/trumpet/spectral/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/spooky)

/obj/item/instrument/trumpet/spectral/attack(mob/living/target_mob, mob/living/user, params)
	playsound(src, 'sound/runtime/instruments/trombone/En4.mid', 1000, 1, -1)
	return ..()

/obj/item/instrument/saxophone
	name = "saxophone"
	desc = "This soothing sound will be sure to leave your audience in tears."
	icon_state = "saxophone"
	allowed_instrument_ids = "saxophone"
	inhand_icon_state = "saxophone"

/obj/item/instrument/saxophone/spectral
	name = "spectral saxophone"
	desc = "This spooky sound will be sure to leave mortals in bones."
	icon_state = "saxophone"
	inhand_icon_state = "saxophone"
	force = 0
	attack_verb_continuous = list("plays", "jazzes", "saxxes", "mourns", "doots", "spooks")
	attack_verb_simple = list("play", "jazz", "sax", "mourn", "doot", "spook")

/obj/item/instrument/saxophone/spectral/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/spooky)

/obj/item/instrument/saxophone/spectral/attack(mob/living/target_mob, mob/living/user, params)
	playsound(src, 'sound/runtime/instruments/trombone/En4.mid', 1000, 1, -1)
	return ..()

/obj/item/instrument/trombone
	name = "trombone"
	desc = "How can any pool table ever hope to compete?"
	icon_state = "trombone"
	allowed_instrument_ids = list("crtrombone", "crbrass", "trombone")
	inhand_icon_state = "trombone"

/obj/item/instrument/trombone/spectral
	name = "spectral trombone"
	desc = "A skeleton's favorite instrument. Apply directly on the mortals."
	icon_state = "trombone"
	inhand_icon_state = "trombone"
	force = 0
	attack_verb_continuous = list("plays", "jazzes", "trombones", "mourns", "doots", "spooks")
	attack_verb_simple = list("play", "jazz", "trombone", "mourn", "doot", "spook")

/obj/item/instrument/trombone/spectral/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/spooky)

/obj/item/instrument/trombone/spectral/attack(mob/living/target_mob, mob/living/user, params)
	playsound(src, 'sound/runtime/instruments/trombone/Cn4.mid', 1000, 1, -1)
	return ..()

/obj/item/instrument/recorder
	name = "recorder"
	desc = "Just like in school, playing ability and all."
	force = 5
	icon_state = "recorder"
	allowed_instrument_ids = "recorder"
	inhand_icon_state = "recorder"

/obj/item/instrument/harmonica
	name = "harmonica"
	desc = "For when you get a bad case of the space blues."
	icon_state = "harmonica"
	allowed_instrument_ids = list("crharmony", "harmonica")
	inhand_icon_state = "harmonica"
	slot_flags = ITEM_SLOT_MASK
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/instrument)

/obj/item/instrument/harmonica/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(!(slot & slot_flags))
		return
	RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/obj/item/instrument/harmonica/dropped(mob/user, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_SAY)

/obj/item/instrument/harmonica/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(!song.playing)
		return
	if(!ismob(loc))
		CRASH("[src] was still registered to listen in on [source] but was not found to be on their mob.")
	to_chat(loc, span_warning("You stop playing the harmonica to talk..."))
	song.playing = FALSE

/datum/action/item_action/instrument
	name = "Use Instrument"
	desc = "Use the instrument specified"

/datum/action/item_action/instrument/Trigger(trigger_flags)
	if(istype(target, /obj/item/instrument))
		var/obj/item/instrument/I = target
		I.interact(usr)
		return
	return ..()

/obj/item/instrument/bikehorn
	name = "gilded bike horn"
	desc = "An exquisitely decorated bike horn, capable of honking in a variety of notes."
	icon_state = "bike_horn"
	inhand_icon_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	allowed_instrument_ids = list("bikehorn", "honk")
	attack_verb_continuous = list("beautifully honks")
	attack_verb_simple = list("beautifully honk")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 3
	throw_range = 15
	hitsound = 'sound/items/bikehorn.ogg'

/obj/item/instrument/musicalmoth
	name = "musical moth"
	desc = "Despite its popularity, this controversial musical toy was eventually banned due to its unethically sampled sounds of moths screaming in agony."
	icon_state = "mothsician"
	allowed_instrument_ids = "mothscream"
	attack_verb_continuous = list("flutters", "flaps")
	attack_verb_simple = list("flutter", "flap")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	hitsound = 'sound/voice/moth/scream_moth.ogg'
	custom_price = PAYCHECK_COMMAND * 2.37
	custom_premium_price = PAYCHECK_COMMAND * 2.37
