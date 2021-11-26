# piconoc
## PICO-8 + Nature of Code + ECS = piconoc.
Emergent ecosystem behaviors for agents in Pico-8.  Based on Daniel Schiffman's "Nature of Code". Uses Entity Component Systems.

Hi!  I want to simulate flies and frogs and lizards and spaceships and such in PICO-8.  And I want to do so in ways that give surprising results.  PLUS I want to refine my understanding of Entity Component Systems (ECS).  This repo holds my efforts to do all those things.  

This is a learning project in process: bulky, proof-of-concept level programming.  An optimized version suitable for projects will be released upon completion.

Play in browser here: https://www.lexaloffle.com/bbs/?tid=45052

## Instructions
There are two main files, both using the same libraries but with different goals.

PICONOC.P8 is a proof-of-concept file, where I develop the various functions and show how they work with diagnostic diagrams.  (e.g. see how vectors allow objects to be aware of each other's locations.)

ECOSYSTEM.P8 is a sample environment that uses all the functions together to simulate life-like behaviors. (e.g. Build a frog that wants to hunt for flies.)

Examine piconoc.p8 and fiddle with the debug settings if you want to see how the functions work.
Examine ecosystem.p8 and create your own data models for critters if you want to enjoy the emergent behaviors that the functions provide.

## Nature of Code
Daniel Schiffman has a fantastic video series (and a free online book!) called Nature of Code (https://natureofcode.com) that explains how to do this in Processing.  Autonomous Agents and Cellular Automata are particularly interesting, but they depend on a lot of preliminary work with vectors and forces and things.  I'm translating that work into Pico-8.

This project is divided into chapters that follow the book.  These are in /libs. The code is liberally commented and played with in piconoc.p8 as proofs-of-concept.

Topics of interest (some, but not all implemented yet):
* Vectors (implemented!)
* Forces  (implemented!)
* Oscilations (in progress!)
* Particle systems
* Autonomous Agents
* Cellular Autonoma
... and such.

## Entity Component Systems (ECS)
piconoc uses the simple PECS system by Jess Telford (https://github.com/jesstelford/pecs).  

ECS gets around Pico-8's avoidance of proper objects in a really clever way.  Basically, if a table has a field that contains a particular type of data, like a position, then a system can be set up that acts on all that data in the same way.  Adding new, independently acting entities is as simple as creating a new entry in a table.  It seems a perfect fit for a project like this.

Each chapter has a related bestow() function.  Bestow_movement(), bestow_linear_physics(), bestow_angular_physics(), and so on as we go.  By applying these functions to a table, that table magically gains powers from that chapter in a standardized way.  This frees you up to focus on defining your game objects and not worrying about how they're going to deal with physics!  Behold the power of ECS!

## Ecosystem
By harnessing the systems that ECS makes possible with the emergent properties behind Nature of Code, I want to be able to create little ecosystems where virtual critters can live and interact without a lot of deliberate AI backing them up.  Some will be predators, some will be prey, others will just hang around.  

Critters in progress:
* flies
* frogs
* rabbits
* snakes

Run ecosystem.p8 in Pico-8 to see the results.  Or play in your browser at https://www.lexaloffle.com/bbs/?tid=45052 ) Hopefully you can tell which is which from their behaviors, since they are all simple dots, not pixel art.
