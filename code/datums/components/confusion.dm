// This component holds no behavior on its own. This is intentional.
// It's strength is checked by /mob/living/get_confusion().

/// A component used for specifying confusion on a living mob.
/// Checked by /mob/living/get_confusion().
/// For most cases, you should be able to just modify the living's confused variable directly.
/// This component exists mostly so you can quickly nullify the effect of a confusion.
/datum/component/confusion
	/// The strength of the confusion. Will eventually lower by 1 per status effect tick.
	var/strength = 0

	dupe_mode = COMPONENT_DUPE_ALLOWED

/datum/component/confusion/Initialize(_strength = 0)
	strength = _strength
