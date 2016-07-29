//////////////////////////Random number generator circuit////////////////////////
// * When pulsed, randomly picks n assemblies connected to it and sends a pulse to them. Also generates a random number from 0 to n.

/obj/item/device/assembly/randomizer
	name = "randomizer circuit"
	short_name = "randomizer"

	desc = "A tiny circuit intended for use in assembly frames. When it receives a pulse, it randomly selects a set amount of devices connected to it, and emits a pulse to them."
	icon_state = "circuit_rng"
	starting_materials = list(MAT_IRON = 100, MAT_GLASS = 25)
	w_type = RECYK_ELECTRONIC

	origin_tech = "programming=1"

	wires = WIRE_PULSE | WIRE_RECEIVE

	connection_text = "connected to"

	var/output_number = 1 //How many assemblies are randomly chosen
	var/last_value = 0

	accessible_values = list("Generated number" = "last_value;number",\
		"Upper limit" = "output_number;number")

/obj/item/device/assembly/randomizer/activate() //Simple stuff - when pulsed, emit a pulse. The assembly frame will handle the next part
	if(!..()) return 0

	last_value = rand(0, output_number)
	pulse()

/obj/item/device/assembly/randomizer/interact(mob/user)
	var/new_output_num = input(user, "How many devices should \the [src] randomly select?", "[src]", output_number) as null|num

	if(!Adjacent(user) || user.isUnconscious()) //sanity 101
		return

	output_number = Clamp(new_output_num, 1, 512)
	to_chat(user, "<span class='info'>Number of outputs set to [output_number].</span>")

/obj/item/device/assembly/randomizer/send_pulses_to_list(var/list/L) //The assembly frame will give us a list of devices to forward a pulse to.
	if(!L || !L.len) return

	var/list/AS = L.Copy() //Copy the list, since we're going to remove stuff from it

	for(var/i = 0 to output_number-1)
		var/obj/item/device/assembly/A = pick(AS) //Pick a random assembly, remove it from the list and pulse it

		AS.Remove(A)
		A.pulsed()

		if(!AS.len) break
