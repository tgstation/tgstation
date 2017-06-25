/*
The Ratvarian Language
	In the lore of the Servants of Ratvar, the Ratvarian tongue is a timeless language and full of power. It sounds like gibberish, much like Nar-Sie's language, but is in fact derived from
aforementioned language, and may induce miracles when spoken in the correct way with an amplifying tool (similar to runes used by the Nar-Sian cult).

	While the canon states that the language of Ratvar and his servants is incomprehensible to the unenlightened as it is a derivative of the most ancient known language, in reality it is
actually very simple. To translate a plain English sentence to Ratvar's tongue, simply move all of the letters thirteen places ahead, starting from "a" if the end of the alphabet is reached.
This cipher is known as "rot13" for "rotate 13 places" and there are many sites online that allow instant translation between English and rot13 - one of the benefits is that moving the translated
sentence thirteen places ahead changes it right back to plain English.

	There are, however, a few parts of the Ratvarian tongue that aren't typical and are implemented for fluff reasons. Some words may have graves, or hyphens (prefix and postfix), making the plain
English translation apparent but disjoined (for instance, "Orubyq zl-cbjre!" translates directly to "Behold my-power!") although this can be ignored without impacting overall quality. When
translating from Ratvar's tongue to plain English, simply remove the disjointments and use the finished sentence. This would make "Orubyq zl-cbjre!" into "Behold my power!" after removing the
abnormal spacing, hyphens, and grave accents.

List of nuances:
- Any time the WORD "of" occurs, it is linked to the previous word by a hyphen. (i.e. "V nz-bs Ratvar." directly translates to "I am-of Ratvar.")
- Any time "th", followed by any two letters occurs, you add a grave (`) between those two letters, i.e; "Thi`s"
- In the same vein, any time "ti", followed by one letter occurs, you add a grave (`) between "i" and the letter, i.e; "Ti`me"
- Whereever "te" or "et" appear and there is another letter next to the e(i.e; "m"etal, greate"r"), add a hyphen between "e" and the letter, i.e; "M-etal", "Greate-r"
- Where "gua" appears, add a hyphen between "gu" and "a", i.e "Gu-ard"
- Where the WORD "and" appears it is linked to all surrounding words by hyphens, i.e; "Sword-and-shield"
- Where the WORD "to" appears, it is linked to the following word by a hyphen, i.e; "to-use"
- Where the WORD "my" appears, it is linked to the following word by a hyphen, i.e; "my-light"
- Although "Ratvar" translates to "Engine" in English, the word "Ratvar" is used regardless of language as it is a proper noun.
 - The same rule applies to Ratvar's four generals: Nezbere (Armorer), Sevtug (Fright), Nzcrentr (Amperage), and Inath-neq (Vangu-Ard), although these words can be used in proper context if one is
   not referring to the four generals and simply using the words themselves.
*/

//Regexes used to alter english to ratvarian style
#define RATVAR_OF_MATCH				regex("(\\w)\\s(\[oO]\[fF])","g")
#define RATVAR_OF_REPLACEMENT 		"$1-$2"
#define RATVAR_GUA_MATCH			regex("(\[gG]\[uU])(\[aA])","g")
#define RATVAR_GUA_REPLACEMENT		"$1-$2"
#define RATVAR_TH_MATCH				regex("(\[tT]\[hH]\\w)(\\w)","g")
#define RATVAR_TH_REPLACEMENT		"$1`$2"
#define RATVAR_TI_MATCH				regex("(\[tT]\[iI])(\\w)","g")
#define RATVAR_TI_REPLACEMENT		"$1`$2"
#define RATVAR_ET_MATCH				regex("(\\w)(\[eE]\[tT])","g")
#define RATVAR_ET_REPLACEMENT		"$1-$2"
#define RATVAR_TE_MATCH				regex("(\[tT]\[eE])(\\w)","g")
#define RATVAR_TE_REPLACEMENT		"$1-$2"
#define RATVAR_PRE_AND_MATCH		regex("(\\w)\\s(\[aA]\[nN]\[dD])(\\W)","g")
#define RATVAR_PRE_AND_REPLACEMENT	"$1-$2$3"
#define RATVAR_POST_AND_MATCH		regex("(\\W)(\[aA]\[nN]\[dD])\\s(\\w)","g")
#define RATVAR_POST_AND_REPLACEMENT	"$1$2-$3"
#define RATVAR_TO_MATCH				regex("(\\s)(\[tT]\[oO])\\s(\\w)","g")
#define RATVAR_TO_REPLACEMENT		"$1$2-$3"
#define RATVAR_MY_MATCH 			regex("(\\s)(\[mM]\[yY])\\s(\\w)","g")
#define RATVAR_MY_REPLACEMENT		"$1$2-$3"

//Regexes used to remove ratvarian styling from english
#define REVERSE_RATVAR_HYPHEN_PRE_AND_MATCH			regex("(\\w)-(\[aA]\[nN]\[dD])","g") //specifically structured to support -emphasis-, including with -and-
#define REVERSE_RATVAR_HYPHEN_PRE_AND_REPLACEMENT	"$1 $2"
#define REVERSE_RATVAR_HYPHEN_POST_AND_MATCH		regex("(\[aA]\[nN]\[dD])-(\\w)","g")
#define REVERSE_RATVAR_HYPHEN_POST_AND_REPLACEMENT	"$1 $2"
#define REVERSE_RATVAR_HYPHEN_TO_MY_MATCH			regex("(\[tTmM]\[oOyY])-","g")
#define REVERSE_RATVAR_HYPHEN_TO_MY_REPLACEMENT		"$1 "
#define REVERSE_RATVAR_HYPHEN_TE_MATCH				regex("(\[tT]\[eE])-","g")
#define REVERSE_RATVAR_HYPHEN_TE_REPLACEMENT		"$1"
#define REVERSE_RATVAR_HYPHEN_ET_MATCH				regex("-(\[eE]\[tT])","g")
#define REVERSE_RATVAR_HYPHEN_ET_REPLACEMENT		"$1"
#define REVERSE_RATVAR_HYPHEN_GUA_MATCH				regex("(\[gG]\[uU])-(\[aA])","g")
#define REVERSE_RATVAR_HYPHEN_GUA_REPLACEMENT		"$1$2"
#define REVERSE_RATVAR_HYPHEN_OF_MATCH				regex("-(\[oO]\[fF])","g")
#define REVERSE_RATVAR_HYPHEN_OF_REPLACEMENT		" $1"


/proc/text2ratvar(text) //Takes english and applies ratvarian styling rules (and rot13) to it.
	var/ratvarian = add_ratvarian_regex(text) //run the regexes twice, so that you catch people translating it beforehand
	ratvarian = rot13(ratvarian)
	return add_ratvarian_regex(ratvarian)

/proc/add_ratvarian_regex(text)
	var/ratvarian 	= replacetext(text, 		RATVAR_OF_MATCH, 		RATVAR_OF_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian,	RATVAR_GUA_MATCH, 		RATVAR_GUA_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian,	RATVAR_TH_MATCH, 		RATVAR_TH_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian,	RATVAR_TI_MATCH, 		RATVAR_TI_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_ET_MATCH, 		RATVAR_ET_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_TE_MATCH, 		RATVAR_TE_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_PRE_AND_MATCH,	RATVAR_PRE_AND_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_POST_AND_MATCH,	RATVAR_POST_AND_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_TO_MATCH, 		RATVAR_TO_REPLACEMENT)
	return replacetext(ratvarian, 				RATVAR_MY_MATCH, 		RATVAR_MY_REPLACEMENT)

/proc/ratvar2text(ratvarian) //Reverts ravarian styling and rot13 in text.
	var/text = remove_ratvarian_regex(ratvarian) //run the regexes twice, so that you catch people translating it beforehand
	text = replacetext(rot13(text), "`", "")
	return remove_ratvarian_regex(text)

/proc/remove_ratvarian_regex(ratvarian)
	var/text 	= replacetext(ratvarian, 	REVERSE_RATVAR_HYPHEN_GUA_MATCH,		REVERSE_RATVAR_HYPHEN_GUA_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_PRE_AND_MATCH,	REVERSE_RATVAR_HYPHEN_PRE_AND_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_POST_AND_MATCH,	REVERSE_RATVAR_HYPHEN_POST_AND_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_TO_MY_MATCH,		REVERSE_RATVAR_HYPHEN_TO_MY_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_TE_MATCH,			REVERSE_RATVAR_HYPHEN_TE_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_ET_MATCH,			REVERSE_RATVAR_HYPHEN_ET_REPLACEMENT)
	return replacetext(text, 				REVERSE_RATVAR_HYPHEN_OF_MATCH,			REVERSE_RATVAR_HYPHEN_OF_REPLACEMENT)

//Causes the mob or AM in question to speak a message; it assumes that the message is already translated to ratvar speech using text2ratvar()
/proc/clockwork_say(atom/movable/AM, message, whisper=FALSE)
	var/list/spans = list(SPAN_ROBOT)

	if(isliving(AM))
		var/mob/living/L = AM
		if(!whisper)
			L.say(message, "clock", spans, language=/datum/language/common)
		else
			L.whisper(message, "clock", spans, language=/datum/language/common)
	else
		AM.say(message, language=/datum/language/common)
