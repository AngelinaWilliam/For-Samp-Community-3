# ⚡ omp_bitflags.inc

A lightweight and efficient **bitflag utility for Pawn and open.mp**.

`omp_bitflags.inc` lets you store and manage multiple **ON/OFF states inside a single integer**, making it useful for player permissions, states, features, settings, and other boolean-style data.

Instead of creating many separate variables like:

```pawn
new bool:CanDrive[MAX_PLAYERS];
new bool:CanTrade[MAX_PLAYERS];
new bool:CanEnter[MAX_PLAYERS];
new bool:IsMuted[MAX_PLAYERS];
new bool:IsAdmin[MAX_PLAYERS];
```

You can group these states together:

```pawn
new PlayerFlags[MAX_PLAYERS];
```

And manage them using simple functions:

```pawn
OBit_Set(PlayerFlags[playerid], FLAG_CAN_DRIVE);
OBit_Set(PlayerFlags[playerid], FLAG_CAN_TRADE);
```

---

## ✨ Why Use Bitflags?

Bitflags are useful when your script needs to keep track of many **yes/no states**.

For example, an RP server may need to know whether a player:

* Can drive
* Can trade
* Can enter a restricted area
* Is muted
* Has a special permission
* Has a feature enabled
* Is currently in a specific state

Instead of maintaining a large collection of separate boolean variables, you can keep them inside one bitfield.

### Benefits

* 🚀 **Efficient** — multiple states can be stored in a compact value.
* 🧹 **Cleaner code** — related states can be grouped together.
* 📦 **Less variable clutter** — no need for dozens of separate boolean variables.
* ⚡ **Fast operations** — setting, clearing, and checking flags are simple bit operations.
* 🔧 **Easy to maintain** — adding a new flag doesn't require creating another variable.
* 🎮 **Great for gamemodes** — useful for permissions, player states, features, and settings.
* 📈 **Scalable** — `OBitArray` can be used when a single bitfield isn't enough.

---

# 🚀 Quick Start

Define the flags you want to use:

```pawn
#define FLAG_CAN_DRIVE  (1 << 0)
#define FLAG_CAN_TRADE  (1 << 1)
#define FLAG_CAN_ENTER  (1 << 2)
```

Create your bitfield:

```pawn
new PlayerFlags[MAX_PLAYERS];
```

Enable a flag:

```pawn
OBit_Set(PlayerFlags[playerid], FLAG_CAN_DRIVE);
```

Check it:

```pawn
if(OBit_IsSet(PlayerFlags[playerid], FLAG_CAN_DRIVE))
{
    SendClientMessage(playerid, -1, "You can drive.");
}
```

Disable it:

```pawn
OBit_Clear(PlayerFlags[playerid], FLAG_CAN_DRIVE);
```

That's it.

---

# 🎮 Real-World Example

Here's a simple example of using bitflags for player permissions:

```pawn
#define FLAG_CAN_DRIVE  (1 << 0)
#define FLAG_CAN_TRADE  (1 << 1)
#define FLAG_CAN_ENTER  (1 << 2)

new PlayerFlags[MAX_PLAYERS];

stock SetDefaultPlayerFlags(playerid)
{
    OBit_ClearAll(PlayerFlags[playerid]);

    OBit_Set(PlayerFlags[playerid], FLAG_CAN_DRIVE);
    OBit_Set(PlayerFlags[playerid], FLAG_CAN_TRADE);

    return 1;
}

stock CanPlayerDrive(playerid)
{
    return OBit_IsSet(PlayerFlags[playerid], FLAG_CAN_DRIVE);
}

stock CanPlayerTrade(playerid)
{
    return OBit_IsSet(PlayerFlags[playerid], FLAG_CAN_TRADE);
}

CMD:bitdemo(playerid, params[])
{
    SetDefaultPlayerFlags(playerid);

    if(CanPlayerDrive(playerid))
        SendClientMessage(playerid, -1, "Permission: You can drive.");

    if(CanPlayerTrade(playerid))
        SendClientMessage(playerid, -1, "Permission: You can trade.");

    if(!OBit_IsSet(PlayerFlags[playerid], FLAG_CAN_ENTER))
        SendClientMessage(playerid, -1, "Permission: You cannot enter yet.");

    return 1;
}
```

The important part is that all three permissions are stored inside:

```pawn
PlayerFlags[playerid]
```

You don't need a separate variable for every permission.

---

# 🧩 Available Functions

| Function        | What it does                          |
| --------------- | ------------------------------------- |
| `OBit_Set`      | Turns a flag ON                       |
| `OBit_Clear`    | Turns a flag OFF                      |
| `OBit_Toggle`   | Switches a flag ON/OFF                |
| `OBit_Get`      | Gets the value of a flag              |
| `OBit_IsSet`    | Checks if a flag is ON                |
| `OBit_Assign`   | Sets a flag to a specific value       |
| `OBit_ClearAll` | Turns all flags OFF                   |
| `OBit_Count`    | Counts active flags                   |
| `OBit_Any`      | Checks if at least one flag is active |

---

# 🔧 Common Operations

### Set a Flag

Turns a flag ON.

```pawn
OBit_Set(flags, FLAG_CAN_DRIVE);
```

### Clear a Flag

Turns a flag OFF.

```pawn
OBit_Clear(flags, FLAG_CAN_DRIVE);
```

### Toggle a Flag

If it's ON, it becomes OFF.
If it's OFF, it becomes ON.

```pawn
OBit_Toggle(flags, FLAG_CAN_DRIVE);
```

### Check a Flag

```pawn
if(OBit_IsSet(flags, FLAG_CAN_DRIVE))
{
    // Flag is active.
}
```

### Get a Flag Value

```pawn
new value = OBit_Get(flags, FLAG_CAN_DRIVE);
```

### Assign a Specific Value

```pawn
OBit_Assign(flags, FLAG_CAN_DRIVE, true);
```

### Clear Everything

Useful when resetting a player's state.

```pawn
OBit_ClearAll(flags);
```

### Count Active Flags

```pawn
new count = OBit_Count(flags);
```

### Check if Anything Is Active

```pawn
if(OBit_Any(flags))
{
    // At least one flag is active.
}
```

---

# 📦 OBitArray

When a single bitfield isn't enough, `omp_bitflags.inc` also provides:

```pawn
OBitArray:%0<%1>
```

The required number of cells can be determined with:

```pawn
OMP_BIT_CELLS
```

This is useful when you need to manage a larger collection of independent flags.

For example, this can be useful for systems with a large number of permissions, features, or states.

---

# 💡 Where Can You Use It?

`omp_bitflags.inc` can be useful in many parts of an open.mp gamemode.

### 👤 Player Permissions

```text
CAN_DRIVE
CAN_TRADE
CAN_USE_WEAPONS
CAN_ENTER
CAN_TALK
```

### 🛡️ Admin Permissions

```text
ADMIN_GOTO
ADMIN_KICK
ADMIN_BAN
ADMIN_JAIL
ADMIN_SPECTATE
```

### 🎮 Player States

```text
IS_MUTED
IS_HANDCUFFED
IS_TIED
IS_DEAD
IS_INJURED
```

### ⚙️ Features / Settings

```text
SHOW_HUD
SHOW_NAMES
VOICE_ENABLED
RADIO_ENABLED
PHONE_ENABLED
```

This makes bitflags especially useful for large roleplay gamemodes where many systems need simple ON/OFF states.

---

# 📊 Bitflags vs Multiple Booleans

Without bitflags:

```pawn
new bool:CanDrive[MAX_PLAYERS];
new bool:CanTrade[MAX_PLAYERS];
new bool:CanEnter[MAX_PLAYERS];
new bool:CanUsePhone[MAX_PLAYERS];
new bool:CanUseRadio[MAX_PLAYERS];
```

With bitflags:

```pawn
#define FLAG_CAN_DRIVE    (1 << 0)
#define FLAG_CAN_TRADE    (1 << 1)
#define FLAG_CAN_ENTER    (1 << 2)
#define FLAG_PHONE        (1 << 3)
#define FLAG_RADIO        (1 << 4)

new PlayerFlags[MAX_PLAYERS];
```

Then:

```pawn
OBit_Set(PlayerFlags[playerid], FLAG_PHONE);

if(OBit_IsSet(PlayerFlags[playerid], FLAG_PHONE))
{
    // Phone is enabled.
}
```

The result is a **compact and centralized way of managing many states**.

---

# 📋 API

`omp_bitflags.inc` provides:

| API                | Purpose                          |
| ------------------ | -------------------------------- |
| `OBit_Set`         | Set a specific bit               |
| `OBit_Clear`       | Clear a specific bit             |
| `OBit_Toggle`      | Toggle a specific bit            |
| `OBit_Get`         | Get a bit value                  |
| `OBit_IsSet`       | Check whether a bit is set       |
| `OBit_Assign`      | Assign a value to a bit          |
| `OBit_ClearAll`    | Clear all bits                   |
| `OBit_Count`       | Count active bits                |
| `OBit_Any`         | Check whether any bit is active  |
| `OBitArray:%0<%1>` | Create a larger bitflag array    |
| `OMP_BIT_CELLS`    | Calculate required bitflag cells |

---

# 📥 Installation

Place the include in your Pawn includes directory:

```text
pawno/include/omp_bitflags.inc
```

Then include it in your script:

```pawn
#include <omp_bitflags>
```

No plugin is required for the bitflag operations themselves.

---

# 🎯 Summary

`omp_bitflags.inc` is designed for situations where your gamemode needs to manage **many simple ON/OFF states efficiently**.

Instead of filling your script with individual boolean variables, you can group related states into bitflags and control them with a clean API:

```pawn
OBit_Set(...)
OBit_Clear(...)
OBit_Toggle(...)
OBit_IsSet(...)
```

It's particularly useful for **open.mp roleplay gamemodes, permission systems, player states, feature toggles, and configuration flags**.
