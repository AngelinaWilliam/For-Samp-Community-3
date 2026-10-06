# 🧪 Demo

The demo shows how `omp_str.inc` can simplify common string operations in an SA-MP / open.mp gamemode.

Use:

```pawn
/stringdemo
```

The demo performs several operations on a realistic server string:

* Measures the string length
* Searches for specific text
* Compares strings
* Removes unnecessary whitespace
* Replaces text

### Example

```pawn
CMD:stringdemo(playerid, params[])
{
    new text[] = "  Cavite Town Roleplay  ";
    new buffer[144];

    SendClientMessage(playerid, 0x00FFFFAA, "=== omp_str String Demo ===");

    format(buffer, sizeof(buffer), "Original: \"%s\"", text);
    SendClientMessage(playerid, -1, buffer);

    format(buffer, sizeof(buffer), "Length: %d characters", str_len(text));
    SendClientMessage(playerid, -1, buffer);

    if(str_contains(text, "Town"))
        SendClientMessage(playerid, 0x33FF33FF, "Search: \"Town\" was FOUND.");
    else
        SendClientMessage(playerid, 0xFF3333FF, "Search: \"Town\" was NOT FOUND.");

    if(str_equals(text, "Cavite Town Roleplay"))
        SendClientMessage(playerid, 0x33FF33FF, "Compare: Strings are EQUAL.");
    else
        SendClientMessage(playerid, 0xFFCC33FF, "Compare: Strings are DIFFERENT.");

    str_trim(text);
    format(buffer, sizeof(buffer), "Trimmed: \"%s\"", text);
    SendClientMessage(playerid, -1, buffer);

    str_replace(text, "Cavite", "Manila", buffer, sizeof(buffer));
    format(buffer, sizeof(buffer), "Replaced: \"%s\"", buffer);
    SendClientMessage(playerid, -1, buffer);

    return 1;
}
```

### In-game result

```text
=== omp_str String Demo ===
Original: "  Cavite Town Roleplay  "
Length: 23 characters
Search: "Town" was FOUND.
Compare: Strings are DIFFERENT.
Trimmed: "Cavite Town Roleplay"
Replaced: "Manila Town Roleplay"
```

The demo is intentionally simple: developers can immediately see what each string operation does without needing to understand the implementation behind it.

---

# ✨ Benefits

## 🧹 Cleaner String Handling

`omp_str.inc` provides reusable helpers for common string operations.

Instead of repeatedly writing your own string-processing logic, you can use simple functions:

```pawn
str_trim(text);
str_replace(text, "Cavite", "Manila", buffer, sizeof(buffer));
```

This keeps your gamemode easier to read and maintain.

---

## ⚡ Less Repetitive Code

String processing is something almost every gamemode needs.

For example:

* Player names
* Commands
* Dialog input
* Chat messages
* Character names
* Vehicle names
* Item names
* Database results
* Configuration values

Having reusable helpers means you don't need to implement the same operations again and again.

---

## 🔎 Easy Text Searching

Checking whether a string contains specific text becomes straightforward:

```pawn
if(str_contains(text, "Town"))
{
    // Found
}
```

This can be useful for:

* Command validation
* Name checking
* Chat filters
* Item searches
* Vehicle searches
* Admin tools
* Database data validation

---

## 🧠 Easier to Read

Compare complicated manual string logic with a descriptive helper:

```pawn
if(str_contains(playerName, "Admin"))
{
    // ...
}
```

The intention is immediately clear.

A developer reading your code doesn't need to figure out what several lines of string manipulation are doing.

---

## 🛡️ Safer String Operations

The utility functions are designed to make common string operations easier to perform while keeping buffer handling in mind.

For example:

```pawn
str_replace(text, "Old", "New", buffer, sizeof(buffer));
```

The destination buffer size is explicitly provided, making the intended output capacity clear.

---

## 🧩 Great for Modular Gamemodes

`omp_str.inc` works well in large modular projects.

You can use it inside systems such as:

```text
modules/
├── character/
├── inventory/
├── vehicles/
├── commands/
├── phone/
└── admin/
```

Each module can use the same string utilities instead of maintaining its own collection of string helpers.

---

# 🎮 Real-World Server Uses

### 👤 Character System

Clean and validate character names.

```pawn
str_trim(name);
```

### 💬 Chat System

Search or process message content.

```pawn
if(str_contains(message, "hello"))
{
    // ...
}
```

### 🎒 Inventory

Search item names.

```pawn
if(str_contains(itemName, search))
{
    // Item matched
}
```

### 🚗 Vehicle System

Process vehicle names and labels.

```pawn
str_replace(vehicleName, "_", " ", buffer, sizeof(buffer));
```

### ⚙️ Admin System

Compare input against expected values.

```pawn
if(str_equals(option, "vehicle"))
{
    // ...
}
```

### 📱 Phone System

Process usernames, messages, contacts, and other text data.

---

# 📚 Available Utilities

The library provides reusable helpers for common string-related tasks such as:

| Utility        | Purpose                       |
| -------------- | ----------------------------- |
| `str_len`      | Get string length             |
| `str_contains` | Search for text               |
| `str_equals`   | Compare strings               |
| `str_trim`     | Remove unnecessary whitespace |
| `str_replace`  | Replace text                  |

Additional utilities may be available depending on the version of `omp_str.inc`.

---

# 🚀 Why `omp_str.inc`?

Pawn already provides basic string functions, but larger gamemodes often need the same operations repeatedly.

`omp_str.inc` focuses on making those operations:

**Simple → Readable → Reusable → Safer**

Instead of building string utilities from scratch for every project, include the library and use the helpers directly.

---

# 📦 Installation

Place:

```text
omp_str.inc
```

inside your Pawn `include` directory.

Then include it:

```pawn
#include <omp_str>
```

No additional plugin is required.

---

# 💻 Compatibility

* **open.mp** ✅
* **SA-MP** ✅
* **Pawn** ✅

Designed for both standalone scripts and large modular gamemodes.

---

# ❤️ Contributing

Contributions, improvements, bug reports, and suggestions are welcome.

If you find an issue or have an idea for another useful string utility, feel free to open an issue or submit a pull request.

---

## ⭐ Support

If `omp_str.inc` helps your project, consider giving the repository a ⭐.

Made for the **SA-MP / open.mp Pawn community**.
