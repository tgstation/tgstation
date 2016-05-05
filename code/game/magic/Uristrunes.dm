
var/list/word_to_uristrune_table = null

/proc/word_to_uristrune_bit(word)
	if(word_to_uristrune_table == null)
		word_to_uristrune_table = list()

		var/bit = 1
		var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "mgar", "balaq", "karazet", "geeri")

		while(length(words))
			var/w = pick(words)

			word_to_uristrune_table[w] = bit

			words -= w
			bit <<= 1

	return word_to_uristrune_table[word]



/obj/effect/rune/proc/get_uristrune_cult(word1, word2, word3,var/mob/living/M = null)
	var/animated

	if((word1 == cultwords["travel"] && word2 == cultwords["self"])						\
	|| (word1 == cultwords["join"] && word2 == cultwords["blood"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["join"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["see"] && word2 == cultwords["blood"] && word3 == cultwords["hell"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["destroy"] && word3 == cultwords["other"])	\
	|| (word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["technology"])	\
	|| (word1 == cultwords["travel"] && word2 == cultwords["blood"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["see"] && word2 == cultwords["hell"] && word3 == cultwords["join"])		\
	|| (word1 == cultwords["blood"] && word2 == cultwords["join"] && word3 == cultwords["hell"])	\
	|| (word1 == cultwords["hide"] && word2 == cultwords["see"] && word3 == cultwords["blood"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["travel"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["blood"] && word2 == cultwords["see"] && word3 == cultwords["travel"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["technology"] && word3 == cultwords["join"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["blood"] && word3 == cultwords["join"])	\
	|| (word1 == cultwords["blood"] && word2 == cultwords["see"] && word3 == cultwords["hide"])	\
	|| (word1 == cultwords["destroy"] && word2 == cultwords["travel"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["travel"] && word2 == cultwords["technology"] && word3 == cultwords["other"])	\
	|| (word1 == cultwords["join"] && word2 == cultwords["other"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["hide"] && word2 == cultwords["other"] && word3 == cultwords["see"])	\
	|| (word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["other"])	\
	|| (word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["blood"])	\
	|| (word1 == cultwords["self"] && word2 == cultwords["other"] && word3 == cultwords["technology"])	\
	|| (word1 == cultwords["travel"] && word2 == cultwords["other"])						\
	|| (word1 == cultwords["join"] && word2 == cultwords["hide"] && word3 == cultwords["technology"])	)
		animated = 1
	else
		animated = 0

	var/bits = word_to_uristrune_bit(word1) \
			 | word_to_uristrune_bit(word2) \
			 | word_to_uristrune_bit(word3)

	if(M && istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		return get_uristrune(bits, animated, H.species.blood_color)
	else
		return get_uristrune(bits, animated)

/proc/get_uristrune_name(word1, word2, word3)
	if((word1 == cultwords["travel"] && word2 == cultwords["self"]))
		return "Travel Self"
	else if((word1 == cultwords["join"] && word2 == cultwords["blood"] && word3 == cultwords["self"]))
		return "Convert"
	else if((word1 == cultwords["hell"] && word2 == cultwords["join"] && word3 == cultwords["self"]))
		return "Tear Reality"
	else if((word1 == cultwords["see"] && word2 == cultwords["blood"] && word3 == cultwords["hell"]))
		return "Summon Tome"
	else if((word1 == cultwords["hell"] && word2 == cultwords["destroy"] && word3 == cultwords["other"]))
		return "Armor"
	else if((word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["technology"]))
		return "EMP"
	else if((word1 == cultwords["travel"] && word2 == cultwords["blood"] && word3 == cultwords["self"]))
		return "Drain"
	else if((word1 == cultwords["see"] && word2 == cultwords["hell"] && word3 == cultwords["join"]))
		return "See Invisible"
	else if((word1 == cultwords["blood"] && word2 == cultwords["join"] && word3 == cultwords["hell"]))
		return "Raise Dead"
	else if((word1 == cultwords["hide"] && word2 == cultwords["see"] && word3 == cultwords["blood"]))
		return "Hide Runes"
	else if((word1 == cultwords["hell"] && word2 == cultwords["travel"] && word3 == cultwords["self"]))
		return "Astral Journey"
	else if((word1 == cultwords["blood"] && word2 == cultwords["see"] && word3 == cultwords["travel"]))
		return "Manifest Ghost"
	else if((word1 == cultwords["hell"] && word2 == cultwords["technology"] && word3 == cultwords["join"]))
		return "Imbue Talisman"
	else if((word1 == cultwords["hell"] && word2 == cultwords["blood"] && word3 == cultwords["join"]))
		return "Sacrifice"
	else if((word1 == cultwords["blood"] && word2 == cultwords["see"] && word3 == cultwords["hide"]))
		return "Reveal Runes"
	else if((word1 == cultwords["destroy"] && word2 == cultwords["travel"] && word3 == cultwords["self"]))
		return "Wall"
	else if((word1 == cultwords["travel"] && word2 == cultwords["technology"] && word3 == cultwords["other"]))
		return "Free Cultist"
	else if((word1 == cultwords["join"] && word2 == cultwords["other"] && word3 == cultwords["self"]))
		return "Summon Cultist"
	else if((word1 == cultwords["hide"] && word2 == cultwords["other"] && word3 == cultwords["see"]))
		return "Deafen"
	else if((word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["other"]))
		return "Blind"
	else if((word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["blood"]))
		return "Blood Boil"
	else if((word1 == cultwords["self"] && word2 == cultwords["other"] && word3 == cultwords["technology"]))
		return "Communicate"
	else if((word1 == cultwords["travel"] && word2 == cultwords["other"]))
		return "Travel Other"
	else if((word1 == cultwords["join"] && word2 == cultwords["hide"] && word3 == cultwords["technology"]))
		return "Stun"
	else
		return null

var/list/uristrune_cache = list()

/obj/effect/rune/proc/get_uristrune(symbol_bits, animated = 0, bloodcolor = "#A10808")
	var/lookup = "[symbol_bits]-[animated]-[bloodcolor]"

	if(lookup in uristrune_cache)
		return uristrune_cache[lookup]

	var/icon/I = icon('icons/effects/uristrunes.dmi', "blank")

	for(var/i = 0, i < 10, i++)
		if(symbol_bits & (1 << i))
			I.Blend(icon('icons/effects/uristrunes.dmi', "rune-[1 << i]"), ICON_OVERLAY)

	var/finalblood = bloodcolor
	var/list/blood_hsl = rgb2hsl(GetRedPart(bloodcolor),GetGreenPart(bloodcolor),GetBluePart(bloodcolor))
	if(blood_hsl.len)
		var/list/blood_rbg = hsl2rgb(blood_hsl[1],blood_hsl[2],128)//producing a color that is neither too bright nor too dark
		if(blood_hsl.len)
			finalblood = rgb(blood_rbg[1],blood_rbg[2],blood_rbg[3])

	var/bc1 = finalblood
	var/bc2 = finalblood
	bc1 += "C8"
	bc2 += "64"
	I.SwapColor(rgb(0, 0, 0, 100), bc1)
	I.SwapColor(rgb(0, 0, 0, 50), bc1)

	for(var/x = 1, x <= 32, x++)
		for(var/y = 1, y <= 32, y++)
			var/p = I.GetPixel(x, y)

			if(p == null)
				var/n = I.GetPixel(x, y + 1)
				var/s = I.GetPixel(x, y - 1)
				var/e = I.GetPixel(x + 1, y)
				var/w = I.GetPixel(x - 1, y)

				if(n == "#000000" || s == "#000000" || e == "#000000" || w == "#000000")
					I.DrawBox(bc1, x, y)

				else
					var/ne = I.GetPixel(x + 1, y + 1)
					var/se = I.GetPixel(x + 1, y - 1)
					var/nw = I.GetPixel(x - 1, y + 1)
					var/sw = I.GetPixel(x - 1, y - 1)

					if(ne == "#000000" || se == "#000000" || nw == "#000000" || sw == "#000000")
						I.DrawBox(bc2, x, y)

	I.MapColors(0.5,0,0,0,0.5,0,0,0,0.5)//we'll darken that color a bit

	icon = I

	if(animated)//This masterpiece of a color matrix stack produces a nice animation no matter which color was the blood used for the rune.
		animate(src, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)//1
		animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)//2
		animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)//3
		animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)//4
		animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)//5
		animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
		animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
		animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
		animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)//9
		animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
		animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
		animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
		animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)//5
		animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)//4
		animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)//3
		animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)//2
