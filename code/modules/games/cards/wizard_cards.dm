var/global/list/wizard_cards_rare = list(
	/obj/item/toy/singlecard/wizard/legendary/honkmother,
	/obj/item/toy/singlecard/wizard/legendary/singularity,
	/obj/item/toy/singlecard/wizard/legendary/jew,
	/obj/item/toy/singlecard/wizard/legendary/narsie,
	/obj/item/toy/singlecard/wizard/legendary/pomf
	)

var/global/list/wizard_cards_normal = list(
	/obj/item/toy/singlecard/wizard/clown,
	/obj/item/toy/singlecard/wizard/bomberman,
	/obj/item/toy/singlecard/wizard/captain,
	/obj/item/toy/singlecard/wizard/hos,
	/obj/item/toy/singlecard/wizard/scientist,
	/obj/item/toy/singlecard/wizard/assistant,
	/obj/item/toy/singlecard/wizard/secborg,
	/obj/item/toy/singlecard/wizard/nukeop,
	/obj/item/toy/singlecard/wizard/engineer,
	/obj/item/toy/singlecard/wizard/chef,
	/obj/item/toy/singlecard/wizard/changeling,
	/obj/item/toy/singlecard/wizard/mime,
	/obj/item/toy/singlecard/wizard/mommi,
	/obj/item/toy/singlecard/wizard/AI,
	/obj/item/toy/singlecard/wizard/vox,
	/obj/item/toy/singlecard/wizard/doctor,
	/obj/item/toy/singlecard/wizard/tator,
	/obj/item/toy/singlecard/wizard/borer,
	/obj/item/toy/singlecard/wizard/ian
	)

#define CARD_PORTRAIT	"portrait"
#define CARD_FLIP		"flip"

/datum/context_click/wizard_card/return_clicked_id(x_pos, y_pos)
	if(14 <= x_pos && x_pos <= 19)
		if(7 <= y_pos && y_pos <= 20)
			return CARD_PORTRAIT
	return CARD_FLIP

/datum/context_click/wizard_card/action(obj/item/used_item, mob/user, params)
	var/obj/item/toy/singlecard/wizard/card = holder
	if(!used_item)
		switch(return_clicked_id_by_params(params))
			if(CARD_PORTRAIT)
				return card.special_effect()
			else
				return card.Flip()


/obj/item/toy/singlecard/wizard
	name = "wizard trading card"
	desc = "A trading card."
	icon = 'icons/obj/wiz_cards.dmi'
	icon_state = "card"
	var/image/char_image
	var/ability_cd = 0

	var/datum/context_click/wizard_card/card_use

/obj/item/toy/singlecard/wizard/New()
	.=..()

	card_use = new(src)

	char_image = image('icons/obj/wiz_cards.dmi',cardname)
	update_icon()

/obj/item/toy/singlecard/wizard/update_icon()
	if(flipped)
		overlays -= char_image
		icon_state = "wizcard_down"
		name = "card"
	else
		src.icon_state = initial(icon_state)
		src.name = initial(src.name)
		src.overlays += char_image

/obj/item/toy/singlecard/wizard/attack_self(mob/user, params)
	return card_use.action(null, user, params)

/obj/item/toy/singlecard/wizard/proc/special_effect(mob/user)
	if(!ability_cd)
		ability_cd = 1
		spawn(50)
			ability_cd = 0
		return 1
	return 0

/obj/item/toy/singlecard/wizard/legendary
	icon_state = "card_legendary"

/obj/item/toy/singlecard/wizard/legendary/honkmother
	name = "rare Honkmother wizard card"
	desc = "Honkmother is a <span class='sinister'>legendary</span> chaos entity. Sweet heavens."
	icon_state = "card_clown"
	cardname = "honkmother"

/obj/item/toy/singlecard/wizard/legendary/honkmother/special_effect(mob/user)
	if(!..())
		to_chat(user, "Honkmother is not ready yet!")
		return

	playsound(get_turf(src), 'sound/items/AirHorn.ogg', 50, 1)

/obj/item/toy/singlecard/wizard/legendary/honkmother/pickup(mob/living/user as mob)
	if(user.mind && user.mind.assigned_role == "Clown")
		to_chat(user, "<span class ='notice'>You feel Honkmother's presence as you pick up the card.</span>")

/obj/item/toy/singlecard/wizard/legendary/singularity
	name = "rare singularity wizard card"
	desc = "The singularity is a <span class='sinister'>legendary</span> neutral entity. Gods help you if you fail to contain it."
	cardname = "singulo"

/obj/item/toy/singlecard/wizard/legendary/jew
	name = "rare Agent Aronowicz wizard card"
	desc = "Agent Aronowicz is a <span class='sinister'>legendary</span> order entity. Never forget the six billion."
	icon_state = "card_rich"
	cardname = "jew"

/obj/item/toy/singlecard/wizard/legendary/narsie
	name = "rare Nar-Sie wizard card"
	desc = "Nar-Sie is a <span class='sinister'>legendary</span> destruction entity. It can destroy bluespace itself."
	icon_state = "card_evil"
	cardname = "narsie"

/obj/item/toy/singlecard/wizard/legendary/pomf
	name = "rare Pomf chicken wizard card"
	desc = "Pomf chicken is a <span class='sinister'>legendary</span> order entity. Despite holding great power, it is easily intimidated."
	icon_state = "card_rich"
	cardname = "chicken"

/obj/item/toy/singlecard/wizard/clown
	name = "clown wizard card"
	desc = "The clown is a strong chaos entity. It's incredibly powerful, but never predictable."
	cardname = "clown"

/obj/item/toy/singlecard/wizard/clown/special_effect(mob/user)
	if(!..())
		to_chat(user, "The clown is not ready yet!")
		return

	playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)

/obj/item/toy/singlecard/wizard/bomberman
	name = "bomberman wizard card"
	desc = "The bomberman is a strong destruction entity. Nothing can match it in terms of wrecking havoc and carnage, but it is often caught in its own explosions."
	cardname = "bomberman"

/obj/item/toy/singlecard/wizard/captain
	name = "captain wizard card"
	desc = "The captain is a medium chaos entity. Let the dice decide whether it will be good or bad for you!"
	cardname = "captain"

/obj/item/toy/singlecard/wizard/hos
	name = "HoS wizard card"
	desc = "The head of security is a medium order entity. It keeps everything under control and in strict order, even when you don't want it to."
	cardname = "hos"

/obj/item/toy/singlecard/wizard/scientist
	name = "scientist wizard card"
	desc = "The scientist is a medium destruction entity. Give it some time to prepare, and you won't be disappointed."
	cardname = "scientist"

/obj/item/toy/singlecard/wizard/assistant
	name = "assistant wizard card"
	desc = "The assistant is a weak chaos entity. What side is it even on? Who knows."
	cardname = "assistant"

/obj/item/toy/singlecard/wizard/secborg
	name = "cyborg wizard card"
	desc = "The cyborg is a weak order entity. While powerful in theory, its asimov lawset often makes it more of a hinderance."
	cardname = "cyborg"

/obj/item/toy/singlecard/wizard/nukeop
	name = "syndicate wizard card"
	desc = "The syndicate operative is a weak destruction entity. While not really powerful by itself, it is a force to be reckoned with when in large numbers. Explodes on death."
	cardname = "nukeop"

/obj/item/toy/singlecard/wizard/engineer
	name = "engineer wizard card"
	desc = "The engineer is a weak order entity. It is weak in fights and powercreeped by MoMMIs."
	cardname = "engineer"

/obj/item/toy/singlecard/wizard/chef
	name = "chef wizard card"
	desc = "The chef is a weak order entity. It has both the ability to be deadly in a fight, and it can keep everybody fed!"
	cardname = "cook"

/obj/item/toy/singlecard/wizard/changeling
	name = "changeling wizard card"
	desc = "The changeling is a medium destruction entity. It is very hard to get rid of."
	cardname = "changeling"

/obj/item/toy/singlecard/wizard/mime
	name = "mime wizard card"
	desc = "The mime is a weak chaos entity, and the clown's mortal enemy."
	cardname = "mime"

/obj/item/toy/singlecard/wizard/mommi
	name = "MoMMI wizard card"
	desc = "The MoMMI is a weak order entity. It can't do anything in fights, but who else can keep an entire space station maintained and powered better than the MoMMI?"
	cardname = "mommi"

/obj/item/toy/singlecard/wizard/AI
	name = "AI wizard card"
	desc = "The AI is a medium order entity. While useless in fights, it can control the cyborgs and the battlefield's environment."
	cardname = "ai"

/obj/item/toy/singlecard/wizard/vox
	name = "vox wizard card"
	desc = "The vox is a medium chaos entity. Time to steal the station's engineering department!"
	cardname = "vox"

/obj/item/toy/singlecard/wizard/doctor
	name = "doctor wizard card"
	desc = "The doctor is a weak order entity. In addition to being robust, the doctor can provide first aid to his injured allies, and even clone the dead ones."
	cardname = "doc"

/obj/item/toy/singlecard/wizard/tator
	name = "traitor wizard card"
	desc = "The traitor is a weak destruction entity. It grows in power with time, and once it gained enough momentum it is very hard to stop."
	cardname = "tator"

/obj/item/toy/singlecard/wizard/borer
	name = "borer wizard card"
	desc = "The borer is a weak chaos entity. It can gain control of a human and produce more borers to completely overtake the station."
	cardname = "borer"

/obj/item/toy/singlecard/wizard/borer/small
	name = "borer token card"
	desc = "The borer is a weak chaos entity. It can gain control of a human, but it can't reproduce."
	icon_state = "card_gray"

/obj/item/toy/singlecard/wizard/borer/special_effect(mob/user)
	if(!..())
		to_chat(user, "The borer is not yet ready.")
		return

	new /obj/item/toy/singlecard/wizard/borer/small(get_turf(src.loc))
	to_chat(user, "You create a borer token card!")

/obj/item/toy/singlecard/wizard/borer/small/special_effect()
	return

/obj/item/toy/singlecard/wizard/ian
	name = "Ian wizard card"
	desc = "Ian is a strong neutral entity. Legends say that the one who kills Ian will forever be cursed."
	cardname = "ian"

/obj/item/weapon/storage/bag/wiz_cards
	icon = 'icons/obj/wiz_cards.dmi'
	icon_state = "cardpack"
	name = "Wizard Card Pack"
	storage_slots = 50
	max_combined_w_class = 200
	max_w_class = 3
	w_class = 1
	can_hold = list("/obj/item/toy/wizard_card","/obj/item/weapon/reagent_containers/food/snacks/chocofrog")

/obj/item/weapon/storage/bag/wiz_cards/full/New()
	..()
	new /obj/item/toy/cards/wizard/full(src)

/obj/item/toy/cards/wizard
	icon = 'icons/obj/wiz_cards.dmi'
	icon_state = "wizdeck_low"
	strict_deck = 0

/obj/item/toy/cards/wizard/generate_cards()
	return

/obj/item/toy/cards/wizard/update_icon()
	if(cards.len > 15)
		src.icon_state = "wizdeck_full"
	else if(cards.len > 8)
		src.icon_state = "wizdeck_half"
	else if(cards.len > 1)
		src.icon_state = "wizdeck_low"
	else
		src.icon_state = "wizdeck_empty"

/obj/item/toy/cards/wizard/full/generate_cards()
	for(var/card in wizard_cards_normal)
		var/newcard = new card(src)
		cards += newcard
	for(var/card in wizard_cards_rare)
		var/newcard = new card(src)
		cards += newcard

/obj/item/weapon/storage/bag/wiz_cards/attack_self(mob/user)
	icon_state = "cardpack_open"
	.=..()

/obj/item/weapon/storage/bag/wiz_cards/show_to(mob/user as mob)
	icon_state = "cardpack_open"
	.=..()

/obj/item/weapon/storage/bag/wiz_cards/frog/New()
	..()
	contents += new /obj/item/weapon/reagent_containers/food/snacks/chocofrog
	var/card
	if(prob(80)) //80% chance for a classic card, 20% for a legendary
		card=pick(wizard_cards_normal)
		new card(src)
	else
		card=pick(wizard_cards_rare)
		new card(src)

