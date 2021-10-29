/obj/item/antag_spawner/impostors //I don't remember why i've added this but this is problably the worst way to make it
	name = "Magical Device"
	desc = "A magical device that will multiply your bodies."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="lovestone"

/obj/item/antag_spawner/impostors/proc/check_usability(mob/user)
	if(!user.mind.has_antag_datum(/datum/antagonist/wizard, TRUE))
		to_chat(user, "<span class='danger'>You have no idea on how to use this thing.</span>")
		return FALSE
	return TRUE


/obj/item/antag_spawner/impostors/attack_self(mob/user)
	if(!(check_usability(user)))
		return
	for(var/datum/mind/M as anything in get_antag_minds(/datum/antagonist/wizard))
		if(!ishuman(M.current))
			continue
		var/mob/living/carbon/human/W = M.current
		var/list/candidates = poll_ghost_candidates("Would you like to be an imposter wizard?", ROLE_WIZARD)
		if(!candidates)
			to_chat(user, "<span class='warning'>Unable to duplicate! You can either attack the spellbook with the contract to refund your points, or wait and try again later..</span>")
			return
		var/mob/dead/observer/C = pick(candidates)

		new /obj/effect/particle_effect/smoke(W.loc)

		var/mob/living/carbon/human/I = new /mob/living/carbon/human(W.loc)
		W.dna.transfer_identity(I, transfer_SE=1)
		I.real_name = I.dna.real_name
		I.name = I.dna.real_name
		I.updateappearance(mutcolor_update=1)
		I.domutcheck()
		I.key = C.key
		var/datum/antagonist/wizard/master = M.has_antag_datum(/datum/antagonist/wizard)
		if(!master.wiz_team)
			master.create_wiz_team()
		var/datum/antagonist/wizard/apprentice/imposter/spawnersr/imposter = new()
		imposter.master = M
		imposter.wiz_team = master.wiz_team
		master.wiz_team.add_member(imposter)
		I.mind.add_antag_datum(imposter)
		//Remove if possible
		I.mind.special_role = "imposter"
		//
		qdel(src)

/datum/antagonist/wizard/apprentice/imposter/spawnersr //Yes, This is actually dumb.
	uses_ambitions = FALSE

/datum/antagonist/wizard/apprentice/imposter/spawnersr/on_gain()
	. = ..()
	equip_wizard()

/datum/antagonist/wizard/apprentice/imposter/spawnersr/equip_wizard()
	var/mob/living/carbon/human/master_mob = master.current
	var/mob/living/carbon/human/H = owner.current
	if(!istype(master_mob) || !istype(H))
		return
	if(master_mob.ears)
		H.equip_to_slot_or_del(new master_mob.ears.type, ITEM_SLOT_EARS)
	if(master_mob.w_uniform)
		H.equip_to_slot_or_del(new master_mob.w_uniform.type, ITEM_SLOT_ICLOTHING)
	if(master_mob.shoes)
		H.equip_to_slot_or_del(new master_mob.shoes.type, ITEM_SLOT_FEET)
	if(master_mob.wear_suit)
		H.equip_to_slot_or_del(new master_mob.wear_suit.type, ITEM_SLOT_OCLOTHING)
	if(master_mob.head)
		H.equip_to_slot_or_del(new master_mob.head.type, ITEM_SLOT_HEAD)
	if(master_mob.back)
		H.equip_to_slot_or_del(new master_mob.back.type, ITEM_SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/teleportation_scroll, ITEM_SLOT_LPOCKET)

	//Operation: Fuck off and scare people
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
