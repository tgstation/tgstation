/datum/action/cooldown/slasher/summon_machette
	name = "Summon Machette"
	desc = "Summon your machete to your active hand, or create one if it doesn't exist. This machete deals 15 BRUTE on hit, and stuns on throw."

	button_icon_state = "summon_machete"

	cooldown_time = 15 SECONDS

	var/obj/item/slasher_machette/stored_machette


/datum/action/cooldown/slasher/summon_machette/Destroy()
	. = ..()
	qdel(stored_machette)
	stored_machette = null

/datum/action/cooldown/slasher/summon_machette/Activate(atom/target)
	. = ..()
	if(!stored_machette)
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

	sharpness = SHARP_EDGED
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/item/slasher_machette/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(iscarbon(hit_atom))
		var/mob/living/carbon/hit_carbon = hit_atom
		hit_carbon.blood_volume -= throwforce
		hit_carbon.Knockdown(1.5 SECONDS)
		playsound(src, 'goon/sounds/impact_sounds/Flesh_Stab_3.ogg', 25, 1)
