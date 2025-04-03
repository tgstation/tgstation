/*
 * Dehydrated Carp
 * Instant carp, just add water
 */

//Child of carpplushie because this should do everything the toy does and more
/obj/item/toy/plush/carpplushie/dehy_carp
	var/mob/owner = null //Carp doesn't attack owner, set when using in hand
	var/mobtype = /mob/living/basic/carp //So admins can change what mob spawns via var fuckery
	var/swelling = FALSE

//Attack self
/obj/item/toy/plush/carpplushie/dehy_carp/attack_self(mob/user)
	if(owner)
		return ..()
	add_fingerprint(user)
	to_chat(user, span_notice("You pet [src]. You swear it looks up at you."))
	owner = user
	RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(owner_deleted))

/obj/item/toy/plush/carpplushie/dehy_carp/plop(obj/item/toy/plush/Daddy)
	return FALSE

/obj/item/toy/plush/carpplushie/dehy_carp/proc/Swell()
	if(swelling)
		return
	swelling = TRUE
	desc = "It's growing!"
	visible_message(span_notice("[src] swells up!"))

	//Animation
	icon = 'icons/mob/simple/carp.dmi'
	flick("carp_swell", src)
	//Wait for animation to end
	addtimer(CALLBACK(src, PROC_REF(spawn_carp)), 0.6 SECONDS)

/obj/item/toy/plush/carpplushie/dehy_carp/suicide_act(mob/living/carbon/human/user)
	user.visible_message(span_suicide("[user] starts eating [src]. It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	if(!istype(user))
		return BRUTELOSS
	user.Paralyze(3 SECONDS)
	forceMove(user) //we move it AWAAAYY
	sleep(2 SECONDS)
	if(QDELETED(src))
		return SHAME
	if(!QDELETED(user))
		user.spawn_gibs()
		user.apply_damage(200, def_zone = BODY_ZONE_CHEST)
		forceMove(drop_location()) //we move it back
	swelling = TRUE
	icon = 'icons/mob/simple/carp.dmi'
	flick("carp_swell", src)
	addtimer(CALLBACK(src, PROC_REF(spawn_carp)), 0.6 SECONDS)
	return BRUTELOSS

/obj/item/toy/plush/carpplushie/dehy_carp/proc/spawn_carp()
	if(QDELETED(src))//we got toasted while animating
		return
	//Make space carp
	var/mob/living/spawned_mob = new mobtype(get_turf(src), owner)
	//Make carp non-hostile to user
	if(owner)
		spawned_mob.faction = list("[REF(owner)]")
		spawned_mob.grant_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_ATOM)
	for(var/mob/living/viewer in viewers(5, get_turf(src)))
		to_chat(viewer, viewer == owner ? span_notice("The newly grown [spawned_mob.name] looks up at you with friendly eyes.") : span_warning("You have a bad feeling about this."))
	qdel(src)

/obj/item/toy/plush/carpplushie/dehy_carp/proc/owner_deleted(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(owner, COMSIG_QDELETING)
	owner = null

/obj/item/toy/plush/carpplushie/dehy_carp/peaceful
	mobtype = /mob/living/basic/carp/passive
