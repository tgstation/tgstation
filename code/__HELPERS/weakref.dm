/// Checks if potential_weakref is a weakref of thing.
#define IS_WEAKREF_OF(thing, potential_weakref) (istype(thing, /datum) && !isnull(potential_weakref) && thing.weak_reference == potential_weakref)
