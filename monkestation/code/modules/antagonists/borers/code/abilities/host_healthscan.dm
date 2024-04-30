/datum/action/cooldown/borer/check_blood
	name = "Check Blood"
	cooldown_time = 5 SECONDS
	button_icon_state = "blood"
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Allows you to check your host's health\n\
	Additionally you will be able to taste the host's chemicals and measure them acuratelly\n\
	"

/datum/action/cooldown/borer/check_blood/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	healthscan(owner, cortical_owner.human_host, advanced = TRUE) // :thinking:
	chemscan(owner, cortical_owner.human_host)
	StartCooldown()
