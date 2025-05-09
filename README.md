# Trash Masters

---

## Tasks:
- [ ] Add attributes
  - HP
  - Armor
  - Damage(Maybe this should be tied to items? Maybe this is just a multiplier?)
  - Walk Speed
  - Sprint Speed
  - Jump strength
  - Jump air control
- [ ] Implement Abilities using GAS:
  - Movement abilities (Not sure if these should be abilities realistically, but we'll go with it for now):
    - [x] Jumping
    - [x] Crouching 
    - [x] Sprinting
    - [ ] Sliding
    - [ ] Vaulting
  - Interaction abilities
    - [ ] Use Primary
    - [ ] Use Secondary
    - [ ] Interact
- [ ] Move abilities to C++
- [ ] Create base interaction system
- [ ] Basic enemy AI using StateTrees
- [ ] Steam multiplayer & lobby
- [ ] Level transitions
- [ ] Level "generation"
  - I don't want to do full-blown procedural level generation, mostly looking for placemen of items, enemies, and traps.
- [ ] Crafting system
  - Item in left hand + item in right hand = new item
- [ ] Trash bag item
  - Stores items in LIFO order
  - Held in hand, when used on and item on floor picks it up, when used without looking at item drops last item placed in.