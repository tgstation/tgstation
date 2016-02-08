# tgui
tgui is the user interface library of /tg/station. It is rendered clientside,  based on JSON data sent from the server. Clicks are processed on the server, in  a similar method to native BYOND `Topic()`.

Basic tgui consists of defining a few procs. In these procs you will handle a request to open or update a UI (typically by updating a UI if it exists or setting up and opening it if it does not), a request for data, in which you build a list to be passed as JSON to the UI, and an action handler, which handles any user input. In addition, you will write a HTML template file which renders your data and provides actionable inputs.

tgui is very different from most UIs you will encounter in BYOND programming, and is heavily reliant of Javascript and web technologies as opposed to DM. However, if you are familiar with NanoUI (a library which can be found on almost every other SS13 codebase), tgui should be fairly easy to pick up.

tgui is a fork of NanoUI. The server-side code (DM) is similar and derived from NanoUI, while the clientside is a wholly new project with no code in common.
