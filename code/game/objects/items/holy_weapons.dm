/obj/item/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of Nar-Sie's followers."
	icon_state = "nullrod"
	item_state = "nullrod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 18
	throw_speed = 3
	throw_range = 4
	throwforce = 10
	w_class = WEIGHT_CLASS_TINY
	var/reskinned = FALSE

/obj/item/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is killing [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to get closer to god!</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/nullrod/attack_self(mob/user)
	if(user.mind && (user.mind.isholy) && !reskinned)
		reskin_holy_weapon(user)

/obj/item/nullrod/proc/reskin_holy_weapon(mob/M)
	if(SSreligion.holy_weapon_type)
		return
	var/obj/item/nullrod/holy_weapon
	var/list/holy_weapons_list = typesof(/obj/item/nullrod)
	var/list/display_names = list()
	for(var/V in holy_weapons_list)
		var/atom/A = V
		display_names += initial(A.name)

	var/choice = input(M,"What theme would you like for your holy weapon?","Holy Weapon Theme") as null|anything in display_names
	if(QDELETED(src) || !choice || M.stat || !in_range(M, src) || M.restrained() || !M.canmove || reskinned)
		return

	var/index = display_names.Find(choice)
	var/A = holy_weapons_list[index]

	holy_weapon = new A

	SSreligion.holy_weapon_type = holy_weapon.type

	SSblackbox.set_details("chaplain_weapon","[choice]")

	if(holy_weapon)
		holy_weapon.reskinned = TRUE
		qdel(src)
		M.put_in_active_hand(holy_weapon)

/obj/item/nullrod/godhand
	icon_state = "disintegrate"
	item_state = "disintegrate"
	name = "god hand"
	desc = "This hand of yours glows with an awesome power!"
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	attack_verb = list("punched", "cross countered", "pummeled")

/obj/item/nullrod/staff
	icon_state = "godstaff-red"
	item_state = "godstaff-red"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	name = "red holy staff"
	desc = "It has a mysterious, protective aura."
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	slot_flags = SLOT_BACK
	block_chance = 50
	var/shield_icon = "shield-red"

/obj/item/nullrod/staff/worn_overlays(isinhands)
	. = list()
	if(isinhands)
		. += mutable_appearance('icons/effects/effects.dmi', shield_icon, MOB_LAYER + 0.01)

/obj/item/nullrod/staff/blue
	name = "blue holy staff"
	icon_state = "godstaff-blue"
	item_state = "godstaff-blue"
	shield_icon = "shield-old"

/obj/item/nullrod/claymore
	icon_state = "claymore"
	item_state = "claymore"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "holy claymore"
	desc = "A weapon fit for a crusade!"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = SLOT_BACK|SLOT_BELT
	block_chance = 30
	sharpness = IS_SHARP
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/nullrod/claymore/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/nullrod/claymore/darkblade
	icon_state = "cultblade"
	item_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	name = "dark blade"
	desc = "Spread the glory of the dark gods!"
	slot_flags = SLOT_BELT
	hitsound = 'sound/hallucinations/growl1.ogg'

/obj/item/nullrod/claymore/chainsaw_sword
	icon_state = "chainswordon"
	item_state = "chainswordon"
	name = "sacred chainsaw sword"
	desc = "Suffer not a heretic to live."
	slot_flags = SLOT_BELT
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'

/obj/item/nullrod/claymore/glowing
	icon_state = "swordon"
	item_state = "swordon"
	name = "force weapon"
	desc = "The blade glows with the power of faith. Or possibly a battery."
	slot_flags = SLOT_BELT

/obj/item/nullrod/claymore/katana
	name = "hanzo steel"
	desc = "Capable of cutting clean through a holy claymore."
	icon_state = "katana"
	item_state = "katana"
	slot_flags = SLOT_BELT | SLOT_BACK

/obj/item/nullrod/claymore/multiverse
	name = "extradimensional blade"
	desc = "Once the harbinger of an interdimensional war, its sharpness fluctuates wildly."
	icon_state = "multiverse"
	item_state = "multiverse"
	slot_flags = SLOT_BELT

/obj/item/nullrod/claymore/multiverse/attack(mob/living/carbon/M, mob/living/carbon/user)
	force = rand(1, 30)
	..()

/obj/item/nullrod/claymore/saber
	name = "light energy sword"
	hitsound = 'sound/weapons/blade1.ogg'
	icon_state = "swordblue"
	item_state = "swordblue"
	desc = "If you strike me down, I shall become more robust than you can possibly imagine."
	slot_flags = SLOT_BELT

/obj/item/nullrod/claymore/saber/red
	name = "dark energy sword"
	icon_state = "swordred"
	item_state = "swordred"
	desc = "Woefully ineffective when used on steep terrain."

/obj/item/nullrod/claymore/saber/pirate
	name = "nautical energy sword"
	icon_state = "cutlass1"
	item_state = "cutlass1"
	desc = "Convincing HR that your religion involved piracy was no mean feat."

/obj/item/nullrod/sord
	name = "\improper UNREAL SORD"
	desc = "This thing is so unspeakably HOLY you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = SLOT_BELT
	force = 4.13
	throwforce = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/nullrod/scythe
	icon_state = "scythe1"
	item_state = "scythe1"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "reaper scythe"
	desc = "Ask not for whom the bell tolls..."
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 35
	slot_flags = SLOT_BACK
	sharpness = IS_SHARP
	attack_verb = list("chopped", "sliced", "cut", "reaped")

/obj/item/nullrod/scythe/vibro
	icon_state = "hfrequency0"
	item_state = "hfrequency1"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "high frequency blade"
	desc = "Bad references are the DNA of the soul."
	attack_verb = list("chopped", "sliced", "cut", "zandatsu'd")
	hitsound = 'sound/weapons/rapierhit.ogg'


/obj/item/nullrod/scythe/spellblade
	icon_state = "spellblade"
	item_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon = 'icons/obj/guns/magic.dmi'
	name = "dormant spellblade"
	desc = "The blade grants the wielder nearly limitless power...if they can figure out how to turn it on, that is."
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/nullrod/scythe/talking
	icon_state = "talking_sword"
	item_state = "talking_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "possessed blade"
	desc = "When the station falls into chaos, it's nice to have a friend by your side."
	attack_verb = list("chopped", "sliced", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	var/possessed = FALSE

/obj/item/nullrod/scythe/talking/attack_self(mob/living/user)
	if(possessed)
		return

	to_chat(user, "You attempt to wake the spirit of the blade...")

	possessed = TRUE

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the spirit of [user.real_name]'s blade?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE)
	var/mob/dead/observer/theghost = null

	if(LAZYLEN(candidates))
		theghost = pick(candidates)
		var/mob/living/simple_animal/shade/S = new(src)
		S.real_name = name
		S.name = name
		S.ckey = theghost.ckey
		S.status_flags |= GODMODE
		var/input = stripped_input(S,"What are you named?", ,"", MAX_NAME_LEN)

		if(src && input)
			name = input
			S.real_name = input
			S.name = input
	else
		to_chat(user, "The blade is dormant. Maybe you can try again later.")
		possessed = FALSE

/obj/item/nullrod/scythe/talking/Destroy()
	for(var/mob/living/simple_animal/shade/S in contents)
		to_chat(S, "You were destroyed!")
		qdel(S)
	return ..()

/obj/item/nullrod/hammmer
	icon_state = "hammeron"
	item_state = "hammeron"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	name = "relic war hammer"
	desc = "This war hammer cost the chaplain forty thousand space dollars."
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("smashed", "bashed", "hammered", "crunched")

/obj/item/nullrod/chainsaw
	name = "chainsaw hand"
	desc = "Good? Bad? You're the guy with the chainsaw hand."
	icon_state = "chainsaw_on"
	item_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	flags_1 = NODROP_1 | ABSTRACT_1
	sharpness = IS_SHARP
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'

/obj/item/nullrod/clown
	icon = 'icons/obj/wizard.dmi'
	icon_state = "clownrender"
	item_state = "render"
	name = "clown dagger"
	desc = "Used for absolutely hilarious sacrifices."
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = IS_SHARP
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/nullrod/whip
	name = "holy whip"
	desc = "What a terrible night to be on Space Station 13."
	icon_state = "chain"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed")
	hitsound = 'sound/weapons/chainhit.ogg'

/obj/item/nullrod/fedora
	name = "atheist's fedora"
	desc = "The brim of the hat is as sharp as your wit. The edge would hurt almost as much as disproving the existence of God."
	icon_state = "fedora"
	item_state = "fedora"
	slot_flags = SLOT_HEAD
	icon = 'icons/obj/clothing/hats.dmi'
	force = 0
	throw_speed = 4
	throw_range = 7
	throwforce = 30
	sharpness = IS_SHARP
	attack_verb = list("enlightened", "redpilled")

/obj/item/nullrod/armblade
	name = "dark blessing"
	desc = "Particularly twisted dieties grant gifts of dubious value."
	icon_state = "arm_blade"
	item_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	flags_1 = ABSTRACT_1 | NODROP_1
	w_class = WEIGHT_CLASS_HUGE
	sharpness = IS_SHARP

/obj/item/nullrod/armblade/tentacle
	name = "unholy blessing"
	icon_state = "tentacle"
	item_state = "tentacle"

/obj/item/nullrod/carp
	name = "carp-sie plushie"
	desc = "An adorable stuffed toy that resembles the god of all carp. The teeth look pretty sharp. Activate it to receive the blessing of Carp-Sie."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	item_state = "carp_plushie"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 15
	attack_verb = list("bitten", "eaten", "fin slapped")
	hitsound = 'sound/weapons/bite.ogg'
	var/used_blessing = FALSE

/obj/item/nullrod/carp/attack_self(mob/living/user)
	if(used_blessing)
	else if(user.mind && (user.mind.isholy))
		to_chat(user, "You are blessed by Carp-Sie. Wild space carp will no longer attack you.")
		user.faction |= "carp"
		used_blessing = TRUE

/obj/item/nullrod/claymore/bostaff //May as well make it a "claymore" and inherit the blocking
	name = "monk's staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts, it is now used to harass the clown."
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	block_chance = 40
	slot_flags = SLOT_BACK
	sharpness = IS_BLUNT
	hitsound = "swing_hit"
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bostaff0"
	item_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'

/obj/item/nullrod/tribal_knife
	icon_state = "crysknife"
	item_state = "crysknife"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "arrhythmic knife"
	w_class = WEIGHT_CLASS_HUGE
	desc = "They say fear is the true mind killer, but stabbing them in the head works too. Honour compels you to not sheathe it once drawn."
	sharpness = IS_SHARP
	slot_flags = null
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	flags_2 = SLOWS_WHILE_IN_HAND_2

/obj/item/nullrod/tribal_knife/Initialize(mapload)
	..()

/obj/item/nullrod/tribal_knife/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/nullrod/tribal_knife/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/nullrod/tribal_knife/process()
	slowdown = rand(-2, 2)


/obj/item/nullrod/pitchfork
	icon_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "unholy pitchfork"
	w_class = WEIGHT_CLASS_NORMAL
	desc = "Holding this makes you look absolutely devilish."
	attack_verb = list("poked", "impaled", "pierced", "jabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP
