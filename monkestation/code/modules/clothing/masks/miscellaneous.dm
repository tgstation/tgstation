/obj/item/clothing/mask/ookmask
	name = "Paper Monkey Mask"
	desc = "One shudders to imagine the inhuman thoughts that lie underneath that mask."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/mask.dmi'
	icon_state = "ook"
	item_state = "ook"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	alternative_screams = list(	'sound/creatures/monkey/monkey_screech_1.ogg',
								'sound/creatures/monkey/monkey_screech_2.ogg',
								'sound/creatures/monkey/monkey_screech_3.ogg',
								'sound/creatures/monkey/monkey_screech_4.ogg',
								'sound/creatures/monkey/monkey_screech_5.ogg',
								'sound/creatures/monkey/monkey_screech_6.ogg',
								'sound/creatures/monkey/monkey_screech_7.ogg')

	alternative_laughs = list(	'monkestation/sound/voice/laugh/misc/big_laugh0.ogg',
								'monkestation/sound/voice/laugh/misc/big_laugh1.ogg',
								'monkestation/sound/voice/laugh/misc/big_laugh2.ogg',
								'monkestation/sound/voice/laugh/misc/big_laugh3.ogg',
								'monkestation/sound/voice/laugh/misc/big_laugh4.ogg')

/obj/item/clothing/mask/translator
	name = "MonkeTech AutoTranslator"
	desc = "A small device that will translate speech."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/mask.dmi'
	icon_state = "translator"
	item_state = "translator"
	slot_flags = ITEM_SLOT_MASK | ITEM_SLOT_NECK
	modifies_speech = TRUE
	var/current_language = /datum/language/common

/obj/item/clothing/mask/translator/proc/generate_language_names(mob/user)
	var/static/list/language_name_list
	if(!language_name_list)
		language_name_list = list()
		for(var/language in user.mind.language_holder.understood_languages)
			if(language in user.mind.language_holder.blocked_languages)
				continue
			var/atom/A = language
			language_name_list[initial(A.name)] = A
	return language_name_list

/obj/item/clothing/mask/translator/attack_self(mob/user)
	. = ..()
	if(ishuman(user))
		var/list/display_names = generate_language_names(user)
		if(!display_names.len > 1)
			return
		var/choice = input(user,"Please select a language","Select a language:") as null|anything in sortList(display_names)
		if(!choice || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
			return
		current_language = display_names[choice]



/obj/item/clothing/mask/translator/equipped(mob/M, slot)
	. = ..()
	if ((slot == ITEM_SLOT_MASK || slot == ITEM_SLOT_NECK) && modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech)
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/translator/handle_speech(datum/source, list/speech_args)
	. = ..()
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		if(obj_flags & EMAGGED)
			speech_args[SPEECH_LANGUAGE] = pick(GLOB.all_languages)
		else
			speech_args[SPEECH_LANGUAGE] = current_language

/obj/item/clothing/mask/translator/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Click while in hand to select output language.</span>"

/obj/item/clothing/mask/translator/emag_act()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	icon_state = "translator_emag"
	playsound(src, "sparks", 100, 1)
