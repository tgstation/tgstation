// Here there are processes designed to work with the Cyrillic alphabet.
// In particular, most of the code that fixes the "ß" is right there.



/proc/strip_macros(t)
	t = replacetext(t, "\proper", "")
	t = replacetext(t, "\improper", "")
	return t

/proc/sanitize_russian(t)
	t = strip_macros(t)
	return replacetext(t, "ÿ", "&#x044f;")

/proc/russian_html2text(t)
	return replacetext(t, "&#x044f;", "&#255;")

/proc/russian_text2html(t)
	return replacetext(t, "&#255;", "&#x044f;")

/proc/rhtml_encode(t)
	t = rhtml_decode(t)
	t = strip_macros(t)
	var/list/c = splittext(t, "ÿ")
	if(c.len == 1)
		return html_encode(t)
	var/out = ""
	var/first = 1
	for(var/text in c)
		if(!first)
			out += "&#x044f;"
		first = 0
		out += html_encode(text)
	return out

/proc/rhtml_decode(var/t)
	t = replacetext(t, "&#x044f;", "ÿ")
	t = replacetext(t, "&#255;", "ÿ")
	t = html_decode(t)
	return t


/proc/char_split(t)
	. = list()
	for(var/x in 1 to length(t))
		. += copytext(t,x,x+1)

/proc/ruscapitalize(t)
	var/s = 2
	if (copytext(t,1,2) == ";")
		s += 1
	else if (copytext(t,1,2) == ":")
		if(copytext(t,3,4) == " ")
			s+=3
		else
			s+=2
	return r_uppertext(copytext(t, 1, s)) + copytext(t, s)

/proc/r_uppertext(text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 223)
			t += ascii2text(a - 32)
		else if (a == 184)
			t += ascii2text(168)
		else t += ascii2text(a)
	return uppertext(t)

/proc/r_lowertext(text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 191 && a < 224)
			t += ascii2text(a + 32)
		else if (a == 168)
			t += ascii2text(184)
		else t += ascii2text(a)
	return lowertext(t)

/proc/pointization(text)
	if (!text)
		return
	if (copytext(text,1,2) == "*") //Emotes allowed.
		return text
	if (copytext(text,-1) in list("!", "?", "."))
		return text
	text += "."
	return text

/proc/intonation(text)
	if (copytext(text,-1) == "!")
		text = "<b>[text]</b>"
	return text


GLOBAL_LIST_INIT(rus_unicode_conversion,list(
	"À" = "0410", "à" = "0430",
	"Á" = "0411", "á" = "0431",
	"Â" = "0412", "â" = "0432",
	"Ã" = "0413", "ã" = "0433",
	"Ä" = "0414", "ä" = "0434",
	"Å" = "0415", "å" = "0435",
	"Æ" = "0416", "æ" = "0436",
	"Ç" = "0417", "ç" = "0437",
	"È" = "0418", "è" = "0438",
	"É" = "0419", "é" = "0439",
	"Ê" = "041a", "ê" = "043a",
	"Ë" = "041b", "ë" = "043b",
	"Ì" = "041c", "ì" = "043c",
	"Í" = "041d", "í" = "043d",
	"Î" = "041e", "î" = "043e",
	"Ï" = "041f", "ï" = "043f",
	"Ð" = "0420", "ð" = "0440",
	"Ñ" = "0421", "ñ" = "0441",
	"Ò" = "0422", "ò" = "0442",
	"Ó" = "0423", "ó" = "0443",
	"Ô" = "0424", "ô" = "0444",
	"Õ" = "0425", "õ" = "0445",
	"Ö" = "0426", "ö" = "0446",
	"×" = "0427", "÷" = "0447",
	"Ø" = "0428", "ø" = "0448",
	"Ù" = "0429", "ù" = "0449",
	"Ú" = "042a", "ú" = "044a",
	"Û" = "042b", "û" = "044b",
	"Ü" = "042c", "ü" = "044c",
	"Ý" = "042d", "ý" = "044d",
	"Þ" = "042e", "þ" = "044e",
	"ß" = "042f", "ÿ" = "044f",

	"¨" = "0401", "¸" = "0451"
	))

GLOBAL_LIST_INIT(rus_unicode_fix,null)

/proc/r_text2unicode(text)
	text = strip_macros(text)
	text = russian_text2html(text)

	for(var/s in GLOB.rus_unicode_conversion)
		text = replacetext(text, s, "&#x[GLOB.rus_unicode_conversion[s]];")

	return text

/proc/r_text2ascii(t)
	t = replacetext(t, "&#x044f;", "ÿ")
	t = replacetext(t, "&#255;", "ÿ")
	var/output = ""
	var/L = lentext(t)
	for(var/i = 1 to L)
		output += "&#[text2ascii(t,i)];"
	return output

/proc/sanitize_russian_list(list)
	for(var/i in list)
		if(islist(i))
			sanitize_russian_list(i)

		if(list[i])
			if(istext(list[i]))
				list[i] = sanitize_russian(list[i])
			else if(islist(list[i]))
				sanitize_russian_list(list[i])


/proc/r_json_encode(json_data)
	if(!GLOB.rus_unicode_fix)
		GLOB.rus_unicode_fix = list()
		for(var/s in GLOB.rus_unicode_conversion)
			if(s == "ÿ")
				GLOB.rus_unicode_fix["&#x044f;"] = "\\u[GLOB.rus_unicode_conversion[s]]"
				continue

			GLOB.rus_unicode_fix[copytext(json_encode(s), 2, -1)] = "\\u[GLOB.rus_unicode_conversion[s]]"

	sanitize_russian_list(json_data)
	var/json = json_encode(json_data)

	for(var/s in GLOB.rus_unicode_fix)
		json = replacetext(json, s, GLOB.rus_unicode_fix[s])

	return json