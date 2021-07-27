/**
 * # Click Intercept Component
 *
 * When activated intercepts next click and outputs clicked atom.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/click_intercept
	display_name = "Click Intercept"
	display_desc = "A component that when activated will intercept next user's click and output the object that was clicked. Requires a shell."

	required_shells = list(/obj/item/organ/cyberimp/bci)

	var/datum/port/output/clicked_atom

	var/obj/item/organ/cyberimp/bci/bci
	var/coodown

/obj/item/circuit_component/click_intercept/Initialize()
	. = ..()
	trigger_input = add_input_port("Activate", PORT_TYPE_SIGNAL)
	trigger_output = add_output_port("Clicked", PORT_TYPE_SIGNAL)
	clicked_atom = add_output_port("Clicked Object", PORT_TYPE_ATOM)

/obj/item/circuit_component/click_intercept/register_shell(atom/movable/shell)
	bci = shell
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, .proc/on_organ_removed)

/obj/item/circuit_component/click_intercept/unregister_shell(atom/movable/shell)
	bci = null
	UnregisterSignal(shell, COMSIG_ORGAN_REMOVED)

/obj/item/circuit_component/click_intercept/input_received(datum/port/input/port)
	. = ..()

	if(. || !bci)
		return

	var/mob/living/owner = bci.owner
	if(!owner || !istype(owner) || !owner.client)
		return

	if(TIMER_COOLDOWN_CHECK(parent, COOLDOWN_CIRCUIT_CLICK_INTERCEPT))
		return

	to_chat(owner, "<B>Left-click to activate click interceptor!</B>")
	owner.client.click_intercept = src

/obj/item/circuit_component/click_intercept/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	if(owner.client && owner.client.click_intercept == src)
		owner.client.click_intercept = null

/obj/item/circuit_component/click_intercept/proc/InterceptClickOn(mob/user, params, atom/object)
	owner.client.click_intercept = null
	clicked_atom.set_output(object)
	trigger_output.set_output(COMPONENT_SIGNAL)
	TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_CLICK_INTERCEPT, 1 SECOND)
