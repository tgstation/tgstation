//spider webs
/datum/mutation/human/webbing
	name = "Webbing Production"
	desc = "Allows the user to lay webbing, and travel through it."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your skin feels webby.</span>"
	instability = 15
	power_path = /datum/action/cooldown/spell/lay_genetic_web

/datum/mutation/human/webbing/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_WEB_WEAVER, GENETIC_MUTATION)

/datum/mutation/human/webbing/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_WEB_WEAVER, GENETIC_MUTATION)

// In the future this could be unified with the spider's web action
/datum/action/cooldown/spell/lay_genetic_web
	name = "Lay Web"
	desc = "Drops a web. Only you will be able to traverse your web easily, making it pretty good for keeping you safe."
	icon_icon = 'icons/mob/actions/actions_genetic.dmi'
	button_icon_state = "lay_web"

	cooldown_time = 4 SECONDS //the same time to lay a web
	spell_requirements = NONE

	/// How long it takes to lay a web
	var/webbing_time = 4 SECONDS
	/// The path of web that we create
	var/web_path = /obj/structure/spider/stickyweb/genetic

/datum/action/cooldown/spell/lay_genetic_web/cast(atom/cast_on)
	var/turf/web_spot = cast_on.loc
	if(!isturf(web_spot) || (locate(web_path) in web_spot))
		to_chat(cast_on, span_warning("You can't lay webs here!"))
		reset_spell_cooldown()
		return FALSE

	cast_on.visible_message(
		span_notice("[cast_on] begins to secrete a sticky substance."),
		span_notice("You begin to lay a web."),
	)

	if(!do_after(cast_on, webbing_time, target = web_spot))
		to_chat(cast_on, span_warning("Your web spinning was interrupted!"))
		return

	new web_path(web_spot, cast_on)
	return ..()
