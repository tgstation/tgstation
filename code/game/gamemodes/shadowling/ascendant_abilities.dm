
/obj/effect/proc_holder/spell/targeted/sling/annihilate //Gibs someone instantly.
	name = "Annihilate"
	desc = "Gibs someone instantly."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = FALSE
	action_icon_state = "annihilate"
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	sound = 'sound/magic/Staff_Chaos.ogg'

/obj/effect/proc_holder/spell/targeted/sling/annihilate/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	var/mob/living/boom = target
	if(user.incorporeal_move)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		revert_cast()
		return
	if(is_shadow(boom)) //Used to not work on thralls. Now it does so you can PUNISH THEM LIKE THE WRATHFUL GOD YOU ARE.
		to_chat(user, "<span class='warning'>Making an ally explode seems unwise.<span>")
		revert_cast()
		return
	if(istype(boom, /mob/living/simple_animal/pet/dog/corgi))
		to_chat(user, "<span class='warning'>Not even we are that bad of monsters..<span>")
		revert_cast()
		return
	if (!boom.is_holding(/obj/item/storage/backpack/holding)) //so people actually have a chance to kill ascended slings without being insta-sploded
		user.visible_message("<span class='warning'>[user]'s markings flare as they gesture at [boom]!</span>", \
							"<span class='shadowling'>You direct a lance of telekinetic energy into [boom].</span>")
		if(iscarbon(boom))
			playsound(boom, 'sound/magic/Disintegrate.ogg', 100, 1)
		boom.visible_message("<span class='userdanger'>[boom] explodes!</span>")
		boom.gib()
	else
		to_chat(user, "<span class='warning'>The telekinetic energy is absorbed by the bluespace portal in [boom]'s hand!<span>")
		to_chat(boom, "<span class='userdanger'>You feel a slight recoil from the bag of holding!<span>")

/obj/effect/proc_holder/spell/targeted/sling/hypnosis //Enthralls someone instantly. Nonlethal alternative to Annihilate
	name = "Hypnosis"
	desc = "Instantly enthralls a human."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	action_icon_state = "enthrall"

/obj/effect/proc_holder/spell/targeted/sling/hypnosis/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	if(user.incorporeal_move)
		revert_cast()
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		return

	if(is_shadow_or_thrall(target))
		to_chat(user, "<span class='warning'>You cannot enthrall an ally.<span>")
		revert_cast()
		return
	if(!target.ckey || !target.mind)
		to_chat(user, "<span class='warning'>The target has no mind.</span>")
		revert_cast()
		return
	if(target.stat)
		to_chat(user, "<span class='warning'>The target must be conscious.</span>")
		revert_cast()
		return
	if(!ishuman(target))
		to_chat(user, "<span class='warning'>You can only enthrall humans.</span>")
		revert_cast()
		return
	to_chat(user, "<span class='shadowling'>You instantly rearrange <b>[target]</b>'s memories, brainwashing them into a thrall.</span>")
	to_chat(target, "<span class='userdanger'><font size=3>An agonizing spike of pain drives into your mind, and--</font></span>")
	target.mind.special_role = "thrall"
	add_thrall(target.mind)
	user = null
	target = null


/obj/effect/proc_holder/spell/self/shadowling_phase_shift //Permanent version of shadow walk with no drawback. Toggleable.
	name = "Phase Shift"
	desc = "Phases you into the space between worlds at will, allowing you to move through walls and become invisible."
	panel = "Ascendant"
	charge_max = 15
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/self/shadowling_phase_shift/cast(mob/living/user)
	user.incorporeal_move = !user.incorporeal_move
	if(user.incorporeal_move)
		user.visible_message("<span class='danger'>[user] suddenly vanishes!</span>", \
		"<span class='shadowling'>You begin phasing through planes of existence. Use the ability again to return.</span>")
		user.density = 0
		user.alpha = 0
	else
		user.visible_message("<span class='danger'>[user] suddenly appears from nowhere!</span>", \
		"<span class='shadowling'>You return from the space between worlds.</span>")
		user.density = 1
		user.alpha = 255


/obj/effect/proc_holder/spell/ascendant_storm //Releases bolts of lightning to everyone nearby
	name = "Lightning Storm"
	desc = "Shocks everyone nearby."
	panel = "Ascendant"
	range = 6
	charge_max = 100
	clothes_req = FALSE
	action_icon_state = "lightning_storm"
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	sound = 'sound/magic/lightningbolt.ogg'

/obj/effect/proc_holder/spell/ascendant_storm/cast(list/targets,mob/user = usr)
	if(user.incorporeal_move)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		revert_cast()
		return
	user.visible_message("<span class='warning'><b>A massive ball of lightning appears in [user]'s hands and flares out!</b></span>", \
						"<span class='shadowling'>You conjure a ball of lightning and release it.</span>")

	for(var/mob/living/carbon/human/target in view(6))
		if(is_shadow_or_thrall(target))
			continue
		to_chat(target, "<span class='userdanger'>You're struck by a bolt of lightning!</span>")
		target.apply_damage(10, BURN)
		playsound(target, 'sound/magic/LightningShock.ogg', 50, 1)
		target.Knockdown(80)
		user.Beam(target,icon_state="red_lightning",time=10)


/obj/effect/proc_holder/spell/self/shadowling_hivemind_ascendant //Large, all-caps text in shadowling chat
	name = "Ascendant Commune"
	desc = "Allows you to LOUDLY communicate with all other shadowlings and thralls."
	panel = "Ascendant"
	charge_max = 0
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/self/shadowling_hivemind_ascendant/cast(mob/living/carbon/human/user)
	var/text = stripped_input(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", "")
	if(!text)
		return
	text = "<font size=4><span class='shadowling'><b>\[Ascendant\]<i> [user.real_name]</i>: [text]</b></span></font>"
	for(var/mob/M in GLOB.mob_list)
		if(is_shadow_or_thrall(M))
			to_chat(M, text)
		if(isobserver(M))
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [text]")
	log_say("[user.real_name]/[user.key] : [text]")

/obj/effect/proc_holder/spell/targeted/sling/gore //Enthralls someone instantly. Nonlethal alternative to Annihilate
	name = "Gore"
	desc = "Allows you to dash forward and turn one into a pile of gore."
	panel = "Ascendant"
	range = 7
	charge_max = 0
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	action_icon_state = "gore"

/obj/effect/proc_holder/spell/targeted/sling/gore/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	if(user.incorporeal_move)
		revert_cast()
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		return
	if(is_shadow(target))
		to_chat(user, "<span class='warning'>You cannot gore an ally.<span>")
		revert_cast()
		return
	if(!isliving(target) || !istype(target))
		return
	var/mob/living/L = target
	var/turf/T = get_turf(L)
	user.face_atom(L)
	user.visible_message("<span class='danger bold'>[user] dashes into [L], instantly turning them into a spray of gore!</span>")
	user.forceMove(T)
	playsound(T, 'sound/magic/disintegrate.ogg', 35, 1)
	L.gib()
	user = null
	target = null