/obj/projectile/hook
	///what iconstate do we use for our chain
	var/chain_iconstate = "chain"

/// non-damaging version for contractor MODsuits
/obj/item/gun/magic/hook/contractor
	name = "SCORPION hook"
	desc = "A hardlight hook used to non-lethally pull targets much closer to the user."
	icon = 'monkestation/icons/obj/guns/magic.dmi'
	icon_state = "contractor_hook"
	inhand_icon_state = "" //nah
	ammo_type = /obj/item/ammo_casing/magic/hook/contractor

/obj/item/ammo_casing/magic/hook/contractor
	projectile_type = /obj/projectile/hook/contractor

/obj/projectile/hook/contractor
	icon_state = "contractor_hook"
	damage = 0
	stamina = 30
	chain_iconstate = "contractor_chain"

/obj/item/gun/magic/hook/contractor/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(prob(1))
		user.say("+GET OVER HERE!+", forced = "scorpion hook")
	return ..()
