# maplint
maplint is a tool that lets you prohibit anti-patterns in maps through simple rules. You can use maplint to do things like ban variable edits for specific types, ban specific variable edits, ban combinations of types, etc.

## Making lints

To create a lint, create a new file in the `lints` folder. Lints use [YAML](https://learnxinyminutes.com/docs/yaml/), which is very expressive, though can be a little complex. If you get stuck, read other lints in this folder.

### Typepaths
The root of the file is your typepaths. This will match not only that type, but also subtypes. For example:

```yml
/mob/dog:
  # We'll get to this...
```

...will define rules for `/mob/dog`, `/mob/dog/corgi`, `/mob/dog/beagle`, etc.

If you only want to match a specific typepath, prefix it with `=`. This:

```yml
=/mob/dog:
```

...will only match `/mob/dog` specifically.

Alternatively, if you want to match ALL types, enter a single `*`, for wildcard.

### `banned`
The simplest rule is to completely ban a subtype. To do this, fill with `banned: true`.

For example, this lint will ban `/mob/dog` and all subtypes:

```yml
/mob/dog:
  banned: true # Cats FTW
```

### `banned_neighbors`
If you want to ban other objects being on the same tile as another, you can specify `banned_neighbors`.

This takes a few forms. The simplest is just a list of types to not be next to. This lint will ban either cat_toy *or* cat_food (or their subtypes) from being on the same tile as a dog.

```yml
/mob/dog:
  banned_neighbors:
  - /obj/item/cat_toy
  - /obj/item/cat_food
```

This also supports the `=` format as specified before. This will ban `/mob/dog` being on the same tile as `/obj/item/toy` *only*.

```yml
/mob/dog:
  banned_neighbors:
  - =/obj/item/toy # Only the best toys for our dogs
```

Anything in this list will *not* include the object itself, meaning you can use it to make sure two of the same object are not on the same tile. For example, this lint will ban two dogs from being on the same tile:

```yml
/mob/dog:
  banned_neighbors:
  - /mob/dog # We're a space station, not a dog park!
```

However, you can add a bit more specificity with `identical: true`. This will prohibit other instances of the *exact* same type *and* variable edits from being on the same tile.

```yml
/mob/dog:
  banned_neighbors:
    # Purebreeds are unnatural! We're okay with dogs as long as they're different.
    /mob/dog: { identical: true }
```

Finally, if you need maximum precision, you can specify a [regular expression](https://en.wikipedia.org/wiki/Regular_expression) to match for a path. If we wanted to ban a `/mob/dog` from being on the same tile as `/obj/bowl/big/cat`, `/obj/bowl/small/cat`, etc, we can write:

```yml
/mob/dog:
  banned_neighbors:
    CAT_BOWLS: { pattern: ^/obj/bowl/.+/cat$ }
```

### `banned_variables`
To ban all variable edits, you can specify `banned_variables: true` for a typepath. For instance, if we want to block dogs from getting any var-edits, we can write:

```yml
/mob/dog:
  banned_variables: true # No var edits, no matter what
```

If we want to be more specific, we can write out the specific variables we want to ban.

```yml
/mob/dog
  banned_variables:
  - species # Don't var-edit species, use the subtypes
```

We can also explicitly create allowlists and denylists of values through `allow` and `deny`. For example, if we want to make sure we're not creating invalid bowls for animals, we can write:

```yml
/obj/bowl/dog:
  banned_variables:
    species:
      # If we specify a species, it's gotta be a dog
      allow: ["beagle", "corgi", "pomeranian"]

/obj/bowl/humans:
  banned_variables:
    species:
      # We're civilized, we don't want to eat from the same bowl that's var-edited for animals
      deny: ["cats", "dogs"]
```

Similar to [banned_neighbors](#banned_neighbors), you can specify a regular expression pattern for allow/deny.

```yml
/mob/dog:
  banned_variables:
    # Names must start with a capital letter
    name:
      allow: { pattern: '^[A-Z].*$' }
```

### `help`
If you want a custom message to go with your lint, you can specify "help" in the root.

```yml
help: Pugs haven't existed on Sol since 2450.
/mob/dog/pug:
  banned: true
```
