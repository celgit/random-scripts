# Random Class Dice

Minimal WoW Classic addon that rolls your next class after you level up and reach a rested area.

## Install

Copy the `RandomClassOracle` folder to your WoW Classic addons folder:

```text
World of Warcraft/_classic_era_/Interface/AddOns/RandomClassOracle
```

If you are using another Classic client flavor, use that client's `Interface/AddOns` folder instead.

## Commands

```text
/rcd roll
/rcd testding
/rcd testdeath
/rcd show
/rcd status
/rcd sound
/rcd reset
```

`/rcd roll` manually rolls a faction-aware class and shows the result window. It only works in a rested area.

`/rcd testding` previews the level-up prompt without changing pending state.

`/rcd testdeath` previews the hardcore death prompt without changing pending state.

Death-triggered rolls exclude the class you died on. Level-up and manual rested rolls can still choose your current class.

`/rcd show` opens the result window.

`/rcd status` prints whether a level-up prompt is pending, whether WoW currently reports that you are in a rested area, the current rest state, and your zone/subzone.

`/rcd sound` toggles result sounds on or off.

`/rcd reset` clears recent rolls and any pending level-up prompt.
