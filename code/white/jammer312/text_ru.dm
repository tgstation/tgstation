#define UPC "я"
#define PHC "&#1103;"
#define PHCH "&#x044f;"
#define PBC "&#255;"

//html uses "&#1103;" (unicode), byond dialogs use "&#255;" (ascii)

//convesion stuff

/proc/ph_to_pb(text)
	return replacetext(text,PHC,PBC)

/proc/pb_to_ph(text)
	return replacetext(text,PBC,PHC)

GLOBAL_LIST_INIT(rus_unicode_conversion,list(
	"А" = "1040", "а" = "1072",
	"Б" = "1041", "б" = "1073",
	"В" = "1042", "в" = "1074",
	"Г" = "1043", "г" = "1075",
	"Д" = "1044", "д" = "1076",
	"Е" = "1045", "е" = "1077",
	"Ж" = "1046", "ж" = "1078",
	"З" = "1047", "з" = "1079",
	"И" = "1048", "и" = "1080",
	"Й" = "1049", "й" = "1081",
	"К" = "1050", "к" = "1082",
	"Л" = "1051", "л" = "1083",
	"М" = "1052", "м" = "1084",
	"Н" = "1053", "н" = "1085",
	"О" = "1054", "о" = "1086",
	"П" = "1055", "п" = "1087",
	"Р" = "1056", "р" = "1088",
	"С" = "1057", "с" = "1089",
	"Т" = "1058", "т" = "1090",
	"У" = "1059", "у" = "1091",
	"Ф" = "1060", "ф" = "1092",
	"Х" = "1061", "х" = "1093",
	"Ц" = "1062", "ц" = "1094",
	"Ч" = "1063", "ч" = "1095",
	"Ш" = "1064", "ш" = "1096",
	"Щ" = "1065", "щ" = "1097",
	"Ъ" = "1066", "ъ" = "1098",
	"Ы" = "1067", "ы" = "1099",
	"Ь" = "1068", "ь" = "1100",
	"Э" = "1069", "э" = "1101",
	"Ю" = "1070", "ю" = "1102",
	"Я" = "1071", "я" = "1103",

	"Ё" = "1025", "ё" = "1105"
	))

GLOBAL_LIST_INIT(rus_unicode_conversion_hex,list(
	"А" = "0410", "а" = "0430",
	"Б" = "0411", "б" = "0431",
	"В" = "0412", "в" = "0432",
	"Г" = "0413", "г" = "0433",
	"Д" = "0414", "д" = "0434",
	"Е" = "0415", "е" = "0435",
	"Ж" = "0416", "ж" = "0436",
	"З" = "0417", "з" = "0437",
	"И" = "0418", "и" = "0438",
	"Й" = "0419", "й" = "0439",
	"К" = "041a", "к" = "043a",
	"Л" = "041b", "л" = "043b",
	"М" = "041c", "м" = "043c",
	"Н" = "041d", "н" = "043d",
	"О" = "041e", "о" = "043e",
	"П" = "041f", "п" = "043f",
	"Р" = "0420", "р" = "0440",
	"С" = "0421", "с" = "0441",
	"Т" = "0422", "т" = "0442",
	"У" = "0423", "у" = "0443",
	"Ф" = "0424", "ф" = "0444",
	"Х" = "0425", "х" = "0445",
	"Ц" = "0426", "ц" = "0446",
	"Ч" = "0427", "ч" = "0447",
	"Ш" = "0428", "ш" = "0448",
	"Щ" = "0429", "щ" = "0449",
	"Ъ" = "042a", "ъ" = "044a",
	"Ы" = "042b", "ы" = "044b",
	"Ь" = "042c", "ь" = "044c",
	"Э" = "042d", "э" = "044d",
	"Ю" = "042e", "ю" = "044e",
	"Я" = "042f", "я" = "044f",

	"Ё" = "0401", "ё" = "0451"
	))

GLOBAL_LIST_INIT(rus_unicode_fix,null)

/proc/up2ph(text)
	text = strip_macros(text)
	text = pb_to_ph(text)

	for(var/s in GLOB.rus_unicode_conversion)
		text = replacetext(text, s, "&#[GLOB.rus_unicode_conversion[s]];")

	return text

/proc/ph2up(text) //dumb as fuck but necessary
	for(var/s in GLOB.rus_unicode_conversion)
		text = replacetext(text, "&#[GLOB.rus_unicode_conversion[s]];",s)
	return text

/proc/pa2pb(t)
	t = replacetext(t, PHC, UPC)
	t = replacetext(t, PBC, UPC)
	var/output = ""
	var/L = lentext(t)
	for(var/i = 1 to L)
		output += "&#[text2ascii(t,i)];"
	return output

//utility stuff

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

/proc/ruscapitalize(t)
	var/s = 1
	if (copytext(t,1,2) == ";" || copytext(t,1,2) == "#")
		s += 1
	else if (copytext(t,1,2) == ":")
		s += 2
	s = findtext(t, regex("\[^ \]","g"), s) + 1
	return r_uppertext(copytext(t, 1, s)) + copytext(t, s)

//sanitization shit

/proc/strip_macros(t)
	t = replacetext(t, "\proper", "")
	t = replacetext(t, "\improper", "")
	return t

/proc/sanitize_russian(t)
	t = strip_macros(t)
	return replacetext(t, UPC, PHC)

/proc/sanitize_russian_list(list) //recursive variant
	for(var/i in list)
		if(islist(i))
			sanitize_russian_list(i)

		if(list[i])
			if(istext(list[i]))
				list[i] = sanitize_russian(list[i])
			else if(islist(list[i]))
				sanitize_russian_list(list[i])

/proc/rhtml_encode(t)
	t = strip_macros(t)
	t = rhtml_decode(t)
	var/list/c = splittext(t, UPC)
	if(c.len == 1)
		return html_encode(t)
	var/out = ""
	var/first = 1
	for(var/text in c)
		if(!first)
			out += PHC
		first = 0
		out += html_encode(text)
	return out

proc/rhtml_decode(var/t)
	t = replacetext(t, PHC, UPC)
	t = replacetext(t, PBC, UPC)
	t = html_decode(t)
	return t

/proc/r_json_encode(json_data)
	if(!GLOB.rus_unicode_fix) // Генерируем табилцу замены
		GLOB.rus_unicode_fix = list()
		for(var/s in GLOB.rus_unicode_conversion_hex)
			if(s == UPC) // UPC breaks json_encode, so here is workaround
				GLOB.rus_unicode_fix[PHC] = "\\u[GLOB.rus_unicode_conversion_hex[s]]"
				continue

			GLOB.rus_unicode_fix[copytext(json_encode(s), 2, -1)] = "\\u[GLOB.rus_unicode_conversion_hex[s]]"

	sanitize_russian_list(json_data)
	var/json = json_encode(json_data)

	for(var/s in GLOB.rus_unicode_fix)
		json = replacetext(json, s, GLOB.rus_unicode_fix[s])

	return json

#undef UPC
#undef PHC
#undef PHCH
#undef PBC