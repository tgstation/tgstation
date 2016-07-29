
//gimmicky hack to collect particles and direct them into the field
/obj/effect/rust_particle_catcher
	icon = 'icons/effects/effects.dmi'
	density = 0
	anchored = 1
	layer = 4
	var/obj/effect/rust_em_field/parent
	var/mysize = 0

	invisibility = 101

/obj/effect/rust_particle_catcher/Destroy()
	. =..()
	parent.particle_catchers -= src
	parent = null

/obj/effect/rust_particle_catcher/proc/SetSize(var/newsize)
	name = "collector [newsize]"
	mysize = newsize
	UpdateSize()

/obj/effect/rust_particle_catcher/proc/AddParticles(var/name, var/quantity = 1)
	if(parent && parent.size >= mysize)
		parent.AddParticles(name, quantity)
		return 1
	return 0

/obj/effect/rust_particle_catcher/proc/UpdateSize()
	if(parent.size >= mysize)
		density = 1
		//invisibility = 0
		name = "collector [mysize] ON"
	else
		density = 0
		//invisibility = 101
		name = "collector [mysize] OFF"

/obj/effect/rust_particle_catcher/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.flag != "bullet" && parent)
		parent.AddEnergy(Proj.damage * 20, 0, 1)
		update_icon()
	return 0

/obj/effect/rust_particle_catcher/Bumped(atom/AM)
	if(ismob(AM) && density && prob(10))
		to_chat(AM, "<span class='warning'>A powerful force pushes you back.</span>")
	..()
