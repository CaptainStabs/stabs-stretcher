# stabs-stretcher
FiveM QB-Core based stretcher script that works even when the player is dead.

# Performance:
## Client
- 0.0ms idle
- 0.02ms in use
## Server
- ~1ms while player is transitioning between last stand and dead
- 0ms idle

# Requirements
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-ambulancejob](https://github.com/qbcore-framework/qb-ambulancejob)
- [qb-menu](https://github.com/qbcore-framework/qb-menu)

# Model
Model is from [https://www.lcpdfr.com/downloads/dev-resources/vehicle-parts/17394-ambulance-stretcher-low-poly](https://www.lcpdfr.com/downloads/dev-resources/vehicle-parts/17394-ambulance-stretcher-low-poly/)


# Enable X while dead

`qb-ambulancejob/client/dead.lua` 

line 144

add 
```lua
            EnableControlAction(0, 32, true)
            EnableControlAction(0, 73, true)
```