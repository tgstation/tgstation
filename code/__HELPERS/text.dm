/*
 * Holds procs designed to help with filtering text
 * Contains groups:
 * SQL sanitization/formating
 * Text sanitization
 * Text searches
 * Text modification
 * Misc
 */


/*
 * SQL sanitization
 */

/proc/format_table_name(table as text)
	return CONFIG_GET(string/feedback_tableprefix) + table

/*
 * Text sanitization
 */


///returns nothing with an alert instead of the message if it contains something in the ic filter, and sanitizes normally if the name is fine. It returns nothing so it backs out of the input the same way as if you had entered nothing.
/proc/sanitize_name(target, allow_numbers = FALSE, cap_after_symbols = TRUE)
	if(is_ic_filtered(target) || is_soft_ic_filtered(target))
		tgui_alert(usr, "You cannot set a name that contains a word prohibited in IC chat!")
		return ""
	var/result = reject_bad_name(target, allow_numbers = allow_numbers, strict = TRUE, cap_after_symbols = cap_after_symbols)
	if(!result)
		tgui_alert(usr, "Invalid name.")
		return ""
	return sanitize(result)


/// Runs byond's html encoding sanitization proc, after replacing new-lines and tabs for the # character.
/proc/sanitize(text)
	var/static/regex/regex = regex(@"[\n\t]", "g")
	return html_encode(regex.Replace(text, "#"))


/// Runs STRIP_HTML_SIMPLE and sanitize.
/proc/strip_html(text, limit = MAX_MESSAGE_LEN)
	return sanitize(STRIP_HTML_SIMPLE(text, limit))


/// Runs STRIP_HTML_FULL and sanitize.
/proc/strip_html_full(text, limit = MAX_MESSAGE_LEN)
	return sanitize(STRIP_HTML_FULL(text, limit))


/// Runs STRIP_HTML_SIMPLE and byond's sanitization proc.
/proc/adminscrub(text, limit = MAX_MESSAGE_LEN)
	return html_encode(STRIP_HTML_SIMPLE(text, limit))


/**
 * Perform a whitespace cleanup on the text, similar to what HTML renderers do
 *
 * This is useful if you want to better predict how text is going to look like when displaying it to a user.
 * HTML renderers collapse multiple whitespaces into one, trims prepending and appending spaces, among other things. This proc attempts to do the same thing.
 * HTML5 defines whitespace pretty much exactly like regex defines the `\s` group, `[ \t\r\n\f]`.
 *
 * Arguments:
 * * t - The text to "render"
 */
/proc/htmlrendertext(t)
	// Trim "whitespace" by lazily capturing word characters in the middle
	var/static/regex/matchMiddle = new(@"^\s*([\W\w]*?)\s*$")
	if(matchMiddle.Find(t) == 0)
		return t
	t = matchMiddle.group[1]

	// Replace any non-space whitespace characters with spaces, and also multiple occurences with just one space
	var/static/regex/matchSpacing = new(@"\s+", "g")
	t = replacetext(t, matchSpacing, " ")

	return t


/**
 * Returns the text if properly formatted, or null else.
 *
 * Things considered improper:
 * * Larger than max_length.
 * * Presence of non-ASCII characters if asci_only is set to TRUE.
 * * Only whitespaces, tabs and/or line breaks in the text.
 * * Presence of the <, >, \ and / characters.
 * * Presence of ASCII special control characters (horizontal tab and new line not included).
 * */
/proc/reject_bad_text(text, max_length = 512, ascii_only = TRUE)
	if(ascii_only)
		if(length(text) > max_length)
			return null
		var/static/regex/non_ascii = regex(@"[^\x20-\x7E\t\n]")
		if(non_ascii.Find(text))
			return null
	else if(length_char(text) > max_length)
		return null
	var/static/regex/non_whitespace = regex(@"\S")
	if(!non_whitespace.Find(text))
		return null
	var/static/regex/bad_chars = regex(@"[\\<>/\x00-\x08\x11-\x1F]")
	if(bad_chars.Find(text))
		return null
	return text


/**
 * Used to get a properly sanitized input. Returns null if cancel is pressed.
 *
 * Arguments
 ** user - Target of the input prompt.
 ** message - The text inside of the prompt.
 ** title - The window title of the prompt.
 ** max_length - If you intend to impose a length limit - default is 1024.
 ** no_trim - Prevents the input from being trimmed if you intend to parse newlines or whitespace.
*/
/proc/stripped_input(mob/user, message = "", title = "", default = "", max_length=MAX_MESSAGE_LEN, no_trim=FALSE)
	var/user_input = input(user, message, title, default) as text|null
	if(isnull(user_input)) // User pressed cancel
		return
	if(no_trim)
		return copytext(html_encode(user_input), 1, max_length)
	else
		return trim(html_encode(user_input), max_length) //trim is "outside" because html_encode can expand single symbols into multiple symbols (such as turning < into &lt;)

/**
 * Used to get a properly sanitized input in a larger box. Works very similarly to stripped_input.
 *
 * Arguments
 ** user - Target of the input prompt.
 ** message - The text inside of the prompt.
 ** title - The window title of the prompt.
 ** max_length - If you intend to impose a length limit - default is 1024.
 ** no_trim - Prevents the input from being trimmed if you intend to parse newlines or whitespace.
*/
/proc/stripped_multiline_input(mob/user, message = "", title = "", default = "", max_length=MAX_MESSAGE_LEN, no_trim=FALSE)
	var/user_input = input(user, message, title, default) as message|null
	if(isnull(user_input)) // User pressed cancel
		return
	if(no_trim)
		return copytext(html_encode(user_input), 1, max_length)
	else
		return trim(html_encode(user_input), max_length)

#define NO_CHARS_DETECTED 0
#define SPACES_DETECTED 1
#define SYMBOLS_DETECTED 2
#define NUMBERS_DETECTED 3
#define LETTERS_DETECTED 4

/**
 * Filters out undesirable characters from names.
 *
 * * strict - return null immidiately instead of filtering out
 * * allow_numbers - allows numbers and common special characters - used for silicon/other weird things names
 * * cap_after_symbols - words like Bob's will be capitalized to Bob'S by default. False is good for titles.
 */
/proc/reject_bad_name(t_in, allow_numbers = FALSE, max_length = MAX_NAME_LEN, ascii_only = TRUE, strict = FALSE, cap_after_symbols = TRUE)
	if(!t_in)
		return //Rejects the input if it is null

	var/number_of_alphanumeric = 0
	var/last_char_group = NO_CHARS_DETECTED
	var/t_out = ""
	var/t_len = length(t_in)
	var/charcount = 0
	var/char = ""

	// This is a sanity short circuit, if the users name is three times the maximum allowable length of name
	// We bail out on trying to process the name at all, as it could be a bug or malicious input and we dont
	// Want to iterate all of it.
	if(t_len > 3 * MAX_NAME_LEN)
		return
	for(var/i = 1, i <= t_len, i += length(char))
		char = t_in[i]
		switch(text2ascii(char))

			// A  .. Z
			if(65 to 90) //Uppercase Letters
				number_of_alphanumeric++
				last_char_group = LETTERS_DETECTED

			// a  .. z
			if(97 to 122) //Lowercase Letters
				if(last_char_group == NO_CHARS_DETECTED || last_char_group == SPACES_DETECTED || cap_after_symbols && last_char_group == SYMBOLS_DETECTED) //start of a word
					char = uppertext(char)
				number_of_alphanumeric++
				last_char_group = LETTERS_DETECTED

			// 0  .. 9
			if(48 to 57) //Numbers
				if(last_char_group == NO_CHARS_DETECTED || !allow_numbers) //suppress at start of string
					if(strict)
						return
					continue
				number_of_alphanumeric++
				last_char_group = NUMBERS_DETECTED
			// '  -  .
			if(39,45,46) //Common name punctuation
				if(last_char_group == NO_CHARS_DETECTED)
					if(strict)
						return
					continue
				last_char_group = SYMBOLS_DETECTED

			// ~   |   @  :  #  $  %  &  *  +
			if(126,124,64,58,35,36,37,38,42,43) //Other symbols that we'll allow (mainly for AI)
				if(last_char_group == NO_CHARS_DETECTED || !allow_numbers) //suppress at start of string
					if(strict)
						return
					continue
				last_char_group = SYMBOLS_DETECTED

			//Space
			if(32)
				if(last_char_group == NO_CHARS_DETECTED || last_char_group == SPACES_DETECTED) //suppress double-spaces and spaces at start of string
					if(strict)
						return
					continue
				last_char_group = SPACES_DETECTED

			if(127 to INFINITY)
				if(ascii_only)
					if(strict)
						return
					continue
				last_char_group = SYMBOLS_DETECTED //for now, we'll treat all non-ascii characters like symbols even though most are letters

			else
				continue
		t_out += char
		charcount++
		if(charcount >= max_length)
			break

	if(number_of_alphanumeric < 2)
		return //protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == SPACES_DETECTED)
		t_out = copytext_char(t_out, 1, -1) //removes the last character (in this case a space)

	for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai")) //prevents these common metagamey names
		if(cmptext(t_out,bad_name))
			return //(not case sensitive)

	// Protects against names containing IC chat prohibited words.
	if(is_ic_filtered(t_out) || is_soft_ic_filtered(t_out))
		return

	return t_out

#undef NO_CHARS_DETECTED
#undef SPACES_DETECTED
#undef NUMBERS_DETECTED
#undef LETTERS_DETECTED



//html_encode helper proc that returns the smallest non null of two numbers
//or 0 if they're both null (needed because of findtext returning 0 when a value is not present)
/proc/non_zero_min(a, b)
	if(!a)
		return b
	if(!b)
		return a
	return (a < b ? a : b)

//Checks if any of a given list of needles is in the haystack
/proc/text_in_list(haystack, list/needle_list, start=1, end=0)
	for(var/needle in needle_list)
		if(findtext(haystack, needle, start, end))
			return TRUE
	return FALSE

//Like above, but case sensitive
/proc/text_in_list_case(haystack, list/needle_list, start=1, end=0)
	for(var/needle in needle_list)
		if(findtextEx(haystack, needle, start, end))
			return TRUE
	return FALSE

//Adds 'char' ahead of 'text' until there are 'count' characters total
/proc/add_leading(text, count, char = " ")
	text = "[text]"
	var/charcount = count - length_char(text)
	var/list/chars_to_add[max(charcount + 1, 0)]
	return jointext(chars_to_add, char) + text

//Adds 'char' behind 'text' until there are 'count' characters total
/proc/add_trailing(text, count, char = " ")
	text = "[text]"
	var/charcount = count - length_char(text)
	var/list/chars_to_add[max(charcount + 1, 0)]
	return text + jointext(chars_to_add, char)

//Returns a string with reserved characters and spaces before the first letter removed
/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)
	return ""

//Returns a string with reserved characters and spaces after the first and last letters removed
//Like trim(), but very slightly faster. worth it for niche usecases
/proc/trim_reduced(text)
	var/starting_coord = 1
	var/text_len = length(text)
	for (var/i in 1 to text_len)
		if (text2ascii(text, i) > 32)
			starting_coord = i
			break

	for (var/i = text_len, i >= starting_coord, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, starting_coord, i + 1)

	if(starting_coord > 1)
		return copytext(text, starting_coord)
	return ""

/**
 * Truncate a string to the given length
 *
 * Will only truncate if the string is larger than the length and *ignores unicode concerns*
 *
 * This exists soley because trim does other stuff too.
 *
 * Arguments:
 * * text - String
 * * max_length - integer length to truncate at
 */
/proc/truncate(text, max_length)
	if(length(text) > max_length)
		return copytext(text, 1, max_length)
	return text

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text, max_length)
	if(max_length)
		text = copytext_char(text, 1, max_length)
	return trim_reduced(text)

//Returns a string with the first element of the string capitalized.
/proc/capitalize(t)
	. = t
	if(t)
		. = t[1]
		return uppertext(.) + copytext(t, 1 + length(.))

/proc/stringmerge(text,compare,replace = "*")
//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
	var/newtext = text
	var/text_it = 1 //iterators
	var/comp_it = 1
	var/newtext_it = 1
	var/text_length = length(text)
	var/comp_length = length(compare)
	while(comp_it <= comp_length && text_it <= text_length)
		var/a = text[text_it]
		var/b = compare[comp_it]
//if it isn't both the same letter, or if they are both the replacement character
//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext, 1, newtext_it) + b + copytext(newtext, newtext_it + length(newtext[newtext_it]))
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext, 1, newtext_it) + a + copytext(newtext, newtext_it + length(newtext[newtext_it]))
			else //The lists disagree, Uh-oh!
				return 0
		text_it += length(a)
		comp_it += length(b)
		newtext_it += length(newtext[newtext_it])

	return newtext

/proc/stringpercent(text,character = "*")
//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
	if(!text || !character)
		return 0
	var/count = 0
	var/lentext = length(text)
	var/a = ""
	for(var/i = 1, i <= lentext, i += length(a))
		a = text[i]
		if(a == character)
			count++
	return count

/proc/reverse_text(text = "")
	var/new_text = ""
	var/lentext = length(text)
	var/letter = ""
	for(var/i = 1, i <= lentext, i += length(letter))
		letter = text[i]
		new_text = letter + new_text
	return new_text

GLOBAL_LIST_INIT(zero_character_only, list("0"))
GLOBAL_LIST_INIT(hex_characters, list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"))
GLOBAL_LIST_INIT(alphabet, list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"))
GLOBAL_LIST_INIT(alphabet_upper, list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"))
GLOBAL_LIST_INIT(numerals, list("1","2","3","4","5","6","7","8","9","0"))
GLOBAL_LIST_INIT(space, list(" "))
GLOBAL_LIST_INIT(binary, list("0","1"))
/proc/random_string(length, list/characters)
	. = ""
	for(var/i in 1 to length)
		. += pick(characters)

/proc/repeat_string(times, string="")
	. = ""
	for(var/i in 1 to times)
		. += string

/proc/random_short_color()
	return random_string(3, GLOB.hex_characters)

/proc/random_color()
	return random_string(6, GLOB.hex_characters)

//merges non-null characters (3rd argument) from "from" into "into". Returns result
//e.g. into = "Hello World"
//     from = "Seeya______"
//     returns"Seeya World"
//The returned text is always the same length as into
//This was coded to handle DNA gene-splicing.
/proc/merge_text(into, from, null_char="_")
	. = ""
	if(!istext(into))
		into = ""
	if(!istext(from))
		from = ""
	var/null_ascii = istext(null_char) ? text2ascii(null_char, 1) : null_char
	var/copying_into = FALSE
	var/char = ""
	var/start = 1
	var/end_from = length(from)
	var/end_into = length(into)
	var/into_it = 1
	var/from_it = 1
	while(from_it <= end_from && into_it <= end_into)
		char = from[from_it]
		if(text2ascii(char) == null_ascii)
			if(!copying_into)
				. += copytext(from, start, from_it)
				start = into_it
				copying_into = TRUE
		else
			if(copying_into)
				. += copytext(into, start, into_it)
				start = from_it
				copying_into = FALSE
		into_it += length(into[into_it])
		from_it += length(char)

	if(copying_into)
		. += copytext(into, start)
	else
		. += copytext(from, start, from_it)
		if(into_it <= end_into)
			. += copytext(into, into_it)

//finds the first occurrence of one of the characters from needles argument inside haystack
//it may appear this can be optimised, but it really can't. findtext() is so much faster than anything you can do in byondcode.
//stupid byond :(
/proc/findchar(haystack, needles, start=1, end=0)
	var/char = ""
	var/len = length(needles)
	for(var/i = 1, i <= len, i += length(char))
		char = needles[i]
		. = findtextEx(haystack, char, start, end)
		if(.)
			return
	return 0

/proc/parsemarkdown_basic_step1(t, limited=FALSE)
	if(length(t) <= 0)
		return

	// This parses markdown with no custom rules

	// Escape backslashed

	t = replacetext(t, "$", "$-")
	t = replacetext(t, "\\\\", "$1")
	t = replacetext(t, "\\**", "$2")
	t = replacetext(t, "\\*", "$3")
	t = replacetext(t, "\\__", "$4")
	t = replacetext(t, "\\_", "$5")
	t = replacetext(t, "\\^", "$6")
	t = replacetext(t, "\\((", "$7")
	t = replacetext(t, "\\))", "$8")
	t = replacetext(t, "\\|", "$9")
	t = replacetext(t, "\\%", "$0")

	// Escape  single characters that will be used

	t = replacetext(t, "!", "$a")

	// Parse hr and small

	if(!limited)
		t = replacetext(t, "((", "<font size=\"1\">")
		t = replacetext(t, "))", "</font>")
		t = replacetext(t, regex("(-){3,}", "gm"), "<hr>")
		t = replacetext(t, regex("^\\((-){3,}\\)$", "gm"), "$1")

		// Parse lists

		var/list/tlist = splittext(t, "\n")
		var/tlistlen = tlist.len
		var/listlevel = -1
		var/singlespace = -1 // if 0, double spaces are used before asterisks, if 1, single are
		for(var/i in 1 to tlistlen)
			var/line = tlist[i]
			var/count_asterisk = length(replacetext(line, regex("\[^\\*\]+", "g"), ""))
			if(count_asterisk % 2 == 1 && findtext(line, regex("^\\s*\\*", "g"))) // there is an extra asterisk in the beggining

				var/count_w = length(replacetext(line, regex("^( *)\\*.*$", "g"), "$1")) // whitespace before asterisk
				line = replacetext(line, regex("^ *(\\*.*)$", "g"), "$1")

				if(singlespace == -1 && count_w == 2)
					if(listlevel == 0)
						singlespace = 0
					else
						singlespace = 1

				if(singlespace == 0)
					count_w = count_w % 2 ? round(count_w / 2 + 0.25) : count_w / 2

				line = replacetext(line, regex("\\*", ""), "<li>")
				while(listlevel < count_w)
					line = "<ul>" + line
					listlevel++
				while(listlevel > count_w)
					line = "</ul>" + line
					listlevel--

			else while(listlevel >= 0)
				line = "</ul>" + line
				listlevel--

			tlist[i] = line
		// end for

		t = tlist[1]
		for(var/i in 2 to tlistlen)
			t += "\n" + tlist[i]

		while(listlevel >= 0)
			t += "</ul>"
			listlevel--

	else
		t = replacetext(t, "((", "")
		t = replacetext(t, "))", "")

	// Parse headers

	t = replacetext(t, regex("^#(?!#) ?(.+)$", "gm"), "<h2>$1</h2>")
	t = replacetext(t, regex("^##(?!#) ?(.+)$", "gm"), "<h3>$1</h3>")
	t = replacetext(t, regex("^###(?!#) ?(.+)$", "gm"), "<h4>$1</h4>")
	t = replacetext(t, regex("^#### ?(.+)$", "gm"), "<h5>$1</h5>")

	// Parse most rules

	t = replacetext(t, regex("\\*(\[^\\*\]*)\\*", "g"), "<i>$1</i>")
	t = replacetext(t, regex("_(\[^_\]*)_", "g"), "<i>$1</i>")
	t = replacetext(t, "<i></i>", "!")
	t = replacetext(t, "</i><i>", "!")
	t = replacetext(t, regex("\\!(\[^\\!\]+)\\!", "g"), "<b>$1</b>")
	t = replacetext(t, regex("\\^(\[^\\^\]+)\\^", "g"), "<font size=\"4\">$1</font>")
	t = replacetext(t, regex("\\|(\[^\\|\]+)\\|", "g"), "<center>$1</center>")
	t = replacetext(t, "!", "</i><i>")

	return t

/proc/parsemarkdown_basic_step2(t)
	if(length(t) <= 0)
		return

	// Restore the single characters used

	t = replacetext(t, "$a", "!")

	// Redo the escaping

	t = replacetext(t, "$1", "\\")
	t = replacetext(t, "$2", "**")
	t = replacetext(t, "$3", "*")
	t = replacetext(t, "$4", "__")
	t = replacetext(t, "$5", "_")
	t = replacetext(t, "$6", "^")
	t = replacetext(t, "$7", "((")
	t = replacetext(t, "$8", "))")
	t = replacetext(t, "$9", "|")
	t = replacetext(t, "$0", "%")
	t = replacetext(t, "$-", "$")

	return t

/proc/parsemarkdown_basic(t, limited=FALSE)
	t = parsemarkdown_basic_step1(t, limited)
	t = parsemarkdown_basic_step2(t)
	return t

/proc/parsemarkdown(t, mob/user=null, limited=FALSE)
	if(length(t) <= 0)
		return

	// Premanage whitespace

	t = replacetext(t, regex("\[^\\S\\r\\n \]", "g"), "  ")

	t = parsemarkdown_basic_step1(t)

	t = replacetext(t, regex("%s(?:ign)?(?=\\s|$)", "igm"), user ? "<font face=\"[SIGNATURE_FONT]\"><i>[user.real_name]</i></font>" : "<span class=\"paper_field\"></span>")
	t = replacetext(t, regex("%f(?:ield)?(?=\\s|$)", "igm"), "<span class=\"paper_field\"></span>")

	t = parsemarkdown_basic_step2(t)

	// Manage whitespace

	t = replacetext(t, regex("(?:\\r\\n?|\\n)", "g"), "<br>")

	t = replacetext(t, "  ", "&nbsp;&nbsp;")

	// Done

	return t

/proc/text2charlist(text)
	var/char = ""
	var/lentext = length(text)
	. = list()
	for(var/i = 1, i <= lentext, i += length(char))
		char = text[i]
		. += char

/proc/rot13(text = "")
	var/lentext = length(text)
	var/char = ""
	var/ascii = 0
	. = ""
	for(var/i = 1, i <= lentext, i += length(char))
		char = text[i]
		ascii = text2ascii(char)
		switch(ascii)
			if(65 to 77, 97 to 109) //A to M, a to m
				ascii += 13
			if(78 to 90, 110 to 122) //N to Z, n to z
				ascii -= 13
		. += ascii2text(ascii)

//Takes a list of values, sanitizes it down for readability and character count,
//then exports it as a json file at data/npc_saves/[filename].json.
//As far as SS13 is concerned this is write only data. You can't change something
//in the json file and have it be reflected in the in game item/mob it came from.
//(That's what things like savefiles are for) Note that this list is not shuffled.
/proc/twitterize(list/proposed, filename, cullshort = 1, storemax = 1000)
	if(!islist(proposed) || !filename || !CONFIG_GET(flag/log_twitter))
		return

	//Regular expressions are, as usual, absolute magic
	//Any characters outside of 32 (space) to 126 (~) because treating things you don't understand as "magic" is really stupid
	var/regex/all_invalid_symbols = new(@"[^ -~]{1}")

	var/list/accepted = list()
	for(var/string in proposed)
		if(findtext(string,GLOB.is_website) || findtext(string,GLOB.is_email) || findtext(string,all_invalid_symbols) || !findtext(string,GLOB.is_alphanumeric))
			continue
		var/buffer = ""
		var/early_culling = TRUE
		var/lentext = length(string)
		var/let = ""

		for(var/pos = 1, pos <= lentext, pos += length(let))
			let = string[pos]
			if(!findtext(let, GLOB.is_alphanumeric))
				continue
			early_culling = FALSE
			buffer = copytext(string, pos)
			break
		if(early_culling) //Never found any letters! Bail!
			continue

		var/punctbuffer = ""
		var/cutoff = 0
		lentext = length_char(buffer)
		for(var/pos in 1 to lentext)
			let = copytext_char(buffer, -pos, -pos + 1)
			if(!findtext(let, GLOB.is_punctuation)) //This won't handle things like Nyaaaa!~ but that's fine
				break
			punctbuffer += let
			cutoff += length(let)
		if(punctbuffer) //We clip down excessive punctuation to get the letter count lower and reduce repeats. It's not perfect but it helps.
			var/exclaim = FALSE
			var/question = FALSE
			var/periods = 0
			lentext = length(punctbuffer)
			for(var/pos = 1, pos <= lentext, pos += length(let))
				let = punctbuffer[pos]
				if(!exclaim && findtext(let, "!"))
					exclaim = TRUE
					if(question)
						break
				if(!question && findtext(let, "?"))
					question = TRUE
					if(exclaim)
						break
				if(!exclaim && !question && findtext(let, ".")) //? and ! take priority over periods
					periods += 1
			if(exclaim)
				if(question)
					punctbuffer = "?!"
				else
					punctbuffer = "!"
			else if(question)
				punctbuffer = "?"
			else if(periods > 1)
				punctbuffer = "..."
			else
				punctbuffer = "" //Grammer nazis be damned
			buffer = copytext(buffer, 1, -cutoff) + punctbuffer
		lentext = length_char(buffer)
		if(!buffer || lentext > 280 || lentext <= cullshort || (buffer in accepted))
			continue

		accepted += buffer

	var/log = file("data/npc_saves/[filename].json") //If this line ever shows up as changed in a PR be very careful you aren't being memed on
	var/list/oldjson = list()
	var/list/oldentries = list()
	if(fexists(log))
		oldjson = json_decode(file2text(log))
		oldentries = oldjson["data"]
	if(length(oldentries))
		for(var/string in accepted)
			for(var/old in oldentries)
				if(string == old)
					oldentries.Remove(old) //Line's position in line is "refreshed" until it falls off the in game radar
					break

	var/list/finalized = list()
	finalized = accepted.Copy() + oldentries.Copy() //we keep old and unreferenced phrases near the bottom for culling
	list_clear_nulls(finalized)
	if(length(finalized) > storemax)
		finalized.Cut(storemax + 1)
	fdel(log)

	var/list/tosend = list()
	tosend["data"] = finalized
	WRITE_FILE(log, json_encode(tosend))

//Used for applying byonds text macros to strings that are loaded at runtime
/proc/apply_text_macros(string)
	var/next_backslash = findtext(string, "\\")
	if(!next_backslash)
		return string

	var/leng = length(string)

	var/next_space = findtext(string, " ", next_backslash + length(string[next_backslash]))
	if(!next_space)
		next_space = leng - next_backslash

	if(!next_space) //trailing bs
		return string

	var/base = next_backslash == 1 ? "" : copytext(string, 1, next_backslash)
	var/macro = lowertext(copytext(string, next_backslash + length(string[next_backslash]), next_space))
	var/rest = next_backslash > leng ? "" : copytext(string, next_space + length(string[next_space]))

	//See https://secure.byond.com/docs/ref/info.html#/DM/text/macros
	switch(macro)
		//prefixes/agnostic
		if("the")
			rest = text("\the []", rest)
		if("a")
			rest = text("\a []", rest)
		if("an")
			rest = text("\an []", rest)
		if("proper")
			rest = text("\proper []", rest)
		if("improper")
			rest = text("\improper []", rest)
		if("roman")
			rest = text("\roman []", rest)
		//postfixes
		if("th")
			base = text("[]\th", rest)
		if("s")
			base = text("[]\s", rest)
		if("he")
			base = text("[]\he", rest)
		if("she")
			base = text("[]\she", rest)
		if("his")
			base = text("[]\his", rest)
		if("himself")
			base = text("[]\himself", rest)
		if("herself")
			base = text("[]\herself", rest)
		if("hers")
			base = text("[]\hers", rest)
		else // Someone fucked up, if you're not a macro just go home yeah?
			// This does technically break parsing, but at least it's better then what it used to do
			return base

	. = base
	if(rest)
		. += .(rest)

//Replacement for the \th macro when you want the whole word output as text (first instead of 1st)
/proc/thtotext(number)
	if(!isnum(number))
		return
	switch(number)
		if(1)
			return "first"
		if(2)
			return "second"
		if(3)
			return "third"
		if(4)
			return "fourth"
		if(5)
			return "fifth"
		if(6)
			return "sixth"
		if(7)
			return "seventh"
		if(8)
			return "eighth"
		if(9)
			return "ninth"
		if(10)
			return "tenth"
		if(11)
			return "eleventh"
		if(12)
			return "twelfth"
		else
			return "[number]\th"

/**
 * Takes a 1, 2 or 3 digit number and returns it in words. Don't call this directly, use convert_integer_to_words() instead.
 *
 * Arguments:
 * * number - 1, 2 or 3 digit number to convert.
 * * carried_string - Text to append after number is converted to words, e.g. "million", as in "eighty million".
 * * capitalise - Whether the number it returns should be capitalised or not, e.g. "Eighty-Eight" vs. "eighty-eight".
 */
/proc/int_to_words(number, carried_string, capitalise = FALSE)
	var/static/list/tens = list("", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety")
	var/static/list/ones = list("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen")
	number = round(number)

	if(number > 999)
		return

	if(number <= 0)
		return

	var/list/string = list()

	if(number >= 100)
		string += int_to_words(number / 100, "hundred")
		number = round(number % 100)
		if(!number)
			return string + carried_string
		string += "and"

	//if number is more than 19, divide it
	if(number > 19)
		var/temp_num = tens[number / 10]
		if(number % 10)
			temp_num += "-"
			if(capitalise)
				temp_num += capitalize(ones[number % 10])
			else
				temp_num += ones[number % 10]
		string += temp_num
	else
		string += ones[number]

	if(carried_string)
		string += carried_string

	return string

/**
 * Takes an integer up to 999,999,999 and returns it in words. Works with negative numbers and 0.
 *
 * Arguments:
 * * number - Integer up to 999,999,999 to convert.
 * * capitalise - Whether the number it returns should be capitalised or not, e.g. "Eighty Million" vs. "eighty million".
 */
/proc/convert_integer_to_words(number, capitalise = FALSE)

	if(!isnum(number))
		return

	var/negative = FALSE
	if(number < 0)
		number = abs(number)
		negative = TRUE

	number = round(number)

	if(number > 999999999)
		return negative ? -number : number

	if(number == 0)
		return capitalise ? "Zero" : "zero"

	//stores word representation of given number
	var/list/output = list()

	//handles millions
	var/millions = int_to_words(((number / 1000000) % 1000), "million", capitalise)
	if(length(millions))
		output += millions

	///handles thousands
	var/thousands = int_to_words(((number / 1000) % 1000), "thousand", capitalise)
	if(length(thousands))
		output += thousands

	if(length(output) && number % 1000 && (number % 1000) < 100) //e.g. One Thousand And Ninety-Nine, instead of One Thousand Ninety-Nine
		output += "and"

	//handles digits at ones, tens and hundreds places (if any)
	output += int_to_words((number % 1000), "", capitalise)

	for(var/index in 1 to length(output))
		if(isnull(output[index]))
			output -= output[index]
			continue
		if(capitalise)
			output[index] = capitalize(output[index])

	if(!length(output))
		return negative ? -number : number

	var/number_in_words
	if(negative)
		number_in_words += capitalise ? "Negative " : "negative "

	number_in_words += output.Join(" ")

	return number_in_words

/proc/random_capital_letter()
	return uppertext(pick(GLOB.alphabet))

/proc/unintelligize(message)
	var/regex/word_boundaries = regex(@"\b[\S]+\b", "g")
	var/prefix = message[1]
	if(prefix == ";")
		message = copytext(message, 1 + length(prefix))
	else if(prefix in list(":", "#"))
		prefix += message[1 + length(prefix)]
		message = copytext(message, length(prefix))
	else
		prefix = ""

	var/list/rearranged = list()
	while(word_boundaries.Find(message))
		var/cword = word_boundaries.match
		if(length(cword))
			rearranged += cword
	shuffle_inplace(rearranged)
	return "[prefix][jointext(rearranged, " ")]"


/proc/readable_corrupted_text(text)
	var/list/corruption_options = list("..", "£%", "~~\"", "!!", "*", "^", "$!", "-", "}", "?")
	var/corrupted_text = ""

	var/lentext = length(text)
	var/letter = ""
	// Have every letter have a chance of creating corruption on either side
	// Small chance of letters being removed in place of corruption - still overall readable
	for(var/letter_index = 1, letter_index <= lentext, letter_index += length(letter))
		letter = text[letter_index]

		if (prob(15))
			corrupted_text += pick(corruption_options)

		if (prob(95))
			corrupted_text += letter
		else
			corrupted_text += pick(corruption_options)

	if (prob(15))
		corrupted_text += pick(corruption_options)

	return corrupted_text

#define is_alpha(X) ((text2ascii(X) <= 122) && (text2ascii(X) >= 97))
#define is_digit(X) ((length(X) == 1) && (length(text2num(X)) == 1))

//json decode that will return null on parse error instead of runtiming.
/proc/safe_json_decode(data)
	try
		return json_decode(data)
	catch
		return null

/proc/num2loadingbar(percent as num, numSquares = 20, reverse = FALSE)
	var/loadstring = ""
	for (var/i in 1 to numSquares)
		var/limit = reverse ? numSquares - percent*numSquares : percent*numSquares
		loadstring += i <= limit ? "█" : "░"
	return "\[[loadstring]\]"

/**
 * Formats a number to human readable form with the appropriate SI unit.
 *
 * Supports SI exponents between 1e-15 to 1e15, but properly handles numbers outside that range as well.
 * Examples:
 * * `siunit(1234, "Pa", 1)` -> `"1.2 kPa"`
 * * `siunit(0.5345, "A", 0)` -> `"535 mA"`
 * * `siunit(1000, "Pa", 4)` -> `"1 kPa"`
 * Arguments:
 * * value - The number to convert to text. Can be positive or negative.
 * * unit - The base unit of the number, such as "Pa" or "W".
 * * maxdecimals - Maximum amount of decimals to display for the final number. Defaults to 1.
 * *
 * * For pressure conversion, use proc/siunit_pressure() below
 */
/proc/siunit(value, unit, maxdecimals=1)
	var/static/list/prefixes = list("f","p","n","μ","m","","k","M","G","T","P")

	// We don't have prefixes beyond this point
	// and this also captures value = 0 which you can't compute the logarithm for
	// and also byond numbers are floats and doesn't have much precision beyond this point anyway
	if(abs(value) <= 1e-18)
		return "0 [unit]"

	var/exponent = clamp(log(10, abs(value)), -15, 15) // Calculate the exponent and clamp it so we don't go outside the prefix list bounds
	var/divider = 10 ** (round(exponent / 3) * 3) // Rounds the exponent to nearest SI unit and power it back to the full form
	var/coefficient = round(value / divider, 10 ** -maxdecimals) // Calculate the coefficient and round it to desired decimals
	var/prefix_index = round(exponent / 3) + 6 // Calculate the index in the prefixes list for this exponent

	// An edge case which happens if we round 999.9 to 0 decimals for example, which gets rounded to 1000
	// In that case, we manually swap up to the next prefix if there is one available
	if(coefficient >= 1000 && prefix_index < 11)
		coefficient /= 1e3
		prefix_index++

	var/prefix = prefixes[prefix_index]
	return "[coefficient] [prefix][unit]"


/** The game code never uses Pa, but kPa, since 1 Pa is too small to reasonably handle
 * Thus, to ensure correct conversion from any kPa in game code, this value needs to be multiplied by 10e3 to get Pa, which the siunit() proc expects
 * Args:
 * * value_in_kpa - Value that should be converted to readable text in kPa
 * * maxdecimals - maximum number of decimals that are displayed, defaults to 1 in proc/siunit()
 */
/proc/siunit_pressure(value_in_kpa, maxdecimals)
	var/pressure_adj = value_in_kpa * 1000 //to adjust for using kPa instead of Pa
	return siunit(pressure_adj, "Pa", maxdecimals)

/// Slightly expensive proc to scramble a message using equal probabilities of character replacement from a list. DOES NOT SUPPORT HTML!
/proc/scramble_message_replace_chars(original, replaceprob = 25, list/replacementchars = list("$", "@", "!", "#", "%", "^", "&", "*"), replace_letters_only = FALSE, replace_whitespace = FALSE)
	var/list/out = list()
	var/static/list/whitespace = list(" ", "\n", "\t")
	for(var/i in 1 to length(original))
		var/char = original[i]
		if(!replace_whitespace && (char in whitespace))
			out += char
			continue
		if(replace_letters_only && (!ISINRANGE(char, 65, 90) && !ISINRANGE(char, 97, 122)))
			out += char
			continue
		out += prob(replaceprob)? pick(replacementchars) : char
	return out.Join("")

///runs `piglatin_word()` proc on each word in a sentence. preserves caps and punctuation
/proc/piglatin_sentence(text)
	var/text_length = length(text)

	//remove caps since words will be shuffled
	text = lowertext(text)
	//remove punctuation for same reasons as above
	var/punctuation = ""
	var/punctuation_hit_list = list("!","?",".","-")
	for(var/letter_index in text_length to 1 step -1)
		var/letter = text[letter_index]
		if(!(letter in punctuation_hit_list))
			break
		punctuation += letter
	punctuation = reverse_text(punctuation)
	text = copytext(text, 1, ((text_length + 1) - length(punctuation)))

	//now piglatin each word
	var/list/old_words = splittext(text, " ")
	var/list/new_words = list()
	for(var/word in old_words)
		new_words += piglatin_word(word)
	text = new_words.Join(" ")
	//replace caps and punc
	text = capitalize(text)
	text += punctuation
	return text

///takes "word", and returns it piglatinized.
/proc/piglatin_word(word)
	if(length(word) == 1)
		return word
	var/first_letter = copytext(word, 1, 2)
	var/first_two_letters = copytext(word, 1, 3)
	var/first_word_is_vowel = (first_letter in list("a", "e", "i", "o", "u"))
	var/second_word_is_vowel = (copytext(word, 2, 3) in list("a", "e", "i", "o", "u"))
	//If a word starts with a vowel add the word "way" at the end of the word.
	if(first_word_is_vowel)
		return word + pick("yay", "way", "hay") //in cultures around the world it's different, so heck lets have fun and make it random. should still be readable
	//If a word starts with a consonant and a vowel, put the first letter of the word at the end of the word and add "ay."
	if(!first_word_is_vowel && second_word_is_vowel)
		word = copytext(word, 2)
		word += first_letter
		return word + "ay"
	//If a word starts with two consonants move the two consonants to the end of the word and add "ay."
	if(!first_word_is_vowel && !second_word_is_vowel)
		word = copytext(word, 3)
		word += first_two_letters
		return word + "ay"
	//otherwise unmutated
	return word

/**
 * The procedure to check the text of the entered text on ntnrc_client.dm
 *
 * This procedure is designed to check the text you type into the chat client.
 * It checks for invalid characters and the size of the entered text.
 */
/proc/reject_bad_chattext(text, max_length = 256)
	var/non_whitespace = FALSE
	var/char = ""
	if (length(text) > max_length)
		return
	else
		for(var/i = 1, i <= length(text), i += length(char))
			char = text[i]
			switch(text2ascii(char))
				if(0 to 31)
					return
				if(32)
					continue
				else
					non_whitespace = TRUE
		if (non_whitespace)
			return text

///Properly format a string of text by using replacetext()
/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

///Returns a string based on the weight class define used as argument
/proc/weight_class_to_text(w_class)
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			. = "tiny"
		if(WEIGHT_CLASS_SMALL)
			. = "small"
		if(WEIGHT_CLASS_NORMAL)
			. = "normal-sized"
		if(WEIGHT_CLASS_BULKY)
			. = "bulky"
		if(WEIGHT_CLASS_HUGE)
			. = "huge"
		if(WEIGHT_CLASS_GIGANTIC)
			. = "gigantic"
		else
			. = ""

/// Removes all non-alphanumerics from the text, keep in mind this can lead to id conflicts
/proc/sanitize_css_class_name(name)
	var/static/regex/regex = new(@"[^a-zA-Z0-9]","g")
	return replacetext(name, regex, "")
