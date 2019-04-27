# Base Combat System

All units have a combination of HP, Attack, Defense, Move stats. It's simplistic but it worked for Sakura Taisen 1. All combat is melee for simplicity's sake. Damage formula TBD.

# Mana Colors

* Red mana represents offensive power.
* Blue mana represents defensive power.
* Green mana represents regenerative power.

(Not tied to any colors/ability names or whatever and all of this can be changed for aesthetic or flavor reasons)

# Units

There are two categories of units:

* **Basic units** are generic units with relatively low stats. Their color associates what mana color they can generate.
* **Hero units** are named characters of the world with a special ability.

# Mana Sacrifice System

To cast their special ability, hero units will need to pay a cost in colored mana. Colored mana can only be obtained by sacrificing a basic unit of that color.

Example special abilities include:

* **Double Strike (4x Red):** When attacking with Hero Unit, you attack twice.
* **Reflector Gate (2x Blue, 1x Red):** Half the damage taken is reflected back to the damage dealer.
* **Healing Aura (2x Green, 1x Blue):** At the start of your turn, Hero Unit gains 15% of their max health.
* **Hungering Blade (2x Red, 1x Green):** When attacking with Hero Unit, you gain health equal to half the damage you deal.

# Out of Scope Ideas

* **Roles tied to mana color:** Red units could be soldiers, blue units could be good defensive walls, and green units could be support characters.
* **Filter stations:** Maybe on some maps you spawn with characters that cannot cast any of your special abilities, and a capturable objective on the map can be used to change the mana color associated to a unit. With roles tied to color this might be a bit broken