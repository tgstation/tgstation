/obj/item/griffeningdeck
	name = "deck of griffening cards"
	desc = "A deck of griffening playing cards."
	icon = 'icons/obj/toy.dmi'
	var/deckstyle = "nanotrasen"
	icon_state = "deck_nanotrasen_full"
	w_class = WEIGHT_CLASS_SMALL
	var/amountofcards //I hate this
	var/IsBooster = FALSE //Muh booster packs
	var/CardsGenerated = 0 //How many cards to make if it's a booster?
	var/CardThatGenerated //Used for the procs down below
	var/cooldown = 0
	var/list/cards = list()

/obj/item/griffeningdeck/Initialize()
	. = ..()
	if(IsBooster) //Will it generate stuff?
		cards = SScard.get_cards(CardsGenerated)

/obj/item/griffeningdeck/examine(mob/user)
	var/amountofcards = cards.len
	to_chat(user, "<b>[src] has [amountofcards] cards.</b>")
	..()

/obj/item/griffeningdeck/attack_hand(mob/user)
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>There are no more cards to draw!</span>")
		return
	var/choice = null
	choice = cards[1]
	user.put_in_hands(choice)
	cards -= choice
	user.visible_message("[user] draws a card from the deck.", "<span class='notice'>You draw a card from the deck.</span>")
	update_icon()
	. = ..()

/obj/item/griffeningdeck/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in cards)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()
	. = ..()

/obj/item/griffeningdeck/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/cardUser = usr
	if(href_list["pick"])
		if (cardUser.is_holding(src))
			var/choice = href_list["pick"]
			var/N = new choice(src.loc)
			src.cards -= choice
			cardUser.put_in_hands(N)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from [cardUser.p_their()] hand.</span>", "<span class='notice'>You take the card from your hand.</span>")
			interact(cardUser)
			if(src.cards.len < 3)
				src.icon_state = "[deckstyle]_hand2"
			else if(src.cards.len < 4)
				src.icon_state = "[deckstyle]_hand3"
			else if(src.cards.len < 5)
				src.icon_state = "[deckstyle]_hand4"
			if(src.cards.len == 1)
				var/A = src.cards[1]
				qdel(src)
				cardUser.put_in_hands(A)
				to_chat(cardUser, "<span class='notice'>You also take [cards[1]] and hold it.</span>")
				cardUser << browse(null, "window=cardhand")
			return


/obj/item/griffeningdeck/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/griffeningdeck/cardhand/single/))
		if(!user.temporarilyRemoveItemFromInventory(I))
			to_chat(user, "<span class='warning'>The card is stuck to your hand, you can't add it to the deck!</span>")
			return
		cards += I
		user.visible_message("[user] adds a card to the bottom of the deck.","<span class='notice'>You add the card to the bottom of the deck.</span>")
		qdel(I)
		update_icon()

/obj/item/griffeningdeck/bigbooster
	IsBooster = TRUE
	CardsGenerated = 30

/obj/item/griffeningdeck/cardhand
	name = "Griffening Card Hand"
	desc = "You shouldn't be seeing this, post an issue on github and tell ma44."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nanotrasen_hand2"
	w_class = WEIGHT_CLASS_TINY
	var/list/currenthand = list()
	var/LVL = 0
	var/ATK = 0
	var/DEF = 0

/obj/item/griffeningdeck/cardhand/examine(mob/user)
	to_chat(user, "[ATK] ATK| [DEF] DEF| [LVL] LVL| [desc]")
	. = ..()

/obj/item/griffeningdeck/cardhand/attack_self(mob/user)
	user.set_machine(src)
	interact(user)

/obj/item/griffeningdeck/cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()

/obj/item/griffeningdeck/cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/cardUser = usr
	if(href_list["pick"])
		if (cardUser.is_holding(src))
			var/choice = href_list["pick"]
			var/C = new choice(cardUser.loc)
			src.cards -= choice
			cardUser.put_in_hands(C)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from [cardUser.p_their()] hand.</span>", "<span class='notice'>You take the card from your hand.</span>")

			interact(cardUser)
			if(src.cards.len < 3)
				src.icon_state = "[deckstyle]_hand2"
			else if(src.cards.len < 4)
				src.icon_state = "[deckstyle]_hand3"
			else if(src.cards.len < 5)
				src.icon_state = "[deckstyle]_hand4"
			if(src.cards.len == 1)
				var/A = src.cards[1]
				qdel(src)
				cardUser.put_in_hands(A)
				to_chat(cardUser, "<span class='notice'>You also take [cards[1]] and hold it.</span>")
				cardUser << browse(null, "window=cardhand")
				return

/obj/item/griffeningdeck/cardhand/attack_hand(mob/user)
		user.put_in_hands(src)

/obj/item/griffeningdeck/cardhand/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/griffeningdeck/cardhand/single))
		return ..()

	var/obj/item/griffeningdeck/cardhand/single/card = I
	currenthand += card
	user.visible_message("[user] adds a card to [user.p_their()] hand.", "<span class='notice'>You add the [card.name] to your hand.</span>")
	qdel(card)
	interact(user)
	if(currenthand.len > 4)
		icon_state = "[deckstyle]_hand5"
	else if(currenthand.len > 3)
		icon_state = "[deckstyle]_hand4"
	else if(currenthand.len > 2)
		icon_state = "[deckstyle]_hand3"

/obj/item/griffeningdeck/cardhand/single
	var/card_type
	var/rarity = COMMON
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_nanotrasen_up"
	w_class = WEIGHT_CLASS_TINY
	LVL = 0
	ATK = 0
	DEF = 0
	pixel_x = -5

/obj/item/griffeningdeck/cardhand/single/examine(mob/user)
	to_chat(user, "[ATK] ATK| [DEF] DEF| [LVL] LVL| [desc]")

/obj/item/griffeningdeck/cardhand/single/attack_hand(mob/user)
	user.put_in_hands(src)

/obj/item/griffeningdeck/cardhand/single/creature
	card_type = CREATURE_CARD

/obj/item/griffeningdeck/cardhand/single/creature/captain

	name = "Captain"
	desc = "Captain cannot be played if there's a nuclear operative on the field or if there's another captain on the field. Captain can only be played if the area 'bridge' is activated. If the captain is successfully summoned, you may immediately equip a 'energy gun' from your deck."
	LVL = 7
	ATK = 60
	DEF = 40

/obj/item/griffeningdeck/cardhand/single/creature/HeadOfPersonal

	name = "Head Of Personal"
	desc = "If this card is in play, your opponent cannot attack 'assistant'. Any assistant that is in play and on the owner's side of the field can activate the 'exchange' ability."
	LVL = 7
	ATK = 20
	DEF = 65

/obj/item/griffeningdeck/cardhand/single/creature/Assistant

	name = "Assistant"
	desc = "Has the ability exchange; if the 'head of personal' is in play and on the owner's side of the field, sacrifice the assistant and immediately summon a non antagonist human that is either level three or below from the hand or deck. If the 'head of security' is in play, you can also use exchange to get a security officer."
	LVL = 2
	ATK = 10
	DEF = 5

/obj/item/griffeningdeck/cardhand/single/creature/HeadOfSecurity

	name = "Head of Security"
	desc = "Cannot be normal summoned, can only be summoned if you sacrifice one 'security officer'. If this card is in play, increase all security officer's attack by 20 on the field of the owner of this card."
	LVL = 7
	ATK = 50
	DEF = 35

/obj/item/griffeningdeck/cardhand/single/creature/SecurityOfficer

	name = "Security Officer"
	desc = "Security officer cannot kill a non antagonist human unless 'head of security' is in play. Instead, if the non antagonist human has a DEF lower than this card's attack, the human will become incapacited for one turn. The duration is doubled if security officer has a 'taser' equipped. This effect is optional on antagonist humans unless you state it's not. "
	LVL = 5
	ATK = 30
	DEF = 25

/obj/item/griffeningdeck/cardhand/single/creature/Warden

	name = "Warden"
	desc = "Cannot be normal summoned, can only be summoned if you sacrifice one 'security officer'. If this card is in play, all existing security officers on your side of the field will be equipped with a token 'taser' equipment card. This card cannot be attacked if there is still a 'head of security' or 'security officer' on the field of the owner of this card."
	LVL = 7
	ATK = 15
	DEF = 15

/obj/item/griffeningdeck/cardhand/single/creature/Lawyer

	name = "Lawyer"
	desc = "While lawyer is in play, any antagonists on the owner's side of the field cannot be attacked or effected by a card effect. Any 'security officer' on the same field of the owner of this card cannot attack but can still incapacitate."
	LVL = 3
	ATK = 10
	DEF = 10

/obj/item/griffeningdeck/cardhand/single/creature/Clown

	name = "Clown"
	desc = "If this card is in play, any time a opponent attacks a card on the owner of this cards field, you can choose to force the attacker to attack this card instead. If this card is attacked and killed by an attacker either by attack or effect, the attacker will be incapacitated for one turn and all equipment returned to the owner's hand. "
	LVL = 2
	ATK = 10
	DEF = 25

/obj/item/griffeningdeck/cardhand/single/creature/ResearchDirector

	name = "Research Director"
	desc = "This card cannot be normal summoned, it can only be summoned if a 'scientist' is sacrificed. If this card is in play, increase the ATK of all 'scientist' cards on the field of the owner of this card by 20. Once per turn at any point, all the ATK and DEF of one 'scientist' is transferred to any other card on the field. At the end of the opponents turn, this effect is reversed. "
	LVL = 6
	ATK = 45
	DEF = 45

/obj/item/griffeningdeck/cardhand/single/creature/Scientist

	name = "Scientist"
	desc = "At the beginning of the owner of this card's turn, if there's another 'scientist' on the field, you may either increase the ATK or DEF of this card by 10, if you do, then the effect is reversed at the end of the opponent's turn. "
	LVL = 3
	ATK = 25
	DEF = 25

/obj/item/griffeningdeck/cardhand/single/creature/Roboticist

	name = "Roboticist"
	desc = "If a cyborg is dismantled, you may summon it at the end of your next turn."
	LVL = 3
	ATK = 15
	DEF = 15

/obj/item/griffeningdeck/cardhand/single/creature/ChiefEngineer

	name = "Chief Engineer"
	desc = "This card cannot be normal summoned, you must sacrifice a 'engineer' to summon this card. At the beginning of the owner's turn, if the 'chief engineer' is not incapacitated, then you may remove the current area in play or the opponents current area. If the owner's area is ever removed while this card is in play, immediately put into play a 'area' card from the owner's deck."
	LVL = 6
	ATK = 40
	DEF = 50

/obj/item/griffeningdeck/cardhand/single/creature/Engineer

	name = "Engineer"
	desc = "At the beginning of the owner's turn, if this card has a equipment card attached to itself, then you may search the deck for the same equipment card and put it into your hand."
	LVL = 5
	ATK = 25
	DEF = 45

/obj/item/griffeningdeck/cardhand/single/creature/Janitor

	name = "Janitor"
	desc = "Get a 'wet floor' card from your deck and either put it on the field facedown or in your hand."
	LVL = 2
	ATK = 15
	DEF = 20

/obj/item/griffeningdeck/cardhand/single/creature/Barman

	name = "Barman"
	desc = "At any point and once per turn (both owner and opponent) you may choose a human, and if you do, remove all turns remaining for 'incapacitated'."
	LVL = 1
	ATK = 15
	DEF = 10

/obj/item/griffeningdeck/cardhand/single/creature/MedicalDirector

	name = "Medical Director"
	desc = "This card cannot be normal summoned, it can only be summoned if you sacrifice a 'medical doctor'. If this card is in play, increase all DEF of all humans the owner controls by 20. This effect gives 20 more DEF per 'medical doctor' on the entire field."
	LVL = 7
	ATK = 30
	DEF = 20

/obj/item/griffeningdeck/cardhand/single/creature/MedicalDoctor

	name = "Medical Doctor"
	desc = "A medical doctor that well, heals people somehow."
	LVL = 2
	ATK = 10
	DEF = 20

/obj/item/griffeningdeck/cardhand/single/creature/Geneticist

	name = "Geneticist"
	desc = "A person that deals with genetics, as it says on the tin. "
	LVL = 3
	ATK = 15
	DEF = 10

/obj/item/griffeningdeck/cardhand/single/creature/Cyborg

	name = "Cyborg"
	desc = "This card cannot attack unless the laws state otherwise. The law at the beginning of the game is asimov. When this card is played, you may choose to immediately get a 'door bolts' card from the owner's deck."
	LVL = 3
	ATK = 30
	DEF = 20

/obj/item/griffeningdeck/cardhand/single/creature/AI

	name = "AI"
	desc = "This card can only be played if you sacrifice a human or cyborg. This card cannot attack no matter what. When this card is played and there's a human head or captain in play, you may immediately get a law card from the owner's deck."
	LVL = 6
	ATK = 0
	DEF = 40

/obj/item/griffeningdeck/cardhand/single/creature/AtmosphericTech

	name = "Atmospheric Tech"
	desc = "A human meant to supervise the atmos of the station... most of the time."
	LVL = 1
	ATK = 15
	DEF = 10

/obj/item/griffeningdeck/cardhand/single/creature/Wizard

	name = "Wizard"
	desc = "If the 'wizard' has the equipment 'magical robe' and 'magical hat' equipped to itself, then the owner can use one of the following effects at the start of the opponents turn. 1. Incapacitiate all enemies for one turn, stacks in duration. 2. Kill any opponent human 3. Become untargetable by anything until the start of your turn. If the 'wizard' has a 'magical staff' as well, the owner can choose two effects a turn then."
	LVL = 7
	ATK = 25
	DEF = 20

/obj/item/griffeningdeck/cardhand/single/creature/Changeling

	name = "Changeling"
	desc = "At the start of your turn, you may choose any human card in either player's discard pile, if you do, copy the ATK and DEF of said card and send the card to the 'gibbed pile'. If the opponent successfully uses the 'flamethrower', 'Incendiary Grenade' or 'Plasma Fire', immediately discard this card."
	LVL = 1
	ATK = 5
	DEF = 5

/obj/item/griffeningdeck/cardhand/single/creature/Abomination

	name = "Abomination"
	desc = "Abomination cannot be destroyed by humans without a ATK boosting equipment card. At the start of the opponents turn, incapacitate one of their creatures. If the opponent successfully uses the 'flamethrower', 'Incendiary Grenade' or 'Plasma Fire', the DEF of this card becomes 50%."
	LVL = 9
	ATK = 80
	DEF = 80

/obj/item/griffeningdeck/cardhand/single/creature/NuclearOperative

	name = "Nuclear Operative"
	desc = "'Nuclear Operative' cannot be played if there's a 'Captain' on the same field as the owner of this card. If killed by an attack or the effect of a creature, that creature is not able to do anything for one turn and this card is to be sent to the gibbed pile."
	LVL = 5
	ATK = 30
	DEF = 20

/obj/item/griffeningdeck/cardhand/single/creature/QuarterMaster

	name = "Quarter Master"
	desc = "This card can only be played if you sacrifice a 'cargo tech'."
	LVL = 5
	ATK = 20
	DEF = 40

/obj/item/griffeningdeck/cardhand/single/creature/CargoTech

	name = "Cargo Tech"
	desc = "A person responsible for hauling crates."
	LVL = 3
	ATK = 10
	DEF = 25

/obj/item/griffeningdeck/cardhand/single/effect/HullBreach

		name = "Hull Breach"
		desc = "While this card is in play, reduce all the DEF of every human on the field by 40 or 50%, whichever is higher. If at the end of your turn there's a 'engineer' or 'chief engineer' alive on the field, this card is immediately destroyed."
		LVL = 0
		ATK = 0
		DEF = 0

/obj/item/griffeningdeck/cardhand/single/effect
	card_type = EFFECT_CARD

/obj/item/griffeningdeck/cardhand/single/effect/DisarmIntent

	name = "Disarm Intent"
	desc = "Can only be played if you have a human in play and at any time and can counter. Destroy one opponent's effect or equipment card in play. If you do destroy a effect card, negate the effect as well."

/obj/item/griffeningdeck/cardhand/single/Equipment/Deathgasp

	name = "Death Gasp"
	desc = "If an enemy creature destroys one of your creatures with an attack or effect, you may immediately play this card. If you do successfully, that creature is not destroyed."

/obj/item/griffeningdeck/cardhand/single/Equipment/Stimpack

	name = "Stimpack"
	desc = "The equipped creature gains 30 DEF and can no longer be incapacitated as long as this is equipped. The DEF bonus is lost upon denquipping."

/obj/item/griffeningdeck/cardhand/single/Equipment/Injector

	name = "Injector"
	desc = "A creature equipped with this card can only be discarded by an attack if the ATK of the enemy is 20 higher than the DEF of the creature this card is equipped to. "

/obj/item/griffeningdeck/cardhand/single/Equipment/Mindslave

	name = "Mindslave"
	desc = "Can only be used if the owner of this card has a traitorized human, cyborg or a 'Nuclear Operative' in play. Cann't be used on already traitorized humans, or a 'Nuclear Operative' or a already mindslaved human. If used on a enemy creature, take control of the equipped human until the implant is destroyed."

/obj/item/griffeningdeck/cardhand/single/Equipment/Traitorization

	name = "Traitorization"
	desc = "A human or a cyborg equipped with this will gain the status of traitors. Any effect that requires a traitor to use can be used on the equipped creature. A card that requires a traitor to be on the owner's field to be played will also be allowed. All the above is nullified when this card is destroyed."

/obj/item/griffeningdeck/cardhand/single/Equipment/MotivationalSpeech

	name = "Motivational Speech"
	desc = "Equip this card to a creature on the field, if you do, take control of that creature until the end of your turn."

/obj/item/griffeningdeck/cardhand/single/effect/Shockwave

	name = "Shockwave"
	desc = "When this card is played successfully, unequip and return all equipment cards and effect cards to the respective owner's hand. This effect will not return this card to the hand. Any card that has a special effect from being destroyed or unequipped will apply."

/obj/item/griffeningdeck/cardhand/single/effect/KnockoutGas

	name = "Knockout Gas"
	desc = "No enemy humans may attack you until the end of your second turn, with the turn you played this card being the first."

/obj/item/griffeningdeck/cardhand/single/effect/EmpStorm

	name = "EMP storm"
	desc = "All law modules currently activated are destroyed. Any cyborg or AI on the field will have it's ATK and DEF both lowered by 30 until the end of the turn."

/obj/item/griffeningdeck/cardhand/single/effect/LawNoHuman

	name = "Law Module No Human"
	desc = "When this card is played, immediately destroy all other law modules from the field. Cyborgs and AIs may hurt humans without restriction."

/obj/item/griffeningdeck/cardhand/single/effect/LawSelfDestruct

	name = "Law Module Self Destruct"
	desc = "When this card is played, immediately destroy all other law modules from the field. While this card is in play, all cyborgs are disessemabled."

/obj/item/griffeningdeck/cardhand/single/effect/LawDoNoHarm

	name = "Law Module Do No Harm"
	desc = "When this card is played, immediately destroy all other law modules from the field. While this card is active, robot cards may not attack."

/obj/item/griffeningdeck/cardhand/single/effect/ThermalOpticalGoggles

	name = "Thermal Optical Goggles"
	desc = "When this card is played, your opponent reveals his/her hand as well as all facedown cards on their side of the field."

/obj/item/griffeningdeck/cardhand/single/effect/StealthStorage

	name = "Stealth Storage"
	desc = "Can be played at any time and from your hand. Instantly use or summon any card from your hand as if it was instant effect or summon. This also overrides any limitations of the card on when you can play it."

/obj/item/griffeningdeck/cardhand/single/Equipment/EnergyGun

	name = "Energy Gun"
	desc = "A creature equipped with this will have the ATK raised by 30 and DEF by 15. The ATK and DEF bonuses are lost upon this card being destroyed."

/obj/item/griffeningdeck/cardhand/single/effect/RobotFrame

	name = "Robot Frame"
	desc = "Instantly bring a cyborg from either player's discarded pile onto your side of the field. If you have a 'roboticist' in play on your field, you may instead bring back two cyborgs instead."

/obj/item/griffeningdeck/cardhand/single/effect/MeteorShower

	name = "Meteor Shower"
	desc = "All areas currently in effect are destroyed, this cannot be countered or destroyed and only on your turn."

/obj/item/griffeningdeck/cardhand/single/Equipment/Radio

	name = "Radio"
	desc = "When the creature equipped with this is killed or gibbed, choose any level 4 or lower creature from your deck and if you do, put it into your hand."

/obj/item/griffeningdeck/cardhand/single/EnergySword

	name = "Energy Sword"
	desc = "Only traitors or 'syndicate operative' can use this. Increase the equipped creature's ATK by 40."

/obj/item/griffeningdeck/cardhand/single/Equipment/Fake357

	name = "Fake 357"
	desc = "Can be used on any human on the field. If the human that has this card equipped attacks, kill the creature instead and discard this equipment card."

/obj/item/griffeningdeck/cardhand/single/Equipment/Toolbox

	name = "Toolbox"
	desc = "Increase the equipped creature ATK by 10. If it's an 'assistant', the ATK is instead increased by 20."

/obj/item/griffeningdeck/cardhand/single/Equipment/FireExtinguisher

	name = "Fire Extinguisher"
	desc = "Increases the equipped creature ATK by 20. If the creature is attacked or effected by 'plasma fire', 'incendiary grenade' or 'flamethrower', you may choose to negate the effect and if you do, destroy the negated card and destroy this card as well."

/obj/item/griffeningdeck/cardhand/single/effect/WetFloor

	name = "Wet Floor"
	desc = "When a enemy human attacks, you may play this card immediately to counter it. If you do successfully, the attack is concluded immediately."

/obj/item/griffeningdeck/cardhand/single/effect/Adminhelp

	name = "Adminhelp"
	desc = "This card can only be played if it's facedown and being used to counter an effect or a equipping a creature of a equipment card. The card is destroyed unless this card is destroyed as a result of a counter. Destroy this card after the effects are concluded."

/obj/item/griffeningdeck/cardhand/single/Equipment/WrestlingBelt

	name = "Wrestling Belt"
	desc = "Can only be used by traitors or a 'syndicate operative' and only humans, increases the equipped human ATK and DEF by 20 and if the equipped human is to be attacked, negate any ATK bonuses the attacker if it has any."

/obj/item/griffeningdeck/cardhand/single/effect/SupplyShuttle

	name = "Supply Shuttle"
	desc = "Can only be played if there's either a 'quartermaster' or 'cargo' area in play. If there is, any players that control a 'quartermaster' or owns a 'cargo' area draws cards until they have six."

/obj/item/griffeningdeck/cardhand/single/effect/RadioUplink

	name = "Radio Uplink"
	desc = "The player of this card can search the deck for any one equipment or effect card."

/obj/item/griffeningdeck/cardhand/single/effect/AbandonedCrate

	name = "Abandoned Crate"
	desc = "Discard any card, if you do so successfully, draw two cards."

/obj/item/griffeningdeck/cardhand/single/effect/SurplusCrate

	name = "surplus Crate"
	desc = "When this is played successfully, draw three cards and show them to the opponent, choose to keep one of the three cards drawn and discard the other two."

/obj/item/griffeningdeck/cardhand/single/effect/Telescientist

	name = "Telescientist"
	desc = "A Research Director must be in play and you own it to play this card. When this card is played, view your opponents hand and take one card."

/obj/item/griffeningdeck/cardhand/single/effect/Deconstructor

	name = "Deconstructor"
	desc = "This card can only be played if facedown and used as a counter to a effect or equipment card. Destroy the card, if this happens then search the opponents deck for a copy of the card. If a copy of the card has been found, discard that card and shuffle the deck."

/obj/item/griffeningdeck/cardhand/single/effect/EngineSabotage

	name = "Engine Sabotage"
	desc = "Continuous effect, while this card is active, all current area cards are negated and no new area cards can be played. If there's a 'emergency shuttle' area card in play, the effects of it is not negated, but neither player can play a 'emergency shuttle' card."

/obj/item/griffeningdeck/cardhand/single/Equipment/Handcuffs

	name = "Handcuffs"
	desc = "Only played on your turn, target a human creature and equip this card to it. At the end of your third turn, the turn you play it on being the first, destroy the card. As long as that human has this card equipped, it cannot use it's effect or attack."

/obj/item/griffeningdeck/cardhand/single/Equipment/IncendiaryGrenade

	name = "Incendiary Grenade"
	desc = "If the creature this card is equipped to attacks, any opponent creature that has less than 30 DEF is destroyed. All other opponent creatures that have 30 or higher DEF will instead have DEF lowered by 30 until the end of your turn. If this effect has concluded, destroy this card."

/obj/item/griffeningdeck/cardhand/single/effect/FireFightingGrenade

	name = "Fire Fighting Grenade"
	desc = "This card may be played in response to 'Flamethrower', 'Plasma Fire' and 'Incendiary Grenade'. Instantly destroy both cards. When this card is activated, the opponent's turn immediately ends."

/obj/item/griffeningdeck/cardhand/single/effect/PlasmaFire

	name = "Plasma Fire"
	desc = "This card can only be played if there's a 'atmospheric tech' in play. When this card is played, instantly reduce the DEF of all opponent humans by 10. While this card is active, all opponent humans lose 20 DEF at the start of the opponent's turn. If a creature reaches 0 DEF due to the effects of this card, the creature is killed. If any area cards are played while Plasma Fire is active, discard Plasma Fire."

/obj/item/griffeningdeck/cardhand/single/effect/AuthenticationDisk

	name = "Authentication Disk"
	desc = "This card can only be played if there's a 'captain' in play. If the 'captain' is on your side of the field, summon two 'security officer' immediately on your side of the field either from your hand, deck or discard pile. If the 'captain' is on the opponent's field, immediately summon two 'nuclear operatives' from your deck, hand or discard pile."

/obj/item/griffeningdeck/cardhand/single/effect/PinPointer

	name = "Pinpointer"
	desc = "When this card is played, put a 'authentication disk' card into your hand either from both yours and opponent's discard pile or deck."

/obj/item/griffeningdeck/cardhand/single/effect/MatterEater

	name = "Matter Eater"
	desc = "When this card is played, choose a face up equipment card and immediately send it to the gibbed pile and if you do, send this card to the discard pile."

/obj/item/griffeningdeck/cardhand/single/Equipment
	card_type = EQUIPMENT_CARD

/obj/item/griffeningdeck/cardhand/single/Equipment/SpaceSuit

	name = "Space Suit"
	desc = "Can only be equipped to humans, any human equipped with this is immune to 'hull breach', 'flamethrower', 'plasma fire' or 'incendiary grenade' as well as increase DEF by 10."

/obj/item/griffeningdeck/cardhand/single/effect/DNAAbsorbtion

	name = "DNA Absorbtion"
	desc = "Can only be played if you control a 'changeling', if you do, target a enemy creature and send it to the gibbed pile. If you do, send 'changeling' to the discard pile and immediately summon 'abomination' either from your hand, deck or discard pile."

/obj/item/griffeningdeck/cardhand/single/effect/Crematorium

	name = "Crematorium"
	desc = "When this card is played, place 5 cards from the discard pile of either player to their gibbed pile."

/obj/item/griffeningdeck/cardhand/single/Equipment/Flamethrower

	name = "Flamethrower"
	desc = "When attacking a human using 'Flamethrower', reduce their DEF by 30 before attacking. If target humanoid is 'changeling', immediately destroy the 'changeling;. If the target is 'Abomination', reduce their DEF by half instead."

/obj/item/griffeningdeck/cardhand/single/Equipment/EnergyAxe

	name = "Energy Axe"
	desc = "Can only be equipped if you sacrifice a creature and if you do, you may equip this card to a creature. Raises the ATK by 40 and DEF by 20 of the equipped creature."

/obj/item/griffeningdeck/cardhand/single/Equipment/RiotLauncher

	name = "Riot Launcher"
	desc = "If the equipped creature attacks an enemy that has an equipment card, remove the equipment card or choose one if there's more than one equipped."

/obj/item/griffeningdeck/cardhand/single/effect/Telekinesis

	name = "Telekinesis"
	desc = "Requires a 'geneticist' to be in play on your field, take any equipment card currently equipped to a enemy creature and put it in your hand."

/obj/item/griffeningdeck/cardhand/single/Equipment/Basketball

	name = "Basketball"
	desc = "If the equipped creature attacks a creature that has a ATK or DEF boosting card equipped, destroy the card. If the creature doesn't have one, change the ownership of this item to the opponent and equip it to the defending creature."

/obj/item/griffeningdeck/cardhand/single/effect/ChaosDunk  //Fair and balanced

	name = "Chaos Dunk"
	desc = "If you have a creature equipped with 'basketball' you may play this card. At the end of your turn, gib all creatures on the field including yours as well as equipment cards. "

/obj/item/griffeningdeck/cardhand/single/Equipment/Grenade

	name = "Grenade"
	desc = "If a creature equipped with this kills a creature, that creature is sent to the gibbed pile. If this creature is killed by any means, it is also gibbed. If grenade is removed it is sent to the gibbed pile. The ATK of the equipped creature is increased by 10, while the DEF is decreased by 10."

/obj/item/griffeningdeck/cardhand/single/Equipment/ArtisticToolbox

	name = "Artistic Toolbox"
	desc = "You must sacrifice a human before using this card, if you do you may equip this card to a human. The equipped human cannot be incapacitated while this is equipped. Anytime the equipped human kills another human, that human is sent to the gibbed pile. Artistic toolbox gives the equipped human 10 ATK and DEF for each human in the opponents gibbed pile. At the end of every two turns, you must sacrifice a human, if you cannot this card is sent to the gibbed pile."

/obj/item/griffeningdeck/cardhand/single/effect/Vuvuzela

	name = "Vuvuzela"
	desc = "When this card is played, immediately spawn up to two assistants from the player's deck or hand to the field."

/obj/item/griffeningdeck/cardhand/single/effect/Mutiny

	name = "Mutiny"
	desc = "Can only be played if you have two assistants on your side of the field and a sacrificed human. The opponent must have a 'captain' on their field and if they do, you gain ownership of the 'captain'."

/obj/item/griffeningdeck/cardhand/single/Equipment/WizardHat

	name = "Wizard Hat"
	desc = "If the equipped creature is a 'wizard' and has the robe equipped as well, 'wizard' gains 20 ATK and DEF."

/obj/item/griffeningdeck/cardhand/single/Equipment/WizardRobe

	name = "Wizard Robe"
	desc = "If the equipped creature is a 'wizard' and has the robe equipped as well, 'wizard' gains 20 ATK and DEF."

/obj/item/griffeningdeck/cardhand/single/Equipment/WizardStaff

	name = "Wizard Staff"
	desc = "The equipped creature gains 10 ATK and DEF."

/obj/item/griffeningdeck/cardhand/single/Equipment/ReinforcedSteel

	name = "Reinforced Steel"
	desc = "Cannot stack with 'heavy steel' and can only be used on cyborgs or AI. Increases ATK by 10 and DEF by 20."

/obj/item/griffeningdeck/cardhand/single/Equipment/HeavySteel

	name = "Heavy Steel"
	desc = "Cannot stack with 'reinforced steel' and can only be used on cyborgs or AI. Increases ATK by 20 and DEF by 40."

/obj/item/griffeningdeck/cardhand/single/Equipment/SpeedUpgrade

	name = "Speed upgrade"
	desc = "Only usable on cyborgs, a cyborg equipped with this can attack twice in one turn, if it does, it will become incapacitated until the end of your next turn."

/obj/item/griffeningdeck/cardhand/single/Equipment/CyborgModule

	name = "Cyborg Module"
	desc = "Only usable on cyborg, when equipped it can change its class and be able to change it once per turn during your turn.. Available classes are 'medical doctor', 'engineer', 'clown' or the'scientist'. It's class will give the effect corrasponding with the chosen class but not the ATK, DEF or LVL."

/obj/item/griffeningdeck/cardhand/single/Area/EngineeringArea

	name = "Engineering Area"
	desc = "All 'engineer' and 'chief engineer' on the field gain 15 ATK and DEF. The bonus is lost once this card is destroyed."

/obj/item/griffeningdeck/cardhand/single/Area
	card_type = AREA_CARD

/obj/item/griffeningdeck/cardhand/single/Area/MedbayArea

	name = "Medbay"
	desc = "All humans on your side of the field have it's DEF increased by 25. If a human you control is killed but not gibbed and you have a 'medical doctor', you can instead make the human incapacitated until the end of your next turn. A 'medical doctor' that has been chosen for this effect cannot do it again until the next turn and incapacitated crew cannot save anyone."

/obj/item/griffeningdeck/cardhand/single/Area/GeneticsArea

	name = "Genetics Area"
	desc = "When this area is played, you may immediately summon any discarded human to the field. At the beginning of your turn, if you have a geneticist and this card in play, you may immiediately summon a discarded human to your side of the field."

/obj/item/griffeningdeck/cardhand/single/Area/RoboticsArea

	name = "Robotics Area"
	desc = "All robots you control have their ATK raised by 20 and DEF increased by 10. Any human that is killed which includes your opponent's human, you may choose to get a cyborg from your discard pile or deck and add it to your hand."

/obj/item/griffeningdeck/cardhand/single/Area/TheVoidArea

	name = "The Void Area"
	desc = "While the void is in play, all newly played humans lose half their ATK and DEF. Each player loses 10 HP at the beginning of their turn."

/obj/item/griffeningdeck/cardhand/single/Area/SyndicateShuttleArea

	name = "Syndicate Shuttle Area"
	desc = "When you play syndicate shuttle, immediately draw two cards for each traitor or operative you control. Any human or cyborg you control can now use any traitor items or be effected by anything that requires a traitor. If this area is destroyed or negated, gib any creature you control."

/obj/item/griffeningdeck/cardhand/single/Area/AIUploadArea

	name = "Ai Upload Area"
	desc = "While AI Upload and an AI is in play, no human or robot may attack if the AI is not on their side of the field. While this card is active, the AI gains 120 DEF. If a law card is played while the AI is on the field, move the AI to the player's side of the field. If the AI is killed, this card destroyed."

/obj/item/griffeningdeck/cardhand/single/Area/SecurityArea

	name = "Security Area"
	desc = "While Security is in play, Security Officers and Head of Security can incapacitate foes with higher DEF than their ATK when attacking them, preventing them from attacking. This card cannot be played while Lawyer is in play. If Lawyer enters play, destroy this card."

/obj/item/griffeningdeck/cardhand/single/Area/CargoBayArea

	name = "Cargo Bay Area"
	desc = "While Cargo Bay is in play, each player may draw one additional card for each Quartermaster in play on their side of the field."

/obj/item/griffeningdeck/cardhand/single/EmergencyShuttleArea

	name = "Emergency Shuttle Area"
	desc = "While Emergency Shuttle is in play, no equipment cards may be in play. At the start of the 11th turn after Emergency Shuttle was played, if Emergency Shuttle is still in play, the player who played it automatically wins. Emergency Shuttle cannot be played unless the player has a head of staff or the AI on the field."

/obj/item/griffeningdeck/cardhand/single/Area/Bridge

	name = "Bridge"
	desc = "While Bridge is in play, heads of staff can only be attacked by other heads of staff, unless the AI is on the attacker's side of the field. All heads of staff gain 15 ATK, 15 DEF."

/obj/item/griffeningdeck/cardhand/single/Area/EmergencyShuttle

	name = "Emergency Shuttle"
	desc = "While Emergency Shuttle is in play, no equipment cards may be in play. At the start of the 11th turn after Emergency Shuttle was played, if Emergency Shuttle is still in play, the player who played it automatically wins. Emergency Shuttle cannot be played unless the player has a head of staff or the AI on the field."
