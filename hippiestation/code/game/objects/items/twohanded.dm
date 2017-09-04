/obj/item/twohanded/required/chainsaw/energy
	name = "energy chainsaw"
	desc = "Become Leatherspace."
	icon = 'hippiestation/icons/obj/items_and_weapons.dmi'
	icon_state = "echainsaw_off"
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	force_on = 60 //I'VE GONE COMPLETELY INSANE! HA HA HA HA!
	w_class = WEIGHT_CLASS_HUGE
	origin_tech = "materials=5;engineering=4;combat=4;syndicate=4"
	attack_verb = list("sawed", "shred", "rended", "gutted", "eviscerated")
	actions_types = list(/datum/action/item_action/startchainsaw)
	block_chance = 50
	armour_penetration = 15
	var/onsound
	var/offsound
	var/wield_cooldown = 0
	onsound = 'hippiestation/sound/weapons/echainsawon.ogg'
	offsound = 'hippiestation/sound/weapons/echainsawoff.ogg'
	on = FALSE

/obj/item/twohanded/required/chainsaw/energy/attack_self(mob/user)
	on = !on
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr intimidatingly." : "the plasma microblades stop moving."]")
	force = on ? force_on : initial(force)
	playsound(user, on ? onsound : offsound , 50, 1)
	throwforce = on ? force_on : initial(force)
	icon_state = "echainsaw_[on ? "on" : "off"]"

	if(hitsound == "swing_hit")
		hitsound = pick('hippiestation/sound/weapons/echainsawhit1.ogg','hippiestation/sound/weapons/echainsawhit2.ogg')
	else
		hitsound = "swing_hit"

	if(src == user.get_active_held_item())
		user.update_inv_hands()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
