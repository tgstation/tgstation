/obj/item/weapon/twohanded/fireaxe/fireyaxe
	desc = "This axe has become touched by the very flames it was built to destroy..."
	force_wielded = 5

/obj/item/weapon/twohanded/fireaxe/fireyaxe/attack(mob/living/carbon/M, mob/user)
	if(!wielded)
		return ..()

	if(isliving(M))
		to_chat(M, "<span class='danger'>You are lit on fire from the intense heat of the [name]!</span>")
		M.adjust_fire_stacks(3)
		if(M.IgniteMob())
			message_admins("[key_name_admin(user)] set [key_name_admin(M)] on fire")
			log_game("[key_name(user)] set [key_name(M)] on fire")

	..()

