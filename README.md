# Galah
  
Galah is a lovingly hand crafted Swift game engine for PC, Mac, Linux, and mobile. It's designed for videogame zinesters, dreamers, bedroom coders, indies, game designers, housewives, and everyone else! It's also designed to be useable, fast, and portable. It's free and open source and built with love. ❤︎

## What works
  *Check out the develop branch to see the actual code! Master will just be used for milestone releases.*
- Not that much yet. Workin' on getting the core architecture going. 
  
## What's envisioned

(From easier to hard / lower prio / time consuming)

- Initial support for PC, Mac, Linux, and mobile. 
- 2D with sprite batching, atlasing, and custom materials
- Write shaders in HLSL. (SPIR-V Cross)
- Easy to use UI layer. 
- Forward rendering pipeline
- Input layer for keyboard, touchscreens, and gamepads. 
- 2D physics with Liquidfun, ported to fit Galah.
- 3D physics with PhysX. 
- 3D Audio, and one day, support for MOD files?
- An editor, built on top of Galah's own tech. 

## The nerdy stuff:
A proof of concept for a fast, multiplatform, component based game engine written in Swift. The eventual grand plan is to have DirectX12, Vulkan, and Metal rendering backends, which means this game engine should hopefully compile on a lot of different platforms.

Galah is an attempt to wed the concepts of DOD and OOP in one (sometimes internally horrifying) package. The idea is to expose a conventional component based game engine API to end users. This means no dealing with lower level drama like manual memory management and the like, and of course there's no garbage collector to hitch your game to death, either.  :)

Internally, Galah tries to follow DOD principles as much as possible whilst fitting the external API & architecture. This means pretty much everything that makes sense is allocated in contiguous buffers for fast iteration, every internal ref type is unsafe, unowned (and there's pointers everywhere), there's a job system to hopefully facilitate concurrency with our components, and, generally, Galah is designed and built on most modern game engine design principles that I'm aware of. The idea is to expose 'normal' Swift as a language to the end users in a minimalist API whilst using a much more fast mix of unsafe Swift and C internally. 

There will also be lots of attention placed to the usual problems on the rendering side like spatial partitioning, culling, texture atlasing, material batching, blah blah. The idea is to write something modern, and future proof. 

Finally, most places where an OS API is accessed are wrapped. For portability. 
