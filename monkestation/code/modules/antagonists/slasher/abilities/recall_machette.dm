/datum/action/cooldown/slasher/summon_machette
	name = "Summon Machette"
	desc = "Summon your machete to your active hand, or create one if it doesn't exist. This machete deals 15 BRUTE on hit increasing by 2.5 for every soul you own, and stuns on throw."

	button_icon_state = "summon_machete"

	cooldown_time = 15 SECONDS

	var/obj/item/slasher_machette/stored_machette


/datum/action/cooldown/slasher/summon_machette/Destroy()
	. = ..()
	QDEL_NULL(stored_machette)

/datum/action/cooldown/slasher/summon_machette/Activate(atom/target)
	. = ..()
	if(!stored_machette || QDELETED(stored_machette))
		stored_machette = new /obj/item/slasher_machette
		var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
		if(!slasherdatum)
			return
		slasherdatum.linked_machette = stored_machette

	if(!owner.put_in_hands(stored_machette))
		stored_machette.forceMove(get_turf(owner))

/obj/item/slasher_machette
	name = "slasher's machete"
	desc = "An old machete, clearly showing signs of wear and tear due to its age."

	icon = 'goon/icons/obj/items/weapons.dmi'
	icon_state = "welder_machete"
	hitsound = 'goon/sounds/impact_sounds/Flesh_Cut_1.ogg'

	inhand_icon_state = "PKMachete0"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/melee_righthand.dmi'

	force = 15 //damage increases by 2.5 for every soul they take
	throwforce = 15 //damage goes up by 2.5 for every soul they take
	demolition_mod = 1.25

	tool_behaviour = TOOL_CROWBAR // lets you pry open doors forcibly

	sharpness = SHARP_EDGED
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/item/slasher_machette/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(iscarbon(hit_atom))
		var/mob/living/carbon/hit_carbon = hit_atom
		hit_carbon.blood_volume -= throwforce
		playsound(src, 'goon/sounds/impact_sounds/Flesh_Stab_3.ogg', 25, 1)
	if(isliving(hit_atom))
		var/mob/living/hit_living = hit_atom
		hit_living.Knockdown(3 SECONDS)

/obj/item/slasher_machette/attack_hand(mob/user, list/modifiers)
	if(isliving(user))
		var/mob/living/living_user = user
		if(!user.mind.has_antag_datum(/datum/antagonist/slasher))
			forceMove(get_turf(user))
			user.emote("scream")
			living_user.adjustBruteLoss(force)
			to_chat(user, span_warning("You scream out in pain as you hold the [src]!"))
			if(ishuman(user))
				var/mob/living/carbon/human/human = user
				var/turf/turf = get_turf(user)
				var/list/blood_drop = list(human.get_blood_id() = 3)
				turf.add_liquid_list(blood_drop, FALSE, 300)
			return FALSE
	. = ..()

/obj/item/slasher_machette/attack(mob/living/target_mob, mob/living/user, params)
	if(isliving(user))
		var/mob/living/living_user = user
		if(!user.mind.has_antag_datum(/datum/antagonist/slasher))
			forceMove(get_turf(user))
			user.emote("scream")
			living_user.adjustBruteLoss(force)
			to_chat(user, span_warning("You scream out in pain as you hold the [src]!"))
			if(ishuman(user))
				var/mob/living/carbon/human/human = user
				var/turf/turf = get_turf(user)
				var/list/blood_drop = list(human.get_blood_id() = 3)
				turf.add_liquid_list(blood_drop, FALSE, 300)
			return FALSE
	. = ..()
