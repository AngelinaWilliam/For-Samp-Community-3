# 📐 omp_math3d.inc

A lightweight 3D math and geometry utility include for **SA-MP / open.mp Pawn**.

`omp_math3d.inc` provides simple helpers for working with **3D coordinates, distances, directions, areas, points, and vectors** without having to write the same calculations repeatedly in your gamemode.

Designed for roleplay servers, gameplay systems, objects, vehicles, NPCs, interaction systems, zones, and other position-based mechanics.

---

## ✨ Features

* 📏 3D distance calculations
* 📍 2D distance calculations
* 🔵 Sphere/radius detection
* 📦 3D cuboid detection
* 👁️ Get a point in front of a player
* 📐 Calculate angles between points
* 🎯 Calculate points using an angle and distance
* 🟢 Midpoint calculations
* 🔄 Linear interpolation
* 🧭 Vector utilities
* ⚡ Lightweight and easy to integrate
* 🧩 Works well with modular gamemodes
* 🆓 Open-source

---

## 📦 Installation

Copy:

```text
omp_math3d.inc
```

to your Pawn include directory.

Then include it in your script:

```pawn
#include <omp_math3d>
```

No additional plugin is required.

---

# 🚀 Quick Example

Checking how far a player is from a location:

```pawn
new Float:x, Float:y, Float:z;

GetPlayerPos(playerid, x, y, z);

new Float:distance = M3D_Distance(x, y, z, 1520.0, -1700.0, 13.5);

printf("Distance: %.2f meters", distance);
```

---

# 🎮 Practical Examples

## 📏 Distance

Useful for checking how close two positions are.

```pawn
new Float:distance = M3D_Distance(x1, y1, z1, x2, y2, z2);
```

Example:

```pawn
if(M3D_Distance(px, py, pz, npcX, npcY, npcZ) <= 5.0)
{
    SendClientMessage(playerid, -1, "You are near the NPC.");
}
```

Perfect for:

* NPC interaction
* ATM systems
* Shops
* Doors
* Job locations
* Player proximity
* Object interaction

---

## 🔵 Sphere Detection

Check whether a player is inside a circular 3D radius.

```pawn
if(M3D_IsPlayerInSphere(playerid, x, y, z, 5.0))
{
    SendClientMessage(playerid, -1, "You are inside the interaction area.");
}
```

Example use:

```text
Player
   ↓
  ( 5m )
   ↓
[ ATM ]
```

This is useful when you want an interaction radius around something.

---

## 📦 Cuboid Detection

Check whether a player is inside a rectangular 3D area.

```pawn
if(M3D_IsPlayerInCuboid(playerid, minX, minY, minZ, maxX, maxY, maxZ))
{
    SendClientMessage(playerid, -1, "You are inside the area.");
}
```

Useful for:

* Buildings
* Warehouses
* Interiors
* Restricted areas
* Job zones
* Custom map areas

Unlike a sphere, a cuboid lets you define exact minimum and maximum coordinates.

---

# 👁️ Point In Front Of Player

Get the coordinates a certain distance in front of the player.

```pawn
new Float:x, Float:y, Float:z;

GetPointInFrontOfPlayer(playerid, 5.0, x, y, z);
```

For example, placing an object 3 meters in front of the player:

```pawn
new Float:x, Float:y, Float:z;

GetPointInFrontOfPlayer(playerid, 3.0, x, y, z);

CreateObject(1238, x, y, z, 0.0, 0.0, 0.0);
```

Useful for:

* Object placement
* Interaction points
* Props
* Furniture systems
* Building systems
* Target positions
* Gameplay mechanics

---

# 📐 Angle Between Points

Calculate the direction from one position to another.

```pawn
new Float:angle = M3D_GetAngleBetweenPoints(x1, y1, x2, y2);
```

Example:

```pawn
new Float:angle = M3D_GetAngleBetweenPoints(playerX, playerY, targetX, targetY);
```

This can be useful for systems where something needs to know **which direction another position is located**.

---

# 🎯 Point At Distance

Calculate a new position based on:

* Starting position
* Angle
* Distance

Example:

```pawn
new Float:x, Float:y;

M3D_GetPointAtAngle(startX, startY, angle, 10.0, x, y);
```

This is useful for:

* Object placement
* Vehicle positioning
* Spawn locations
* Circular formations
* Directional mechanics

---

# 🟢 Midpoint

Find the center between two positions.

```pawn
new Float:x, Float:y, Float:z;

M3D_GetMidpoint(x1, y1, z1, x2, y2, z2, x, y, z);
```

For example, finding the center between two objects:

```text
Object A -------- ● -------- Object B
                  ↑
               Midpoint
```

Useful for:

* Centering objects
* Map systems
* Two-player interactions
* UI/world markers
* Position calculations

---

# 🔄 Linear Interpolation

Move between two positions using a percentage.

```pawn
M3D_Lerp(startX, endX, 0.5);
```

`0.0` represents the start.

`1.0` represents the end.

`0.5` represents the middle.

This can be useful for:

* Smooth object movement
* Animations
* Position transitions
* Camera systems
* Moving world elements

---

# 🧭 Vector Utilities

`omp_math3d.inc` also provides vector-related helpers for more advanced systems.

These can be useful when working with:

* Direction
* Movement
* Facing
* Physics-style calculations
* Advanced object systems
* Raycast-style mechanics

Available helpers include vector operations such as:

```pawn
M3D_Dot(...)
M3D_Cross(...)
M3D_Normalize(...)
```

You don't need to use these for normal proximity or interaction systems. They are available when your project needs more advanced 3D calculations.

---

# 💡 Real Server Use Cases

`omp_math3d.inc` can be useful when creating systems such as:

### 🏧 ATM

```pawn
if(M3D_IsPlayerInSphere(playerid, atmX, atmY, atmZ, 2.0))
{
    // Open ATM
}
```

### 🚪 Door Interaction

```pawn
if(M3D_IsPlayerInSphere(playerid, doorX, doorY, doorZ, 2.5))
{
    // Open door
}
```

### 🏪 Shop

```pawn
if(M3D_IsPlayerInSphere(playerid, shopX, shopY, shopZ, 3.0))
{
    // Open shop
}
```

### 📦 Object Placement

```pawn
new Float:x, Float:y, Float:z;

GetPointInFrontOfPlayer(playerid, 2.0, x, y, z);
```

### 🚧 Restricted Area

```pawn
if(M3D_IsPlayerInCuboid(playerid, minX, minY, minZ, maxX, maxY, maxZ))
{
    // Player entered restricted area
}
```

---

# 🧪 Demo

A simple demo command can show the most useful features without requiring the developer to understand the underlying mathematics.

Example:

```pawn
CMD:mathdemo(playerid, params[])
{
    new Float:px, Float:py, Float:pz;
    new Float:fx, Float:fy, Float:fz;
    new message[144];

    GetPlayerPos(playerid, px, py, pz);

    new Float:distance = M3D_Distance(px, py, pz, DEMO_X, DEMO_Y, DEMO_Z);

    SendClientMessage(playerid, 0x00FFFFAA, "=== omp_math3d Demo ===");

    format(message, sizeof(message), "Distance to demo point: %.2f meters", distance);
    SendClientMessage(playerid, -1, message);

    if(M3D_IsPlayerInSphere(playerid, DEMO_X, DEMO_Y, DEMO_Z, 10.0))
        SendClientMessage(playerid, 0x33FF33FF, "Sphere: You are inside the 10m radius.");
    else
        SendClientMessage(playerid, 0xFF3333FF, "Sphere: You are outside the 10m radius.");

    GetPointInFrontOfPlayer(playerid, 5.0, fx, fy, fz);

    format(message, sizeof(message), "5m in front: %.2f, %.2f, %.2f", fx, fy, fz);
    SendClientMessage(playerid, 0xFFFFFFFF, message);

    return 1;
}
```

The goal of the demo is simple:

```text
=== omp_math3d Demo ===
Distance to demo point: 18.42 meters
Sphere: You are outside the 10m radius.
5m in front: 1542.22, -1721.51, 13.54
```

This lets developers immediately understand **what the include does in-game**.

---

# 📚 API

| Function                    | Description                                 |
| --------------------------- | ------------------------------------------- |
| `M3D_Distance`              | Calculate 3D distance                       |
| `M3D_Distance2D`            | Calculate 2D distance                       |
| `M3D_IsPlayerInSphere`      | Check player inside sphere                  |
| `M3D_IsPlayerInCuboid`      | Check player inside cuboid                  |
| `GetPointInFrontOfPlayer`   | Get position in front of player             |
| `M3D_GetAngleBetweenPoints` | Calculate direction/angle                   |
| `M3D_GetPointAtAngle`       | Calculate position using angle and distance |
| `M3D_GetMidpoint`           | Get midpoint between positions              |
| `M3D_Lerp`                  | Interpolate between values                  |
| `M3D_Dot`                   | Vector dot product                          |
| `M3D_Cross`                 | Vector cross product                        |
| `M3D_Normalize`             | Normalize a vector                          |

---

# ⚡ Why Use It?

Instead of repeatedly writing your own coordinate calculations:

```pawn
// Lots of repeated math
```

you can simply use:

```pawn
if(M3D_IsPlayerInSphere(playerid, x, y, z, 5.0))
{
    // Player is nearby
}
```

The goal is to make common 3D operations **shorter, cleaner, and easier to reuse**.

---

# 🛠️ Compatibility

* **open.mp** ✅
* **SA-MP** ✅
* **Pawn** ✅

Designed to work well with modular gamemodes and existing server systems.

---

# 📄 License

Open-source. See the repository license for details.

---

## ❤️ Contributing

Pull requests, improvements, bug reports, and suggestions are welcome.

If you find a bug or have an idea for a useful 3D utility, feel free to open an issue or submit a pull request.

---

## ⭐ Support

If this include is useful for your project, consider giving the repository a ⭐.

Made for the **SA-MP / open.mp Pawn community**.
