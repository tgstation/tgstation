//Clockwork marauder: A well-rounded frontline construct. Only one can exist for every two human servants.
/mob/living/simple_animal/hostile/clockwork/marauder
	name = "clockwork marauder"
	desc = "The stalwart apparition of a soldier, blazing with crimson flames. It's armed with a gladius and shield."
	icon_state = "clockwork_marauder"
	health = 150
	maxHealth = 150
	force_threshold = 8
	speed = 0
	obj_damage = 40
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	weather_immunities = list("lava")
	movement_type = FLYING
	loot = list(/obj/item/clockwork/component/geis_capacitor/fallen_armor)
	light_range = 2
	light_power = 1.1
	playstyle_string = "<b><span class='neovgre'>You are a clockwork marauder,</span> a well-rounded frontline construct of Ratvar. Although you have no \
	unique abilities, you're a fearsome fighter in one-on-one combat, and your shield protects from projectiles!<br><br>Obey the Servants and do as they \
	tell you. Your primary goal is to defend the Ark from destruction; they are your allies in this, and should be protected from harm.</b>"
	empower_string = "<span class='neovgre'>The Anima Bulwark's power flows through you! Your weapon will strike harder, your armor is sturdier, and your shield is considerably more \
	likely to deflect shots.</span>"
	var/deflect_chance = 40 //Chance to deflect any given projectile (non-damaging energy projectiles are always deflected)

/mob/living/simple_animal/hostile/clockwork/marauder/update_values()
	if(GLOB.ratvar_awakens) //Massive attack damage bonuses and health increase, because Ratvar
		health = 300
		maxHealth = 300
		melee_damage_upper = 25
		melee_damage_lower = 25
		attacktext = "devastates"
		speed = -1
		obj_damage = 100
	else if(GLOB.ratvar_approaches) //Hefty health bonus and slight attack damage increase
		health = 200
		maxHealth = 200
		melee_damage_upper = 15
		melee_damage_lower = 15
		attacktext = "carves"
		obj_damage = 50

/mob/living/simple_animal/hostile/clockwork/marauder/death(gibbed)
	visible_message("<span class='danger'>[src]'s equipment clatters lifelessly to the ground as the red flames within dissipate.</span>", \
	"<span class='userdanger'>Dented and scratched, your armor falls away, and your fragile form breaks apart without its protection.</span>")
	. = ..()

/mob/living/simple_animal/hostile/clockwork/marauder/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/hostile/clockwork/marauder/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0)
		for(var/mob/living/L in view(2, src))
			if(L.is_holding_item_of_type(/obj/item/nullrod))
				to_chat(src, "<span class='userdanger'>The presence of a brandished holy artifact weakens your armor!</span>")
				amount *= 4 //if a wielded null rod is nearby, it takes four times the health damage
				break
	. = ..()

/mob/living/simple_animal/hostile/clockwork/marauder/bullet_act(obj/item/projectile/P)
	if(deflect_projectile(P))
		return
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/proc/deflect_projectile(obj/item/projectile/P)
	var/final_deflection_chance = deflect_chance
	var/energy_projectile = istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam)
	if(P.nodamage || P.damage_type == STAMINA)
		final_deflection_chance = 100
	else if(!energy_projectile) //Flat 40% chance against energy projectiles; ballistic projectiles are 40% - (damage of projectile)%, min. 10%
		final_deflection_chance = max(10, deflect_chance - P.damage)
	if(GLOB.ratvar_awakens)
		final_deflection_chance = 100
	else if(GLOB.ratvar_approaches)
		final_deflection_chance = min(100, final_deflection_chance + 20) //20% bonus to deflection if the servants heralded Ratvar
	if(prob(final_deflection_chance))
		visible_message("<span class='danger'>[src] deflects [P] with their shield!</span>", \
		"<span class='danger'>You block [P] with your shield!</span>")
		if(energy_projectile)
			playsound(src, 'sound/weapons/effects/searwall.ogg', 50, TRUE)
		else
			playsound(src, "ricochet", 50, TRUE)
		. = TRUE
