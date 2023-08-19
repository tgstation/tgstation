/obj/item/book/granter/action/spell/summon_cheese
	name = "Lusty Xenomorph Maid vol. III - Cheese Bakery"
	desc = "Wonderful! Time for a celebration... Cheese for everyone!"
	icon_state = "bookcheese"
	action_name = "summon cheese"
	granted_action = /datum/action/cooldown/spell/conjure/cheese
	remarks = list(
		"I never knew so many types of cheese existed...",
		"Why do I need a reason for everything?..",
		"Madness tastes of parmesan...",
		"Healthy snacks for unsuspecting victims...",
		"Time is an artificial construct...",
		"Why cheese, of all things?..",
		"What's this about sacrificing cheese?!..",
		"Always forward, never back...",
		"Order or biscuits...",
		"Who wouldn't like that?..",
	)

/obj/item/book/granter/action/spell/summon_cheese/recoil(mob/living/user)
	to_chat(user, span_warning("\The [src] turns into a wedge of cheese!"))
	var/obj/item/food/cheese/wedge/book_cheese = new
	user.put_in_hands(book_cheese)
	qdel(src)
