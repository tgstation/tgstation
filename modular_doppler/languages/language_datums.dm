/obj/item/organ/internal/tongue/get_possible_languages()
	var/list/langs = ..()
	langs += /datum/language/yangyu
	langs += /datum/language/movespeak
	return langs



/// ACTUAL LANGUAGES BEGIN HERE
/datum/language/yangyu
	name = "Yangyu"
	desc = "Also popularly known as \"Konjin\", this language group formally regarded as Orbital Sino-Tibetan is a result of a genetic relationship between Chinese, Tibetan, Burmese, and other Human languages of similar characteristics that was first proposed in the early 19th century and is extremely popular even in the space age. Originating from Asia, this group of tongues is the second most spoken by Human and Human-derived populations since the birth of Sol Common - and was a primary contender to be the Sol Federation's official language. Many loanwords, idioms, and cultural relics of Japanese, Ryukyuan, Korean, and other societies have managed to persist within it, especially in the daily lives of speakers coming from Martian cities."
	key = "Y"
	flags = TONGUELESS_SPEECH
	space_chance = 70
	// Entirely Chinese save for the isolated 2 "nya" style syllables. I don't want to bloat the syllable list with other mixes, but they generally sound somewhat alike.
	syllables = list (
		"ai", "ang", "bai", "beng", "bian", "biao", "bie", "bing", "cai", "can", "cao", "cei", "ceng", "chai", "chan", "chang",
		"chen", "chi", "chong", "chou", "chu", "chuai", "chuang", "chui", "chun", "dai", "dao", "dang", "deng", "diao", "dong", "duan",
		"fain", "fang", "feng", "fou", "gai", "gang", "gao", "gong", "guai", "guang", "hai", "han", "hang", "hao", "heng", "huai", "ji", "jiang",
		"jiao", "jin", "jun", "kai", "kang", "kong", "kuang", "lang", "lao", "liang", "ling", "long", "luan", "mao", "meng", "mian", "miao",
		"ming", "miu", "nyai", "nang", "nao", "neng", "nyang", "nuan", "qi", "qiang", "qiao", "quan", "qing", "sen", "shang", "shao", "shuan", "song", "tai",
		"tang", "tian", "tiao", "tong", "tuan", "wai", "wang", "wei", "weng", "xi", "xiang", "xiao", "xie", "xin", "xing", "xiong", "xiu", "xuan", "xue", "yan", "yang",
		"yao", "yin", "ying", "yong", "yuan", "zang", "zao", "zeng", "zhai", "zhang",
		"zhen", "zhi", "zhuai", "zhui", "zou", "zun", "zuo"
	)
	icon_state = "hanzi"
	icon = 'modular_doppler/languages/language.dmi'
	default_priority = 94
	default_name_syllable_min = 1
	default_name_syllable_max = 2

/datum/language/movespeak
	name = "Move-Speak"
	desc = "A primarily nonverbal language comprised of body movements, gesticulation, and sign language, with only intermittent warbles & other vocalizations.  It's almost completely incomprehensible without its somatic components."
	key = "M"
	flags = TONGUELESS_SPEECH
	space_chance = 30
	syllables = list(
		"wa", "wawa", "awa", "a"
	)
	icon = 'modular_doppler/languages/language.dmi'
	icon_state = "movepeak"
	default_priority = 93
