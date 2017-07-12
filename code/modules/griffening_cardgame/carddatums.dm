/datum/griffeningcard

	var/name = ""
	var/desc = ""
	var/ATK = 0
	var/DEF = 0
	var/LVL = 0
	var/BONUSATK = 0
	var/BONUSDEF = 0
	var/REMOVEATK = 0
	var/REMOVEDEF = 0
	var/summonsound = null //Same thing for if you use an effect
	var/attacksound = null //also hologram hype
	var/deathsound = null
	var/hologramvisual = null
	var/card_type = null
	var/rarity = common
	var/list/Attributes = list() //What special effects does this have? will be shown during examining a card
 
 
/datum/griffeningcard/creature
	card_type = CREATURE_CARD

/datum/griffeningcard/effect
	card_type = EFFECT_CARD
	LVL = 0
	ATK = 0
	DEF = 0

/datum/griffeningcard/equipment
	card_type = EQUIPMENT_CARD
	LVL = 0
	ATK = 0
	DEF = 0
	BONUSATK = 0
	BONUSDEF = 0
	REMOVEATK = 0
	REMOVEDEF = 0
/datum/griffeningcard/area
	card_type = AREA_CARD

/datum/griffeningcard/creature/captain
	name = "Captain"
	desc = "Captain cannot be played if there's a nuclear operative or captain in play. Requires the bridge area to be played. If this card is summoned, get a energy gun card from your hand, discard pile or deck and attach it to this card. You may also immediately search your deck for a card that's a head and if you do, summon it. The card cannot be a captain."
	LVL = 7
	ATK = 60
	DEF = 60
	Attributes = list(DECK_SEARCH_ENERGY_GUN, DECK_SEARCH_HEAD, HEAD, TWO_SACRIFICE, NO_OP, NO_CAPTAIN, AREA_BRIDGE, HUMAN, NON_ANTAG)

/datum/griffeningcard/creature/HeadOfPersonnel
	name = "Head Of Personnel"
	desc = "If you control this card, then you may sacrifice a assistant, if you do then immediately summon any level 3 or below non antagonist human from your deck."
	LVL = 7
	ATK = 20
	DEF = 65
	Attributes = list(ASSISTANT_IMMUNITY, ASSISTANT_PROMOTION, HEAD, HUMAN, NON_ANTAG)

/datum/griffeningcard/creature/Assistant
	name = "Assistant"
	desc = "A regular assistant, while not powerful, with the right people the combined power would had been to great for many."
	LVL = 2
	ATK = 10
	DEF = 5
	Attributes = list(ASSISTANT, HUMAN, NON_ANTAG)

/datum/griffeningcard/creature/HeadOfSecurity

	name = "Head Of Security"
	desc = "Requires a security officer to be sacrificed to play this card. If you control a Head Of Personnel then you may sacrifice a assistant to instead immiediately summon a security officer. Increase all security officers ATK by 20."
	LVL = 7
	ATK = 50
	DEF = 35
	Attributes = list(HEAD, ASSISTANT_SEC_PROMOTION, SECURITY_OFFICER_20_ATK, SECURITY, HUMAN, NON_ANTAG, SECURITY_SACRIFICE)

/datum/griffeningcard/creature/SecurityOfficer

	name = "Security Officer"
	desc = "Security officer cannot kill a non antagonist human unless 'head of security' is in play. Instead, if the non antagonist human has a DEF lower than this card's attack, the human will become incapacited for one turn. The duration is doubled if security officer has a 'taser' equipped. This effect is optional on antagonist humans unless you state it's not. "
	LVL = 5
	ATK = 30
	DEF = 25
	Attributes = list(HUMAN, SECURITY, NON_ANTAG, NOATK_NON_ANTAG, INCAPACITATINGATTACK, SECURITY_OFFICER)

/datum/griffeningcard/creature/Warden

	name = "Warden"
	desc = "Requires a security officer to be sacrificed to play this card. Cannot be attacked if you control a Security Officer or Head Of Security. When summoned, all current and future security guards you summon will have a taser equipped to them."
	LVL = 7
	ATK = 15
	DEF = 15
	Attributes = list(HUMAN, SECURITY, NON_ANTAG, SECURITY_IMMUNITY, TASERDISTRIBUTION, SECURITY_SACRIFICE)

/datum/griffeningcard/creature/Lawyer

	name = "Lawyer"
	desc = "While lawyer is in play, any antagonists on the owner's side of the field cannot be attacked or effected by a card effect. Any 'security officer' on the same field of the owner of this card cannot attack but can still incapacitate."
	LVL = 3
	ATK = 10
	DEF = 10
	Attributes = list(HUMAN, NON_ANTAG, ANTAG_IMMUNITY, SECURITY_OFFICER_NOATK)

/datum/griffeningcard/creature/Clown
	name = "Clown"
	desc = "When the opponent's creature attacks and you control this card, you may instead redirect the target the opponent is attacking to this one. If this card dies as a result of a creature attack, that creature will be incapacitated for one turn."
	LVL = 2
	ATK = 10
	DEF = 25
	Attributes = list(HUMAN, NON_ANTAG, CHANGEATTACKTARGET, COUNTER, DEATHRATTLEINCAPACITATE)

/datum/griffeningcard/creature/ResearchDirector

	name = "Research Director"
	desc = "This card can only be summoned by sacrificing a scientist.. If this card is in play, increase the ATK of all scientist cards you own by 20. Once per turn at any point, all the ATK and DEF of one 'scientist' is transferred to any other card on the field. At the end of the opponents turn, this effect is reversed. "
	LVL = 6
	ATK = 45
	DEF = 45
	Attributes = list(HUMAN, NON_ANTAG, HEAD, SCIENTIST_SACRIFICE, SCIENTIST_20_ATK, SCIENTIST_STAT_DONATION)

/datum/griffeningcard/creature/Scientist

	name = "Scientist"
	desc = "At the beginning of the owner of this card's turn, if there's another scientist on the field you control, increase the ATK and DEF of this card by 10 until you control no more scientists."
	LVL = 3
	ATK = 25
	DEF = 25
	Attributes = list(HUMAN, NON_ANTAG, SCIENTIST, SCIENTIST_10_STAT)

/datum/griffeningcard/creature/Roboticist

	name = "Roboticist"
	desc = "If a cyborg you control is dismantled, you may summon it as soon as your turn begins."
	LVL = 3
	ATK = 15
	DEF = 15
	Attributes = list(HUMAN, NON_ANTAG, CYBORG_REVIVAL)

/datum/griffeningcard/creature/ChiefEngineer
	name = "Chief Engineer"
	desc = "You must sacrifice a engineer to play this card. At the start of your turn, if this card is not incapacitated then you may remove the opponent's current area card. While this card is in play and the engineering area active, your area card cannot be destroyed or replaced."
	LVL = 6
	ATK = 40
	DEF = 50
	Attributes = list(HUMAN, NON_ANTAG, HEAD, ENGINEER, ENGINEER_SACRIFICE, AREA_REMOVER, AREA_REPLACER)

/datum/griffeningcard/creature/Engineer

	name = "Engineer"
	desc = "At the beginning of your turn, if this card has a equipment card attached to itself, then you may search the deck for the same equipment card and put it into your hand."
	LVL = 5
	ATK = 25
	DEF = 45
	Attributes = list(HUMAN, NON_ANTAG, ONE_SACRIFICE, EQUIPMENT_GENERATOR)

/datum/griffeningcard/creature/Janitor

	name = "Janitor"
	desc = "When this card is played, get a wet floor effect card from your deck and either put it on the field facedown or in your hand."
	LVL = 2
	ATK = 15
	DEF = 20
	Attributes = list(HUMAN, NON_ANTAG, SEARCH_DECK_WET_FLOOR, WET_FLOOR_REFRESHER)
	
/datum/griffeningcard/creature/Barman

	name = "Barman"
	desc = "As long as this card remains on the field, all non antag humans you control are immune to incapacitation."
	LVL = 2
	ATK = 15
	DEF = 10
	Attributes = list(HUMAN, NON_ANTAG, HUMAN_NONANTAG_INCAPACITATION_IMMUNITY)

/datum/griffeningcard/creature/CMO

	name = "Chief Medical Officer"
	desc = "This card can only be played if you sacrifice a medical doctor. If this card is in play, increase all DEF of all humans you control by 20. This effect gives 20 more DEF per medical doctor you control."
	LVL = 7
	ATK = 30
	DEF = 20
	Attributes = list(HUMAN, NON_ANTAG, HEAD, MEDICAL_DOCTOR_SACRIFICE, HUMAN_20_DEF, MED_DOC_20_DEF)

/datam/griffeningcard/creature/MedicalDoctor

	name = "Medical Doctor"
	desc = "A medical doctor that well, heals people somehow."
	LVL = 2
	ATK = 10
	DEF = 20
	Attributes = list(HUMAN, NON_ANTAG, MEDICAL_DOCTOR)
	
/datum/griffeningcard/creature/Geneticist

	name = "Geneticist"
	desc = "A person that deals with genetics, as it says on the tin. "
	LVL = 3
	ATK = 15
	DEF = 10
	Attributes = list(HUMAN, NON_ANTAG, GENETICIST)
	
/datum/griffeningcard/creature/Cyborg

	name = "Cyborg"
	desc = "Cannot attack humans unless a law card states so. The starting law is NoHarm. When this card is played, you may get a door bolts card from your deck or discard pile and place it in your hand."
	LVL = 3
	ATK = 30
	DEF = 20
	Attributes = list(CYBORG, NON_ANTAG, EFFECTED_BY_LAW, DECK_SEARCH_DOOR_BOLTS)

/datum/griffeningcard/creature/AI
	
	name = "AI"
	desc = "This card can only be played if you sacrifice a cyborg. This card cannot attack. If a Human that's a head is on either side when this card is played, you may search your deck for a law card."
	LVL = 6
	ATK = 0
	DEF = 40
	Attributes = list(AI, NON_ANTAG, EFFECTED_BY_LAW, DECK_SEARCH_LAW)

/datum/griffeningcard/creature/AtmosphericTech

	name = "Atmospheric Tech"
	desc = "A human meant to supervise the atmos of the station... most of the time."
	LVL = 1
	ATK = 15
	DEF = 10
	Attributes = list(HUMAN, NON_ANTAG, ATMOSPHERIC)

/datum/griffeningcard/creature/Wizard

	name = "Wizard"
	desc = "If this card has a magical robe and magical hat equipped, when the opponent starts their turn, you may use one of the following effects, 1. Incapacitate all enemies for one turn. This stacks in duration. 2. Kill any opponent human card. 3. For the rest of the opponent's turn, this card cannot be effected by anything. If this card also has a magical staff, you can instead do two effects per turn."
	LVL = 7
	ATK = 25
	DEF = 20
	Attributes = list(HUMAN, ANTAG, TWO_SACRIFICES, WIZARD)

/datum/griffeningcard/creature/Changeling

	name = "Changeling"
	desc = "At the start of your turn, you may choose any human card in either player's discard pile, if you do, copy the ATK and DEF of said card and send the card to the 'gibbed pile'. If the opponent successfully uses the 'flamethrower', 'Incendiary Grenade' or 'Plasma Fire', immediately discard this card. This card is considered a non human."
	LVL = 1
	ATK = 5
	DEF = 5
	Attributes = list(NON_HUMAN, ANTAG, STAT_COPY, STRONGFLAMEWEAKNESS, CHANGELING)

/datum/griffeningcard/creature/Abomination

	desc = "Abomination cannot be destroyed by humans without a ATK boosting equipment card. At the start of the opponents turn, incapacitate one of their creatures. If the opponent successfully uses the 'flamethrower', 'Incendiary Grenade' or 'Plasma Fire', the DEF of this card becomes 50%. This is considered a non human."
	LVL = 9
	ATK = 90
	DEF = 90
	Attributes = list(NO_HUMAN, ANTAG, FLAMEWEAKNESS)

/datum/griffeningcard/creature/NuclearOperative

	name = "Nuclear Operative"
	desc = "You cannot play this card if you also control a captain. If this card is destroyed as a result of a creature, that creature is incapacitated for two turns and this card is sent to the gibbed pile."
	LVL = 7
	ATK = 6
	DEF = 40
	Attributes = list(HUMAN, ANTAG, OP, STRONG_DEATHRATTLEINCAPACITATE)

/datum/griffeningcard/creature/Quartermaster

	name = "Quarter Master"
	desc = "This card can only be played if you sacrifice a cargo tech."
	LVL = 5
	ATK = 35
	DEF = 50
	Attributes = list(HUMAN, NON_ANTAG, QUARTERMASTER, CARGOTECH_SACRIFICE)

/datum/griffeningcard/creature/CargoTech

	name = "Cargo Tech"
	desc = "A person responsible for hauling crates."
	LVL = 3
	ATK = 10
	DEF = 25
	Attributes = list(HUMAN, NON_ANTAG, CARGOTECH)

/datum/griffeningcard/effect/HullBreach

	name = "Hull Breach"
	desc = "This card can only be played if you control a antag human or cyborg. While this card is in play, reduce the def of all humans on the field by 40 unless they have a space suit equipped. By the end of the turn, if either you or your opponent have a engineer or chief engineer in play, this card is discarded."
	REMOVEDEF = 40
	Attributes = list(GLOBAL_DEF_DECREASE, CONTINUOUS, SPACESUIT_IMMUNITY, ENGINEER_REMOVES, ANTAG_REQUIRED)

/datum/griffeningcard/effect/Disarm

	name = "Disarm Intent"
	desc = "Can be played at any time, you may either use one of two effects 1. Destroy a effect card, can negate a effect card being activated. 2. Select a creature, remove any one equipment card from it."
	Attributes = list(NEGATE_EFFECT_CARD, ANY_TIME, TARGETTED, ONE_EQUIPMENT_DESTROY)

/datum/griffeningcard/effect/DeathGasp

	name = "Death Gasp"
	desc = "If an enemy creature destroys one of your creatures with an attack or effect, you may immediately play this card, that creature is not destroyed."
	Attributes = list(DEFY_DEATH, ANY_TIME, ON_CREATURE_DEATH)

/datum/griffeningcard/equipment/Stimpack

	name = "Stimpack"
	desc = "Antag only. The equipped creature gains 30 DEF and can no longer be incapacitated as long as this is equipped. The DEF bonus is lost upon denquipping."
	BONUSDEF = 30
	Attributes = list(DEFBOOST, TARGETTED, EQUIPMENT, INCAPACITATE_IMMUNITY)

/datum/griffeningcard/equipment/Injector

	name = "Injector"
	desc = "If the creature equipped with this card would had been discarded, discard this card instead. This card otherwise cannot be removed."
	Attributes = list(DISCARD_IMMUNITY, SECOND_LIFE)

/datum/griffeningcard/equipment/Mindslave

	name = "Mindslave"
	desc = "Can only be used if the owner of this card has a antag human, cyborg or a 'Nuclear Operative' in play. Cannot be used on a human already antags, or a 'Nuclear Operative' or a already mindslaved human. If used on a enemy creature, take control of the equipped human until the implant is destroyed. This cannot work on security officers, wardens or Heads"
	Attributes = list(MINDSLAVE, TARGETTED, EQUIPMENT, HUMAN_ONLY, REQUIRE_ANTAG) //Mindslave attribute cause that's snowflaky as hell

/datum/griffeningcard/equipment/motivationalspeech

	name = "Motivational Speech"
	desc = "Equip this card to a creature on the field, if you do, take control of that creature until the end of your turn."
	Attributes = list(TAKE_CONTROL_ONE_TURN, TARGETTED, ANY_CREATURE

/datum/griffeningcard/effect/shockwave

	name = "Shockwave"
	desc = "When this card is played successfully, unequip and return all equipment cards and effect cards to the respective owner's hand. This effect will not return this card to the hand. Any card that has a special effect from being destroyed or unequipped will apply."
	Attributes = list(UNEQUIP_ALL, RETURNEFFECTS)

/datum/griffeningcard/effect/knockoutgas

	name = "Knockout Gas"
	desc = "No enemy humans may attack you until the end of your second turn, with the turn you played this card being the first."
	Attributes = list(NO_ATTACK_TWO_TURNS)

/datum/griffeningcard/effect/empstorm

	name = "EMP storm"
	desc = "All law modules currently activated are destroyed. Any cyborg or AI on the field will have it's ATK and DEF both lowered by 20 until the end of the turn."
	REMOVEATK = 20
	REMOVEDEF = 20
	Attributes = list(GLOBAL_CYBORG_DEF_DECREASE, GLOBAL_CYBORG_ATK_DECREASE, LAW_DELETE)

/datum/griffeningcard/effect/lawnohuman

	name = "Law Module No Human"
	desc = "When this card is played, immediately destroy all other law modules from the field. Cyborgs and AIs may hurt humans without restriction."
	Attributes = list(LAW_NO_HUMAN)

/datum/griffeningcard/effect/lawselfdestruct

	name = "Law Module Deactivation"
	desc = "When this card is played, immediately destroy all other law modules from the field. While this card is in play, all cyborgs and AIs are incapacitated."
	Attributes = list(LAW_DEACTIVATION)

/datum/griffeningcard/effect/lawdonotharm

	name = "Law Module Do No Harm"
	desc = "When this card is played, immediately destroy all other law modules from the field. While this card is active, robot cards may not attack."
	Attributes = list(LAW_DO_NO_HARM)

/datum/griffeningcard/effect/ThermalOpticalGoggles

	name = "Thermal Optical Goggles"
	desc = "When this card is played, your opponent reveals his/her hand as well as all facedown cards on their side of the field."
	Attributes = list(SHOW_OPPONENT_HAND, SHOW_OPPONENT_FACEDOWN)

/datum/griffeningcard/effect/stealthstorage

	name = "Stealth Storage"
	desc = "Can be played at any time, allows a card you pick to be played at any time, no matter what it says."
	Attributes = list(ANY_TIME, ADDTAG_ANY_TIME)

/datum/griffeningcard/equipment/energygun

	name = "Energy Gun"
	desc = "A creature equipped with this will have the ATK raised by 30 and DEF by 15. The ATK and DEF bonuses are lost upon this card being destroyed."
	BONUSATK = 30
	BONUSDEF = 15
	Attributes = list(EQUIPMENT, ATKBOOST, DEFBOOST, TARGETTED)

/datum/griffeningcard/effect/robotframe

	name = "Robot Frame"
	desc = "Instantly bring a cyborg from either player's discarded pile onto your side of the field. If you have a 'roboticist' in play on your field, you may instead bring back two cyborgs instead."
	Attributes = list(REVIVE_CYBORG)

/datum/griffeningcard/effect/meteorshower

	name = "Meteor Shower"
	desc = "All areas currently in effect are destroyed, this cannot be countered or destroyed and only on your turn."
	Attributes = list(DESTROY_ALL_AREAS, NO_COUNTER)

/datum/griffeningcard/equipment/radio

	name = "Radio"
	desc = "When the creature equipped with this is killed or gibbed, choose any level 4 or lower creature from your deck and if you do, put it into your hand."
	Attributes = list(SUMMON_LEVEL_FOUR_CREATURE, EQUIPMENT, TARGETTED)
	
/datum/griffeningcard/equipment/esword

	name = "Energy Sword"
	desc = "Only traitors or 'syndicate operative' can use this. Increase the equipped creature's ATK by 40. If you were to attack and the defending creature has a DEF or ATK boosting weapon, nullify the effects. Same applies with defending an attack."
	BOOSTATK = 40
	Attributes = list(NULLIFY_EQUIPMENT_STAT_BOOST, ANTAG_ONLY)

/datum/griffeningcard/equipment/fake357

	name = "Fake 357"
	desc = "Can be used on any human on the field. If the human that has this card equipped attacks, kill the creature instead and discard this equipment card."
	Attributes = list(KILL_ON_ATTACK, ANY_TARGET, TARGETTED, EQUIPMENT)

/datum/griffeningcard/equipment/toolbox

	name = "Toolbox"
	desc = "Increase the equipped creature ATK by 10. If it's an assistant, the ATK is instead increased by 25."
	BONUSATK = 10
	Attributes = list(ATKBOOST, TARGETTED, EQUIPMENT, ASSISTANT_ATK_BOOST_25)

/datum/griffeningcard/equipment/fireextinguisher

	name = "Fire Extinguisher"
	desc = "Increases the equipped creature ATK by 20. If the creature is attacked or effected by plasma fire, incendiary grenade or flamethrower, you may choose to negate the effect and if you do, destroy the negated card and destroy this card as well."
	BOOSTATK = 20
	Attributes = list(NULLIFY_FIRE, BOOSTATK, TARGETTED, EQUIPMENT, DISCARD_AFTER_EFFECT)

/datum/griffeningcard/effect/wetfloor

	name = "Wet Floor"
	desc = "When a enemy human attacks, you may play this card. If you do successfully, the attack is concluded immediately. If you control a janitor, this card is put into your hand instead of the discard pile."
	Attributes = list(STOP_ATTACK, ANY_TIME_DURING_ATTACK, JANITOR_REFRESH, TARGETTED)

/datum/griffeningcard/effect/adminhelp

	name = "Adminhelp"
	desc = "This card can only be played if it's facedown and being used to counter an effect or a equipping a creature of a equipment card. The card is destroyed unless this card is destroyed as a result of a counter. Destroy this card after the effects are concluded."
	Attributes = list(FACEDOWN_ONLY, STOP_EQUIPPING, STOP_EFFECT, ANY_TIME)

/datum/griffeningcard/equipment/wrestlingbelt

	name = "Wrestling Belt"
	desc = "Can only be used by traitors or a syndicate operative and only humans, increases the equipped human ATK and DEF by 20 and if the equipped human is to be attacked, negate any ATK bonuses the attacker if it has any."
	BOOSTATK = 20
	BOOSTDEF = 20
	Attributes = list(EQUIPMENT, TARGETTED, BOOSTATK, BOOSTDEF, NULLIFY_ATTACKER_WEAPON_STAT_BOOST)

/datum/griffeningcard/effect/supplyshuttle

	name = "Supply Shuttle"
	desc = "Can only be played if there's either a quartermaster or cargo area in play. If there is, any players that control a quartermaster or owns a cargo area draws cards until they have six."
	Attributes = list(ONLY_QUARTERMASTER_OR_CARGO_AREA, DRAW_TIL_SIX)

/datum/griffeningcard/effect/radiouplink

	name = "Radio Uplink"
	desc = "The player of this card can search the deck for any one equipment or effect card."
	Attributes = list(SEARCH_DECK_EQUIPMENT, SEARCH_DECK_EFFECT)

/datum/griffeningcard/effect/abandonedcrate

	name = "Abandoned Crate"
	desc = "Discard any card, if you do so successfully, draw two cards."
	Attributes = list(DISCARD_ON_USE, DRAW_TWO)

/datum/griffeningcard/effect/surpluscrate

	name = "surplus Crate"
	desc = "When this is played successfully, draw three cards and show them to the opponent, then discard two cards."
	Attributes = list(DRAW_THREE, DISCARD_TWO, SHOW_CARDS)

/datum/griffeningcard/effect/telescientist

	name = "Telescientist"
	desc = "A Research Director must be in play and you own it to play this card. When this card is played, view your opponents hand and take one card."
	Attributes = list(RESEARCH_DIRECTOR_REQUIRED, OPPONENT_HAND_SEARCH, DRAW_OPPONENT_HAND_CARD)

/datum/griffeningcard/effect/deconstructor

	name = "Deconstructor"
	desc = "This card can only be played if facedown and used as a counter to a effect or equipment card and only if you control a scientist. Destroy the card, if this happens then search the opponents deck for a copy of the card. If a copy of the card has been found, discard that card and shuffle the deck."
	Attributes = list(FACEDOWN_ONLY, SCIENTIST_REQUIRED, STOP_EQUIPPING, STOP_EFFECT, SEARCH_OPPONENT_DECK_FOR_COPY)

/datum/griffeningcard/effect/enginesabotage

	name = "Engine Sabotage"
	desc = "Continuous effect, requires a antag to play, while this card is active, all opponent area cards are negated and no new area cards can be played. If there's a 'emergency shuttle' area card in play, the effects of it is not negated, but neither player can play a 'emergency shuttle' card."
	Attributes = list(ANTAG_ONLY, CONTINUOUS, NULLIFY_OPPONENT_AREA

/datum/griffeningcard/equipment/handcuffs

	name = "Handcuffs"
	desc = "Cannot be put facedown, target a human creature and equip this card to it. At the end of your third turn, the turn you play it on being the first, destroy the card. As long as that human has this card equipped, it cannot use it's effect or attack."
	Attributes = list(NO_FACEDOWN, ANY_HUMAN, EQUIPMENT, TARGETTED, THREE_TURN_INCAPACITATE, THREE_TURN_DISCARD)

/datum/griffeningcard/equipment/incendiarygrenade

	name = "Incendiary Grenade"
	desc = "If the creature this card is equipped to attacks, any opponent creature that has less than 20 DEF is destroyed. All other opponent creatures that have 20 or higher DEF will instead have DEF lowered by 20 until the end of your turn. If this effect has concluded, destroy this card."
	REMOVEDEF = 20
	Attributes = list(OPPONENT_REMOVEDEF_20_ONE_TURN, DISCARD_AFTER_EFFECT, EQUIPMENT, TARGETTED, DISCARD_BELOW_DEF)

/datum/griffeningcard/effect/firefightinggrenade

	name = "Fire Fighting Grenade"
	desc = "This card may be played in response to Flamethrower, Plasma Fire and Incendiary Grenade. Instantly destroy both cards. When this card is activated, the opponent's turn immediately ends."
	Attributes = list(END_OPPONENT_TURN, NULLIFY_FIRE, DISCARD_AFTER_EFFECT, ANY_TIME)

/datum/griffeningcard/equipment/plasmafire

	name = "Plasma Fire"
	desc = "This card can only be played if there's a atmospheric tech in play. When this card is played, instantly reduce the DEF of all opponent humans by 10. While this card is active, all opponent humans lose 20 DEF at the start of the opponent's turn. If a creature reaches 0 DEF due to the effects of this card, the creature is killed. If any area cards are played while Plasma Fire is active, discard Plasma Fire."
	REMOVEDEF = 10
	Attributes = list(GLOBAL_REMOVEDEF, REMOVEDEF_20_PER_TURN, FIRE, DISCARD_ON_AREA)

/datum/griffeningcard/effect/authenticationdisk

	name = "Authentication Disk"
	desc = "This card can only be played if there's a captain in play. If the captain is on your side of the field, summon two security officer immediately on your side of the field either from your hand, deck or discard pile. If the captain is on the opponent's field, immediately summon two 'nuclear operatives' from your deck, hand or discard pile."
	
/datum/griffeningcard/effect/pinpointer

	name = "Pinpointer"
	desc = "When this card is played, put a 'authentication disk' card into your hand either from both yours and opponent's discard pile or deck."

/datum/griffeningcard/effect/mattereater

	name = "Matter Eater"
	desc = "When this card is played, choose a face up equipment card and immediately send it to the gibbed pile and if you do, send this card to the discard pile."

/datum/griffeningcard/equipment/spacesuit

	name = "Space Suit"
	desc = "Can only be equipped to humans, any human equipped with this is immune to 'hull breach', 'flamethrower', 'plasma fire' or 'incendiary grenade' as well as increase DEF by 10."

/datum/griffeningcard/effect/dnaabsorbtion

	name = "DNA Absorbtion"
	desc = "Can only be played if you control a 'changeling', if you do, target a enemy creature and send it to the gibbed pile. If you do, send 'changeling' to the discard pile and immediately summon 'abomination' either from your hand, deck or discard pile."

/datum/griffeningcard/effect/crematorium

	name = "Crematorium"
	desc = "When this card is played, place 5 cards from the discard pile of either player to their gibbed pile."

/datum/griffeningcard/equipment/flamethrower

	name = "Flamethrower"
	desc = "When attacking a human using 'Flamethrower', reduce their DEF by 30 before attacking. If target humanoid is 'changeling', immediately destroy the 'changeling;. If the target is 'Abomination', reduce their DEF by half instead."

/datum/griffeningcard/equipment/energyaxe

	name = "Energy Axe"
	desc = "Can only be equipped if you sacrifice a creature and if you do, you may equip this card to a creature. Raises the ATK by 40 and DEF by 20 of the equipped creature."

/datum/griffeningcard/equipment/riotlauncher

	name = "Riot Launcher"
	desc = "If the equipped creature attacks an enemy that has an equipment card, remove the equipment card or choose one if there's more than one equipped."

/datum/griffeningcard/equipment/telekinesis

	name = "Telekinesis"
	desc = "Requires a 'geneticist' to be in play on your field, take any equipment card currently equipped to a enemy creature and put it in your hand."

/datum/griffeningcard/equipment/basketball

	name = "Basketball"
	desc = "If the equipped creature attacks a creature that has a ATK or DEF boosting card equipped, destroy the card. If the creature doesn't have one, change the ownership of this item to the opponent and equip it to the defending creature."

/datum/griffeningcard/effect/chaosdunk

	name = "Chaos Dunk"
	desc = "If you have a creature equipped with 'basketball' you may play this card. At the end of your turn, gib all creatures on the field including yours as well as equipment cards. "

/datum/griffeningcard/equipment/grenade

	name = "Grenade"
	desc = "If a creature equipped with this kills a creature, that creature is sent to the gibbed pile. If this creature is killed by any means, it is also gibbed. If grenade is removed it is sent to the gibbed pile. The ATK of the equipped creature is increased by 10, while the DEF is decreased by 10."

/datum/griffeningcard/equipment/artistictoolbox

	name = "Artistic Toolbox"
	desc = "You must sacrifice a human before using this card, if you do you may equip this card to a human. The equipped human cannot be incapacitated while this is equipped. Anytime the equipped human kills another human, that human is sent to the gibbed pile. Artistic toolbox gives the equipped human 10 ATK and DEF for each human in the opponents gibbed pile. At the end of every two turns, you must sacrifice a human, if you cannot this card is sent to the gibbed pile."

/datum/griffeningcard/effect/greyide

	name = "Greytide"
	desc = "When this card is played, immediately spawn up to two assistants from the your deck, hand or discard pile to the field."

/datum/griffeningcard/effect/mutiny

	name = "Mutiny"
	desc = "Can only be played if you have three assistants on your side of the field and a sacrificed human. The opponent must have a 'captain' on their field and if they do, you gain ownership of the 'captain'."

/datum/griffeningcard/equipment/wizardhat

	name = "Wizard Hat"
	desc = "If the equipped creature is a 'wizard' and has the robe equipped as well, 'wizard' gains 20 ATK and DEF."

/datum/griffeningcard/equipment/wizardrobe

	name = "Wizard Robe"
	desc = "If the equipped creature is a 'wizard' and has the robe equipped as well, 'wizard' gains 20 ATK and DEF."

/datum/griffeningcard/equipment/wizardstaff

	name = "Wizard Staff"
	desc = "The equipped creature gains 10 ATK and DEF."

/datum/griffeningcard/equipment/reinforcedsteel

	name = "Reinforced Steel"
	desc = "Cannot stack with 'heavy steel' and can only be used on cyborgs or AI. Increases ATK by 10 and DEF by 20."

/datum/griffeningcard/equipment/heavysteel

	name = "Heavy Steel"
	desc = "Cannot stack with 'reinforced steel' and can only be used on cyborgs or AI. Increases ATK by 20 and DEF by 40."

/datum/griffeningcard/equipment/speedupgrade

	name = "Speed upgrade"
	desc = "Only usable on cyborgs, a cyborg equipped with this can attack twice in one turn, if it does, it will become incapacitated until the end of your next turn."

/datum/griffeningcard/equipment/cyborgmodule

	name = "Cyborg Module"
	desc = "Only usable on cyborg, when equipped it can change its class and be able to change it once per turn during your turn.. Available classes are 'medical doctor', 'engineer', 'clown' or the'scientist'. It's class will give the effect corrasponding with the chosen class but not the ATK, DEF or LVL."

/datum/griffeningcard/area/engineering

	name = "Engineering Area"
	desc = "All 'engineer' and 'chief engineer' on the field gain 15 ATK and DEF. The bonus is lost once this card is destroyed."

/datum/griffeningcard/area/medbay

	name = "Medbay"
	desc = "All humans on your side of the field have it's DEF increased by 25. If a human you control is killed but not gibbed and you have a 'medical doctor', you can instead make the human incapacitated until the end of your next turn. A 'medical doctor' that has been chosen for this effect cannot do it again until the next turn and incapacitated crew cannot save anyone."

/datum/griffeningcard/area/genetics

	name = "Genetics Area"
	desc = "When this area is played, you may immediately summon any one discarded human to the field. At the beginning of your turn, if you have a geneticist and this card in play, you may immiediately summon a discarded human to your side of the field."

/datum/griffeningcard/area/robotics
	name = "Robotics Area"
	desc = "All robots you control have their ATK raised by 20 and DEF increased by 10. Any human that is killed which includes your opponent's human, you may choose to get a cyborg from your discard pile or deck and add it to your hand."

/datum/griffeningcard/area/thevoidarea

	name = "The Void Area"
	desc = "While the void is in play, all newly played humans lose half their ATK and DEF. Each player loses 10 HP at the beginning of their turn."

/datum/griffeningcard/area/syndicateshuttlearea

	name = "Syndicate Shuttle Area"
	desc = "When you play syndicate shuttle, immediately draw two cards for each traitor or operative you control. Any human or cyborg you control can now use any traitor items or be effected by anything that requires a traitor. This area is automatically destroyed if you control no creatures and cannot be destroyed any other way. If this card is discarded, any discarded card is gibbed instead."

/datum/griffeningcard/area/aiupload

	name = "Ai Upload Area"
	desc = "While AI Upload and an AI is in play, no human or robot may attack if the AI is not on their side of the field. While this card is active, the AI gains 120 DEF. If a law card is played while the AI is on the field, move the AI to the player's side of the field. If the AI is killed, this card destroyed."

/datum/griffeningcard/area/securityarea

	name = "Security Area"
	desc = "While Security is in play, Security Officers and Head of Security can incapacitate foes with higher DEF than their ATK when attacking them, preventing them from attacking. This card cannot be played while Lawyer is in play. If Lawyer enters play, destroy this card."

/datum/griffeningcard/area/cargobay

	name = "Cargo Bay Area"
	desc = "While Cargo Bay is in play, you may draw a card for every quartermaster you control."

/datum/griffeningcard/area/emergencyshuttlearea

	name = "Emergency Shuttle Area"
	desc = "While Emergency Shuttle is in play, no equipment cards may be in play. At the start of the 11th turn after Emergency Shuttle was played, if Emergency Shuttle is still in play, the player who played it automatically wins. Emergency Shuttle cannot be played unless the player has a head of staff or the AI on the field."

/datum/griffeningcard/area/bridge

	name = "Bridge"
	desc = "While Bridge is in play, heads of staff can only be attacked by other heads of staff, unless the AI is on the attacker's side of the field. All heads of staff gain 15 ATK, 15 DEF."




