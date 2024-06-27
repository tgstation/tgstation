#define SPELLBOOK_CATEGORY_OFFENSIVE "Offensive"
// Offensive wizard spells

datum/spellbook_entry/testicular_torsion
	name = "Testicular Torsion"
	desc = "A dark spell capable of exploding victim's balls."
	spell_type =  /datum/action/cooldown/spell/touch/testicular_torsion
	cost = 1
	category = SPELLBOOK_CATEGORY_OFFENSIVE

#undef SPELLBOOK_CATEGORY_OFFENSIVE
