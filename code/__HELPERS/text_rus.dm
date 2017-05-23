// Тут лежат процессы, предназначенные для работы с кириллицей.
// В частности, большая часть кода, фиксящего "я", находится именно тут.
// Документация тоже туточки. Читаем и мотаем на ус.

/*
Суть фикса "я":

Эта ублюдочная буква имеет код символа 255, а он зарезервирован в BYOND для своих ублюдочных целей.
В частности, "я" (0xFF) используется как первый байт "макросов" \proper, \improper, \red, \green и подобных им.
Да, BYOND юзает свою собственную двухбайтовую кодировку в качестве надстройки над ASCII. Браво макакам-разработчикам!

Чтобы "я" отображалась нормально, не исчезала и не пыталась красить цвет в зелёный, необходимо заменять её HTML-кодом символа.
Однако этот процесс ломает "макросы" бьенда. Обычно они не отображаются, но после замены "я" на код они вылезают в виде "я~" или "y~", где "~" - хуита.
Поэтому самые частые макросы, \proper, \improper и \t, мы тоже выпилим.


Буква "я" должна заменяться, либо на входе, либо на выходе, процессами:
  sanitize_russian() - заменяет "я" и срезает макросы.
  rhtml_encode() - заменяет "я", срезает макросы и эскейпит HTML вшитыми средствами бьенда. Полезно на большинстве входов.

Замена происходит на "&#x044f;" - HTML код "я", стандарт Unicode.
Этот стандарт юзается HTML-окошками, на которых держатся почти все интерфейсы.

По дефолту в фиксе "я" эти процессы вставляются в stripped_input(), stripped_multiline_input() и reject_bad_text().
Это покрывает собой почти все входы, используемые игроками.

Ещё в reject_bad_text() закомментирована строчка "//if(127 to 255) return", которая заставляет реджектор слать кириллицу лесом.


Есть ещё один нужный процесс:
  russian_html2text(msg) - заменяет "&#x044f;" на "&#255;", стандарт CP1251.

Нужен он потому, что чат и не-HTML часть интерфейсов бьенда принимает только кодировку системы, а она у нас CP1251.
По дефолту используется в to_chat() и везде, где нужно вывести русский текст в бьендоокна вроде input().
Ещё Win-1251 используется в "name" объектов, но кириллица в "name" в любом случае вызывает дохуя проблем. Видите такое говно - смело выпиливайие.
*/

/*
Суть фикса TG UI:

Все динамические данные попадают в TG UI в виде JSON-объектов. Объекты берутся из бьендопроцесса json_encode().
Вот только этот процесс считает, что на входе всегда CP1292, и переубедить его нельзя. Как результат, русские буквы кодируются в абракадабру.
К тому же "буква 255" и тут выходит боком: бьенд режет её и символ за ней, принимая их за макрос.

JSON на выходе - строго ASCII, строки закодированы в Unicode, все Unicode-символы имеют вид "\u0000", где 0000 - код символа.

Процесс r_json_encode() - обёртка над json_encode().
Перед энкодом он заменяет "я" на код. После энкода заменяет коды всех "кривых" символов на правильные руские, и TG UI начинают работать как надо.
*/


// Срезает бьендовые "макросы" с текста.
/proc/strip_macros(t)
	t = replacetext(t, "\proper", "")
	t = replacetext(t, "\improper", "")
	t = replacetext(t, "я!", "")
	return t

// Меняет "я" на код, попутно срезая макросы.
/proc/sanitize_russian(t)
	t = strip_macros(t)
	return replacetext(t, "я", "&#x044f;")

// Меняет стандарт "я" с Unicode на CP1251
/proc/russian_html2text(t)
	return replacetext(t, "&#x044f;", "&#255;")

// Меняет стандарт "я" с CP1251 на Unicode
/proc/russian_text2html(t)
	return replacetext(t, "&#255;", "&#x044f;")

// Срезает макросы, меняет "я" на код И эскейпит HTML-символы.
// Никогда не пропускайте текст через эту функцию больше чем один раз, на выходе будет каша.
/proc/rhtml_encode(t)
	t = strip_macros(t)
	var/list/c = splittext(t, "я")
	if(c.len == 1)
		return t
	var/out = ""
	var/first = 1
	for(var/text in c)
		if(!first)
			out += "&#x044f;"
		first = 0
		out += html_encode(text)
	return out

// По идее меняет коды символов обратно на "я" и меняет HTML-эскейп обратно на символы.
// На деле не используется, ибо зачем?
/proc/rhtml_decode(var/t)
	t = replacetext(t, "&#x044f;", "я")
	t = replacetext(t, "&#255;", "я")
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


var/list/rus_unicode_conversion = list(
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
	)

var/list/rus_unicode_fix = null

// Кодирует все русские символы в HTML-коды Unicode, попутно срезая макросы.
/proc/r_text2unicode(text)
	text = strip_macros(text)
	text = russian_text2html(text)

	for(var/s in rus_unicode_conversion)
		text = replacetext(text, s, "&#x[rus_unicode_conversion[s]];")

	return text

// Рекуривно заменяет "я" на код в листе
/proc/sanitize_russian_list(list)
	for(var/i in list)
		if(islist(i))
			sanitize_russian_list(i)

		if(list[i])
			if(istext(list[i]))
				list[i] = sanitize_russian(list[i])
			else if(islist(list[i]))
				sanitize_russian_list(list[i])


// Фиксит русский Unicode в сгенерированных json_encode() JSON.
/proc/r_json_encode(json_data)
	if(!rus_unicode_fix) // Генерируем табилцу замены
		rus_unicode_fix = list()
		for(var/s in rus_unicode_conversion)
			if(s == "я") // Буква 255 ломается юникодером, с ней разбираемся отдельно.
				rus_unicode_fix["&#x044f;"] = "\\u[rus_unicode_conversion[s]]"
				continue

			rus_unicode_fix[copytext(json_encode(s), 2, -1)] = "\\u[rus_unicode_conversion[s]]"

	sanitize_russian_list(json_data)
	var/json = json_encode(json_data)

	for(var/s in rus_unicode_fix)
		json = replacetext(json, s, rus_unicode_fix[s])

	return json
