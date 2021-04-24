
/datum/antagonist/nukeop/clownop
	name = "Clown Operative"
	roundend_category = "clown operatives"
	antagpanel_category = "ClownOp"
	nukeop_outfit = /datum/outfit/syndicate/clownop

/datum/antagonist/nukeop/clownop/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = "Clown Operative"
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has clown op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has clown op'ed [key_name(new_owner)].")

/datum/antagonist/nukeop/clownop/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/L = owner.current || mob_override
	ADD_TRAIT(L, TRAIT_NAIVE, CLOWNOP_TRAIT)

/datum/antagonist/nukeop/clownop/remove_innate_effects(mob/living/mob_override)
	var/mob/living/L = owner.current || mob_override
	REMOVE_TRAIT(L, TRAIT_NAIVE, CLOWNOP_TRAIT)
	return ..()

/datum/antagonist/nukeop/clownop/equip_op()
	. = ..()
	var/mob/living/current_mob = owner.current
	var/obj/item/organ/liver/liver = current_mob.getorganslot(ORGAN_SLOT_LIVER)
	if(liver)
		ADD_TRAIT(liver, TRAIT_COMEDY_METABOLISM, CLOWNOP_TRAIT)

/datum/antagonist/nukeop/leader/clownop/give_alias()
	title = pick("Head Honker", "Slipmaster", "Clown King", "Honkbearer")
	if(nuke_team?.syndicate_name)
		owner.current.real_name = "[nuke_team.syndicate_name] [title]"
	else
		owner.current.real_name = "Syndicate [title]"

/datum/antagonist/nukeop/leader/clownop
	name = "Clown Operative Leader"
	roundend_category = "clown operatives"
	antagpanel_category = "ClownOp"
	nukeop_outfit = /datum/outfit/syndicate/clownop/leader
	challengeitem = /obj/item/nuclear_challenge/clownops

/datum/antagonist/nukeop/leader/clownop/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/L = owner.current || mob_override
	ADD_TRAIT(L, TRAIT_NAIVE, CLOWNOP_TRAIT)

/datum/antagonist/nukeop/leader/clownop/remove_innate_effects(mob/living/mob_override)
	var/mob/living/L = owner.current || mob_override
	REMOVE_TRAIT(L, TRAIT_NAIVE, CLOWNOP_TRAIT)
	return ..()

/datum/antagonist/nukeop/leader/clownop/equip_op()
	. = ..()
	var/mob/living/L = owner.current
	var/obj/item/organ/liver/liver = L.getorganslot(ORGAN_SLOT_LIVER)
	if(liver)
		ADD_TRAIT(liver, TRAIT_COMEDY_METABOLISM, CLOWNOP_TRAIT)
