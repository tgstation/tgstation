/datum/action/cooldown/spell/conjure/mime
	background_icon_state = "bg_mime"
	icon_icon = 'icons/mob/actions/actions_mime.dmi'
	panel = "Mime"

	school = SCHOOL_MIME

	invocation_type = INVOCATION_EMOTE
	spell_requirements = (SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_HUMAN)
	spell_max_level = 1

/datum/action/cooldown/spell/conjure/mime/New()
	. = ..()
	AddComponent(/datum/component/mime_spell, CALLBACK(src, .proc/get_invocation_content))

/datum/action/cooldown/spell/conjure/mime/proc/get_invocation_content(mob/living/carbon/human/caster)
	CRASH("[type] did not implement get_invocation_content().")

/datum/action/cooldown/spell/conjure/mime/invisible_wall
	name = "Invisible Wall"
	desc = "The mime's performance transmutates a wall into physical reality."
	button_icon_state = "invisible_wall"

	cooldown_time = 30 SECONDS
	invocation_self_message = "<span class='notice'>You form a wall in front of yourself.</span>"

	summon_type = list(/obj/effect/forcefield/mime)
	summon_lifespan = 30 SECONDS

/datum/action/cooldown/spell/conjure/mime/invisible_wall/get_invocation_content(mob/living/carbon/human/caster)
	return "<b>[caster.real_name]</b> looks as if a wall is in front of [owner.p_them()]."

/datum/action/cooldown/spell/conjure/mime/invisible_chair
	name = "Invisible Chair"
	desc = "The mime's performance transmutates a chair into physical reality."
	button_icon_state = "invisible_chair"

	cooldown_time = 30 SECONDS
	invocation_self_message = "<span class='notice'>You conjure an invisible chair and sit down.</span>"

	summon_type = list(/obj/structure/chair/mime)
	summon_lifespan = 25 SECONDS

/datum/action/cooldown/spell/conjure/mime/invisible_chair/get_invocation_content(mob/living/carbon/human/caster)
	return "<b>[caster.real_name]</b> pulls out an invisible chair and sits down."

/datum/action/cooldown/spell/conjure/mime/invisible_chair/post_summon(atom/summoned_object, mob/living/carbon/human/cast_on)
	if(!istype(summoned_object, /obj/structure/chair/mime))
		return

	var/obj/structure/chair/mime/chair = summoned_object
	chair.setDir(cast_on.dir)
	chair.buckle_mob(cast_on)

/datum/action/cooldown/spell/conjure/mime/invisible_box
	name = "Invisible Box"
	desc = "The mime's performance transmutates a box into physical reality."
	button_icon_state = "invisible_box"

	cooldown_time = 30 SECONDS
	invocation_self_message = "<span class='notice'>You conjure up an invisible box, large enough to store a few things.</span>"

	summon_type = list(/obj/item/storage/box/mime)
	summon_lifespan = 50 SECONDS

/datum/action/cooldown/spell/conjure/mime/invisible_chair/get_invocation_content(mob/living/carbon/human/caster)
	return "<b>[caster.real_name]</b> moves [caster.p_their()] hands in the shape of a cube, pressing a box out of the air."

/datum/action/cooldown/spell/conjure/mime/invisible_box/post_summon(atom/summoned_object, mob/living/carbon/human/cast_on)
	if(!istype(summoned_object, /obj/item/storage/box/mime))
		return

	cast_on.put_in_hands(summoned_object)
	summoned_object.alpha = 255
	addtimer(CALLBACK(summoned_object, /obj/item/storage/box/mime/.proc/emptyStorage, FALSE), (summon_lifespan - 1))
