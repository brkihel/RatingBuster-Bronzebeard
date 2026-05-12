# ✨ RatingBuster Ascension

> A BronzeBeard specific port of **RatingBuster** for the **World of Warcraft Ascension** client.

![WoW Version](https://img.shields.io/badge/WoW-Ascension%20BronzeBeard-blueviolet)
![Client Base](https://img.shields.io/badge/Client%20Base-WotLK%203.3.5a-informational)
![Addon Type](https://img.shields.io/badge/Addon-Tooltip%20Enhancement-success)
![Status](https://img.shields.io/badge/Status-Work%20in%20Progress-orange)

---

## 🧭 What is this?

**RatingBuster Ascension** is a fork/port of the classic **RatingBuster** addon, adapted for the **BronzeBeard Ascension** client.

BronzeBeard is based on **World of Warcraft 3.3.5a / Wrath of the Lich King**, but it is not a clean Blizzard 3.3.5a client. Ascension has custom systems, custom itemization, custom tooltips, and API behavior that can differ from both old WotLK and newer WoW clients.

So instead of simply copy-pasting an old addon and hoping it works, this fork aims to make RatingBuster more:

- 🛡️ Defensive
- 🧩 Modular
- 🔍 Debuggable
- 🧠 Ascension-aware
- 🧪 Easier to test and expand

The goal is simple:

> Make item tooltips easier to understand, especially when the game throws a pile of ratings, stats, gems, enchants, and custom itemization at you.

---

## ⚔️ What does RatingBuster do?

RatingBuster enhances item tooltips by converting raw item stats into values that are easier to understand while playing.

Instead of looking at something like this:

```txt
+37 Hit Rating
+42 Critical Strike Rating
+51 Agility
```

You can get extra information like:

```txt
+37 Hit Rating = +1.13% Hit
+42 Crit Rating = +0.91% Crit
+51 Agility = Crit, Dodge, Armor and other derived values
```

Less calculator. More playing.

---

## 🧮 Main Features

### ✅ Rating Conversion

Converts combat ratings into practical percentages or derived values:

| Rating | Converted Into |
|---|---|
| Hit Rating | Hit % |
| Spell Hit Rating | Spell Hit % |
| Critical Strike Rating | Crit % |
| Spell Critical Strike Rating | Spell Crit % |
| Haste Rating | Haste % |
| Spell Haste Rating | Spell Haste % |
| Expertise Rating | Expertise / Dodge & Parry reduction |
| Defense Rating | Defense Skill |
| Dodge Rating | Dodge % |
| Parry Rating | Parry % |
| Block Rating | Block % |
| Resilience Rating | Resilience effects |
| Armor Penetration Rating | Armor Penetration % |

---

### 💪 Primary Stat Breakdown

Breaks primary stats into useful derived values:

| Stat | Possible Derived Values |
|---|---|
| Strength | Attack Power, Block Value |
| Agility | Crit, Dodge, Armor, Attack Power, Ranged Attack Power |
| Stamina | Health |
| Intellect | Mana, Spell Crit, Mana Regen |
| Spirit | Mana Regen, Health Regen |

Exact values may depend on class, level, talents, and Ascension-specific behavior.

---

### 📊 Item Summary

The addon can summarize an item into more meaningful totals, for example:

```txt
Summary:
Attack Power: +40
Crit: +0.81%
Hit: +0.98%
Health: +300
Mana: +150
```

This makes it easier to compare gear at a glance instead of mentally converting every single line.

---

### ⚖️ Equipped Item Comparison

RatingBuster Ascension aims to compare the hovered item against your currently equipped item.

Example:

```txt
Compared to equipped:
Attack Power: +24
Crit: +0.42%
Hit: -0.31%
Health: +100
```

Special cases such as rings, trinkets, one-handed weapons, off-hands, shields, and two-handed weapons may require extra handling and testing because item comparison can get messy fast.

---

## 🛠️ Commands

Main slash commands:

```txt
/rba
/ratingbusterascension
```

Useful commands:

```txt
/rba help
/rba debug on
/rba debug off
/rba dump
/rba scan
/rba reset
```

---

## 🔍 Debug Mode

Debug mode is one of the most important parts of this port.

Because BronzeBeard can expose item data differently from stock 3.3.5a, the addon needs a way to inspect what the client is actually returning.

Debug output may include:

- Item link
- Item ID
- Item level
- `GetItemInfo` return values
- `GetItemStats` return values, if available
- Raw tooltip text
- Normalized stats
- Derived stats
- Final summary
- Equipped item comparison data

Example:

```txt
[RBA] Item: [Some Item]
[RBA] ItemID: 12345
[RBA] EquipSlot: INVTYPE_CHEST
[RBA] GetItemStats available: true
[RBA] Raw stat: ITEM_MOD_STRENGTH_SHORT = 20
[RBA] Normalized: STR = 20
[RBA] Derived: AP = 40
```

If something looks wrong, `/rba dump` is the first thing to check.

---


## ⚠️ Known Limitations

This fork may not be perfectly accurate for every Ascension-specific item or custom stat yet.

Possible limitations:

- Custom BronzeBeard stats may need manual mapping
- Some tooltip formats may not be parsed yet
- Avoidance calculations may initially use pre-diminishing-return values
- Some class-specific formulas may need adjustment
- Custom Ascension talents may affect final values in ways the addon cannot automatically detect
- Gem, enchant, and socket parsing may need extra testing depending on client behavior

This is expected for a custom client port.

---

## 🧰 Development Notes

When testing new items, use:

```txt
/rba debug on
/rba dump
```

Recommended first test items:

- Simple Strength/Stamina item
- Agility item
- Hit Rating item
- Crit Rating item
- Haste Rating item
- Expertise item
- Defense/Dodge/Parry/Block item
- Ring
- Trinket
- One-hand weapon
- Two-hand weapon
- Shield or off-hand
- Gemmed item
- Enchanted item

For each item, verify:

```txt
Item link detected
Item ID detected
Item level detected
Raw stats detected
Stats normalized correctly
Rating conversion looks sane
Tooltip lines do not duplicate
Comparison does not crash
```

---

## 🤝 Contributing

Contributions are welcome.

Useful contributions include:

- BronzeBeard tooltip samples
- Custom stat mappings
- Formula corrections
- Class-specific stat behavior
- Bug reports with `/rba dump` output
- Fixes for item comparison edge cases
- Localization improvements
- Cleaner UI/config work

When reporting a bug, please include:

```txt
Character class
Character level
Item link
Screenshot of the tooltip
/rba dump output
Any Lua error text
```

That makes debugging much faster.

---

## 🙏 Credits

Original RatingBuster concept and addon by the original RatingBuster authors and maintainers.

This fork exists to make the addon usable and maintainable on **BronzeBeard Ascension**.

Big thanks to the Ascension addon/dev community for keeping weird old-client addon development alive.

---

## 💬 Final Note

This addon is here to answer a very simple question:

> “Is this item actually better for me?”

Sometimes the answer is obvious.

Sometimes the answer is buried under five ratings, two sockets, a weird enchant, and Ascension being Ascension.

That second case is why this fork exists.
