# Galah Design

## Core Design:

- A data oriented, multiplatform game engine, written in Swift. Some low level functionality is written in C so that it may interface with renderers and other platform specific code that will also be written in C/C++/Objective-C. 
- In order to really embrace the 'data oriented' philosophy, Galah will be written with an ECS framework as its core architecture, and the renderer, physics, and other subsystems will be built to work using this same ECS framework. In Galah, everything is ECS. 
- In Swift, 'data oriented' can only really be achieved with structs, therefore, Galah's design will centre structs and protocol based programming. Only some core Swift (singleton) systems will be written as classes. 
  
## ECS (or node component system):

Note that in Galah, 'Entities' are referred to as 'Nodes'. 

- Node Archetypes
- Node tagging system
- Node hierarchy system
- Systems
- Pipelines and Pipeline Stages
- Systems can be assigned to a pipeline. 
- Pipelines can be run sequentially or simultaneously?

