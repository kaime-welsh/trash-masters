# Trash Masters

> A cooperative liminal sandbox game where you and up to 5 friends scramble around in the sewers, subways, and subterranean-tunnels scavenging for scraps to please the almighty "Trash Master".
> 
> Will you find the right garbage and descend deeper, or will you join the abandoned knick-knacks scattered around? 

## Roadmap

### MILESTONE #1: Gameplay Ability System (GAS) Integration

  - [ ] Base attributes:
    - [ ] HP
    - [ ] Armor
    - [ ] Damage
    - [ ] Walk Speed
    - [ ] Sprint Speed
    - [ ] Jump strength
  - [x] Movement abilities
    - [x] Jumping
    - [x] Crouching
    - [x] Sprinting
  - [ ] Interaction abilities
    - [ ] Use Primary (Left Hand/Click)
    - [ ] Use Secondary (Right Hand/Click)
    - [ ] Interact (E/X, interfaces with general interaction system)
      - [ ] Should also include holding E to carry props/items

### MILESTONE #2: Flesh out interation system and items

  - [ ] Create generic interection system
    - [ ] Stuck between creating an interaction component or just relying on a base "Prop" class that implements an interface, leaning towards the latter
  - [ ] Create basic interactive props:
    - [ ] Energy Drink: Gives a 45 second speed and jump boost, with 10 seconds of half speed debuff after. Stacks increase timer, stacks over 10 will kill you.
    - [ ] Gobbo-gun: Just a hand gun, has 6 rounds and is not reloadable.
    - [ ] Bat: It's a baseball bat.
    - [ ] Trash bag: When used while hovering a prop, stores that item in the back. When used while not hovering over a prop, drops last item in LIFO order.
  - [ ] Add some random garbage props to carry and throw
  - [ ] Basic crafting system:
    - Hold something in each hand, crouch and look at ground/third ingredient, then press left and right click to combine.
    - Example: Knife in one hand, stick in other, duct tape on ground = Spear

### MILESTONE #3: Multiplayer & UI
  - [ ] I plan on using steam, so get the Steam Online Subsystem setup
  - [ ] Create Lobby list UI as well as the UI for create lobbies
    - I'm thinkig a diagetic UI will be fun here, the lobby list will be inside an elevator in a subway, with each server being a floor button.
    - I would like to look into making join codes so you can punch the join code in on the elevator keypad
  - [ ] Handle steam invites
  - [ ] Pause menu and Settings menu integration

### MILESTONE #4: Make some goals

  - [ ] Create the "Trash Master", a large hooded figure that will assign each player a specific piece of garbage to look for.
    - The Trash Master should show the prop that is to be found as well as list the name
  - [ ] 3 Basic enemies to wander the map
    - I would like to learn StateTrees rather than behavior trees for this project, so that's what we're gonna do. Maybe I'll mix them both, we'll see.
  - [ ] 3 Traps to spawn randomly on the map
  - [ ] Implement the level "generation"
    - Level genreation just means randomly placing the props, monsters, and traps around.
    - Maybe as a stretch goal I'll add random map layouts, but it doesn't feel necessary.
  - [ ] Allow the player to continue to a new level after bring the assigned prop to the trash master.
  
### MILESTONE #5: Polish

  - [ ] This is where the art will be added, so meshes, audio, lighting setups, etc.
  - [ ] Also design three to five distinct levels to randomly pick from.
  - [ ] Stretch goal: add more props and enemies, that could be fun.
  - [ ] Release as demo on itch and steam.