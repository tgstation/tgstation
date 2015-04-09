//Gashapon vending machine things, probably going to be so broken that I either start over or give up entirely


/obj/machinery/gashapon
	name = "Gashapon Machine"
	icon = 'icons/obj/gashapon.dmi'
	icon_state = "gashapon"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/gashapon/attackby(var/obj/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/weapon/coin/))
		user.drop_item(src)
		user.visible_message("[user] puts a coin into [src] and turns the knob.", "You put a coin into [src] and turn the knob.")
		src.visible_message("[src] clicks softly.")
		sleep(rand(10,15))
		src.visible_message("[src] dispenses a capsule!")
		var/obj/item/weapon/capsule/b = new(src.loc)
		b.icon_state = "capsule[rand(1,12)]"
		del(O)
	else
		return ..()


/obj/item/weapon/capsule
	name = "capsule"
	desc = "A capsule from a gashapon machine. What are you waiting for? Open it!"
	icon = 'icons/obj/gashapon.dmi'
	icon_state = "capsule"
	item_state = "capsule"

/obj/item/weapon/capsule/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)

/obj/item/weapon/capsule/ex_act()
	qdel(src)
	return

/obj/item/weapon/capsule/attack_self(mob/M as mob)
	var/capsule_prize = pick(
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/gasha/greyshirt,
		/obj/item/toy/gasha/greytide,
		/obj/item/toy/gasha/corgitoy,
		/obj/item/toy/gasha/borertoy,
		/obj/item/toy/gasha/minislime,
		/obj/item/toy/gasha/AI,
		/obj/item/toy/gasha/AI/malf,
		/obj/item/toy/gasha/minibutt,
		/obj/item/toy/gasha/newcop,
		/obj/item/toy/gasha/jani,
		/obj/item/toy/gasha/miner,
		/obj/item/toy/gasha/clown,
		/obj/item/toy/gasha/goliath,
		/obj/item/toy/gasha/basilisk,
		/obj/item/toy/gasha/mommi,
		/obj/item/toy/gasha/guard,
		/obj/item/toy/gasha/hunter,
		/obj/item/toy/gasha/nurse,
		/obj/item/toy/gasha/alium,
		/obj/item/toy/gasha/pomf,
		/obj/item/toy/gasha/engi,
		/obj/item/toy/gasha/atmos,
		/obj/item/toy/gasha/sec,
		/obj/item/toy/gasha/plasman,
		/obj/item/toy/gasha/shard)

	var/obj/item/I = new capsule_prize(M)
	M.u_equip(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	M << "<span class='notice'>You got \a [I]!</span>"
	qdel(src)
	return