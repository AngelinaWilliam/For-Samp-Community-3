# 🚀 Mineiga CMD, mDialog & Crashdetect Suite

![SA-MP](https://img.shields.io/badge/SA--MP-0.3.7-orange)
![open.mp](https://img.shields.io/badge/open.mp-Supported-blue)
![Pawn.CMD](https://img.shields.io/badge/Pawn.CMD-v3.3%2B-green)
![Crashdetect](https://img.shields.io/badge/Crashdetect-Plugin-red)
![License](https://img.shields.io/badge/License-MPL--2.0-brightgreen)

A collection of development utilities for **SA-MP 0.3.7** and **open.mp** servers, focused on command processing, dialog management, runtime debugging, and server-side development workflow improvements.

The suite combines **Mineiga_CMD**, **mDialog**, **Pawn.CMD**, and **Crashdetect** to provide a cleaner and more structured development environment while reducing the amount of repetitive code commonly required in traditional SA-MP gamemodes.

---

## ✨ Features

### 🧩 Mineiga_CMD — Command Processing

Mineiga_CMD is an extension layer built around **Pawn.CMD**, providing additional command-management and server-protection functionality.

#### Included Features

* Native-backed command processing
* Command aliases
* Global command flood protection
* Per-command cooldowns
* Player bypass support
* Command execution profiling
* Compatible with standard `CMD:` / `cmd:` command syntax
* Designed for SA-MP and open.mp environments

Example:

```pawn
cmd:heal(playerid, params[])
{
    SetPlayerHealth(playerid, 100.0);
    SendClientMessage(playerid, -1, "SUCCESS: Your health has been refilled!");
    return 1;
}
```

### Command Aliases

Create multiple aliases for a single command without duplicating command implementations.

```pawn
alias:heal("fixhp", "sethp");
```

This allows:

```text
/heal
/fixhp
/sethp
```

to route to the same command handler.

---

## 🛡️ Flood Protection & Cooldowns

Mineiga_CMD provides optional command protection mechanisms for servers that need to control command spam.

### Global Flood Guard

```pawn
public OnGameModeInit()
{
    // Maximum of 5 commands within 3 seconds.
    // Violations result in a temporary 5-second block.
    PC_SetFloodGuard(5, 3000, 5000);

    return 1;
}
```

### Per-Command Cooldown

```pawn
public OnGameModeInit()
{
    PC_SetCommandCooldown("heal", 10000);

    return 1;
}
```

The example above limits `/heal` to one successful execution every 10 seconds.

### Player Bypass

Administrative or trusted users can optionally bypass command protection:

```pawn
cmd:makeadmin(playerid, params[])
{
    PC_SetBypass(playerid, true);
    return 1;
}
```

> **Note:** Configure bypass behavior carefully. Automatically bypassing protection for large groups of players may reduce the effectiveness of flood protection.

---

# 🐛 Crashdetect — Runtime Debugging

**Crashdetect** provides runtime diagnostics and stack-trace information that can make debugging Pawn scripts significantly easier.

Instead of receiving only a generic runtime-error message, developers can use debug builds to identify the function and source location associated with an error.

### Example

```pawn
cmd:badcode(playerid, params[])
{
    new arr[5];

    arr[10] = 50;

    return 1;
}
```

With debugging information enabled, Crashdetect can report information similar to:

```text
[runtime error] Array index out of bounds (10 >= 5)
[stack trace]
#0 in public pc_cmd_badcode (playerid=0, params[]="") at gamemodes/main.pwn:142
```

This makes problems such as the following easier to investigate:

* Array index errors
* Invalid memory access
* Runtime errors
* Native-call failures
* Callback/function stack traces
* Script execution problems

### Debug Compilation

For detailed source-line information, compile your script with debugging information enabled:

```text
pawncc.exe main.pwn -d3 -Z+
```

> Crashdetect is a **debugging and diagnostic tool**. It does not guarantee that a server crash can be prevented.

---

# 💬 mDialog — Dynamic Dialog Management

mDialog provides a structured interface for managing SA-MP/open.mp dialogs without relying on large collections of manually assigned dialog IDs.

### Core Features

* Dynamic dialog ID management
* Named dialog handlers
* Reduced dialog ID collisions
* List dialog pagination
* Cleaner response handling
* Reusable dialog structures
* Improved organization for large gamemodes

### Example

```pawn
cmd:menu(playerid, params[])
{
    Dialog_Show(
        playerid,
        MainMenu,
        DIALOG_STYLE_LIST,
        "Server Menu",
        "1. Stat Profile\n2. Spawn Vehicle\n3. Help",
        "Select",
        "Cancel"
    );

    return 1;
}
```

The response can then be handled using a named dialog callback:

```pawn
Dialog:MainMenu(playerid, response, listitem, inputtext[])
{
    if (!response)
        return 1;

    switch (listitem)
    {
        case 0:
        {
            SendClientMessage(playerid, -1, "You selected Profile.");
        }

        case 1:
        {
            SendClientMessage(playerid, -1, "You selected Spawn Vehicle.");
        }

        case 2:
        {
            SendClientMessage(playerid, -1, "You selected Help.");
        }
    }

    return 1;
}
```

This avoids manually checking dialog IDs throughout `OnDialogResponse`.

---

# 📊 Feature Comparison

| Feature            | Traditional Approach                | Mineiga Suite                    |
| ------------------ | ----------------------------------- | -------------------------------- |
| Command Processing | Pawn-side command routing           | Native-backed command processing |
| Command Aliases    | Duplicate handlers / manual routing | Built-in alias support           |
| Flood Protection   | Custom timers & counters            | Optional built-in protection     |
| Command Cooldowns  | Custom implementation               | Global & per-command API         |
| Runtime Debugging  | Basic server logs                   | Crashdetect stack traces         |
| Source Line Errors | Difficult to locate                 | Debug line information           |
| Dialog IDs         | Manually assigned IDs               | Dynamic dialog management        |
| Dialog Pagination  | Custom implementation               | Built-in paginator support       |
| Dialog Responses   | Manual ID checks                    | Named dialog handlers            |
| Command Profiling  | Custom instrumentation              | Mineiga_CMD profiling API        |

---

# 📦 Installation

## 1. Install Required Plugins

Place the required plugin binaries inside your server's `plugins` directory.

### Windows

```text
plugins/
├── pawncmd.dll
└── crashdetect.dll
```

### Linux

```text
plugins/
├── pawncmd.so
└── crashdetect.so
```

---

## 2. Configure Your Server

### SA-MP `server.cfg`

```text
plugins pawncmd crashdetect
```

### open.mp

Add the corresponding plugins/components according to your open.mp server configuration.

> Plugin filenames and loading configuration may differ depending on your operating system and server distribution.

---

# 📚 Includes

Add the required includes to your Pawn project:

```pawn
#include <a_samp>
#include <crashdetect>
#include <Pawn.CMD>
#include <Mineiga_CMD>
#include <mdialog>
```

> Make sure the include files are available in your Pawn compiler's `include` directory.

---

# 📈 Command Profiling

Mineiga_CMD can provide command execution statistics through its profiling interface.

Example:

```text
---------- MineigaCMD Profile ----------
1. /heal       calls=142  total=12ms   avg=0.08ms  max=2ms
2. /stats      calls=98   total=8ms    avg=0.08ms  max=1ms
3. /inventory  calls=45   total=15ms   avg=0.33ms  max=4ms
----------------------------------------
```

Depending on the implementation and platform, profiling data can be used to identify commands that may require optimization.

Example:

```text
PC_PrintProfile();
```

> Performance results are environment-dependent. CPU, server load, command frequency, database operations, and other gamemode logic can significantly affect measured execution times.

---

# 🏗️ Architecture

The suite is designed around several specialized components:

```text
                    ┌──────────────────────┐
                    │      SA-MP / open.mp │
                    └──────────┬───────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
         ┌──────▼──────┐              ┌──────▼──────┐
         │  MineigaCMD │              │   mDialog   │
         └──────┬──────┘              └──────┬──────┘
                │                             │
         ┌──────▼──────┐              ┌──────▼──────┐
         │  Pawn.CMD   │              │   Dialog    │
         │ Command API │              │ Management  │
         └──────┬──────┘              └─────────────┘
                │
         ┌──────▼──────┐
         │  Native /   │
         │ Plugin Layer│
         └─────────────┘

                    ┌──────────────────────┐
                    │     Crashdetect     │
                    │ Runtime Diagnostics  │
                    └──────────────────────┘
```

Each component has a specific responsibility:

* **Mineiga_CMD** — command extensions and protection
* **Pawn.CMD** — command processing
* **mDialog** — dialog management
* **Crashdetect** — runtime diagnostics and debugging

---

# 🔧 Compatibility

| Platform    | Status      |
| ----------- | ----------- |
| SA-MP 0.3.7 | ✅ Supported |
| open.mp     | ✅ Supported |
| Pawn        | ✅ Required  |
| Pawn.CMD    | ✅ Required  |
| Crashdetect | ✅ Supported |
| Windows     | ✅           |
| Linux       | ✅           |

Actual compatibility may depend on the specific plugin/include versions being used by your server.

---

# 🧪 Development Status

This project is intended for developers working on **SA-MP** and **open.mp** gamemodes.

Features may evolve over time as the project is tested and improved.

If you encounter a bug:

1. Reproduce the issue.
2. Check the server console and Crashdetect output.
3. Include the relevant error or stack trace.
4. Provide the smallest possible code example that reproduces the problem.
5. Open an issue with the relevant environment information.

---

# 🤝 Contributing

Contributions are welcome.

Before submitting a pull request:

* Keep changes focused.
* Follow the existing code style.
* Avoid unrelated modifications.
* Test changes on a supported server environment.
* Document new public APIs.
* Include reproduction steps when fixing bugs.

For larger changes, opening an issue first is recommended so the proposed implementation can be discussed before development begins.

---

# 📜 Credits & Acknowledgments

This project builds upon the work of several members of the SA-MP/open.mp community.

### Crashdetect

**Zeex** — Creator and maintainer of Crashdetect.

Crashdetect is used for runtime diagnostics, error reporting, and stack tracing.

### ZCMD / Command Processing

**Zeex** — Original creator of ZCMD.

### Pawn.CMD

**urkq / Katyshev** — Developers of Pawn.CMD.

Pawn.CMD provides the command-processing foundation used by Mineiga_CMD.

### easyDialog

**Emmet_** — Creator of the original easyDialog library.

### mDialog

**Wildcard / PHOENIX** — Developers of the mDialog dynamic dialog engine.

### Mineiga_CMD

**Mineiga** — Developer of the Mineiga_CMD extension layer.

---

# 📄 License

This project is licensed under the **Mozilla Public License 2.0 (MPL-2.0)** unless otherwise specified by individual third-party components.

See the [`LICENSE`](LICENSE) file for the complete license text.

Third-party libraries, plugins, includes, and other components may be distributed under their respective licenses. Their original licenses and attribution requirements remain applicable.

---

# ⭐ Support the Project

If this project is useful to you:

* ⭐ Star the repository
* 🐛 Report bugs
* 💡 Suggest improvements
* 🔧 Submit pull requests
* 📖 Improve documentation

Every contribution helps improve the SA-MP/open.mp development ecosystem.

---

## 🚀 Mineiga Development Suite

**Built for developers.
Designed for cleaner gamemodes.
Made for SA-MP & open.mp.**
