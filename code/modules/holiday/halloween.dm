//spooky halloween stuff. only tick on halloween!!!
//uses super seekrit double proc definition stuffs. remember to call ..()!
/*/mob/dead/observer/say(var/message) //this doesn't actually work vOv
	..()
	for(var/mob/M in hearers(src, 1))
		if(!M.stat)
			if(M.job == "Chaplain")
				if (prob (49))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
					if(prob(20))
						playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
				else
					M.show_message("<span class='game'><i>You hear muffled speech... you can almost make out some words...</i></span>", 2)
//				M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)
					if(prob(30))
						playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
			else
				if(prob(50))
					return
				else if(prob (95))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
					if(prob(20))
						playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
				else
					M.show_message("<span class='game'><i>You hear muffled speech... you can almost make out some words...</i></span>", 2)
//				M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)
					playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)*/


///////////////////////////////////////
///////////HALLOWEEN CONTENT///////////
///////////////////////////////////////

//spooky foods
/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookyskull
	name = "skull cookie"
	desc = "Spooky! It's got delicious calcium flavouring!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "skeletoncookie"

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookycoffin
	name = "coffin cookie"
	desc = "Spooky! It's got delicious coffee flavouring!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "coffincookie"

//spooky recipes

/datum/recipe/sugarcookie/spookyskull
	reagents = list("flour" = 5, "sugar" = 5, "milk" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookyskull

/datum/recipe/sugarcookie/spookycoffin
	reagents = list("flour" = 5, "sugar" = 5, "coffee" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookycoffin

//spooky items

/obj/item/weapon/storage/spooky
	name = "trick-o-treat bag"
	desc = "A Pumpkin shaped bag that holds all sorts of goodies!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "treatbag"

/obj/item/weapon/storage/spooky/New()
	..()
	for(var/distrobuteinbag=0 to 6)
		var/type = pick(/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookyskull,
		/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookycoffin,
		/obj/item/weapon/reagent_containers/food/snacks/candy_corn,
		/obj/item/weapon/reagent_containers/food/snacks/candy,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
		new type(src)

//////////////////////////////
//Spookoween trapped closets//
//////////////////////////////

#define SPOOKY_SKELETON 1
#define ANGRY_FAITHLESS 2
#define SCARY_BATS 		3
#define INSANE_CLOWN	4
#define HOWLING_GHOST	5

//Spookoween variables
/obj/structure/closet
	var/trapped = 0
	var/mob/trapped_mob

/obj/structure/closet/initialize()
	..()
	if(prob(30))
		set_spooky_trap()

/obj/structure/closet/dump_contents()
	..()
	trigger_spooky_trap()

/obj/structure/closet/proc/set_spooky_trap()
	if(prob(0.1))
		trapped = INSANE_CLOWN
		return
	if(prob(1))
		trapped = ANGRY_FAITHLESS
		return
	if(prob(15))
		trapped = SCARY_BATS
		return
	if(prob(20))
		trapped = HOWLING_GHOST
		return
	else
		var/mob/living/carbon/human/H = new (loc)
		H.makeSkeleton()
		H.health = 1e5
		insert(H)
		trapped_mob = H
		trapped = SPOOKY_SKELETON
		return

/obj/structure/closet/proc/trigger_spooky_trap()
	if(!trapped)
		return

	if(trapped == SPOOKY_SKELETON)
		src.visible_message("<span class='userdanger'><font size='5'>BOO!</font></span>");
		playsound(src.loc, pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg','sound/spookoween/girlscream.ogg'), 300, 1)
		trapped = 0
		spawn(60)
			if(trapped_mob.loc != loc)
				var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
				smoke.set_up(1,0, trapped_mob.loc, 0)
				smoke.start()
				trapped_mob.loc = loc
			src.close()
			trapped = SPOOKY_SKELETON
		return

	if(trapped == ANGRY_FAITHLESS)
		src.visible_message("<span class='userdanger'>The closet bursts open!</span>");
		src.visible_message("<span class='userdanger'><font size='5'>THIS BEING RADIATES PURE EVIL! YOU BETTER RUN !!!</font></span>");
		playsound(src.loc, 'sound/hallucinations/wail.ogg', 300, 1)
		var/mob/living/simple_animal/hostile/faithless/F = new (loc)
		F.health =1e5
		F.stance = HOSTILE_STANCE_ATTACK
		F.GiveTarget(usr)
		trapped = 0
		qdel(src)
		spawn(120)
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
			smoke.set_up(1,0, F.loc, 0)
			smoke.start()
			qdel(F)
		return

	if(trapped == SCARY_BATS)
		src.visible_message("<span class='userdanger'><font size='5'>Protect your hairs !!!</font></span>");
		playsound(src.loc, 'sound/spookoween/bats.ogg', 300, 1)
		var/number = rand(1,4)
		for(var/i=0,i < number,i++)
			new /mob/living/simple_animal/hostile/retaliate/bat (loc)
		trapped = 0
		return


	if(trapped == INSANE_CLOWN)
		src.visible_message("<span class='userdanger'><font size='5'>...</font></span>");
		playsound(src.loc, 'sound/spookoween/scary_clown_appear.ogg', 300, 1)
		var/mob/living/simple_animal/hostile/retaliate/clown/insane/IC = new (loc)
		IC.GiveTarget(usr)
		trapped = 0
		return

	if(trapped == HOWLING_GHOST)
		src.visible_message("<span class='userdanger'><font size='5'>Woo Woo</font></span>");
		playsound(src.loc, 'sound/spookoween/ghosty_wind.ogg', 300, 1)
		new /mob/living/simple_animal/shade/howling_ghost (loc)
		trapped = 0
		return

//don't spawn in crates
/obj/structure/closet/crate/trigger_spooky_trap()
	return 0

/obj/structure/closet/crate/set_spooky_trap()
	return 0


////////////////////
//Spookoween Ghost//
////////////////////

/mob/living/simple_animal/shade/howling_ghost
	name ="Ghost"
	real_name = "Ghost"
	icon = 'icons/mob/mob.dmi'
	maxHealth = 1e6
	health = 1e6
	speak_emote = list("howls")
	emote_hear = list("wails","screeches")
	density = 0
	anchored = 1
	incorporeal_move = 1
	layer = 4
	var/timer = 0

/mob/living/simple_animal/shade/howling_ghost/New()
	..()
	icon_state = pick("ghost","ghostian","ghostian2","ghostking","ghost1","ghost2")
	icon_living = icon_state
	status_flags |= GODMODE
	timer = rand(1,15)

/mob/living/simple_animal/shade/howling_ghost/Life()
	..()
	timer--
	if(timer == 0)
		roam()
		spooky_ghosty()
		timer = rand(1,15)

/mob/living/simple_animal/shade/howling_ghost/proc/EtherealMove(direction)
	loc = get_step(src, direction)
	dir = direction

/mob/living/simple_animal/shade/howling_ghost/proc/roam()
	if(prob(80))
		var/direction = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
		EtherealMove(direction)

/mob/living/simple_animal/shade/howling_ghost/proc/spooky_ghosty()
	if(prob(20)) //haunt
		playsound(src.loc, pick('sound/spookoween/ghosty_wind.ogg','sound/spookoween/ghost_whisper.ogg','sound/spookoween/chain_rattling.ogg'), 300, 1)
	if(prob(10)) //flickers
		var/obj/machinery/light/L = locate(/obj/machinery/light) in view(5, src)
		if(L)
			L.flicker()
	if(prob(5)) //poltergeist
		var/obj/item/I = locate(/obj/item) in view(3, src)
		if(I)
			var/direction = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
			step(I,direction)
		return

/mob/living/simple_animal/shade/howling_ghost/adjustBruteLoss()
	return

/mob/living/simple_animal/shade/howling_ghost/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1


///////////////////////////
//Spookoween Insane Clown//
///////////////////////////

/mob/living/simple_animal/hostile/retaliate/clown/insane
	name = "Insane Clown"
	desc = "May the HonkMother have mercy..."
	icon_state = "scary_clown"
	icon_living = "scary_clown"
	icon_dead = "scary_clown"
	icon_gib = "scary_clown"
	speak = list("...", ". . .")
	maxHealth = 1e6
	health = 1e6
	emote_see = list("silently stares")
	heat_damage_per_tick = 0
	cold_damage_per_tick = 0
	unsuitable_atmos_damage = 0

	var/timer

/mob/living/simple_animal/hostile/retaliate/clown/insane/New()
	..()
	timer = rand(5,15)
	status_flags = (status_flags | GODMODE)
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/Retaliate()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/ex_act()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/Life()
	timer--
	if(target)
		stalk()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/proc/stalk()
	var/mob/living/M = target
	if(M.stat == DEAD)
		playsound(M.loc, 'sound/spookoween/insane_low_laugh.ogg', 300, 1)
		qdel(src)
	if(timer == 0)
		timer = rand(5,15)
		playsound(M.loc, pick('sound/spookoween/scary_horn.ogg','sound/spookoween/scary_horn2.ogg', 'sound/spookoween/scary_horn3.ogg'), 300, 1)
		spawn(12)
			loc = M.loc
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/MoveToTarget()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/AttackTarget()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/adjustBruteLoss()
	if(prob(5))
		playsound(src.loc, 'sound/spookoween/insane_low_laugh.ogg', 300, 1)
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/weapon/nullrod))
		if(prob(5))
			visible_message("<span class='notice'>[src] finally found the peace it deserves. HONK for the HonkMother !</span>");
			playsound(src.loc, 'sound/spookoween/insane_low_laugh.ogg', 300, 1)
			qdel(src)
			return
		else
			visible_message("<span class='userdanger'>It seems to be resisting the effect!!!</span>");
			return
	..()

