/obj/effect/proc_holder/spell/self/basic_heal //This spell exists mainly for debugging purposes, and also to show how casting works
	name = "Lesser Heal"
	desc = "Heals a small amount of brute and burn damage."
	requires_human = TRUE
	requires_wizard_garb = FALSE
	charge_max = 100
	cooldown_min = 50
	invocation = "Victus sano!"
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_RESTORATION
	sound = 'sound/magic/staff_healing.ogg'

/obj/effect/proc_holder/spell/self/basic_heal/cast(list/targets, mob/living/carbon/human/user) //Note the lack of "list/targets" here. Instead, use a "user" var depending on mob requirements.
	//Also, notice the lack of a "for()" statement that looks through the targets. This is, again, because the spell can only have a single target.
	user.visible_message(span_warning("A wreath of gentle light passes over [user]!"), span_notice("You wreath yourself in healing light!"))
	user.adjustBruteLoss(-10)
	user.adjustFireLoss(-10)
