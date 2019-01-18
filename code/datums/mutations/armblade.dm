//Job specific traitor item for the geneticist/CMO
/datum/mutation/human/armblade
	name = "Syndicate Armblade"
	desc = "A highly illegal mutation, reverse-engineered from changeling DNA in an unknown syndicate facility."
	quality = NEGATIVE //illegal
	text_gain_indication = "<span class='notice'>You can feel the flesh in your arm twist for a moment.</span>"
	text_lose_indication = "<span class='notice'>You can feel your arm stabilizing.</span>"
	difficulty = 20
	power = /obj/effect/proc_holder/spell/targeted/syndiblade
	instability = 40
	locked = TRUE
//	mutadone_proof = TRUE

/datum/mutation/human/armblade/on_losing(mob/living/carbon/human/owner)
	if(power && isobj(power))
		var/obj/effect/proc_holder/spell/targeted/syndiblade/SB = power
		if(SB.blade)
			SB.ungrow_blade(owner)
	return ..()

/obj/effect/proc_holder/spell/targeted/syndiblade
	name = "Toggle Armblade"
	desc = "Grow your arm into a blade of flesh and bone."
	clothes_req = 0
	charge_max = 100
	cooldown_min = 100
	range = -1
	include_user = 1
	action_icon_state = "armblade"
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	var/obj/item/melee/arm_blade/blade

/obj/effect/proc_holder/spell/targeted/syndiblade/cast(list/targets,mob/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		if(blade)
			ungrow_blade(H)
		else
			grow_blade(H)
		break

/obj/effect/proc_holder/spell/targeted/syndiblade/proc/grow_blade(mob/living/carbon/human/H)
	if(!ishuman(H) || blade)
		return
	blade = new /obj/item/melee/arm_blade(H,1)
	if(H.can_put_in_hand(blade, H.active_hand_index))
		H.put_in_active_hand(blade)
		playsound(H, 'sound/effects/blobattack.ogg', 30, 1)
	else
		QDEL_NULL(blade)

/obj/effect/proc_holder/spell/targeted/syndiblade/proc/ungrow_blade(mob/living/carbon/human/H)
	QDEL_NULL(blade)
	H.update_inv_hands()
	playsound(H, 'sound/effects/blobattack.ogg', 30, 1)