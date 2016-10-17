
# Special attacks

## Features

[Youtube video](https://youtu.be/uQhNLrtVprk)

- `CastSpecialAttack(string sAtkScript, location lLoc, float fDelay, int nShape, float fRange, float fWidth = 0.0)`
    + Allows to cast special attacks from script
    + `sAtkScript` is a custom script you can write (see [specatk_godhammer](specatk_godhammer.nss))
    + See [specatk_inc](specatk_inc.nss) for more info
- Special attack shapes:
    + None: `sAtkScript` won't be called for nearby creatures
    + Circle: Affects anybody in a circle of custom radius
    + Line: Affects anybody in a rectangle of custom size
    + Cone: Affects anybody in a cone shape of custom radius & angle
        * Note: cone angle can be > 180 deg
- Automatically calls the script with the damage event on any creature in the shape.


## Install

Just copy all files starting with `specatk_` into your module repertory (or mod file using an ERF tool)

Feel free to move `sef`, `bbx` and `tga` files into a custom hak instead of the module itself.

__Don't forget to build scripts :wink:__


## Examples / use

- Example attack scripts:
    + Circle shape: [specatk_godhammer](specatk_godhammer.nss)
    + Line shape: [specatk_line_lightning](specatk_line_lightning.nss)
    + Cone shape: [specatk_cone_fire](specatk_cone_fire.nss)
- Library:
    + [specatk_inc](specatk_inc.nss)
