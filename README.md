# Galah

A WIP game engine in Swift, for PC, Mac, Linux, and mobile. 

## Elevator pitch!

Galah is a lovingly hand crafted attempt to build a useable, fast, and portable game engine in Swift, for bedroom coders, indies, solo devs, game designers, and everyone else! It's free and open source and built with love. <3

Because it's an engine crafted for smaller teams Galah has been envisioned with strong, specialised design for both 2D and 3D games of any artstyle. No shoehorning your 2D game into a 3D engine here. 

## The envisioned features:

(From easier to hard/time consuming)

- It's Swift! It's fast and popular. No more learning obscure scripting languages or weird bindings. 
- A modern, fast, hitch free core. No garbage collector. :)
- Free and open source.
- Minimalist API that is easy to learn and fun to use. 
- Both 2D and 3D first. If you're writing a 2D game, you won't need 3D vectors or any of that.
- Write shaders in HLSL, build your own materials. (SPIR-V Cross)
- Easy to use UI layer. 
- Physics with Liquidfun, ported to fit Galah. 
- Initial support for PC, Mac, Linux, and mobile. 
- 3D Audio, and one day, support for MOD files?
- An editor, built on top of Galah's own tech. 

## The nerdy stuff:
A proof of concept for a fast, multiplatform, component based game engine written in Swift. The eventual grand plan is to have DirectX12, Vulkan, and Metal rendering backends, which means this game engine should hopefully compile on a lot of different platforms.

Galah is an attempt to wed the concepts of DOD and OOP in one (sometimes internally horrifying) package. The idea is to expose a conventional component based game engine API to end users. This means no dealing with lower level drama like manual memory management and the like, and of course there's no garbage collector to hitch your game to death, either.  :)

Internally, Galah tries to follow DOD principles as much as possible whilst fitting the external API & architecture. This means pretty much everything that makes sense is allocated in contiguous buffers for fast iteration, every internal ref type is unsafe, unowned (and there's pointers everywhere), there's a job system to hopefully facilitate concurrency with our components, and, generally, Galah is designed and built on most modern game engine design principles that I'm aware of. The idea is to expose 'normal' Swift as a language to the end users in a minimalist API whilst using a much more fast mix of unsafe Swift and C internally. 

There will also be lots of attention placed to the usual problems on the rendering side like spatial partitioning, culling, texture atlasing, material batching, blah blah. The idea is to write something modern, and future proof. 

Finally, most places where an OS API is accessed are wrapped. For portability. 

## The dose of reality:
At the moment this is a bit of a fun toy for me to fiddle with, and it's just a hobby I can spend time on here and there. I'm just one little person trying to build a big fancy thing and the implementation in places may be subpar or completely missing due to lack of time, or just a lack of foresight. This is partly also a testbed for me to learn new things (like Swift!) or try out ideas which means development time is slow and often goes in circles. 

Or, put another way, this game engine probably won't be usable for anything serious for a while, if not ever. Hopefully this changes and this will one day be useful to someone, but in the meantime, this is really just an amorphous blob of code that is at best just poached for chunks of its tech or for ideas. Maybe one day I'll finally write the rendering backend for this! xD

Check the develop branch where all the action is happening (will probably use master for milestone commits at some point).
