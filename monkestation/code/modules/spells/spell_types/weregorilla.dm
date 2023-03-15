/obj/effect/proc_holder/spell/targeted/shapeshift/weregorilla
	name = "WEREGORILLA"
	desc = "WEREGORILLA"
	invocation = "WEREGORILLA!"
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "lesser_form"
	shapeshift_type = /mob/living/simple_animal/hostile/gorilla/rabid
	possible_shapes = list(/mob/living/simple_animal/hostile/gorilla/rabid)

/obj/effect/proc_holder/spell/targeted/shapeshift/weregorilla/cast(list/targets,mob/user = usr)
	if(src in user.mob_spell_list)
		user.mob_spell_list.Remove(src)
		user.mind.AddSpell(src)
	if(user.buckled)
		user.buckled.unbuckle_mob(src,force=TRUE)
	for(var/mob/living/M in targets)
		var/obj/shapeshift_holder/S = locate() in M
		if(S)
			playsound(M, 'sound/creatures/gorilla.ogg', 50, mixer_channel = CHANNEL_MOB_SOUNDS)
			Restore(M)
		else
			playsound(M, 'sound/creatures/gorilla.ogg', 50, mixer_channel = CHANNEL_MOB_SOUNDS)
			Shapeshift(M)

/obj/effect/proc_holder/spell/targeted/shapeshift/weregorilla/Shapeshift(mob/living/caster)
	var/obj/shapeshift_holder/H = locate() in caster
	if(H)
		to_chat(caster, "<span class='warning'>You're already shapeshifted!</span>")
		return

	var/mob/living/shape = new shapeshift_type(caster.loc)
	H = new(shape,src,caster)
	shape.a_intent = INTENT_HARM

	clothes_req = FALSE
	human_req = FALSE

