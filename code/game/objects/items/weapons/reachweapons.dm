/*For weapons that utilize reach.
Currently contains:
Pikes
*/

/obj/item/weapon/twohanded/spear/pike
	name = "pike"
	desc = "It's a spear with a much longer handle. A lot harder to maneuver in combat and probably less aerodynamic, but it should give you some extra reach."
	throwforce = 10
	throw_speed = 2
	//could use sprites
	reach = 2

/obj/item/weapon/twohanded/spear/pike/attack(mob/living/target, mob/living/user)
	var/dist = get_dist(target, user)
	if(dist < reach)
		to_chat(user, "<span class='warning'>You're too close to hit [target] effectively.</span>")
		return
	else
		..()
