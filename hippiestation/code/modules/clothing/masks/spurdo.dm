/obj/item/clothing/mask/spurdo
	name = "spurdo sparde mask"
	desc = "Made from a rare Gondola hide. Is said to be cursed by the spirits of Space Finland, which speak through the mask when you scream."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_1 = MASKINTERNALS_1
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "spurdo"
	item_state = "spurdo"
	icon = 'hippiestation/icons/obj/clothing/masks.dmi'
	alternate_worn_icon = 'hippiestation/icons/mob/mask.dmi'
	alternate_screams = list('hippiestation/sound/voice/finnish_1.ogg', 'hippiestation/sound/voice/finnish_2.ogg', 'hippiestation/sound/voice/finnish_3.ogg')
	// god emperor pyko has lended us his voice for scream sounds

/obj/item/clothing/mask/spurdo/speechModification(M)
	if(copytext(M, 1, 2) != "*")
		M = " [M]"
		var/list/spurdo_words = strings("hippie_word_replacement.json", "spurdo") // Technically not modular, but unless we want to write an entire function for one damn mask then we'll just have this here.

		for(var/key in spurdo_words)
			var/value = spurdo_words[key]
			if(islist(value))
				value = pick(value)

			M = replacetextEx(M, " [uppertext(key)]", " [uppertext(value)]")
			M = replacetextEx(M, " [capitalize(key)]", " [capitalize(value)]")
			M = replacetextEx(M, " [key]", " [value]")

		M = replacetext(M,"p","b") // This part and the lines below it are doubling down for accent's sake. It's modular.
		M = replacetext(M,"oo","u")
		M = replacetext(M,"ck","gg")
		M = replacetext(M,"c","g")
		M = replacetext(M,"t","j")

		if(prob(50))
			M += pick(" :DDDDD", " :-DDDDDD")
			if(prob(20))
				M += pick (" EBIN!!"," FUGG!!"," BENIS!!", " SPORO LORO SPLARLE SBOERDOLOLA!!")
	return trim(M)

/obj/item/clothing/mask/spurdo/equipped(mob/user, slot) //when you put it on
	var/mob/living/carbon/C = user
	if(C.wear_mask == src)
		C.emote("scream")
		C.say("SUOMI PERKELE") // bawb made me do this
	return ..()

obj/item/clothing/mask/spurdo/cursed
	flags_1 = NODROP_1 | MASKINTERNALS_1