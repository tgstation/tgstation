#define NULLROD "null rod"
#define GODHAND "god hand"
#define REDSTAFF "red staff"
#define BLUESTAFF "blue staff"
#define CLAYMORE "claymore"
#define DARKBLADE "dark blade"
#define SORD "sord"
#define SCYTHE "scythe"
#define CHAINSAW "chainsaw hand"
#define CLOWNDAGGER "clown dagger"
#define WHIP "whip"
#define FEDORA "athiests fedora"
#define ARMBLADE "dark blessing"
#define CARP "carp-sie plushie"


/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of Nar-Sie's followers."
	icon_state = "nullrod"
	item_state = "nullrod"
	force = 15
	throw_speed = 3
	throw_range = 4
	throwforce = 10
	w_class = 1
	var/reskinned = FALSE

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/attack_self(mob/user)
	if(reskinned)
		return
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		reskin_holy_weapon(user)

/obj/item/weapon/nullrod/proc/reskin_holy_weapon(mob/M)
	var/choice = input(M,"What theme would you like for your holy weapon?","Holy Weapon Theme") as null|anything in list(NULLROD, GODHAND, REDSTAFF, BLUESTAFF, CLAYMORE, DARKBLADE, SORD, SCYTHE, CHAINSAW, CLOWNDAGGER, WHIP, FEDORA, ARMBLADE, CARP)

	var/obj/item/weapon/nullrod/holy_weapon

	if(src && choice && !M.stat && in_range(M,src) && !M.restrained() && M.canmove && !reskinned)
		switch(choice)
			if(NULLROD)
				M << "On second thought, the null rod suits you just fine."
			if(GODHAND)
				holy_weapon = new /obj/item/weapon/nullrod/godhand
			if(REDSTAFF)
				holy_weapon = new /obj/item/weapon/nullrod/staff
			if(BLUESTAFF)
				holy_weapon = new /obj/item/weapon/nullrod/staff/blue
			if(CLAYMORE)
				holy_weapon = new /obj/item/weapon/nullrod/claymore
			if(DARKBLADE)
				holy_weapon = new /obj/item/weapon/nullrod/darkblade
			if(SORD)
				holy_weapon = new /obj/item/weapon/nullrod/sord
			if(SCYTHE)
				holy_weapon = new /obj/item/weapon/nullrod/scythe
			if(CHAINSAW)
				holy_weapon = new /obj/item/weapon/nullrod/chainsaw
			if(CLOWNDAGGER)
				holy_weapon = new /obj/item/weapon/nullrod/clown
			if(WHIP)
				holy_weapon = new /obj/item/weapon/nullrod/whip
			if(FEDORA)
				holy_weapon = new /obj/item/weapon/nullrod/fedora
			if(ARMBLADE)
				holy_weapon = new /obj/item/weapon/nullrod/armblade
			if(CARP)
				holy_weapon = new /obj/item/weapon/nullrod/carp
		feedback_set_details("chaplain_weapon","[choice]")

		if(holy_weapon)
			holy_weapon.reskinned = TRUE
			M.unEquip(src)
			M.put_in_active_hand(holy_weapon)
			qdel(src)


/obj/item/weapon/nullrod/godhand
	icon_state = "disintegrate"
	item_state = "disintegrate"
	name = "god hand"
	desc = "This hand of yours glows with an awesome power!"
	flags = ABSTRACT | NODROP
	w_class = 5
	hitsound = 'sound/weapons/sear.ogg'
	force = 20
	damtype = BURN
	attack_verb = list("punched", "cross countered", "pummeled")

/obj/item/weapon/nullrod/staff
	icon_state = "godstaff-red"
	item_state = "godstaff-red"
	name = "holy staff"
	desc = "It has a mysterious, protective aura."
	w_class = 5
	force = 5
	slot_flags = SLOT_BACK
	block_chance = 50


/obj/item/weapon/nullrod/staff/blue
	icon_state = "godstaff-blue"
	item_state = "godstaff-blue"

/obj/item/weapon/nullrod/claymore
	icon_state = "claymore"
	item_state = "claymore"
	name = "holy claymore"
	desc = "A weapon fit for a crusade!"
	w_class = 5
	force = 20
	slot_flags = SLOT_BACK|SLOT_BELT
	block_chance = 20
	sharpness = IS_SHARP
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/nullrod/darkblade
	icon_state = "cultblade"
	item_state = "cultblade"
	name = "dark blade"
	desc = "Spread the glory of the dark gods!"
	slot_flags = SLOT_BELT
	w_class = 5
	force = 20
	block_chance = 20
	sharpness = IS_SHARP
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/nullrod/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/nullrod/scythe
	icon_state = "scythe0"
	name = "reaper scythe"
	desc = "Ask not for whom the bell tolls..."
	force = 15
	w_class = 4
	armour_penetration = 100
	slot_flags = SLOT_BACK
	sharpness = IS_SHARP
	attack_verb = list("chopped", "sliced", "cut", "reaped")

/obj/item/weapon/nullrod/chainsaw
	name = "chainsaw hand"
	desc = "Good? Bad? You're the guy with the chainsaw hand."
	icon_state = "chainsaw_on"
	item_state = "mounted_chainsaw"
	w_class = 5
	flags = NODROP | ABSTRACT
	force = 20
	sharpness = IS_SHARP
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'

/obj/item/weapon/nullrod/clown
	icon = 'icons/obj/wizard.dmi'
	icon_state = "honkrender"
	item_state = "render"
	name = "clown dagger"
	desc = "Used for absolutely hilarious sacrafices."
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = IS_SHARP
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/nullrod/whip
	name = "holy whip"
	desc = "What a terrible night to be on Space Station 13."
	icon_state = "chain"
	item_state = "chain"
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed")

/obj/item/weapon/nullrod/fedora
	name = "athiest's fedora"
	desc = "The brim of the hat is as sharp as your wit. Throwing it at someone would hurt almost as much as disproving the existence of God."
	icon_state = "fedora"
	item_state = "fedora"
	slot_flags = SLOT_HEAD
	icon = 'icons/obj/clothing/hats.dmi'
	force = 0
	throw_speed = 4
	throw_range = 7
	throwforce = 20

/obj/item/weapon/nullrod/armblade
	name = "dark blessing"
	desc = "Particularly twisted dieties grant gifts of dubious value."
	icon_state = "arm_blade"
	item_state = "arm_blade"
	flags = ABSTRACT | NODROP
	w_class = 5.0
	force = 20
	sharpness = IS_SHARP

/obj/item/weapon/nullrod/carp
	name = "carp-sie plushie"
	desc = "An adorable stuffed toy that resembles the god of all carp. The teeth look pretty sharp."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	item_state = "carp_plushie"
	attack_verb = list("bitten", "eaten", "fin slapped")
	hitsound = 'sound/weapons/bite.ogg'



#undef NULLROD
#undef GODHAND
#undef REDSTAFF
#undef BLUESTAFF
#undef CLAYMORE
#undef DARKBLADE
#undef SORD
#undef SCYTHE
#undef CHAINSAW
#undef CLOWNDAGGER
#undef WHIP
#undef FEDORA
#undef ARMBLADE
#undef CARP