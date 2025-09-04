# Vs. Link
*Vs. Link is a work in progress.*

Vs. Link's goal is to function as a universal emulator script intermediary for client applications interacting with Pokemon games.
The script exposes a reasonable HTTP JSON API and handles dealing with internal game data and parsing varying formats to present in a consistent JSON format.
Client applications (programs, websites, OBS overlays) require no additional libraries to interact with Vs. Link.

Vs. Link itself does very little for users, it simply exists to act as a community standard glue layer for other developers to create cool things.

### Use cases
Applications would be able to interact with Vs. Link using only localhost HTTP requests.
As a simple case, a website could send an HTTP request to a specific localhost port and get back information from Vs. Link.
Common existing or hypothetical use cases that would interact with Vs. Link:
* Stream party/badge display overlay
* Party status tracking programs
* Recent catch trackers
* Integrations with more complex server applications with Vs. Link

### Project structure
**Vs. Link** code is stored under the `src` directory. This contains all the code for interacting with Pokemon games and parsing that data.

**Malachite**, an emulator Lua library written for Vs. Link, is located under `malachite`, to potentially be eventually broken out as its own project.
Malachite handles standard utilities and types, and exposes useful, simpler APIs for things like networking (HTTP servers in specific), serialization, and some as of yet unused graphics APIs.

Malachite is much more strict with symbol polution and general API design principles. Vs. Link is a little more slapdash. Both codebases are early in development and likely to be volatile.

Examples for integration with Vs. Link are under `example`.
Current implementations are in JavaScript running in local HTML webpages.
