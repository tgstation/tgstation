# Datum Component System (DCS)

## Concept

Loosely adapted from /vg/. This is an entity component system for adding behaviours to datums when inheritance doesn't quite cut it. By using signals and events instead of direct inheritance, you can inject behaviours without hacky overloads. It requires a different method of thinking, but is not hard to use correctly. If a behaviour can have application across more than one thing. Make it generic, make it a component. Atom/mob/obj event? Give it a signal, and forward it's arguments with a `SendSignal()` call. Now every component that want's to can also know about this happening.

### In the code

#### Slippery things

At the time of this writing, every object that is slippery overrides atom/Crossed does some checks, then slips the mob. Instead of all those Crossed overrides they could add a slippery component to all these objects. And have the checks in one proc that is run by the Crossed event

#### Powercells

A lot of objects have powercells. The `get_cell()` proc was added to give generic access to the cell var if it had one. This is just a specific use case of `GetComponent()`

#### Radios

The radio object as it is should not exist, given that more things use the _concept_ of radios rather than the object itself. The actual function of the radio can exist in a component which all the things that use it (Request consoles, actual radios, the SM shard) can add to themselves.

#### Standos

Stands have a lot of procs which mimic mob procs. Rather than inserting hooks for all these procs in overrides, the same can be accomplished with signals

## API

### Vars

1. `/datum/var/list/datum_components` (private)
    * Lazy associated list of type -> component/list of components.
1. `/datum/component/var/enabled` (protected, boolean)
    * If the component is enabled. If not, it will not react to signals
    * TRUE by default
1. `/datum/component/var/dupe_mode` (protected, enum)
    * How multiple components of the exact same type are handled when added to the datum.
        * `COMPONENT_DUPE_HIGHLANDER` (default): Old component will be deleted, new component will first have `/datum/component/proc/InheritComponent(datum/component/old, FALSE)` on it
        * `COMPONENT_DUPE_ALLOWED`: The components will be treated as separate, `GetComponent()` will return the first added
        * `COMPONENT_DUPE_UNIQUE`: New component will be deleted, old component will first have `/datum/component/proc/InheritComponent(datum/component/new, TRUE)` on it
1. `/datum/component/var/list/signal_procs` (private)
    * Associated lazy list of signals -> callbacks that will be run when the parent datum recieves that signal
1. `/datum/component/var/datum/parent` (protected, read-only)
    * The datum this component belongs to

### Procs

1. `/datum/proc/GetComponent(component_type(type)) -> datum/component?` (public, final)
    * Returns a reference to a component of component_type if it exists in the datum, null otherwise
1. `/datum/proc/GetComponents(component_type(type)) -> list` (public, final)
    * Returns a list of references to all components of component_type that exist in the datum
1. `/datum/proc/GetExactComponent(component_type(type)) -> datum/component?` (public, final)
    * Returns a reference to a component whose type MATCHES component_type if that component exists in the datum, null otherwise
1. `GET_COMPONENT(varname, component_type)` OR `GET_COMPONENT_FROM(varname, component_type, src)`
    * Shorthand for `var/component_type/varname = src.GetComponent(component_type)`
1. `/datum/proc/AddComponent(component_type(type), ...) -> datum/component`  (public, final)
    * Creates an instance of `component_type` in the datum and passes `...` to it's `New()` call
    * Sends the `COMSIG_COMPONENT_ADDED` signal to the datum
    * All components a datum owns are deleted with the datum
    * Returns the component that was created. Or the old component in a dupe situation where `COMPONENT_DUPE_UNIQUE` was set
1. `/datum/proc/ComponentActivated(datum/component/C)` (abstract)
    * Called on a component's `parent` after a signal recieved causes it to activate. `src` is the parameter
    * Will only be called if a component's callback returns `TRUE`
1. `/datum/proc/TakeComponent(datum/component/C)` (public, final)
    * Properly transfers ownership of a component from one datum to another
    * Singals `COMSIG_COMPONENT_REMOVING` on the parent
    * Called on the datum you want to own the component with another datum's component
1. `/datum/proc/SendSignal(signal, ...)` (public, final)
    * Call to send a signal to the components of the target datum
    * Extra arguments are to be specified in the signal definition
1. `/datum/component/New(datum/parent, ...)` (protected, virtual)
    * Forwarded the arguments from `AddComponent()`
1. `/datum/component/Destroy()` (virtual)
    * Sends the `COMSIG_COMPONENT_REMOVING` signal to the parent datum if the `parent` isn't being qdeleted
    * Properly removes the component from `parent` and cleans up references
1. `/datum/component/proc/InheritComponent(datum/component/C, i_am_original(boolean))` (abstract)
    * Called on a component when a component of the same type was added to the same parent
    * See `/datum/component/var/dupe_mode`
    * `C`'s type will always be the same of the called component
1. `/datum/component/proc/OnTransfer(datum/new_parent)` (abstract)
    * Called before the new `parent` is assigned in `TakeComponent()`, after the remove signal, before the added signal
    * Allows the component to react to ownership transfers
1. `/datum/component/proc/_RemoveNoSignal()` (private, final)
    * Internal, clears the parent var and removes the component from the parents component list
1. `/datum/component/proc/RegisterSignal(signal(string), proc_ref(type), override(boolean))` (protected, final) (Consider removing for performance gainz)
    * Makes a component listen for the specified `signal` on it's `parent` datum.
    * When that signal is recieved `proc_ref` will be called on the component, along with associated arguments
    * Example proc ref: `.proc/OnEvent`
    * If a previous registration is overwritten by the call, a runtime occurs. Setting `override` to TRUE prevents this
    * These callbacks run asyncronously
    * Returning `TRUE` from these callbacks will trigger a `TRUE` return from the `SendSignal()` that initiated it
1. `/datum/component/proc/ReceiveSignal(signal, ...)` (virtual)
    * Called when a component recieves any signal and is enabled
    * Default implementation looks if the signal is registered and runs the appropriate proc

### See signals and their arguments in __DEFINES\components.dm

## Examples
    Material Containers: #29268 (Too many GetComponent calls, but not bad)
    Slips: #00000 (PR DIS)
    Powercells: (TODO)