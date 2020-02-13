# The Holy Bible of TGUI with Arcane and a shot of Vodka

> NOTE: This is a near verbatim copy of the pastebin by Arcane, formatted
> in markdown, and saved here in memoriam of ye olde atrocious
> Ractive-based TGUI.

**Alright FUCKERS.**

This is the ArcaneMusic guide to TGUI, because the readme is ASS and most
existing tgui's are 20 fucking miles long.

---

First off, read the tgui ReadME here:
https://github.com/tgstation/tgstation/blob/c451d37f4db8303761445f6975613ea6f65e60b4/tgui/README.md

Cool, read the code for the specifics of how it should look, at the very least.

Look good?

Cool.

Ignore all the examples in the code, including the copypasta, they don't
actually compile.

Really, none of it works, it's not even complete code, and there are unassigned
VARS covering the example.

---

FIRST OFF: Make sure your shit is downloaded. Go to https://nodejs.org/en/ and
download the lts version of nodeJS. YOu can probably use either, but if we all
agree to use one version then less headache for everyone.

Cool, now, open your command line once that's done installing (Not the Node.JS
command line, just the standard command line. This guide is intended for windows
after all, but hopefully there's enough carryover that it won't be an issue for
anyone.

in CMD, enter `npm install gulp-cli`. This'll install gulp-cli, a necessary part
of tgui. If when you install it throws a bunch of errors, just listen to Oranges
and "Ignore all warnings". It's fine for what we're doing with it.

Cool, now open your /tg/station local files, and run the following 2 files in
order, `install_dependencies.bat` and `build_assets.bat`. This basically checks
the code for any resulting changes within the interface files, since Dream Maker
doesn't actually check to include these files, and makes sure they're stitched
into your final compiled build.

Done with all that? Great, now we can actually start coding something.

---

Here is MY code, reworking the existing example tgui, and filling in the gaps.

I'm going to keep the my_machine syntax for everything to keep it consistant
with their example, and I'll leave comments in the code so it can still be
copypasted, but will note where and when things deviate from the code.

---

```
/obj/machinery/my_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Note 1a.
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "my_machine", name, 300, 300, master_ui, state) // note 1b
    ui.open() // note 1c

/obj/machinery/my_machine/ui_data(mob/living/carbon/human/user)
  var/list/data = list()
  var/brute_loss = user.getBruteLoss()
  var/fire_loss = user.getFireLoss()
  var/tox_loss = user.getToxLoss()
  var/oxy_loss = user.getOxyLoss()

  data["brute_health"] = brute_loss // note 2a
  data["burn_health"] = fire_loss
  data["toxin_health"] = tox_loss
  data["suffocation_health"] = oxy_loss

  return data

/obj/machinery/my_machine/ui_act()
  if(..()) // note 3a
    return
 /* switch(action) // note 3b
    if("change_color")
      var/new_color = params["color"]
      if(!(color in allowed_coors))
        return
      color = new_color
      . = TRUE */ // note 3c
  update_icon()
```

- Note 1a: Different from the existing example, is set to
`datum/ui_state/state = GLOB.default_state`. This is just a syntax error
off the original, I guess, or the syntax changed over time. Not sure to be
honest.

- Note 1b: make sure that "my_machine" is the name of your .ract file. Here you
can also change the default window size, so keep that in mind.

- Note 1c: Gonna be real here, outside of renaming your .ract file on the 4th
line, almost every method for ui_interact is going to be pretty much the same.
There are obviously exceptions, but this layout is used on quite, QUITE A LOT of
tgui layouts.

- Note 2a: So you're always going to call `var/list/data = list()` every time,
and setting data `["var"]` to your byond side variables is how you do that. The
original example included a color variable too, but I decided to forego that and
turn it into a medical machine.

- Note 3a: This part of the code is required in every tgui. It may not be needed
to compile, but it sanitizes inputs, and we like that.

- Note 3b: So... this was part of that aforementioned color code that's been
removed, but I left it in as a comment in order to good idea of how the actions
and button code works. That being said, a far better example is bin.dm, just
look at the UI in game alongside this aspect of the code. That being said, as
this window has no functionality outside of information, ui_act is functionally
empty for us.

- Note 3c: Every interaction within ui_act should end with a `. = TRUE`. I
believe it's for sanitized inputs, but I couldn't tell you for sure. If your
button or action or switch isn't working, check this first.

---

Now, this part of the code should be saved as "my_machine.ract". DON'T BE FOOLED BY WINDOWS FILE BROWSER LIKE I WAS, it's not .RACT . Anyone more experienced in coding probably knows that already, but I didn't have file extensions on by default on my machine (Pun intended) so this took far too long to test.

```
<ui-display>
  <ui-section label='damage values'>
    <span>{{data.brute_health}}</span>
    <span>{{data.burn_health}}</span>
    <span>{{data.toxin_health}}</span>
    <span>{{data.suffocation_health}}</span>
  </ui-section>
</ui-display> // Note 4a
```

- Note 4a: So this window is honestly EXTREMELY barebones. It's only a little
bit better off than a hello world window, but it has a bit of functionality.
It'll actively track each of your damage values seperately, all on the same
line, and updates every time you check the console. Neato, hunh? With just a
little bit of cleanup, this could be an actual feature. I'm probably going to
make it a real feature out of spite too.

---

Here's where all the magic happens and the layout of the window gets pieced
together. Make sure the .ract file is saved in the interfaces folder.

Remember how in the near beginning you ran "install_dependencies.bat" and
"build_assets.bat"? You thought you were done with those files? So, EVERY TIME
you change your .ract file, and to be sure, any major part of the UI, run those
2 .bat files. This reloads the correct new changes in your .ract file, which
since it controls if Dream Maker even sees the file, you'll be using those 2
batch files quite a lot.

---

Now for the fun part, the part where I attempt to troubleshoot and horribly fuck it.

> I'm getting a message saying, "The requested interface (my_machine) was
> not found. Does it exist?".

So, check through the following:

1. Make sure the file is saved as a .ract file and not anything else.
2. Make sure the file is saved in the interfaces folder of your /tg/ local code.
3. Attempt recompiling and running install_dependencies.bat and build_assets.bat
again.
4. Verify that your .ract file and your linked file in ui_interact are pointing
to the same files.
5. If not, ask on discord. We hate TGUI as much as you do.

> I'm getting an issue with the UI state, where the default variable isn't
> "letting Dream Maker Compile".

This is conjecture from someone who is still relatively new to this shit, so
bare with me. I think that the old syntax for tgui didn't require the default
state to be a global variable, but almost every tgui seems to run
GLOB.default_state nowadays. Probably because there's no point in having
instanced versions of a console that'll be the same for everyone. Just make sure
it's running GLOB and you'll be fine.

> I want to use more complex functionality in my machine, where should I start
> "looking?"

Hey look a question I'm better at answering. For a good example with just a
little bit of everything, check the `bin.dm` file here:

https://github.com/tgstation/tgstation/blob/68c8b71ae9d21e46c6f937eb96601e048de81ac6/code/modules/recycling/disposal/bin.dm

It's got everything from colored text, a functional bar showing pressure,
several buttons with on-off functionality, a better idea of sectioned off text
boxes and values, etc.

> JESUS CHRIST I HATE RUNNING THOSE 2 BATCH FILES

Then run Reload! Reload.bat lets you recompile JUST the tgui window components
without needing to even close your game window.

```
gulp --min && reload.bat
```

Thanks AnturK.
