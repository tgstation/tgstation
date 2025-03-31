/// she, he, they, it "%PRONOUN_they" = "p_they"
/// She, He, They, It "%PRONOUN_They" = "p_They"
/// her, his, their, its "%PRONOUN_their" = "p_their"
/// Her, His, Their, Its "%PRONOUN_Their" = "p_Their"
/// hers, his, theirs, its "%PRONOUN_theirs" = "p_theirs"
/// Hers, His, Theirs, Its "%PRONOUN_Theirs" = "p_Theirs"
/// her, him, them, it "%PRONOUN_them" = "p_them"
/// Her, Him, Them, It "%PRONOUN_Them" = "p_Them"
/// has, have "%PRONOUN_have" = "p_have"
/// is, are "%PRONOUN_are" = "p_are"
/// was, were "%PRONOUN_were" = "p_were"
/// does, do "%PRONOUN_do" = "p_do"
/// she has, he has, they have, it has "%PRONOUN_theyve" = "p_theyve"
/// She has, He has, They have, It has "%PRONOUN_Theyve" = "p_Theyve"
/// she is, he is, they are, it is "%PRONOUN_theyre" = "p_theyre"
/// She is, He is, They are, It is "%PRONOUN_Theyre" = "p_Theyre"
/// s, null (she looks, they look) "%PRONOUN_s" = "p_s"
/// es, null (she goes, they go) "%PRONOUN_es" = "p_es"

/// 	Don't forget to update the grep if you add more! tools/ci/check_grep.sh -> pronoun helper spellcheck

/// A list for all the pronoun procs, if you need to iterate or search through it or something.
#define ALL_PRONOUNS list( \
	"%PRONOUN_they" = TYPE_PROC_REF(/datum, p_they), \
	"%PRONOUN_They" = TYPE_PROC_REF(/datum, p_They), \
	"%PRONOUN_their" = TYPE_PROC_REF(/datum, p_their), \
	"%PRONOUN_Their" = TYPE_PROC_REF(/datum, p_Their), \
	"%PRONOUN_theirs" = TYPE_PROC_REF(/datum, p_theirs), \
	"%PRONOUN_Theirs" = TYPE_PROC_REF(/datum, p_Theirs), \
	"%PRONOUN_them" = TYPE_PROC_REF(/datum, p_them), \
	"%PRONOUN_Them" = TYPE_PROC_REF(/datum, p_Them), \
	"%PRONOUN_have" = TYPE_PROC_REF(/datum, p_have), \
	"%PRONOUN_are" = TYPE_PROC_REF(/datum, p_are), \
	"%PRONOUN_were" = TYPE_PROC_REF(/datum, p_were), \
	"%PRONOUN_do" = TYPE_PROC_REF(/datum, p_do), \
	"%PRONOUN_theyve" = TYPE_PROC_REF(/datum, p_theyve), \
	"%PRONOUN_Theyve" = TYPE_PROC_REF(/datum, p_Theyve), \
	"%PRONOUN_theyre" = TYPE_PROC_REF(/datum, p_theyre), \
	"%PRONOUN_Theyre" = TYPE_PROC_REF(/datum, p_Theyre), \
	"%PRONOUN_s" = TYPE_PROC_REF(/datum, p_s), \
	"%PRONOUN_es" = TYPE_PROC_REF(/datum, p_es) \
)
