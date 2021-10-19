# piconoc
## PICO-8 + Nature of Code + ECS = piconoc.
Emergent ecosystem behaviors for agents in Pico-8.  Based on Daniel Schiffman's "Nature of Code". Uses Entity Component Systems.

Hi!  I want to simulate flies and frogs and lizards and spaceships and such in PICO-8.  And I want to do so in ways that give surprising results.  PLUS I want to refine my understanding of Entity Component Systems (ECS).  This repo holds my efforts to do all those things.  This is a learning project in process.

## Nature of Code
Daniel Schiffman has a fantastic video series (and a free online book!) called Nature of Code (https://natureofcode.com) that explains how to do this in Processing.  Autonomous Agents and Cellular Automata are particularly interesting, but they depend on a lot of preliminary work with vectors and forces and things.  I'm translating that work into Pico-8.

This project is divided into chapters that follow the book.  These are in /libs. The code is liberally commented and played with in piconoc.p8 as proofs-of-concept.

Topics of interest (some, but not all implemented yet): 
* Vectors
* Forces
* Occilations
* Particle systems
* Autonomous Agents
* Cellular Autonoma
... and such.

## Entity Component Systems (ECS)
piconoc uses the simple PECS system by Jess Telford (https://github.com/jesstelford/pecs).  

ECS gets around Pico-8's avoidance of proper objects in a really clever way.  Basically, if a table has a field that contains a particular type of data, like a position, then a system can be set up that acts on all that data in the same way.  Adding new, independently acting entities is as simple as creating a new entry in a table.  It seems a perfect fit for a project like this.

## Ecosystem
By harnessing the systems that ECS makes possible with the emergent properties behind Nature of Code, I want to be able to create little ecosystems where virtual critters can live and interact.  

Run ecosystem.p8 in Pico-8 to see the result.
