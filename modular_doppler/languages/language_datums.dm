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

/datum/language/gutter
	name = "Plutonian"
	desc = "Plutonian Franco-Castilian is a constructed Romance language that was developed early on in the Sol Federation's colonization history out of necessity for communication between its first Plutonian colonists. It heavily borrows from Spanish and French, with minor influence from other tongues the likes of Italian and Portuguese, despite coming off as elegant it carries a heavy amount of slang and idioms correlated to certain criminal groups. Today, it stands heavily engrained in the planet's culture - and almost every citizen will speak at least some of it on top of Sol."
	key = "G"
	flags = TONGUELESS_SPEECH
	syllables = list (
		"bai", "cai", "jai", "quai", "vai", "dei", "lei", "quei", "sei", "noi", "quoi", "voi", "beu", "queu", "seu", "gan", "zan", "quan", "len", "ten",
		"ba", "be", "bi", "bo", "bu", "ca", "ce", "ci", "co", "cu", "da", "de", "di", "do", "du", "fa", "fe", "fi", "fo", "fu", "ga", "gue", "gui", "go",
		"gu", "ña", "ñe", "ñi", "ño", "ñu", "que", "qui", "cha", "che", "chi", "cho", "chu", "lla", "lle", "lli", "llo", "llu",
		"tá", "vé", "sál", "fáb", "l'e", "seu", "deu", "meu", "vai", "ción", "tá"
	)
	icon_state = "gutter"
	icon = 'modular_doppler/languages/language.dmi'
	default_priority = 40
