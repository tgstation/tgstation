/obj/item/statuebust
	name = "bust"
	desc = "A priceless ancient marble bust, the kind that belongs in a museum." //or you can hit people with it
	icon = 'icons/obj/art/statue.dmi'
	icon_state = "bust"
	force = 15
	throwforce = 10
	throw_speed = 5
	throw_range = 2
	attack_verb_continuous = list("busts")
	attack_verb_simple = list("bust")
	var/impressiveness = 45

/obj/item/statuebust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/art, impressiveness)
	AddElement(/datum/element/beauty, 1000)

/obj/item/statuebust/hippocratic
	name = "hippocrates bust"
	desc = "A bust of the famous Greek physician Hippocrates of Kos, often referred to as the father of western medicine."
	icon_state = "hippocratic"
	impressiveness = 50
	// If it hits the prob(reference_chance) chance, this is set to TRUE. Adds medical HUD when wielded, but has a 10% slower attack speed and is too bloody to make an oath with.
	var/reference = FALSE
	// Chance for above.
	var/reference_chance = 1
	// Minimum time inbetween oaths.
	COOLDOWN_DECLARE(oath_cd)

/obj/item/statuebust/hippocratic/evil
	reference_chance = 100

/obj/item/statuebust/hippocratic/Initialize(mapload)
	. = ..()
	if(prob(reference_chance))
		name = "Solemn Vow"
		desc = "Art lovers will cherish the bust of Hippocrates, commemorating a time when medics still thought doing no harm was a good idea."
		attack_speed = CLICK_CD_SLOW
		reference = TRUE

/obj/item/statuebust/hippocratic/examine(mob/user)
	. = ..()
	if(reference)
		. += span_notice("You could activate the bust in-hand to swear or forswear a Hippocratic Oath... but it seems like somebody decided it was more of a Hippocratic Suggestion. This thing is caked with bits of blood and gore.")
		return
	. += span_notice("You can activate the bust in-hand to swear or forswear a Hippocratic Oath! This has no effects except pacifism or bragging rights. Does not remove other sources of pacifism. Do not eat.")

/obj/item/statuebust/hippocratic/equipped(mob/living/carbon/human/user, slot)
	..()
	if(!(slot & ITEM_SLOT_HANDS))
		return
	ADD_TRAIT(user, TRAIT_MEDICAL_HUD, type)

/obj/item/statuebust/hippocratic/dropped(mob/living/carbon/human/user)
	..()
	if(HAS_TRAIT_NOT_FROM(user, TRAIT_MEDICAL_HUD, type))
		return
	REMOVE_TRAIT(user, TRAIT_MEDICAL_HUD, type)

/obj/item/statuebust/hippocratic/attack_self(mob/user)
	if(!iscarbon(user))
		to_chat(user, span_warning("You remember how the Hippocratic Oath specifies 'my fellow human beings' and realize that it's completely meaningless to you."))
		return

	if(reference)
		to_chat(user, span_warning("As you prepare yourself to swear the Oath, you realize that doing so on a blood-caked bust is probably not a good idea."))
		return

	if(!COOLDOWN_FINISHED(src, oath_cd))
		to_chat(user, span_warning("You've sworn or forsworn an oath too recently to undo your decisions. The bust looks at you with disgust."))
		return

	COOLDOWN_START(src, oath_cd, 5 MINUTES)

	if(HAS_TRAIT_FROM(user, TRAIT_PACIFISM, type))
		to_chat(user, span_warning("You've already sworn a vow. You start preparing to rescind it..."))
		if(do_after(user, 5 SECONDS, target = user))
			user.say("Yeah this Hippopotamus thing isn't working out. I quit!", forced = "hippocratic hippocrisy")
			REMOVE_TRAIT(user, TRAIT_PACIFISM, type)

	// they can still do it for rp purposes
	if(HAS_TRAIT_NOT_FROM(user, TRAIT_PACIFISM, type))
		to_chat(user, span_warning("You already don't want to harm people, this isn't going to do anything!"))


	to_chat(user, span_notice("You remind yourself of the Hippocratic Oath's contents and prepare to swear yourself to it..."))
	if(do_after(user, 4 SECONDS, target = user))
		user.say("I swear to fulfill, to the best of my ability and judgment, this covenant:", forced = "hippocratic oath")
	else
		return fuck_it_up(user)
	if(do_after(user, 2 SECONDS, target = user))
		user.say("I will apply, for the benefit of the sick, all measures that are required, avoiding those twin traps of overtreatment and therapeutic nihilism.", forced = "hippocratic oath")
	else
		return fuck_it_up(user)
	if(do_after(user, 3 SECONDS, target = user))
		user.say("I will remember that I remain a member of society, with special obligations to all my fellow human beings, those sound of mind and body as well as the infirm.", forced = "hippocratic oath")
	else

		return fuck_it_up(user)
	if(do_after(user, 3 SECONDS, target = user))
		user.say("If I do not violate this oath, may I enjoy life and art, respected while I live and remembered with affection thereafter. May I always act so as to preserve the finest traditions of my calling and may I long experience the joy of healing those who seek my help.", forced = "hippocratic oath")
	else
		return fuck_it_up(user)

	to_chat(user, span_notice("Contentment, understanding, and purpose washes over you as you finish the oath. You consider for a second the concept of harm and shudder."))
	ADD_TRAIT(user, TRAIT_PACIFISM, type)

// Bully the guy for fucking up.
/obj/item/statuebust/hippocratic/proc/fuck_it_up(mob/living/carbon/user)
	to_chat(user, span_warning("You forget what comes next like a dumbass. The Hippocrates bust looks down on you, disappointed."))
	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
	COOLDOWN_RESET(src, oath_cd)

/obj/item/maneki_neko
	name = "Maneki-Neko"
	desc = "A figurine of a cat holding a coin, said to bring fortune and wealth, and perpetually moving its paw in a beckoning gesture."
	icon = 'icons/obj/fluff/general.dmi'
	icon_state = "maneki-neko"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	attack_verb_continuous = list("bashes", "beckons", "hit")
	attack_verb_simple = list("bash", "beckon", "hit")

/obj/item/maneki_neko/Initialize(mapload)
	. = ..()
	//Not compatible with greyscale configs because it's animated.
	color = pick_weight(list(COLOR_WHITE = 3, COLOR_GOLD = 2, COLOR_DARK = 1))
	var/mutable_appearance/neko_overlay = mutable_appearance(icon, "maneki-neko-overlay", appearance_flags = RESET_COLOR)
	add_overlay(neko_overlay)
	AddElement(/datum/element/art, GOOD_ART)
	AddElement(/datum/element/beauty, 800)
