/obj/item/book/granter/action/spell/mime
	name = "Guide to Mimery Vol 0"
	desc = "The missing entry into the legendary saga. Unfortunately it doesn't teach you anything."
	icon_state ="bookmime"
	remarks = list("...")

/obj/item/book/granter/action/spell/mime/attack_self(mob/user)
	. = ..()
	if(!.)
		return

	// Gives the user a vow ability if they don't have one
	var/datum/action/cooldown/spell/vow_of_silence/vow = locate() in user.actions
	if(!vow && user.mind)
		vow = new(user.mind)
		vow.Grant(user)

/obj/item/book/granter/action/spell/mime/mimery_blockade
	granted_action = /datum/action/cooldown/spell/forcewall/mime
	action_name = "Invisible Blockade"
	name = "Guide to Advanced Mimery Vol 1"
	desc = "The pages don't make any sound when turned."

/obj/item/book/granter/action/spell/mime/mimery_guns
	granted_action = /datum/action/cooldown/spell/pointed/projectile/finger_guns
	action_name = "Finger Guns"
	name = "Guide to Advanced Mimery Vol 2"
	desc = "There aren't any words written..."
