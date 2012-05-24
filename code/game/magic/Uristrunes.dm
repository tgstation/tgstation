
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



/proc/get_uristrune_cult(word1, word2, word3)
	var/animated

	if((word1 == wordtravel && word2 == wordself)						\
	|| (word1 == wordjoin && word2 == wordblood && word3 == wordself)	\
	|| (word1 == wordhell && word2 == wordjoin && word3 == wordself)	\
	|| (word1 == wordsee && word2 == wordblood && word3 == wordhell)	\
	|| (word1 == worddestr && word2 == wordsee && word3 == wordtech)	\
	|| (word1 == wordtravel && word2 == wordblood && word3 == wordself)	\
	|| (word1 == wordsee && word2 == wordhell && word3 == wordjoin)		\
	|| (word1 == wordblood && word2 == wordjoin && word3 == wordhell)	\
	|| (word1 == wordhide && word2 == wordsee && word3 == wordblood)	\
	|| (word1 == wordhell && word2 == wordtravel && word3 == wordself)	\
	|| (word1 == wordblood && word2 == wordsee && word3 == wordtravel)	\
	|| (word1 == wordhell && word2 == wordtech && word3 == wordjoin)	\
	|| (word1 == wordhell && word2 == wordblood && word3 == wordjoin)	\
	|| (word1 == wordblood && word2 == wordsee && word3 == wordhide)	\
	|| (word1 == worddestr && word2 == wordtravel && word3 == wordself)	\
	|| (word1 == wordtravel && word2 == wordtech && word3 == wordother)	\
	|| (word1 == wordjoin && word2 == wordother && word3 == wordself)	\
	|| (word1 == wordhide && word2 == wordother && word3 == wordsee)	\
	|| (word1 == worddestr && word2 == wordsee && word3 == wordother)	\
	|| (word1 == worddestr && word2 == wordsee && word3 == wordblood)	\
	|| (word1 == wordself && word2 == wordother && word3 == wordtech)	\
	|| (word1 == wordtravel && word2 == wordother)						\
	|| (word1 == wordjoin && word2 == wordhide && word3 == wordtech)	)
		animated = 1
	else
		animated = 0

	var/bits = word_to_uristrune_bit(word1) \
			 | word_to_uristrune_bit(word2) \
			 | word_to_uristrune_bit(word3)

	return get_uristrune(bits, animated)


var/list/uristrune_cache = list()

/proc/get_uristrune(symbol_bits, animated = 0)
	var/lookup = "[symbol_bits]-[animated]"

	if(lookup in uristrune_cache)
		return uristrune_cache[lookup]

	var/icon/I = icon('icons/effects/uristrunes.dmi', "blank")

	for(var/i = 0, i < 10, i++)
		if(symbol_bits & (1 << i))
			I.Blend(icon('icons/effects/uristrunes.dmi', "rune-[1 << i]"), ICON_OVERLAY)


	I.SwapColor(rgb(0, 0, 0, 100), rgb(100, 0, 0, 200))
	I.SwapColor(rgb(0, 0, 0, 50), rgb(150, 0, 0, 200))

	for(var/x = 1, x <= 32, x++)
		for(var/y = 1, y <= 32, y++)
			var/p = I.GetPixel(x, y)

			if(p == null)
				var/n = I.GetPixel(x, y + 1)
				var/s = I.GetPixel(x, y - 1)
				var/e = I.GetPixel(x + 1, y)
				var/w = I.GetPixel(x - 1, y)

				if(n == "#000000" || s == "#000000" || e == "#000000" || w == "#000000")
					I.DrawBox(rgb(200, 0, 0, 200), x, y)

				else
					var/ne = I.GetPixel(x + 1, y + 1)
					var/se = I.GetPixel(x + 1, y - 1)
					var/nw = I.GetPixel(x - 1, y + 1)
					var/sw = I.GetPixel(x - 1, y - 1)

					if(ne == "#000000" || se == "#000000" || nw == "#000000" || sw == "#000000")
						I.DrawBox(rgb(200, 0, 0, 100), x, y)

	var/icon/result = icon(I, "")

	result.Insert(I,  "", frame = 1, delay = 10)

	if(animated == 1)
		var/icon/I2 = icon(I, "")
		I2.MapColors(rgb(0xff,0x0c,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0xff))
		I2.SetIntensity(1.04)

		var/icon/I3 = icon(I, "")
		I3.MapColors(rgb(0xff,0x18,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0xff))
		I3.SetIntensity(1.08)

		var/icon/I4 = icon(I, "")
		I4.MapColors(rgb(0xff,0x24,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0xff))
		I4.SetIntensity(1.12)

		var/icon/I5 = icon(I, "")
		I5.MapColors(rgb(0xff,0x30,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0xff))
		I5.SetIntensity(1.16)

		result.Insert(I2, "", frame = 2, delay = 4)
		result.Insert(I3, "", frame = 3, delay = 3)
		result.Insert(I4, "", frame = 4, delay = 2)
		result.Insert(I5, "", frame = 5, delay = 6)
		result.Insert(I4, "", frame = 6, delay = 2)
		result.Insert(I3, "", frame = 7, delay = 2)
		result.Insert(I2, "", frame = 8, delay = 2)

		uristrune_cache[lookup] = result

	return result
