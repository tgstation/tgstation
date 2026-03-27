// A note if I have to cram in future languages:
// Taken keys for languages at present are as follows:
// tgstation: !, 0, 1, 4, 6, b, c, d, f, g, h, i, k, m, n, o, p, s, t, u, v, w, x, y, z
// troutstation: a (myrtongue), q (slosh/slugcat), 2 (flock)

// not yet taken: 3, 5, 7, 8, 9, e, j, l, r

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
