// A note if I have to cram in future languages:
// Taken keys for languages at present are as follows:
// tgstation: i, u, z, b, c, t, 0, o, d, 6, m, 1, y, n, f, p, x, k, s, h, g, !, v, 4, (w if wormspeak gets added)
// troutstation: a (myrtongue), q (slosh/slugcat), 1 (flock)

// not yet taken: e, j, l, r, 2, 3, 5, 7, 8, 9

/datum/language_holder/anteater
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/myrtongue = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/myrtongue = list(LANGUAGE_ATOM),
	)

/datum/language_holder/slugcat
	understood_languages = list(/datum/language/common = list(LANGUAGE_MIND),
								/datum/language/wawa = list(LANGUAGE_MIND))
	spoken_languages = list(/datum/language/wawa = list(LANGUAGE_MIND))

/datum/language_holder/flock
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/flock = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/flock = list(LANGUAGE_ATOM),
	)
