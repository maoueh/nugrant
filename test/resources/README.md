This readme give information on how to read resources file
that test merge possibilities.

Naming conventions
-----------------

The filename uses a specific convention:

    params_*kind*_*level*.[yml|json]

The kind is one of: [`current`|`user`|`system`] and defines which
responsibility they will hold. The order is `current` overrides
`user` overrides `system`.

Inside file, keys have special meaning. They define how
the overrides take place. We used the binary format
to represent each possibilities.

    key = "1.1.1"

Each element represent a specific kind. Read from left to
right, they are assigned to `current`, `user` and `system`
respectively.

So,

    `current`   `user`   `system`
       1    .  1   .   1

A 1 signify that the file kind *column* will have a key "1.1.1" set
to value *kind*. A 0 means the key is not set. With this in mind,
it is easy to reason about the value that will need to be asserted
for key "1.1.1" on level file *level*.

    # params_current_1.yml file
    "1.1.1": "current"

    # params_user_1.yml file
    "1.1.1": "user"

    # params_system_1.yml file
    "1.1.1": "system"

    # Value to assert
    assert("current", parameters.get("1.1.1"))

With the help of params_combinations, it is easy to create test file
either for other formats or for more level. Copy the all keys expect
"0.0.0" to the file. Say the file is of kind `current`, then for
column `current`, each time a one is there, replace `base` by the
kind (here `current`). The line that still have value base as the
value must be deleted.
