//Adapted from another project in a horrifying attempt to make gender management shit easier.
// From The Big BYOND Book:
// The grammatical gender of the object may be set using this variable. The possible values are "neuter", "male", "female", and "plural". The default is "neuter".

                    //     LABEL        SUBJ    OBJ     REF           POS     PP
                    //                  I       me      myself        my      mine
var/global/list/genders=list(
	"male"   = new /gender("male",      "he",   "him",  "himself",    "his",  "his"),
	"female" = new /gender("female",    "she",  "her",  "herself",    "her",  "hers"),
	"neuter" = new /gender("neutral",   "it",   "its",  "itself",     "its",  "its"),
	"plural" = new /gender("plural",    "they", "them", "themselves", "their","their"), // Not sure about PP - N3X
	// For formatting purposes
	"you"    = new /gender("you",       "you",  "your", "yourself",   "your", "your", complex=1),
	"me"     = new /gender("me",        "I",    "me",   "myself",     "my",   "mine", complex=1)
)

/gender
	/**
	 * Used primarily for debugging.
	 */
	var/name = ""

	/**
	 * X did it! (I)
	 */
	var/subject = ""

	/**
	 *
	 * It was X! (me)
	 */
	var/objective = ""

	/**
	 * [subject] shot X! (myself)
	 */
	var/reflexive = ""

	/**
	 * That is X thing. (my)
	 */
	var/possessive = ""

	/**
	 * That is X. (mine)
	 */
	var/possessivePronoun = ""

	var/_complex=0

/gender/New(var/label,var/subj,var/obj,var/ref,var/pos,var/pp, var/complex=0)
	name=label
	subject=subj
	objective=obj
	reflexive=ref
	possessive=pos
	possessivePronoun=pp
	_complex=complex

/gender/proc/getHim()
	if(_complex)
		warning("getHim() unsupported for gender [name]}")
		return ""
	return objective

/gender/proc/getHis()
	if(_complex)
		warning("getHis() unsupported for gender [name]}")
		return ""
	return possessive

/gender/proc/getHimself()
	if(_complex)
		warning("getHimself() unsupported for gender [name]}")
		return ""
	return reflexive

/gender/proc/getHers()
	if(_complex)
		warning("getHers() unsupported for gender [name]}")
		return ""
	return possessivePronoun

/gender/proc/getHe()
	if(_complex)
		warning("getHe() unsupported for gender [name]}")
		return ""
	return subject

/**
* "Macro" replacement.
*
* YES I KNOW THIS IS TERRIBLE SHUT UP.  I'll do a simpler one later
*
* The problem is, using $he, $his, etc doesn't work for all cases.
*
* Plurals, for example, have a different objective noun and possessives (them vs. their)
*  whereas male/female have the same (his/her vs. his/her).  It gets even more complex with
*  "you" and "my".
*
* Also, if you look at the table above, it's not as simple as replacing his with hers.
*
* SO HERE'S WHAT YOU GET:
*/
/gender/proc/replace(var/s)
	// I
	if(findtext(s,"$sub"))
		s=replacetextEx(s,"$sub",subject)
		s=replacetextEx(s,"$Sub",capitalize(subject))
		s=replacetextEx(s,"$SUB",uppertext(subject))

	// Me
	if(findtext(s,"$obj"))
		s=replacetextEx(s,"$obj",objective)
		s=replacetextEx(s,"$Obj",capitalize(objective))
		s=replacetextEx(s,"$OBJ",uppertext(objective))

	// Myself
	if(findtext(s,"$ref"))
		s=replacetextEx(s,"$ref",reflexive)
		s=replacetextEx(s,"$Ref",capitalize(reflexive))
		s=replacetextEx(s,"$REF",uppertext(reflexive))

	// Mine
	if(findtext(s,"$posp"))
		s=replacetextEx(s,"$posp",possessivePronoun)
		s=replacetextEx(s,"$Posp",capitalize(possessivePronoun))
		s=replacetextEx(s,"$POSP",uppertext(possessivePronoun))

	// My
	if(findtext(s,"$pos"))
		s=replacetextEx(s,"$pos",possessive)
		s=replacetextEx(s,"$Pos",capitalize(possessive))
		s=replacetextEx(s,"$POS",uppertext(possessive))

	/////////////////////////////////////////////////////
	// The rules for this shit is a little more complex,
	// so we're making wild fucking assumptions
	//
	// Avoid using these if you're using anything other
	// than MALE, FEMALE, or NEUTRAL..
	/////////////////////////////////////////////////////
	if(!_complex)
		// Himself (must come before $him)
		if(findtext(s,"$himself"))
			s=replacetextEx(s,"$himself",getHimself())
			s=replacetextEx(s,"$Himself",capitalize(getHimself()))
			s=replacetextEx(s,"$HIMSELF",uppertext(getHimself()))

		// Him
		if(findtext(s,"$him"))
			s=replacetextEx(s,"$him",getHim())
			s=replacetextEx(s,"$Him",capitalize(getHim()))
			s=replacetextEx(s,"$HIM",uppertext(getHim()))

		// His
		if(findtext(s,"$his"))
			s=replacetextEx(s,"$his",getHis())
			s=replacetextEx(s,"$His",capitalize(getHis()))
			s=replacetextEx(s,"$HIS",uppertext(getHis()))

		// He
		if(findtext(s,"$he"))
			s=replacetextEx(s,"$he",getHe())
			s=replacetextEx(s,"$He",capitalize(getHe()))
			s=replacetextEx(s,"$HE",uppertext(getHe()))

		// Special case for "hers"
		if(findtext(s,"$hers"))
			s=replacetextEx(s,"$hers",getHers())
			s=replacetextEx(s,"$Hers",capitalize(getHers()))
			s=replacetextEx(s,"$HERS",uppertext(getHers()))

	return s

/proc/gender_replace(var/gender,var/text)
	var/gender/G = genders[gender]
	if(!G)
		warning("Invalid gender \"[gender]\" given to gender_replace().")
		return text // FUCK YOU
	return G.replace(text)