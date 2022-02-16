/obj/item/clothing/head/wizard
	name = "wizard hat"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"
	permeability_coefficient = 0.01
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 20, FIRE = 100, ACID = 100,  WOUND = 20)
	strip_delay = 50
	equip_delay_other = 50
	clothing_flags = SNUG_FIT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	dog_fashion = /datum/dog_fashion/head/blue_wizard

/obj/item/clothing/head/wizard/red
	name = "red wizard hat"
	desc = "Strange-looking red hat-wear that most certainly belongs to a real magic user."
	icon_state = "redwizard"
	dog_fashion = /datum/dog_fashion/head/red_wizard

/obj/item/clothing/head/wizard/yellow
	name = "yellow wizard hat"
	desc = "Strange-looking yellow hat-wear that most certainly belongs to a powerful magic user."
	icon_state = "yellowwizard"
	dog_fashion = null

/obj/item/clothing/head/wizard/black
	name = "black wizard hat"
	desc = "Strange-looking black hat-wear that most certainly belongs to a real skeleton. Spooky."
	icon_state = "blackwizard"
	dog_fashion = null

/obj/item/clothing/head/wizard/fake
	name = "wizard hat"
	desc = "It has WIZZARD written across it in sequins. Comes with a cool beard."
	icon_state = "wizard-fake"
	permeability_coefficient = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	resistance_flags = FLAMMABLE
	dog_fashion = /datum/dog_fashion/head/blue_wizard

/obj/item/clothing/head/wizard/marisa
	name = "witch hat"
	desc = "Strange-looking hat-wear. Makes you want to cast fireballs."
	icon_state = "marisa"
	dog_fashion = null

/obj/item/clothing/head/wizard/magus
	name = "\improper Magus helm"
	desc = "A mysterious helmet that hums with an unearthly power."
	icon_state = "magus"
	inhand_icon_state = "magus"
	dog_fashion = null

/obj/item/clothing/head/wizard/santa
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags_inv = HIDEHAIR|HIDEFACIALHAIR
	dog_fashion = null

/obj/item/clothing/suit/wizrobe
	name = "wizard robe"
	desc = "A magnificent, gem-lined robe that seems to radiate power."
	icon_state = "wizard"
	inhand_icon_state = "wizrobe"
	permeability_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 20, FIRE = 100, ACID = 100, WOUND = 20)
	allowed = list(/obj/item/teleportation_scroll, /obj/item/highfrequencyblade/wizard)
	flags_inv = HIDEJUMPSUIT
	strip_delay = 50
	equip_delay_other = 50
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A magnificent red gem-lined robe that seems to radiate power."
	icon_state = "redwizard"
	inhand_icon_state = "redwizrobe"

/obj/item/clothing/suit/wizrobe/yellow
	name = "yellow wizard robe"
	desc = "A magnificent yellow gem-lined robe that seems to radiate power."
	icon_state = "yellowwizard"
	inhand_icon_state = "yellowwizrobe"

/obj/item/clothing/suit/wizrobe/black
	name = "black wizard robe"
	desc = "An unnerving black gem-lined robe that reeks of death and decay."
	icon_state = "blackwizard"
	inhand_icon_state = "blackwizrobe"

/obj/item/clothing/suit/wizrobe/marisa
	name = "witch robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	inhand_icon_state = "marisarobe"

/obj/item/clothing/suit/wizrobe/magusblue
	name = "\improper Magus robe"
	desc = "A set of armored robes that seem to radiate a dark power."
	icon_state = "magusblue"
	inhand_icon_state = "magusblue"

/obj/item/clothing/suit/wizrobe/magusred
	name = "\improper Magus robe"
	desc = "A set of armored robes that seem to radiate a dark power."
	icon_state = "magusred"
	inhand_icon_state = "magusred"


/obj/item/clothing/suit/wizrobe/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	inhand_icon_state = "santa"

/obj/item/clothing/suit/wizrobe/fake
	name = "wizard robe"
	desc = "A rather dull blue robe meant to mimic real wizard robes."
	icon_state = "wizard-fake"
	inhand_icon_state = "wizrobe"
	permeability_coefficient = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	resistance_flags = FLAMMABLE

/obj/item/clothing/head/wizard/marisa/fake
	name = "witch hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	permeability_coefficient = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	resistance_flags = FLAMMABLE

/obj/item/clothing/suit/wizrobe/marisa/fake
	name = "witch robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	inhand_icon_state = "marisarobe"
	permeability_coefficient = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	resistance_flags = FLAMMABLE

/obj/item/clothing/suit/wizrobe/paper
	name = "papier-mache robe" // no non-latin characters!
	desc = "A robe held together by various bits of clear-tape and paste."
	icon_state = "wizard-paper"
	inhand_icon_state = "wizard-paper"
	var/robe_charge = TRUE
	actions_types = list(/datum/action/item_action/stickmen)


/obj/item/clothing/suit/wizrobe/paper/ui_action_click(mob/user, action)
	stickmen()


/obj/item/clothing/suit/wizrobe/paper/verb/stickmen()
	set category = "Object"
	set name = "Summon Stick Minions"
	if(!isliving(usr))
		return
	if(!robe_charge)
		to_chat(usr, span_warning("The robe's internal magic supply is still recharging!"))
		return

	usr.say("Rise, my creation! Off your page into this realm!", forced = "stickman summoning")
	playsound(loc, 'sound/magic/summon_magic.ogg', 50, TRUE, TRUE)
	var/mob/living/M = new /mob/living/basic/stickman(get_turf(usr))
	M.faction += list("[REF(usr)]")
	robe_charge = FALSE
	sleep(30)
	robe_charge = TRUE
	to_chat(usr, span_notice("The robe hums, its internal magic supply restored."))

// The actual code for this is handled in the shielded component, see [/datum/component/shielded/proc/check_recharge_rune]
/obj/item/wizard_armour_charge
	name = "battlemage shield charges"
	desc = "A powerful rune that will increase the number of hits a suit of battlemage armour can take before failing.."
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"
