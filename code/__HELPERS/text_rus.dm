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
Поэтому самые честые макросы, \proper и \improper, мы тоже выпилим.


Буква "я" на входах (input(), входные значения verbs, загрузка из файлов) заменяется процессами:
  sanitize_russian() - заменяет "я" и срезает макросы.
  rhtml_encode() - заменяет "я", срезает макросы и эскейпит HTML вшитыми средствами бьенда. Полезно на большинстве входов.

Замена происходит на "&#x44F;" - HTML код "я", стандарт Unicode.
Этот стандарт юзается HTML-окошками, на которых держатся почти все интерфейсы.

По дефолту в фиксе "я" эти процессы вставляются в stripped_input(), stripped_multiline_input() и reject_bad_text().
Это покрывает собой почти все входы, используемые игроками. Остальные нужно менять вручную.

Ещё в reject_bad_text() закомментирована строчка "//if(127 to 255) return", которая заставляет реджектор слать кириллицу лесом.


Есть ещё один нужный процесс:
  russian_html2text(msg) - заменяет "&#x44F;" на "&#255;", стандарт CP1251.

Нужен он потому, что чат и не-HTML часть интерфейсов бьенда принимает только кодировку системы, а она у нас CP1251.
По дефолту используется в to_chat() и везде, где нужно вывести русский текст в бьендоокна вроде input().
Ещё Win-1251 используется в "name" объектов, но кириллица в "name" в любом случае вызывает дохуя проблем. Видите такое говно - смело выпиливайие.
*/

/*
Суть фикса TG UI:

!!!WIP!!!

*/


// Срезает бьендовые "макросы" с текста.
/proc/strip_macros(t)
	t = replacetext(t, "\proper", "")
	t = replacetext(t, "\improper", "")
	return t

// Меняет "я" на код, попутно срезая макросы.
/proc/sanitize_russian(t)
	t = strip_macros(t)
	return replacetext(t, "я", "&#x44F;")

// Меняет стандарт "я" с Unicode на CP1251
/proc/russian_html2text(t)
	return replacetext(t, "&#x44F;", "&#255;")

// Меняет стандарт "я" с CP1251 на Unicode
/proc/russian_text2html(t)
	return replacetext(t, "&#255;", "&#x44F;")

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
			out += "&#x44F;"
		first = 0
		out += html_encode(text)
	return out

// По идее меняет коды символов обратно на "я" и меняет HTML-эскейп обратно на символы.
// На деле не используется, ибо зачем?
/proc/rhtml_decode(var/t)
	t = replacetext(t, "&#x44F;", "я")
	t = replacetext(t, "&#255;", "я")
	t = html_decode(t)
	return t


/proc/char_split(t)
	. = list()
	for(var/x in 1 to length(t))
		. += copytext(t,x,x+1)

/proc/uppertext_uni(text)
	var/rep = "Я"
	var/index = findtext(text, "я")
	while(index)
		text = copytext(text, 1, index) + rep + copytext(text, index + 1)
		index = findtext(text, "я")
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 223)
			t += ascii2text(a - 32)
		else if (a == 184)
			t += ascii2text(168)
		else t += ascii2text(a)
	return t

/proc/lowertext_uni(text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 191 && a < 224)
			t += ascii2text(a + 32)
		else if (a == 168)
			t += ascii2text(184)
		else t += ascii2text(a)
	return t

/proc/ruscapitalize(t)
	var/s = 2
	if (copytext(t,1,2) == ";")
		s += 1
	else if (copytext(t,1,2) == ":")
		if(copytext(t,3,4) == " ")
			s+=3
		else
			s+=2
	return upperrustext(copytext(t, 1, s)) + copytext(t, s)

/proc/upperrustext(text)
	var/rep = "&#223;"
	var/index = findtext(text, "я")
	while(index)
		text = copytext(text, 1, index) + rep + copytext(text, index + 1)
		index = findtext(text, "я")
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 223)
			t += ascii2text(a - 32)
		else if (a == 184)
			t += ascii2text(168)
		else t += ascii2text(a)
	return t

/proc/lowerrustext(text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 191 && a < 224)
			t += ascii2text(a + 32)
		else if (a == 168)
			t += ascii2text(184)
		else t += ascii2text(a)
	return t

/proc/capitalize_uni(var/t)
	var/s = 2
	if (copytext(t,1,2) == ";")
		s += 1
	else if (copytext(t,1,2) == ":")
		if(copytext(t,3,4) == " ")
			s+=3
		else
			s+=2
	return pointization(uppertext_uni(copytext(t, 1, s)) + copytext(t, s))

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
	"А" = "&#x410;", "а" = "&#x430;",
	"Б" = "&#x411;", "б" = "&#x431;",
	"В" = "&#x412;", "в" = "&#x432;",
	"Г" = "&#x413;", "г" = "&#x433;",
	"Д" = "&#x414;", "д" = "&#x434;",
	"Е" = "&#x415;", "е" = "&#x435;",
	"Ж" = "&#x416;", "ж" = "&#x436;",
	"З" = "&#x417;", "з" = "&#x437;",
	"И" = "&#x418;", "и" = "&#x438;",
	"Й" = "&#x419;", "й" = "&#x439;",
	"К" = "&#x41A;", "к" = "&#x43A;",
	"Л" = "&#x41B;", "л" = "&#x43B;",
	"М" = "&#x41C;", "м" = "&#x43C;",
	"Н" = "&#x41D;", "н" = "&#x43D;",
	"О" = "&#x41E;", "о" = "&#x43E;",
	"П" = "&#x41F;", "п" = "&#x43F;",
	"Р" = "&#x420;", "р" = "&#x440;",
	"С" = "&#x421;", "с" = "&#x441;",
	"Т" = "&#x422;", "т" = "&#x442;",
	"У" = "&#x423;", "у" = "&#x443;",
	"Ф" = "&#x424;", "ф" = "&#x444;",
	"Х" = "&#x425;", "х" = "&#x445;",
	"Ц" = "&#x426;", "ц" = "&#x446;",
	"Ч" = "&#x427;", "ч" = "&#x447;",
	"Ш" = "&#x428;", "ш" = "&#x448;",
	"Щ" = "&#x429;", "щ" = "&#x449;",
	"Ъ" = "&#x42A;", "ъ" = "&#x44A;",
	"Ы" = "&#x42B;", "ы" = "&#x44B;",
	"Ь" = "&#x42C;", "ь" = "&#x44C;",
	"Э" = "&#x42D;", "э" = "&#x44D;",
	"Ю" = "&#x42E;", "ю" = "&#x44E;",
	"Я" = "&#x42F;", "я" = "&#x44F;",

	"Ё" = "&#x401;", "ё" = "&#x451;"
	)

// Кодирует все русские символы в HTML-коды Unicode, попутно срезая макросы.
/proc/russian_text2unicode(text)
	text = strip_macros(text)
	text = russian_text2html(text)

	for(var/s in rus_unicode_conversion)
		text = replacetext(text, s, rus_unicode_conversion[s])

	return text

