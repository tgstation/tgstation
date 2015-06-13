var/global/list/wizard_cards_rare = list(
	/obj/item/toy/wizard_card/legendary/honkmother,
	/obj/item/toy/wizard_card/legendary/singularity,
	/obj/item/toy/wizard_card/legendary/jew,
	/obj/item/toy/wizard_card/legendary/narsie,
	/obj/item/toy/wizard_card/legendary/pomf
	)

var/global/list/wizard_cards_normal = list(
	/obj/item/toy/wizard_card/clown,
	/obj/item/toy/wizard_card/bomberman,
	/obj/item/toy/wizard_card/captain,
	/obj/item/toy/wizard_card/hos,
	/obj/item/toy/wizard_card/scientist,
	/obj/item/toy/wizard_card/assistant,
	/obj/item/toy/wizard_card/secborg,
	/obj/item/toy/wizard_card/nukeop,
	/obj/item/toy/wizard_card/engineer,
	/obj/item/toy/wizard_card/chef,
	/obj/item/toy/wizard_card/changeling,
	/obj/item/toy/wizard_card/mime,
	/obj/item/toy/wizard_card/mommi,
	/obj/item/toy/wizard_card/AI,
	/obj/item/toy/wizard_card/vox,
	/obj/item/toy/wizard_card/doctor,
	/obj/item/toy/wizard_card/tator,
	/obj/item/toy/wizard_card/borer,
	/obj/item/toy/wizard_card/ian
	)

/obj/item/toy/wizard_card
	name = "wizard trading card"
	desc = "A trading card."
	icon = 'icons/obj/wiz_cards.dmi'
	icon_state = "card"
	var/character = "pomf"
	var/ability_cd = 0

/obj/item/toy/wizard_card/New()
	.=..()

	var/image/char_img=image('icons/obj/wiz_cards.dmi',character)
	overlays += char_img

/obj/item/toy/wizard_card/attack_self(mob/user)
	if(ability_cd==0)
		ability_cd = 1
		spawn(50)
			ability_cd = 0
		return 1
	return 0

/obj/item/toy/wizard_card/legendary
	icon_state = "card_legendary"

/obj/item/toy/wizard_card/legendary/honkmother
	name = "rare Honkmother wizard card"
	desc = "Honkmother is a <span class='sinister'>legendary</span> chaos entity. Sweet heavens."
	icon_state = "card_clown"
	character = "honkmother"

/obj/item/toy/wizard_card/legendary/honkmother/attack_self(mob/user)
	if(!..())
		user << "Honkmother is not yet ready!"
		return
	playsound(get_turf(src), 'sound/items/AirHorn.ogg', 50, 1)

/obj/item/toy/wizard_card/legendary/honkmother/pickup(mob/living/user as mob)
	if(user.mind && user.mind.assigned_role == "Clown")
		user << "<span class ='notice'>You feel Honkmother's presence as you pick up the card.</span>"

/obj/item/toy/wizard_card/legendary/singularity
	name = "rare singularity wizard card"
	desc = "The singularity is a <span class='sinister'>legendary</span> neutral entity. Gods help you if you fail to contain it."
	character = "singulo"

/obj/item/toy/wizard_card/legendary/jew
	name = "rare Agent Aronowicz wizard card"
	desc = "Agent Aronowicz is a <span class='sinister'>legendary</span> order entity. Never forget the six billion."
	icon_state = "card_rich"
	character = "jew"

/obj/item/toy/wizard_card/legendary/narsie
	name = "rare Nar-Sie wizard card"
	desc = "Nar-Sie is a <span class='sinister'>legendary</span> destruction entity. It can destroy bluespace itself."
	icon_state = "card_evil"
	character = "narsie"

/obj/item/toy/wizard_card/legendary/pomf
	name = "rare Pomf chicken wizard card"
	desc = "Pomf chicken is a <span class='sinister'>legendary</span> order entity. Despite holding great power, it is easily intimidated."
	icon_state = "card_rich"
	character = "chicken"

/obj/item/toy/wizard_card/clown
	name = "clown wizard card"
	desc = "The clown is a strong chaos entity. It's incredibly powerful, but never predictable."
	character = "clown"

/obj/item/toy/wizard_card/clown/attack_self(mob/user)
	if(!..())
		user << "The clown is not yet ready!"
		return
	playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)

/obj/item/toy/wizard_card/bomberman
	name = "bomberman wizard card"
	desc = "The bomberman is a strong destruction entity. Nothing can match it in terms of wrecking havoc and carnage, but it is often caught in its own explosions."
	character = "bomberman"

/obj/item/toy/wizard_card/captain
	name = "captain wizard card"
	desc = "The captain is a medium chaos entity. Let the dice decide whether it will be good or bad for you!"
	character = "captain"

/obj/item/toy/wizard_card/hos
	name = "HoS wizard card"
	desc = "The head of security is a medium order entity. It keeps everything under control and in strict order, even when you don't want it to."
	character = "hos"

/obj/item/toy/wizard_card/scientist
	name = "scientist wizard card"
	desc = "The scientist is a medium destruction entity. Give it some time to prepare, and you won't be disappointed."
	character = "scientist"

/obj/item/toy/wizard_card/assistant
	name = "assistant wizard card"
	desc = "The assistant is a weak chaos entity. What side is it even on? Who knows."
	character = "assistant"

/obj/item/toy/wizard_card/secborg
	name = "cyborg wizard card"
	desc = "The cyborg is a weak order entity. While powerful in theory, its asimov lawset often makes it more of a hinderance."
	character = "cyborg"

/obj/item/toy/wizard_card/nukeop
	name = "syndicate wizard card"
	desc = "The syndicate operative is a weak destruction entity. While not really powerful by itself, it is a force to be reckoned with when in large numbers. Explodes on death."
	character = "nukeop"

/obj/item/toy/wizard_card/engineer
	name = "engineer wizard card"
	desc = "The engineer is a weak order entity. It is weak in fights and powercreeped by MoMMIs."
	character = "engineer"

/obj/item/toy/wizard_card/chef
	name = "chef wizard card"
	desc = "The chef is a weak order entity. It has both the ability to be deadly in a fight, and it can keep everybody fed!"
	character = "cook"

/obj/item/toy/wizard_card/changeling
	name = "changeling wizard card"
	desc = "The changeling is a medium destruction entity. It is very hard to get rid of."
	character = "changeling"

/obj/item/toy/wizard_card/mime
	name = "mime wizard card"
	desc = "The mime is a weak chaos entity, and the clown's mortal enemy."
	character = "mime"

/obj/item/toy/wizard_card/mommi
	name = "MoMMI wizard card"
	desc = "The MoMMI is a weak order entity. It can't do anything in fights, but who else can keep an entire space station maintained and powered better than the MoMMI?"
	character = "mommi"

/obj/item/toy/wizard_card/AI
	name = "AI wizard card"
	desc = "The AI is a medium order entity. While useless in fights, it can control the cyborgs and the battlefield's environment."
	character = "ai"

/obj/item/toy/wizard_card/vox
	name = "vox wizard card"
	desc = "The vox is a medium chaos entity. Time to steal the station's engineering department!"
	character = "vox"

/obj/item/toy/wizard_card/doctor
	name = "doctor wizard card"
	desc = "The doctor is a weak order entity. In addition to being robust, the doctor can provide first aid to his injured allies, and even clone the dead ones."
	character = "doc"

/obj/item/toy/wizard_card/tator
	name = "traitor wizard card"
	desc = "The traitor is a weak destruction entity. It grows in power with time, and once it gained enough momentum it is very hard to stop."
	character = "tator"

/obj/item/toy/wizard_card/borer
	name = "borer wizard card"
	desc = "The borer is a weak chaos entity. It can gain control of a human and produce more borers to completely overtake the station."
	character = "borer"

/obj/item/toy/wizard_card/borer/small
	name = "borer token card"
	desc = "The borer is a weak chaos entity. It can gain control of a human, but it can't reproduce."
	icon_state = "card_gray"

/obj/item/toy/wizard_card/borer/attack_self(mob/user)
	if(!..())
		user << "The borer is not yet ready."
		return

	new /obj/item/toy/wizard_card/borer/small(get_turf(src.loc))
	user << "You create a borer token card!"

/obj/item/toy/wizard_card/borer/small/attack_self(mob/user)
	return

/obj/item/toy/wizard_card/ian
	name = "Ian wizard card"
	desc = "Ian is a strong neutral entity. Legends say that the one who kills Ian will forever be cursed."
	character = "ian"
