/datum/quirk/unholy
	name = "Unholy Aura"
	desc = "Whether it's as a punishment for your actions or due to the circumstances of your birth, you've been cursed by \
			whatever dieties take an interest in this sector. You have a harder time interacting with holy figures."
	icon = FA_ICON_SMOG
	value = -2
	mob_trait = TRAIT_EVIL
	gain_text = span_warning("A dispassionate gaze from on high weighs on you.")
	lose_text = span_notice("The deities' gaze turns away.")
	medical_record_text = "Patient has a strong aversion to religious figures."

/datum/mood_event/holy_figure
	description = "Holy people are anathema to me. I must be more careful..."
	mood_change = -4
	timeout = 1 MINUTES
