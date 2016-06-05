//If you're looking for spawners like ash walker eggs, check ghost_role_spawners.dm

/obj/structure/lavaland_door
	name = "necropolis gate"
	desc = "A tremendous and impossibly large gateway, bored into dense bedrock."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door"
	anchored = 1
	density = 1
	opacity = 1
	bound_width = 96
	bound_height = 96
	pixel_x = -32
	bound_x = -32
	burn_state = LAVA_PROOF
	luminosity = 1
	var/boss = FALSE
	var/is_anyone_home = FALSE

/obj/structure/lavaland_door/attack_hand(mob/user)
	for(var/mob/living/simple_animal/hostile/megafauna/legion/L in mob_list)
		return
	if(is_anyone_home)
		return
	var/safety = alert(user, "You think this might be a bad idea...", "Knock on the door?", "Proceed", "Abort")
	if(safety == "Abort" || !in_range(src, user) || !src || is_anyone_home || user.incapacitated())
		return
	user.visible_message("<span class='warning'>[user] knocks on [src]...</span>", "<span class='userdanger'>You reach out and rap on [src] three times...</span>")
	playsound(user.loc, 'sound/effects/shieldbash.ogg', 100, 1)
	is_anyone_home = TRUE
	sleep(50)
	if(boss)
		user << "<span class='notice'>There's no response.</span>"
		is_anyone_home = FALSE
		return 0
	boss = TRUE
	visible_message("<span class='warning'>Locks along the door begin clicking open from within...</span>")
	var/volume = 60
	for(var/i in 1 to 3)
		playsound(src, 'sound/items/Deconstruct.ogg', volume, 0)
		volume += 20
		sleep(10)
	sleep(10)
	visible_message("<span class='userdanger'>Something horrible emerges from the Necropolis!</span>")
	message_admins("[key_name_admin(user)] has summoned Legion!")
	log_game("[key_name(user)] summoned Legion.")
	is_anyone_home = FALSE
	new/mob/living/simple_animal/hostile/megafauna/legion(get_step(src.loc, SOUTH))

/obj/structure/lavaland_door/singularity_pull()
	return 0

/obj/structure/lavaland_door/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/machinery/lavaland_controller
	name = "weather control machine"
	desc = "Controls the weather."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"
	var/datum/weather/ongoing_weather = FALSE
	var/weather_cooldown = 0

/obj/machinery/lavaland_controller/process()
	if(ongoing_weather || weather_cooldown > world.time)
		return
	weather_cooldown = world.time + rand(3500, 6500)
	var/datum/weather/ash_storm/LAVA = new /datum/weather/ash_storm
	ongoing_weather = LAVA
	LAVA.weather_start_up()
	ongoing_weather = null

/obj/machinery/lavaland_controller/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

//lavaland_surface_seed_vault.dmm
//Seed Vault

/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/seeds/gatfruit = 10,
				/obj/item/seeds/cherry = 15,
				/obj/item/seeds/berry/glow = 10,
				/obj/item/seeds/sunflower/moonflower = 8
				)

//Greed

/obj/structure/cursed_slot_machine
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots1"
	anchored = 1
	density = 1
	var/win_prob = 5

/obj/structure/cursed_slot_machine/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(in_use)
		return
	in_use = TRUE
	user << "<span class='danger'><B>You feel your very life draining away as you pull the lever...it'll be worth it though, right?</B></span>"
	user.adjustCloneLoss(20)
	if(user.stat)
		user.gib()
	icon_state = "slots2"
	sleep(50)
	icon_state = "slots1"
	in_use = FALSE
	if(prob(win_prob))
		new /obj/item/weapon/dice/d20/fate/one_use(get_turf(src))
		if(user)
			user << "You hear laughter echoing around you as the machine fades away. In it's place...more gambling."
			qdel(src)
	else
		if(user)
			user << "<span class='danger'>Looks like you didn't win anything this time...next time though, right?</span>"
//Gluttony

/obj/effect/gluttony
	name = "gluttony's wall"
	desc = "Only those who truly indulge may pass."
	anchored = 1
	density = 1
	icon_state = "blob"
	icon = 'icons/mob/blob.dmi'

/obj/effect/gluttony/CanPass(atom/movable/mover, turf/target, height=0)//So bullets will fly over and stuff.
	if(height==0)
		return 1
	if(istype(mover, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mover
		if(H.nutrition >= NUTRITION_LEVEL_FAT)
			return 1
		else
			H << "<span class='danger'><B>You're not gluttonous enough to pass this barrier!</B></span>"
	else
		return 0

//Pride

/obj/structure/mirror/magic/pride
	name = "pride's mirror"
	desc = "Pride cometh before the..."
	icon_state = "magic_mirror"

/obj/structure/mirror/magic/pride/curse(mob/user)
	user.visible_message("<span class='danger'><B>The ground splits beneath [user] as their hand leaves the mirror!</B></span>")
	var/turf/T = get_turf(user)
	T.ChangeTurf(/turf/open/chasm/straight_down)
	var/turf/open/chasm/straight_down/C = T
	C.drop(user)

//Sloth - I'll finish this item later

//Envy

/obj/item/weapon/knife/envy
	name = "envy's knife"
	desc = "Their success will be yours."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 18
	throwforce = 10
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/knife/envy/afterattack(atom/movable/AM, mob/living/carbon/human/user, proximity)
	..()
	if(!proximity)
		return
	if(!istype(user))
		return
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(user.real_name != H.dna.real_name)
			user.real_name = H.dna.real_name
			H.dna.transfer_identity(user, transfer_SE=1)
			user.updateappearance(mutcolor_update=1)
			user.domutcheck()
			user << "You assume the face of [H]. Are you satisfied?"

///Ash Walkers

/mob/living/simple_animal/hostile/spawner/ash_walker
	name = "ash walker nest"
	desc = "A nest built around a necropolis tendril. The eggs seem to grow unnaturally fast..."
	icon = 'icons/mob/nest.dmi'
	icon_state = "ash_walker_nest"
	icon_living = "ash_walker_nest"
	faction = list("ashwalker")
	health = 200
	maxHealth = 200
	loot = list(/obj/effect/gibspawner, /obj/item/device/assembly/signaler/anomaly)
	del_on_death = 1
	var/meat_counter

/mob/living/simple_animal/hostile/spawner/ash_walker/Life()
	..()
	if(!stat)
		consume()
		spawn_mob()

/mob/living/simple_animal/hostile/spawner/ash_walker/proc/consume()
	for(var/mob/living/H in view(src,1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Tendrils reach out from \the [src.name] pulling [H] in! Blood seeps over the eggs as [H] is devoured.</span>")
			playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
			if(istype(H,/mob/living/simple_animal/hostile/megafauna/dragon))
				meat_counter += 20
			else
				meat_counter ++
			for(var/obj/item/W in H)
				H.unEquip(W)
			H.gib()

/mob/living/simple_animal/hostile/spawner/ash_walker/spawn_mob()
	if(meat_counter >= 2)
		new /obj/effect/mob_spawn/human/ash_walker(get_step(src.loc, SOUTH))
		visible_message("<span class='danger'>An egg is ready to hatch!</span>")
		meat_counter -= 2

//Free Golems

/obj/item/weapon/disk/design_disk/golem_shell
	name = "Golem Creation Disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"

/obj/item/weapon/disk/design_disk/golem_shell/New()
	..()
	var/datum/design/golem_shell/G = new
	blueprint = G

/datum/design/golem_shell
	name = "Golem Shell Construction"
	desc = "Allows for the construction of a Golem Shell."
	id = "golem"
	req_tech = list("materials" = 12)
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 40000)
	build_path = /obj/item/golem_shell
	category = list("Imported")

/obj/item/golem_shell
	name = "incomplete golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/species
	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/O = I

		if(istype(O, /obj/item/stack/sheet/metal))
			species = /datum/species/golem

		if(istype(O, /obj/item/stack/sheet/mineral/plasma))
			species = /datum/species/golem/plasma

		if(istype(O, /obj/item/stack/sheet/mineral/diamond))
			species = /datum/species/golem/diamond

		if(istype(O, /obj/item/stack/sheet/mineral/gold))
			species = /datum/species/golem/gold

		if(istype(O, /obj/item/stack/sheet/mineral/silver))
			species = /datum/species/golem/silver

		if(istype(O, /obj/item/stack/sheet/mineral/uranium))
			species = /datum/species/golem/uranium

		if(species)
			if(O.use(10))
				user << "You finish up the golem shell with ten sheets of [O]."
				var/obj/effect/mob_spawn/human/golem/G = new(get_turf(src))
				G.mob_species = species
				qdel(src)
			else
				user << "You need at least ten sheets to finish a golem."
		else
			user << "You can't build a golem out of this kind of material."
