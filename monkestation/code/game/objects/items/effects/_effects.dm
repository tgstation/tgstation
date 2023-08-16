/obj/item/effect_granter
	name = "Effect Granter"
	desc = "Uh you shouldn't see this period if you are its because it hasn't despawned yet contact a coder about this."

	icon = 'monkestation/icons/obj/effect_granters.dmi'
	icon_state = "none"

	///can this be done as a silicon or ai?
	var/human_only = TRUE


///blank grant effect in case this is called just delete ones self
/obj/item/effect_granter/proc/grant_effect(mob/living/carbon/granter)
	qdel(src)
	return TRUE
