# Datum Component System (DCS)

## Concept

Loosely adapted from /vg/. This is an entity component system for adding behaviours to datums when inheritance doesn't quite cut it. By using signals and events instead of direct inheritance, you can inject behaviours without hacky overloads. It requires a different method of thinking, but is not hard to use correctly. If a behaviour can have application across more than one thing. Make it generic, make it a component. Atom/mob/obj event? Give it a signal, and forward its arguments with a `SendSignal()` call. Now every component that want's to can also know about this happening.

### [HackMD page for an introduction to the system as a whole.](https://hackmd.io/@tgstation/SignalsComponentsElements)

### See/Define signals and their arguments in [\_\_DEFINES\components.dm](../../__DEFINES/components.dm)
