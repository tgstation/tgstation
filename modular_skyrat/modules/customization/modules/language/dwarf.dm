// The language of the Dwarves, based on Dwarf Fortress
/datum/language/dwarf
	name = "Dwarvish"
	desc = "The language of the dwarves"
	space_chance = 100 // Each 'syllable' is its own word
	key = "D"
	flags = TONGUELESS_SPEECH
	//Yeah I axed like 90% of those syllables, ain't letting anything iterate over that
	syllables = list("kulet", "alak", "bidok", "nicol", "anam", "gatal", "mabdug", "kun", "kiror", "nicat", "onshen", "r%rith", "mafol", "sid", "ntdn", "kontuth", "letmos", "mishim", "losush", "othbem", "b^ngeng", "lasgan", "utal", "sedur", "engig", "sunggor", "thistun", "k''shdes", "ngefel", "umer", "uleb", "n shas", "r''mab", "sezom", "shashdon", "m%bnith", "k n", "gitnuk", "daros", "nokim", "mostib", "thethrus", "kagmel", "bidnoz", "elbost", "oten", "ushdish", "kitung", "nubam", "onget", "d%ngstam", "nimar", "gelut", "nis-n", "tarem", "nam", "kozoth", "tokmek", "ed", "et", "thunen", "shokmug", "vutok", "zanos", "torad", "berdan", "nal", "mosol", "othduk", "kinem", "zatthud", "nabtr", "rirn''l", "lised", "danman", "nirk£n", "mubun")
	default_priority = 90
	icon_state = "dwarf"
	icon = 'modular_skyrat/modules/customization/icons/misc/language.dmi'
