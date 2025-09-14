
GLOBAL_LIST_INIT(cursed_animal_masks, list(
		/obj/item/clothing/mask/animal/pig/cursed,
		/obj/item/clothing/mask/animal/frog/cursed,
		/obj/item/clothing/mask/animal/cowmask/cursed,
		/obj/item/clothing/mask/animal/horsehead/cursed,
		/obj/item/clothing/mask/animal/small/rat/cursed,
		/obj/item/clothing/mask/animal/small/fox/cursed,
		/obj/item/clothing/mask/animal/small/bee/cursed,
		/obj/item/clothing/mask/animal/small/bear/cursed,
		/obj/item/clothing/mask/animal/small/bat/cursed,
		/obj/item/clothing/mask/animal/small/raven/cursed,
		/obj/item/clothing/mask/animal/small/jackal/cursed
	))

/obj/item/clothing/mask/animal
	abstract_type = /obj/item/clothing/mask
	w_class = WEIGHT_CLASS_SMALL
	clothing_flags = VOICEBOX_TOGGLABLE
	var/modifies_speech = TRUE
	flags_cover = MASKCOVERSMOUTH

	var/animal_type ///what kind of animal the masks represents. used for automatic name and description generation.
	var/list/animal_sounds ///phrases to be said when the player attempts to talk when speech modification / voicebox is enabled.
	var/list/animal_sounds_alt ///lower probability phrases to be said when talking.
	var/animal_sounds_alt_probability ///probability for alternative sounds to play.

	var/cursed ///if it's a cursed mask variant.
	var/curse_spawn_sound ///sound to play when the cursed mask variant is spawned.

/obj/item/clothing/mask/animal/Initialize(mapload)
	. = ..()
	if(cursed)
		make_cursed()

/obj/item/clothing/mask/animal/equipped(mob/M, slot)
	. = ..()
	if ((slot & ITEM_SLOT_MASK) && modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/animal/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/animal/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, cursed))
		if(vval)
			if(!cursed)
				make_cursed()
		else if(cursed)
			clear_curse()
	if(vname == NAMEOF(src, modifies_speech) && ismob(loc))
		var/mob/M = loc
		if(M.get_item_by_slot(ITEM_SLOT_MASK) == src)
			if(vval)
				if(!modifies_speech)
					RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
			else if(modifies_speech)
				UnregisterSignal(M, COMSIG_MOB_SAY)
	return ..()

/obj/item/clothing/mask/animal/examine(mob/user)
	. = ..()
	if(clothing_flags & VOICEBOX_TOGGLABLE)
		. += span_notice("Its voicebox is currently [clothing_flags & VOICEBOX_DISABLED ? "disabled" : "enabled"]. <b>Alt-click</b> to toggle it.")

/obj/item/clothing/mask/animal/click_alt(mob/user)
	if(!(clothing_flags & VOICEBOX_TOGGLABLE))
		return NONE
	clothing_flags ^= VOICEBOX_DISABLED
	to_chat(user, span_notice("You [clothing_flags & VOICEBOX_DISABLED ? "disabled" : "enabled"] [src]'s voicebox."))
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/mask/animal/proc/make_cursed() //apply cursed effects.
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	clothing_flags = NONE //force animal sounds to always on.
	if(flags_inv == initial(flags_inv))
		flags_inv = HIDEFACIALHAIR
	name = "[animal_type] face"
	desc = "It looks like a [animal_type] mask, but closer inspection reveals it's melded onto this person's face!"
	if(curse_spawn_sound)
		playsound(src, curse_spawn_sound, 50, TRUE)
	var/update_speech_mod = !modifies_speech && LAZYLEN(animal_sounds)
	if(update_speech_mod)
		modifies_speech = TRUE
	if(ismob(loc))
		var/mob/M = loc
		if(M.get_item_by_slot(ITEM_SLOT_MASK) == src)
			if(update_speech_mod)
				RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
			to_chat(M, span_userdanger("[src] was cursed!"))
			M.update_worn_mask()
			M.refresh_obscured()

/obj/item/clothing/mask/animal/proc/clear_curse()
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	clothing_flags = initial(clothing_flags)
	flags_inv = initial(flags_inv)
	name = initial(name)
	desc = initial(desc)
	var/update_speech_mod = modifies_speech && !initial(modifies_speech)
	if(update_speech_mod)
		modifies_speech = FALSE
	if(ismob(loc))
		var/mob/M = loc
		if(M.get_item_by_slot(ITEM_SLOT_MASK) == src)
			to_chat(M, span_notice("[src]'s curse has been lifted!"))
			if(update_speech_mod)
				UnregisterSignal(M, COMSIG_MOB_SAY)
			M.update_worn_mask()

/obj/item/clothing/mask/animal/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(clothing_flags & VOICEBOX_DISABLED)
		return
	if(!modifies_speech || !LAZYLEN(animal_sounds))
		return
	speech_args[SPEECH_MESSAGE] = pick((prob(animal_sounds_alt_probability) && LAZYLEN(animal_sounds_alt)) ? animal_sounds_alt : animal_sounds)

/obj/item/clothing/mask/animal/equipped(mob/user, slot)
	if(!iscarbon(user))
		return ..()
	if((slot & ITEM_SLOT_MASK) && HAS_TRAIT_FROM(src, TRAIT_NODROP, CURSED_MASK_TRAIT))
		to_chat(user, span_userdanger("[src] was cursed!"))
	return ..()


/obj/item/clothing/mask/animal/pig
	name = "pig mask"
	desc = "A rubber pig mask with a built-in voice modulator."
	animal_type = "pig"
	icon_state = "pig"
	inhand_icon_state = null
	animal_sounds = list("Oink!","Squeeeeeeee!","Oink Oink!")
	curse_spawn_sound = 'sound/effects/magic/pighead_curse.ogg'
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/animal/pig/cursed
	cursed = TRUE

///frog mask - reeee!!
/obj/item/clothing/mask/animal/frog
	name = "frog mask"
	desc = "An ancient mask carved in the shape of a frog.<br> Sanity is like gravity, all it needs is a push."
	icon_state = "frog"
	inhand_icon_state = null
	animal_sounds = list("Ree!!", "Reee!!","REEE!!","REEEEE!!")
	animal_sounds_alt_probability = 5
	animal_sounds_alt = list("HUUUUU!!","SMOOOOOKIN'!!","Hello my baby, hello my honey, hello my rag-time gal.", "Feels bad, man.", "GIT DIS GUY OFF ME!!" ,"SOMEBODY STOP ME!!", "NORMIES, GET OUT!!")
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/animal/frog/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, cursed ? 4 : -4)

/obj/item/clothing/mask/animal/frog/make_cursed()
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 4)

/obj/item/clothing/mask/animal/frog/clear_curse()
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -4)

/obj/item/clothing/mask/animal/frog/cursed
	cursed = TRUE

/obj/item/clothing/mask/animal/cowmask
	name = "cow mask"
	icon_state = "cowmask"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	curse_spawn_sound = 'sound/effects/magic/cowhead_curse.ogg'
	animal_sounds = list("Moooooooo!","Moo!","Moooo!")

/obj/item/clothing/mask/animal/cowmask/cursed
	cursed = TRUE

/obj/item/clothing/mask/animal/horsehead
	name = "horse mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	animal_type = "horse"
	icon_state = "horsehead"
	inhand_icon_state = null
	animal_sounds = list("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEYES|HIDEEARS|HIDESNOUT
	curse_spawn_sound = 'sound/effects/magic/horsehead_curse.ogg'

/obj/item/clothing/mask/animal/horsehead/cursed
	cursed = TRUE

/obj/item/clothing/mask/animal/small
	name = "A small animal mask"
	desc = "If you're seeing this, yell at a coder."
	abstract_type = /obj/item/clothing/mask/animal/small
	flags_inv = HIDEFACE|HIDESNOUT

/obj/item/clothing/mask/animal/small/make_cursed()
	flags_inv = NONE
	return ..()

/obj/item/clothing/mask/animal/small/rat
	name = "rat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a rat."
	animal_type = "rat"
	icon_state = "rat"
	inhand_icon_state = null
	animal_sounds = list("Skree!","SKREEE!","Squeak!")

/obj/item/clothing/mask/animal/small/rat/cursed
	cursed = TRUE

/obj/item/clothing/mask/animal/small/fox
	name = "fox mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a fox."
	animal_type = "fox"
	icon_state = "fox"
	inhand_icon_state = null
	animal_sounds = list("Ack-Ack!","Ack-Ack-Ack-Ackawoooo!","Geckers!","AWOO!","TCHOFF!")

/obj/item/clothing/mask/animal/small/fox/cursed
	cursed = TRUE

/obj/item/clothing/mask/animal/small/bee
	name = "bee mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bee."
	animal_type = "bee"
	icon_state = "bee"
	inhand_icon_state = null
	animal_sounds = list("BZZT!", "BUZZZ!", "B-zzzz!", "Bzzzzzzttttt!")

/obj/item/clothing/mask/animal/small/bee/cursed
	cursed = TRUE

/obj/item/clothing/mask/animal/small/bear
	name = "bear mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bear."
	animal_type = "bear"
	icon_state = "bear"
	inhand_icon_state = null
	animal_sounds = list("RAWR!","Rawr!","GRR!","Growl!")

/obj/item/clothing/mask/animal/small/bear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, cursed ? 4 : -4)

/obj/item/clothing/mask/animal/small/bear/make_cursed()
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 4)

/obj/item/clothing/mask/animal/small/bear/clear_curse()
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -4)

/obj/item/clothing/mask/animal/small/bear/cursed
	cursed = TRUE

/obj/item/clothing/mask/animal/small/bat
	name = "bat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bat."
	animal_type = "bat"
	icon_state = "bat"
	inhand_icon_state = null

/obj/item/clothing/mask/animal/small/bat/cursed
	cursed = TRUE


/obj/item/clothing/mask/animal/small/raven
	name = "raven mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a raven."
	icon_state = "raven"
	inhand_icon_state = null
	animal_type = "raven"
	animal_sounds = list("CAW!", "C-CAWW!", "Squawk!")
	animal_sounds_alt = list("Nevermore...")
	animal_sounds_alt_probability = 1

/obj/item/clothing/mask/animal/small/raven/cursed
	cursed = TRUE

/obj/item/clothing/mask/animal/small/jackal
	name = "jackal mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a jackal."
	animal_type = "jackal"
	icon_state = "jackal"
	inhand_icon_state = null
	animal_sounds = list("YAP!", "Woof!", "Bark!", "AUUUUUU!")

/obj/item/clothing/mask/animal/small/jackal/cursed
	cursed = TRUE

/obj/item/clothing/mask/animal/small/tribal
	name = "tribal mask"
	desc = "A mask carved out of wood, detailed carefully by hand."
	animal_type = "tribal" //honk.
	icon_state = "bumba"
	inhand_icon_state = null
	animal_sounds = list("Bad juju, mon!", "Da Iwa be praised!", "Sum bad mojo, dat!", "You do da voodoo, mon!")
	animal_sounds_alt = list("Eekum-bokum!", "Oomenacka!", "In mah head..... Zombi.... Zombi!")
	animal_sounds_alt_probability = 5

/obj/item/clothing/mask/animal/small/tribal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, cursed ? 5 : -5)

/obj/item/clothing/mask/animal/small/tribal/make_cursed()
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 5)

/obj/item/clothing/mask/animal/small/tribal/clear_curse()
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -5)

/obj/item/clothing/mask/animal/small/tribal/cursed //adminspawn only.
	cursed = TRUE
