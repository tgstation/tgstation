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

/// A list for all the pronoun procs, if you need to iterate or search through it or something.
#define ALL_PRONOUNS list( \
"%PRONOUN_they" = "p_they", \
"%PRONOUN_They" = "p_They", \
"%PRONOUN_their" = "p_their", \
"%PRONOUN_Their" = "p_Their", \
"%PRONOUN_theirs" = "p_theirs", \
"%PRONOUN_Theirs" = "p_Theirs", \
"%PRONOUN_them" = "p_them", \
"%PRONOUN_Them" = "p_Them", \
"%PRONOUN_have" = "p_have", \
"%PRONOUN_are" = "p_are", \
"%PRONOUN_were" = "p_were", \
"%PRONOUN_do" = "p_do", \
"%PRONOUN_theyve" = "p_theyve", \
"%PRONOUN_Theyve" = "p_Theyve", \
"%PRONOUN_theyre" = "p_theyre", \
"%PRONOUN_Theyre" = "p_Theyre", \
"%PRONOUN_s" = "p_s", \
"%PRONOUN_es" = "p_es" \
)
