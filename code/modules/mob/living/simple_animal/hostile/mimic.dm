//
// Abstract Class
//

/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	icon_living = "crate"

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/mimic
	holder_type = null //Can't pick up

	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"
	speed = -1
	maxHealth = 250
	health = 250

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "attacks"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "mimic"
	move_to_delay = 8

	var/atom/copied_object = /obj/structure/closet/crate
	var/angry = 0

/mob/living/simple_animal/hostile/mimic/New()
	.=..()
	apply_disguise()

/mob/living/simple_animal/hostile/mimic/Die()
	..()
	visible_message("<span class='warning'><b>[src]</b> stops moving!</span>")
	qdel(src)

/mob/living/simple_animal/hostile/mimic/show_inv() //Makes it harder to distinguish mimics from real dudes
	return

/mob/living/simple_animal/hostile/mimic/proc/environment_disguise(list/L = crate_mimic_disguises)
	if(!L) return
	//First, determine the environment we're in

	var/our_area_type = "default"

	var/area/A = get_area(src)
	if(A.fire)
		our_area_type = "emergency"
	else
		if(isspace(A))
			our_area_type = "space"
		else if(istype(A,/area/engine) || istype(A,/area/engineering) || istype(A,/area/construction))
			our_area_type = "engineering"
		else if(istype(A,/area/medical/medbay))
			our_area_type = "medbay"
		else if(istype(A,/area/crew_quarters/bar))
			our_area_type = "bar"
		else if(istype(A,/area/security))
			our_area_type = "security"
		else if(istype(A,/area/chapel))
			our_area_type = "chapel"
		else if(istype(A,/area/library))
			our_area_type = "library"
		else if(istype(A,/area/hydroponics))
			our_area_type = "botany"
		else if(istype(A,/area/crew_quarters/kitchen))
			our_area_type = "kitchen"
		else if(istype(A,/area/storage/nuke_storage))
			our_area_type = "vault"

	if(health < (0.75*maxHealth)) //Health below 3/4
		if(L["lowhealth"]) //If we have a special set of disguises for low health
			our_area_type = "lowhealth" //Then use it!

	//Found our area type - time to get a disguise!

	var/list/possible_disguises = L[our_area_type]

	if(!possible_disguises || !possible_disguises.len) //If can't find a disguise for that type of area
		possible_disguises = L["default"] //Use default disguise
		if(!possible_disguises || !possible_disguises.len) //No default disguise - abort
			return

	copied_object = pick(possible_disguises) //We did it!
	if(!initial(copied_object.icon_state) || !initial(copied_object.icon)) //No icon!
		copied_object = initial(copied_object) //Revert to default

/mob/living/simple_animal/hostile/mimic/proc/apply_disguise()
	if(ispath(copied_object))
		appearance = initial(copied_object.appearance)
//
// Crate mimic
//
// Sits still until somebody tries to open it!

var/global/list/crate_mimic_disguises = list(\
	"default" = list(/obj/structure/closet/crate),
	"space"   = list(/obj/structure/closet/emcloset),
	"medbay"  = list(/obj/structure/closet/crate, /obj/structure/closet/crate/medical, /obj/structure/closet/crate/freezer),
	"engineering" = list(/obj/structure/closet/crate, /obj/structure/closet/crate/engi, /obj/structure/closet/crate/secure/engisec, /obj/structure/closet/crate/radiation),
	"bar" = list(/obj/structure/closet/crate, /obj/structure/closet/cabinet, /obj/structure/closet/crate/freezer),
	"emergency" = list(/obj/structure/closet/emcloset),
)

/mob/living/simple_animal/hostile/mimic/crate
	a_intent = I_HURT //To prevent dudes from swapping positions with us

	maxHealth = 100
	health = 100

/mob/living/simple_animal/hostile/mimic/crate/New(loc, atom/new_disguise = null)
	if(ispath(new_disguise))
		copied_object = new_disguise
	else if(istype(new_disguise))
		copied_object = new_disguise.type
	else
		environment_disguise()

	..()

	drop_meat(src) //Fill the mimic up with its own meat
	initialize() //Collect all items from its turf!

/mob/living/simple_animal/hostile/mimic/crate/Life()
	if(!angry)
		if(health < maxHealth)
			health = min(health + 2, maxHealth) //Regenerate 2 health per tick
			if(health == maxHealth) //Normally when mimics go to sleep with wounds, they take on a less noticeable disguise (like a cigarette butt). If we fully heal while in sleep, it's time to change our disguise to something more noticeable!

				var/found_alive_mob = 0

				for(var/mob/living/L in view(7,src))
					if(L == src) continue
					if(L.stat) continue //Dead bodies don't bother us

					found_alive_mob = 1
					break

				if(!found_alive_mob)
					environment_disguise() //Disguise ourselves
					apply_disguise()

		if(pulledby && prob(25))
			anger()
		else
			return

	.=..()

/mob/living/simple_animal/hostile/mimic/crate/Destroy()
	..()

	Die()

/mob/living/simple_animal/hostile/mimic/crate/initialize()
	..()
	//Put all loot inside us!
	for(var/obj/item/I in loc)
		if(I.anchored || I.density) continue

		I.forceMove(src)

/mob/living/simple_animal/hostile/mimic/crate/Die()
	if(copied_object)
		var/obj/structure/C = new copied_object(get_turf(src))
		//Drop all loot!
		for(var/atom/movable/AM in src)
			AM.loc = C
	..()

/mob/living/simple_animal/hostile/mimic/crate/attackby(obj/W, mob/user)
	if(angry) //If we're angry - proceed as normal
		return ..()
	else
		return attack_hand(user) //If we're hidden - attempt to open (same as a normal crate)

/mob/living/simple_animal/hostile/mimic/crate/attack_hand(mob/user)
	if(angry)
		return ..()

	to_chat(user, "<span class='notice'>It won't budge.</span>")

	spawn(rand(1,20))
		visible_message("<span class='warning'>\The [src] starts moving!</span>")
		anger()

/mob/living/simple_animal/hostile/mimic/crate/LoseTarget()
	..()
	calm_down()

/mob/living/simple_animal/hostile/mimic/crate/LostTarget()
	..()
	calm_down()

/mob/living/simple_animal/hostile/mimic/crate/proc/anger(berserk = 0, change_icon = 1)
	angry = 1
	if(change_icon)
		if(ispath(copied_object, /obj/structure/closet))
			var/obj/structure/closet/C = copied_object
			icon_state = initial(C.icon_opened)

	if(berserk)
		angry = 2 //Can't calm down
		melee_damage_lower = initial(melee_damage_lower) + 4
		melee_damage_upper = initial(melee_damage_upper) + 4 //Increase damage
		move_to_delay = 0 //Remove delay for automated movement
		name = "[initial(name)] mimic"

/mob/living/simple_animal/hostile/mimic/crate/proc/calm_down(change_icon = 1)
	if(angry > 1) return //If angry is 2, can't calm down!

	angry = 0
	if(change_icon)
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/hitby() //This is called when the mimic is hit by a thrown object
	..()

	if(!angry)
		anger(berserk = 1) //Go berserk because some asshole tried to snipe us
		visible_message("<span class='danger'>\The [src] roars in rage!</span>")

/mob/living/simple_animal/hostile/mimic/crate/bullet_act(obj/item/projectile/P, def_zone)
	..()

	if(P.damage > 0) //The projectile isn't a dummy
		if(!angry)
			anger(berserk = 1)
			visible_message("<span class='danger'>\The [src] roars in rage!</span>")
			playsound(get_turf(src), 'sound/hallucinations/growl1.ogg', 50, 1)

// Chest mimic - more robust than crate mimic
// Does more damage, has a robust tongue that it uses to grab things
// When attacking, it GRABS a dude and eats him

/mob/living/simple_animal/hostile/mimic/crate/chest
	name = "chest"
	copied_object = /obj/structure/closet/crate/chest

	melee_damage_lower = 12
	melee_damage_upper = 16

	maxHealth = 140
	health = 140

	stat_attack = 1 //Attack unconscious dudes

	icon_state = "chest"

	maxbodytemp = AUTOIGNITION_WOOD //The chest is wooden

	var/can_grab = 1

/mob/living/simple_animal/hostile/mimic/crate/chest/Die()
	for(var/atom/A in locked_atoms)
		unlock_atom(A)
		visible_message("<span class='notice'>\The [src] lets go of \the [A]!</span>")
	..()

/mob/living/simple_animal/hostile/mimic/crate/chest/AttackingTarget()
	..()
	if(can_grab && istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(!locked_atoms.len) //Eating nobody
			if(prob(60))
				lock_atom(H)
				visible_message("<span class='danger'>\The [src] grabs \the [H] with its tongue!")
		else
			if(H in locked_atoms)
				if(prob(20))
					to_chat(H, "<span class='danger'>You feel very weak!</span>")
					H.Weaken(3)

/mob/living/simple_animal/hostile/mimic/crate/chest/LoseTarget()
	if(target in locked_atoms)
		unlock_atom(target)

	var/mob/living/L = target
	if(istype(L) && Adjacent(L)) //If we're near our ex-target!
		if(L.stat == DEAD) //The target is dead (which what caused us to lose it in the first place)
			L.forceMove(src)
			visible_message("<span class='danger'>\The [src] eats \the [L]'s corpse!</span>")

	return ..()

/mob/living/simple_animal/hostile/mimic/crate/chest/relaymove(mob/user)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		return

	if(user.loc == src) //We're inside the chest
		to_chat(user, "<span class='info'>You try to escape from \the [src]. This will take a while!</span>")
		if(do_after(user, src, 300)) //30 seconds
			to_chat(user, "<span class='info'>You successfully escape from \the [src].</span>")
			user.forceMove(get_turf(src))
	else //We're being held by the mimic
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if((M_HULK in H.mutations) || (M_STRONG in H.mutations)) //Finally a use for M_STRONG
				unlock_atom(H)
				visible_message("<span class='notice'>[H] easily breaks free of \the [src]'s hold!</span>")
				return

/mob/living/simple_animal/hostile/mimic/crate/chest/attackby(obj/item/W, mob/user)
	if(angry)
		if(locked_atoms.len)
			if(W.is_sharp())
				user.visible_message("<span class='danger'>[user] slashes at \the [src]'s tongue!</span>")

				for(var/atom/M in locked_atoms)
					unlock_atom(M)
					visible_message("<span class='notice'>\The [src] loses its hold on [M].</span>")

				if(can_grab && (W.is_sharp() >= 1.2) && prob(20)) //Required sharpness same as the normal kitchen knife's
					visible_message("<span class='notice'>\The [src]'s tongue has been damaged!</span>")
					can_grab = 0
	..()

/mob/living/simple_animal/hostile/mimic/crate/chest/environment_disguise(list/L) //We're always chests
	return 0

/mob/living/simple_animal/hostile/mimic/crate/chest/anger(berserk, change_icon = 1)
	..()

	icon_state = "chestmimic"

//
// Item mimic
//
// Lies still until somebody tries to pick it up

var/global/list/item_mimic_disguises = list(
	"default" = list(/obj/item/alien_embryo, /obj/item/ammo_storage, /obj/item/device/chameleon, /obj/item/toy/crossbow, /obj/item/toy/waterflower, /obj/item/weapon/banhammer/admin,\
				/obj/item/weapon/beach_ball, /obj/item/weapon/card/emag, /obj/item/weapon/extinguisher, /obj/item/weapon/hand_labeler, /obj/item/weapon/soap, /obj/item/weapon/crowbar,\
				/obj/item/weapon/caution, /obj/item/weapon/bananapeel, /obj/item/device/chameleon, /obj/item/weapon/storage/pneumatic, /obj/item/trash/discountchocolate,\
				/obj/item/weapon/fireaxe, /obj/item/weapon/gun/gatling, /obj/item/weapon/table_parts, /obj/item/weapon/wrench/socket, /obj/item/weapon/lighter, /obj/item/weapon/bikehorn/rubberducky,\
				/obj/item/weapon/lipstick, /obj/item/weapon/stamp/clown, /obj/item/weapon/storage/backpack/holding, /obj/item/clothing/gloves/yellow,\
				/obj/item/device/aicard, /obj/item/device/analyzer, /obj/item/device/assembly/igniter, /obj/item/device/camera, /obj/item/device/codebreaker, /obj/item/device/device_analyser,\
				/obj/item/device/flash, /obj/item/device/flashlight, /obj/item/device/hailer, /obj/item/device/material_synth, /obj/item/device/megaphone, /obj/item/device/paicard,\
				/obj/item/device/pda/clown, /obj/item/device/rcd/matter/engineering, /obj/item/device/radio, /obj/item/device/robotanalyzer, /obj/item/device/soulstone,\
				/obj/item/device/soundsynth, /obj/item/device/violin, /obj/item/device/wormhole_jaunter, /obj/item/weapon/gun/portalgun, /obj/item/target), //Common items

	"medbay" = list(/obj/item/weapon/circular_saw, /obj/item/weapon/melee/defibrillator, /obj/item/weapon/surgicaldrill, /obj/item/weapon/hemostat, /obj/item/weapon/dnainjector/nofail/hulkmut,\
				/obj/item/weapon/bonesetter, /obj/item/weapon/autopsy_scanner, /obj/item/weapon/FixOVein, /obj/item/stack/medical/ointment, /obj/item/weapon/storage/firstaid,\
				/obj/item/weapon/gun/syringe/rapidsyringe, /obj/item/weapon/storage/firstaid/fire, /obj/item/weapon/storage/firstaid/o2, /obj/item/weapon/storage/firstaid/toxin,\
				/obj/item/weapon/cautery, /obj/item/device/healthanalyzer, /obj/item/pizzabox/margherita, /obj/item/toy/balloon, /obj/item/weapon/coin/clown,\
				/obj/item/weapon/dice/d4, /obj/item/weapon/dice/d12, /obj/item/weapon/dice/d20, /obj/item/weapon/gun/gravitywell, /obj/item/weapon/harpoon), //Medbay and some common items

	"security" = list(/obj/item/device/chameleon, /obj/item/weapon/card/emag, /obj/item/weapon/gun/energy/taser, /obj/item/weapon/melee/baton, /obj/item/weapon/tome,\
				/obj/item/weapon/crowbar, /obj/item/weapon/storage/fancy/donut_box, /obj/item/weapon/storage/firstaid, /obj/item/weapon/storage/pneumatic, /obj/item/weapon/gun/gatling,\
				/obj/item/weapon/handcuffs, /obj/item/weapon/melee/energy/sword/green, /obj/item/clothing/gloves/yellow, /obj/item/weapon/gun/osipr, /obj/item/weapon/gun/energy/staff/animate,\
				/obj/item/weapon/gun/energy/mindflayer, /obj/item/weapon/gun/energy/lasercannon, /obj/item/weapon/gun/energy/pulse_rifle, /obj/item/weapon/katana/hfrequency,\
				/obj/item/weapon/melee/cultblade, /obj/item/weapon/pickaxe/jackhammer, /obj/item/weapon/tank/plasma, /obj/item/weapon/gibtonite), //Security items and weapons

	"bar" = (typesof(/obj/item/weapon/reagent_containers/food/drinks) - typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable) - /obj/item/weapon/reagent_containers/food/drinks/bottle - /obj/item/weapon/reagent_containers/food/drinks/soda_cans),  //All drinks (except for abstract types)

	"emergency" = list(/obj/item/clothing/mask/breath, /obj/item/weapon/tank/jetpack/oxygen, /obj/item/weapon/tank/emergency_oxygen, /obj/item/weapon/tank/air, /obj/item/weapon/crowbar,\
					/obj/item/weapon/storage/firstaid, /obj/item/weapon/storage/backpack/holding, /obj/item/weapon/storage/backpack/security, /obj/item/device/maracas, /obj/item/device/multitool,\
					/obj/item/clothing/gloves/yellow, /obj/item/weapon/hand_tele, /obj/item/weapon/card/id/captains_spare, /obj/item/weapon/card/emag, /obj/item/weapon/extinguisher, /obj/item/weapon/gun/portalgun), //Focus on breath masks, jetpacks/oxygen tanks and generally useful stuff

	"lowhealth" = list(/obj/item/weapon/cigbutt, /obj/item/weapon/shard, /obj/item/toy/blink, /obj/item/toy/ammo/crossbow, /obj/item/ammo_casing/a666), //Small, hard-to-notice items to turn into when at low health

	//All foods EXCEPT for those with no icons (plenty of them)
	"kitchen" = (typesof(/obj/item/weapon/reagent_containers/food/snacks) - /obj/item/weapon/reagent_containers/food/snacks - typesof(/obj/item/weapon/reagent_containers/food/snacks/chip) - typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable) - typesof(/obj/item/weapon/reagent_containers/food/snacks/sliceable) - /obj/item/weapon/reagent_containers/food/snacks/slimesoup - typesof(/obj/item/weapon/reagent_containers/food/snacks/sweet)),

	"library" = typesof(/obj/item/weapon/book), //All default books

	"botany" = (typesof(/obj/item/weapon/reagent_containers/food/snacks/grown) - /obj/item/weapon/reagent_containers/food/snacks/grown), //All grown items

	//Nuke, nuke disk, all coins, all minerals (except for those with no icons)
	"vault" = list(/obj/machinery/nuclearbomb, /obj/item/weapon/disk/nuclear) + typesof(/obj/item/weapon/coin) + typesof(/obj/item/stack/sheet/mineral) - /obj/item/stack/sheet/mineral - /obj/item/stack/sheet/mineral/enruranium,

	"chapel" = list(/obj/item/weapon/storage/bible, /obj/item/clothing/head/chaplain_hood, /obj/item/clothing/head/helmet/space/plasmaman/chaplain, /obj/item/clothing/suit/chaplain_hoodie, /obj/item/clothing/suit/space/plasmaman/chaplain,\
				/obj/item/device/pda/chaplain, /obj/item/weapon/nullrod, /obj/item/weapon/reagent_containers/food/drinks/bottle/holywater, /obj/item/weapon/staff), //Chaplain garb, null rod, bible, holy water
)

/mob/living/simple_animal/hostile/mimic/crate/item
	name = "item mimic"
	density = 0

	move_to_delay = 2 //Faster than crate mimics
	maxHealth = 60
	health = 60 //Slightly less robust

	copied_object = /obj/item/target //Default form for us if we accidentally morph into an item with no icon. Gets overridden on New()

	var/icon/mouth_overlay = icon('icons/mob/mob.dmi', icon_state = "mimic_mouth")

/mob/living/simple_animal/hostile/mimic/crate/item/initialize()
	return //Don't take any items!

/mob/living/simple_animal/hostile/mimic/crate/item/examine(mob/user) //Total override to make the mimics look EXACTLY like items!
	var/s_size
	switch(src.size)
		if(1.0)
			s_size = "tiny"
		if(2.0)
			s_size = "small"
		if(3.0)
			s_size = "normal-sized"
		if(4.0)
			s_size = "bulky"
		if(5.0)
			s_size = "huge"
		else
	//if ((M_CLUMSY in usr.mutations) && prob(50)) t = "funny-looking"
	var/pronoun
	if (src.gender == PLURAL)
		pronoun = "They are"
	else
		pronoun = "It is"

	to_chat(user, "\icon[src] That's \a [src]. [pronoun] a [s_size] item.")
	if(desc)
		to_chat(user, desc)

/mob/living/simple_animal/hostile/mimic/crate/item/Die()
	copied_object = meat_type //Without this line, mimics would spawn items they're disguised as. Since they're relatively weak and can appear as gatling guns, this is required!
	..()

/mob/living/simple_animal/hostile/mimic/crate/item/attack_hand(mob/user)
	if(angry)
		return ..()

	user.simple_message("<span class='warning'>Oh no! \The [src] is actually a mimic!</span>",\
		"<span class='info'>\The [src] starts moving. Wow.</span>") //Second line is for hallucinating dudes
	anger()

/mob/living/simple_animal/hostile/mimic/crate/item/anger(berserk)
	..(berserk, change_icon = 0) //Don't change icon state
	overlays += mouth_overlay
	visible_message("<span class='danger'>\The [src] comes to life!</span>")
	name = "[initial(copied_object.name)] mimic"
	density = 1

/mob/living/simple_animal/hostile/mimic/crate/item/calm_down()
	..(change_icon = 0)
	overlays -= mouth_overlay
	visible_message("<span class='notice'>\The [src] falls to the ground, lifeless.</span>")
	density = 0

	//Disguise as something else for bonus stealth points
	environment_disguise()
	if(copied_object)
		appearance = initial(copied_object.appearance)

		if(ispath(copied_object, /obj/item))
			var/obj/item/I = copied_object
			size = initial(I.w_class)
		else
			size = SIZE_NORMAL

/mob/living/simple_animal/hostile/mimic/crate/item/environment_disguise(list/L = item_mimic_disguises)
	..(item_mimic_disguises)

	if(ispath(copied_object, /obj/item))
		var/obj/item/I = copied_object
		size = initial(I.w_class)
	else
		size = SIZE_NORMAL

//
// Copy Mimic
//

var/global/list/protected_objects = list(
	/obj/structure/table,
	/obj/structure/cable,
	/obj/structure/window,
	/obj/structure/particle_accelerator // /vg/ Redmine #116
)

/mob/living/simple_animal/hostile/mimic/copy

	health = 100
	maxHealth = 100

	copied_object = null
	var/mob/living/creator = null // the creator
	var/destroy_objects = 0
	var/knockdown_people = 0
	var/time_to_die=0 // The world.time after which we expire. (0 = no time limit)

/mob/living/simple_animal/hostile/mimic/copy/New(loc, var/obj/copy, var/mob/living/creator, var/destroy_original = 0, var/duration=0)
	..(loc)
	CopyObject(copy, creator, destroy_original)
	if(duration)
		time_to_die=world.time+duration

/mob/living/simple_animal/hostile/mimic/copy/Life()
	if(timestopped) return 0 //under effects of time magick
	..()

	spawn()
		var/amplitude = 2
		var/pixel_x_diff = rand(-amplitude, amplitude)
		var/pixel_y_diff = rand(-amplitude, amplitude)
		animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
		animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)
		pixel_x_diff = rand(-amplitude, amplitude)
		pixel_y_diff = rand(-amplitude, amplitude)
		animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
		animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)
		pixel_x_diff = rand(-amplitude, amplitude)
		pixel_y_diff = rand(-amplitude, amplitude)
		animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
		animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)

	// Die after a specified time limit
	if(time_to_die && world.time >= time_to_die)
		Die()
		return
	for(var/mob/living/M in contents) //a fix for animated statues from the flesh to stone spell
		Die()
		return

/mob/living/simple_animal/hostile/mimic/copy/Die()

	for(var/atom/movable/M in src)
		M.loc = get_turf(src)
	..()

/mob/living/simple_animal/hostile/mimic/copy/ListTargets()
	// Return a list of targets that isn't the creator
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/mimic/copy/proc/ChangeOwner(var/mob/owner)
	if(owner != creator)
		LoseTarget()
		creator = owner
		faction = "\ref[owner]"

/mob/living/simple_animal/hostile/mimic/copy/proc/CheckObject(var/obj/O)
	if((istype(O, /obj/item) || istype(O, /obj/structure)) && !is_type_in_list(O, protected_objects))
		return 1
	return 0

/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject(var/obj/O, var/mob/living/creator, var/destroy_original = 0)


	if(destroy_original || CheckObject(O))

		O.loc = src

		src.appearance = O.appearance
		src.icon_living = src.icon_state
		var/icon/redimage = icon(icon,icon_state)
		redimage.MapColors(rgb(255,0,0), rgb(255,0,0), rgb(255,0,0))
		var/icon/redimage_south = redimage
		var/icon/redimage_east = redimage
		redimage_south.Shift(SOUTH,1)
		underlays += redimage_south
		redimage_east.Shift(EAST,1)
		underlays += redimage_east

		spawn()
			var/amplitude = 2
			var/pixel_x_diff = rand(-amplitude, amplitude)
			var/pixel_y_diff = rand(-amplitude, amplitude)
			animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
			animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)
			pixel_x_diff = rand(-amplitude, amplitude)
			pixel_y_diff = rand(-amplitude, amplitude)
			animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
			animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)
			pixel_x_diff = rand(-amplitude, amplitude)
			pixel_y_diff = rand(-amplitude, amplitude)
			animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
			animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)

		if(istype(O, /obj/structure) || istype(O, /obj/machinery))
			health = (anchored * 50) + 50
			destroy_objects = 1
			if(O.density && O.anchored)
				knockdown_people = 1
				melee_damage_lower *= 2
				melee_damage_upper *= 2
		else if(istype(O, /obj/item))
			var/obj/item/I = O
			health = 15 * I.w_class
			melee_damage_lower = 2 + I.force
			melee_damage_upper = 2 + I.force
			move_to_delay = 2 * I.w_class

		maxHealth = health
		if(creator)
			src.creator = creator
			faction = "\ref[creator]" // very unique
		if(destroy_original)
			qdel(O)
		return 1
	return

/mob/living/simple_animal/hostile/mimic/copy/DestroySurroundings()
	if(destroy_objects)
		..()

/mob/living/simple_animal/hostile/mimic/copy/AttackingTarget()
	. =..()
	if(knockdown_people)
		var/mob/living/L = .
		if(istype(L))
			if(prob(15))
				L.Weaken(1)
				L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")