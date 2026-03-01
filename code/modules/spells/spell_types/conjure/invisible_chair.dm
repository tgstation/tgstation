/datum/action/cooldown/spell/conjure/invisible_chair
	name = "Invisible Chair"
	desc = "The mime's performance transmutates a chair into physical reality."
	background_icon_state = "bg_mime"
	overlay_icon_state = "bg_mime_border"
	button_icon = 'icons/mob/actions/actions_mime.dmi'
	button_icon_state = "invisible_chair"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED
	panel = "Mime"
	sound = null

	school = SCHOOL_MIME
	cooldown_time = 30 SECONDS
	invocation = span_notice("<b>%CASTER</b> pulls out an invisible chair and sits down.")
	invocation_self_message = span_notice("You conjure an invisible chair and sit down.")
	invocation_type = INVOCATION_EMOTE

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIME_VOW
	antimagic_flags = NONE
	spell_max_level = 1

	summon_radius = 0
	summon_type = list(/obj/structure/chair/mime)
	summon_lifespan = 25 SECONDS

/datum/action/cooldown/spell/conjure/invisible_chair/post_summon(atom/summoned_object, mob/living/carbon/human/cast_on)
	if(!isobj(summoned_object))
		return

	var/obj/chair = summoned_object
	chair.setDir(cast_on.dir)
	chair.buckle_mob(cast_on)
