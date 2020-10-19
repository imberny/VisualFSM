# VisualFSM

A visual finite state machine editor plugin for Godot.

## Features

- Visualize and edit your finite state machines with this intuitive editor.
- Event-based transitions to simplify your states' logic.
- Use prebuilt events to trigger transitions, or script your own.
- Minimal setup required. Just add a VisualFSM node below the node you want controlled!

## Planned features

- [ ] Hierarchical state machine. Turn a state into an FSM.
- [ ] Unit tests.
- [ ] Allow duplication of finite state machine resource when copying VisualFSM node.

## Why another FSM plugin for Godot?

Managing transitions between states can easily become a pain, especially if when you have to trigger transitions manually through code, like the other FSM plugins do. I wanted a tool that would allow to view your FSM at a glance and identify potential problems. This plugin offers an intuitive editor based on GraphEdit. Furthermore, transitions are handled by the FSM, not the states, reducing the complexity of the states' scripts.

It does not generate new files or folders. The FSM, including your custom state and event scripts, is saved as a resource inside the VisualFSM node. I tried to make this plugin be a "model Godot citizen", making it feel as though it's part of the base editor.

## Links

Primer on finite state machines and their uses in games: https://gameprogrammingpatterns.com/state.html

The finite state machine implementation was inspired by [this article](https://www.codeproject.com/Articles/1087619/State-Machine-Design-in-Cplusplus-2).
