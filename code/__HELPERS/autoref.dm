/// Checks if potential_autoref is a autoref of thing.
#define IS_AUTOREF_OF(thing, potential_autoref) (isdatum(thing) && !isnull(potential_autoref) && thing.auto_reference == potential_autoref)
