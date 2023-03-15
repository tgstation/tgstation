/obj/item/bearserum
	name = "Bear Serum"
	desc = "This serum made by BEAR Co (A group of very wealthy bears) will give other species the chance to be bear."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	var/mob/living/simple_animal/hostile/bear/russian/created_bear

/obj/item/bearserum/attack(mob/living/target, mob/living/user)
	. = ..()
	if(target != user)
		return

	created_bear = new(get_turf(target))
	target.forceMove(created_bear)
	target.mind.transfer_to(created_bear)
	ADD_TRAIT(target, TRAIT_NOBREATH, "werebear_transform")

	RegisterSignal(created_bear, COMSIG_MOB_DEATH, .proc/on_bear_death)

	var/obj/effect/proc_holder/spell/self/werebear_revert/revert = new
	created_bear.AddSpell(revert)

	qdel(src)

/obj/item/bearserum/proc/on_bear_death()
	if(!created_bear)
		return
	var/mob/living/carbon/human/human_mob = locate() in created_bear
	created_bear.mind.transfer_to(human_mob)
	human_mob.grab_ghost()
	human_mob.forceMove(get_turf(created_bear))
	REMOVE_TRAIT(human_mob, TRAIT_NOBREATH, "werebear_transform")
	created_bear.death()
	human_mob.adjustBruteLoss(30)
	human_mob.Knockdown(2 SECONDS)

//Ability

/obj/effect/proc_holder/spell/self/werebear_revert
	name = "Revert to Self"
	desc = "Revert to your previous, much less bearlike form."
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "image.png"
	action_background_icon_state = "bg_alien"
	human_req = FALSE
	clothes_req = FALSE
	charge_max = 600

/obj/effect/proc_holder/spell/self/werebear_revert/cast(list/targets, mob/living/user)
	var/mob/living/carbon/human/human_mob = locate() in user
	user.mind.transfer_to(human_mob)
	human_mob.grab_ghost()
	human_mob.forceMove(get_turf(user))
	REMOVE_TRAIT(human_mob, TRAIT_NOBREATH, "werebear_transform")
	user.death()
