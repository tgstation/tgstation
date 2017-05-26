// 'catpeople' language; spoken by players with cat ears/tails and cats.
/datum/language/cat
	name = "Internyational Galactic"
	desc = "Language used by catpeople"
	speech_verb = "meows"
    ask_verb = "pawnders"
    exclaim_verb = "hisses"
	whisper_verb = "purrs"
	key = "c"
	flags = TONGUELESS_SPEECH
	default_priority = 90
	space_chance = 30
	icon_state = "cat"

//Syllable Lists
/*
	Syllabe source http://www.stevemorse.org/japanese/description.html
*/
/datum/language/common/syllables = list(
"ka", "ki", "ku", "ke", "ko", 
"ga", "gi", "gu", "ge", "go", 
"sa", "su", "se", "so", "si", 
"za", "zu", "ze", "zo", "zi", 
"ta", "tsu", "te", "to", "ti", "tu", 
"da", "du", "de", "do", "di", 
"na", "ni", "nu", "ne", "no", "n", 
"ha", "hi", "hu", "he", ho", 
"ba", "bi", "bu", "be", "bo", 
"pa", "pi", "pu", "pe", "po", 
"ma", "mi", "mu", "me", "mo", 
"ya", "yi", "yu", "ye", "yo",
"ra", "ri", "ru", "re", "ree", "ro",
"wa", "wi", "wu", "we", "wo",
"va", "vi", "vu", "ve", "vo",
"fa", "fi", "fu", "fe", "fo",
"cha", "chi", "chu", "che", "cho",
"ja", "ji", "ju", "je", "jo",
"sha", "shi", "shu", "she", "sho",
"kya", "gya", "nya", "hya", "bya", "pya", "mya", "rya",
"kyu", "gyu", "nyu", "hyu", "byu", "pyu", "myu", "ryu",
"kyo", "gyo", "nyo", "hyo", "byo", "pyo", "myo", "ryo",)
