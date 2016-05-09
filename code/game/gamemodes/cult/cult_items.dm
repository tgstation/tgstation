/obj/item/weapon/melee/cultblade
	name = "eldritch longsword"
	desc = "A sword humming with unholy energy. It glows with a dim red light."
	icon_state = "cultblade"
	item_state = "cultblade"
	flags = CONDUCT
	sharpness = IS_SHARP
	w_class = 4
	force = 30
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")


/obj/item/weapon/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!iscultist(user))
		user.Weaken(5)
		user.unEquip(src, 1)
		user.visible_message("<span class='warning'>A powerful force shoves [user] away from [target]!</span>", \
							 "<span class='cultlarge'>\"You shouldn't play with sharp things. You'll poke someone's eye out.\"</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick("l_arm", "r_arm"))
		else
			user.adjustBruteLoss(rand(force/2,force))
		return
	..()

/obj/item/weapon/melee/cultblade/pickup(mob/living/user)
	..()
	if(!iscultist(user))
		user << "<span class='cultlarge'>\"I wouldn't advise that.\"</span>"
		user << "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>"
		user.Dizzy(120)

/obj/item/weapon/melee/cultblade/dagger
	name = "sacrificial dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = 2
	force = 15
	throwforce = 25
	embed_chance = 75

/obj/item/weapon/melee/cultblade/dagger/attack(mob/living/target, mob/living/carbon/human/user)
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.drip(50)


/obj/item/weapon/restraints/legcuffs/bola/cult
	name = "nar'sien bola"
	desc = "A strong bola, bound with dark magic. Throw it to trip and slow your victim."
	icon_state = "bola_cult"
	breakouttime = 45
	weaken = 1


/obj/item/clothing/head/culthood
	name = "ancient cultist hood"
	icon_state = "culthood"
	desc = "A torn, dust-caked hood. Strange letters line the inside."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5,energy = 5, bomb = 0, bio = 0, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT

/obj/item/clothing/suit/cultrobes
	name = "ancient cultist robes"
	desc = "A ragged, dusty set of robes. Strange letters line the inside."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT


/obj/item/clothing/head/culthood/alt
	name = "cultist hood"
	desc = "An armored hood worn by the followers of Nar-Sie."
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/suit/cultrobes/alt
	name = "cultist robes"
	desc = "An armored set of robes worn by the followers of Nar-Sie."
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"


/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES
	armor = list(melee = 30, bullet = 30, laser = 30,energy = 20, bomb = 0, bio = 0, rad = 0)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie"
	icon_state = "magusred"
	item_state = "magusred"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/head/helmet/space/cult
	name = "nar-sien hardened helmet"
	desc = "A heavily-armored helmet worn by warriors of the Nar-Sien cult. It can withstand hard vacuum."
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/cult
	name = "nar-sien hardened armor"
	icon_state = "cult_armor"
	item_state = "cult_armor"
	desc = "A heavily-armored exosuit worn by warriors of the Nar-Sien cult. It can withstand hard vacuum."
	w_class = 2
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/tank/internals/)
	armor = list(melee = 70, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/weapon/sharpener/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	used = 0
	increment = 5
	max = 40
	prefix = "darkened"

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist armor"
	desc = "Empowered garb which creates a powerful shield around the user."
	icon_state = "cult_armor"
	item_state = "cult_armor"
	w_class = 4
	armor = list(melee = 50, bullet = 40, laser = 50,energy = 30, bomb = 50, bio = 30, rad = 30)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	var/current_charges = 3
	var/shield_state = "shield-red"
	hooded = 1
	hoodtype = /obj/item/clothing/head/cult_hoodie
	
/obj/item/clothing/head/cult_hoodie
	name = "empowered cultist armor"
	desc = "Empowered garb which creates a powerful shield around the user."
	icon_state = "cult_hoodalt"
	armor = list(melee = 50, bullet = 40, laser = 50,energy = 30, bomb = 50, bio = 30, rad = 30)
	body_parts_covered = HEAD
	flags = NODROP
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	
/obj/item/clothing/suit/hooded/cultrobes/cult_shield/pickup(mob/living/user)
	..()
	if(!iscultist(user))
		user << "<span class='cultlarge'>\"I wouldn't advise that.\"</span>"
		user << "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>"
		user.unEquip(src, 1)
		user.Dizzy(30)
		user.Weaken(5)
		

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/hit_reaction(mob/living/carbon/human/owner, attack_text, isinhands)
	if(current_charges > 0)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(2, 1, src)
		s.start()
		owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!</span>")
		current_charges--
		if(current_charges <= 0)
			owner.visible_message("[owner]'s shield is destroyed!")
			shield_state = "broken"
			owner.update_inv_wear_suit()
		return 1
	return 0

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/worn_overlays(isinhands)
    . = list()
    if(!isinhands)
        . += image(icon = 'icons/effects/effects.dmi', icon_state = "[shield_state]")

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list(melee = -100, bullet = -100, laser = -100,energy = -100, bomb = -100, bio = -100, rad = -100)
	slowdown = -1
	hooded = 1
	hoodtype = /obj/item/clothing/head/berserkerhood
	
/obj/item/clothing/head/berserkerhood
	name = "flagellant's robes"
	desc = "Blood-soaked garb infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "culthood"
	body_parts_covered = HEAD
	flags = NODROP
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	armor = list(melee = -100, bullet = -100, laser = -100,energy = -100, bomb = -100, bio = -100, rad = -100)
	
/obj/item/clothing/suit/hooded/cultrobes/berserker/pickup(mob/living/user)
	..()
	if(!iscultist(user))
		user << "<span class='cultlarge'>\"I wouldn't advise that.\"</span>"
		user << "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>"
		user.unEquip(src, 1)
		user.Dizzy(30)
		user.Weaken(5)
   	    	
/obj/item/clothing/glasses/night/cultblind
	desc = "May nar-sie guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	item_state = "blindfold"
	darkness_view = 8
	flash_protect = 1
	
/obj/item/clothing/glasses/night/cultblind/pickup(mob/living/user)
	..()
	if(!iscultist(user))
		user << "<span class='cultlarge'>\"I wouldn't advise that.\"</span>"
		user << "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>"
		user.unEquip(src, 1)
		user.Dizzy(30)
		user.Weaken(5)

/obj/item/weapon/reagent_containers/food/drinks/bottle/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers; this water renews and reinvigorates the faithful of nar'sie."
	icon_state = "holyflask"
	color = "#333333"
	list_reagents = list("unholywater" = 40)

/obj/item/device/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the escape shuttle."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	color = "#ff0000"
	var/global/curselimit = 0
	
/obj/item/device/shuttle_curse/attack_self(mob/user)
	if(!iscultist(user))
		user.unEquip(src, 1)
		user.Weaken(5)
		user << "<span class='warning'>A powerful force shoves you away from [src]!</span>"
		return
	if(curselimit > 1)
		user << "<span class='notice'>We have exhausted our ability to curse the shuttle.</span>"
		return
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 1500
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		SSshuttle.emergency.setTimer(timer)
		user << "<span class='danger'>You shatter the orb! A dark essence spirals into the air, then disappears.</span>"
		playsound(user.loc, "sound/effects/Glassbr1.ogg", 50, 1)
		qdel(src)
		sleep(20)
		var/global/list/curses
		if(!curses)
			curses = list("A fuel technician just slit his own throat and begged for death. The shuttle will be delayed by two minutes.",
			"The shuttle's navigation programming was replaced by a file containing two words, IT COMES. The shuttle will be delayed by two minutes.",
			"The shuttle's custodian tore out his guts and began painting strange shapes on the floor. The shuttle will be delayed by two minutes.",
			"A shuttle engineer began screaming 'DEATH IS NOT THE END' and ripped out wires until an arc flash seared off her flesh. The shuttle will be delayed by two minutes.",
			"A shuttle inspector started laughing madly over the radio and then threw herself into an engine turbine. The shuttle will be delayed by two minutes.",
			"The shuttle dispatcher was found dead with bloody symbols carved into their flesh. The shuttle will be delayed by two minutes.")
		var/message = pick_n_take(curses)
		priority_announce("[message]", "System Failure", 'sound/misc/notice1.ogg')
		curselimit++
		
/obj/item/device/cult_shift
	name = "veil shifter"
	desc = "The veil between worlds is weak, this relic teleports you forward a small distance. It may be used twice before its power is lost."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shifter"
	var/uses = 2
	
/obj/item/device/cult_shift/proc/handle_teleport_grab(turf/T, mob/user)
	var/mob/living/carbon/human/H = user
	if(H.pulling && (istype(H.pulling, /mob/living)))
		var/mob/living/victim =	H.pulling
		if(!victim.anchored)
			victim.forceMove(locate(T.x+rand(-1,1),T.y+rand(-1,1),T.z))
	return

/obj/item/device/cult_shift/attack_self(mob/user)
	if(!iscultist(user))
		user.unEquip(src, 1)
		user.Weaken(5)
		user << "<span class='warning'>A powerful force shoves you away from [src]!</span>"
		return
	uses--
	if (uses<1)
		qdel(src)
	var/mob/living/carbon/human/H = user
	var/turf/destination = get_teleport_loc(H.loc,H,9,1,3,1,0,1)
	var/turf/mobloc = get_turf(H.loc)//Safety

	if(destination&&istype(mobloc, /turf))//So we don't teleport out of containers
		spawn(0)
			playsound(H.loc, "sparks", 50, 1)
			anim(mobloc,src,'icons/mob/mob.dmi',,"cultout",,H.dir)

		handle_teleport_grab(destination, H)
		H.loc = destination

		spawn(0)
			PoolOrNew(/obj/effect/particle_effect/sparks, H.loc)
			playsound(H.loc, 'sound/effects/phasein.ogg', 25, 1)
			playsound(H.loc, "sparks", 50, 1)
			anim(H.loc,H,'icons/mob/mob.dmi',,"cultin",,H.dir)
			
	else
		H << "<span class='danger'>The veil cannot be torn here!</span>"
