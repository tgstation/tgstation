/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of Nar-Sie's followers."
	icon_state = "nullrod"
	item_state = "nullrod"
	force = 18
	throw_speed = 3
	throw_range = 4
	throwforce = 10
	w_class = 1
	var/reskinned = FALSE

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is killing \himself with \the [src.name]! It looks like \he's trying get closer to god!</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/attack_self(mob/user)
	if(reskinned)
		return
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		reskin_holy_weapon(user)

/obj/item/weapon/nullrod/proc/reskin_holy_weapon(mob/M)
	var/list/holy_weapons_list = typesof(/obj/item/weapon/nullrod)
	var/list/display_names = list()
	for(var/V in holy_weapons_list)
		var/atom/A = V
		display_names += initial(A.name)

	var/choice = input(M,"What theme would you like for your holy weapon?","Holy Weapon Theme") as null|anything in display_names
	if(!src || !choice || M.stat || !in_range(M, src) || M.restrained() || !M.canmove || reskinned)
		return

	var/index = display_names.Find(choice)
	var/A = holy_weapons_list[index]

	var/obj/item/weapon/nullrod/holy_weapon = new A

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
	damtype = BURN
	attack_verb = list("punched", "cross countered", "pummeled")

/obj/item/weapon/nullrod/staff
	icon_state = "godstaff-red"
	item_state = "godstaff-red"
	name = "red holy staff"
	desc = "It has a mysterious, protective aura."
	w_class = 5
	force = 5
	slot_flags = SLOT_BACK
	block_chance = 50
	var/shield_icon = "shield-red"

/obj/item/weapon/nullrod/staff/worn_overlays(isinhands)
    . = list()
    if(isinhands)
        . += image(icon = 'icons/effects/effects.dmi', icon_state = "[shield_icon]")

/obj/item/weapon/nullrod/staff/blue
	name = "blue holy staff"
	icon_state = "godstaff-blue"
	item_state = "godstaff-blue"
	shield_icon = "shield-old"

/obj/item/weapon/nullrod/claymore
	icon_state = "claymore"
	item_state = "claymore"
	name = "holy claymore"
	desc = "A weapon fit for a crusade!"
	w_class = 5
	slot_flags = SLOT_BACK|SLOT_BELT
	block_chance = 30
	sharpness = IS_SHARP
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


/obj/item/weapon/nullrod/claymore/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()


/obj/item/weapon/nullrod/claymore/darkblade
	icon_state = "cultblade"
	item_state = "cultblade"
	name = "dark blade"
	desc = "Spread the glory of the dark gods!"
	slot_flags = SLOT_BELT
	hitsound = 'sound/hallucinations/growl1.ogg'

/obj/item/weapon/nullrod/sord
	name = "\improper UNREAL SORD"
	desc = "This thing is so unspeakably HOLY you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/nullrod/scythe
	icon_state = "scythe0"
	name = "reaper scythe"
	desc = "Ask not for whom the bell tolls..."
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

/obj/item/weapon/nullrod/whip/afterattack(atom/movable/AM, mob/user, proximity)
	if(!proximity)
		return
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(is_shadow(H))
			var/phrase = pick("Die monster! You don't belong in this world!!!", "You steal men's souls and make them your slaves!!!", "Your words are as empty as your soul!!!", "Mankind ill needs a savior such as you!!!")
			user.say("[phrase]")
			H.adjustBruteLoss(8) //Bonus damage

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
	w_class = 5
	sharpness = IS_SHARP

/obj/item/weapon/nullrod/carp
	name = "carp-sie plushie"
	desc = "An adorable stuffed toy that resembles the god of all carp. The teeth look pretty sharp. Activate it to recieve the blessing of Carp-Sie."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	item_state = "carp_plushie"
	force = 15
	attack_verb = list("bitten", "eaten", "fin slapped")
	hitsound = 'sound/weapons/bite.ogg'
	var/used_blessing = FALSE


/obj/item/weapon/nullrod/carp/attack_self(mob/living/user)
	if(used_blessing)
		return
	if(user.mind && (user.mind.assigned_role != "Chaplain"))
		return
	user << "You are blessed by Carp-Sie. Wild space carp will no longer attack you."
	user.faction |= "carp"
	used_blessing = TRUE