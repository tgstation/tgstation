//Gashapon vending machine things, probably going to be so broken that I either start over or give up entirely


/obj/machinery/gashapon
	name = "Gashapon Machine"
	desc = "Insert coin, recieve capsule!"
	icon = 'icons/obj/gashapon.dmi'
	icon_state = "gashapon"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/gashapon/attackby(var/obj/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/weapon/coin/))
		user.drop_item(O, src)
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
		/obj/item/toy/gasha/shard,
		/obj/item/toy/gasha/mime,
		/obj/item/toy/gasha/captain,
		/obj/item/toy/gasha/comdom,
		/obj/item/toy/gasha/doctor,
		/obj/item/toy/gasha/defsquid,
		/obj/item/toy/gasha/wizard,
		/obj/item/toy/gasha/shade,
		/obj/item/toy/gasha/wraith,
		/obj/item/toy/gasha/juggernaut,
		/obj/item/toy/gasha/artificer,
		/obj/item/toy/gasha/harvester,
		/obj/item/toy/gasha/skub,
		/obj/item/toy/gasha/fingerbox,
		/obj/item/toy/gasha/cattoy,
		/obj/item/toy/gasha/parrottoy,
		/obj/item/toy/gasha/beartoy,
		/obj/item/toy/gasha/carptoy,
		/obj/item/toy/gasha/monkeytoy,
		/obj/item/toy/gasha/huggertoy,
		/obj/item/toy/gasha/narnar,
		/obj/item/toy/gasha/quote,
		/obj/item/toy/gasha/quote/curly,
		/obj/item/toy/gasha/quote/malco,
		/obj/item/toy/gasha/quote/scout,
		/obj/item/toy/gasha/mimiga/sue,
		/obj/item/toy/gasha/mimiga/toroko,
		/obj/item/toy/gasha/mimiga/king,
		/obj/item/toy/gasha/mimiga/chaco,
		/obj/item/toy/gasha/mario,
		/obj/item/toy/gasha/mario/luigi,
		/obj/item/toy/gasha/mario/star,
		/obj/item/toy/gasha/bomberman/white,
		/obj/item/toy/gasha/bomberman/black,
		/obj/item/toy/gasha/bomberman/red,
		/obj/item/toy/gasha/bomberman/blue)

	var/obj/item/I = new capsule_prize(M)
	M.u_equip(src, 0)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	to_chat(M, "<span class='notice'>You got \a [I]!</span>")
	qdel(src)
	return