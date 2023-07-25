# stabs-stretcher
FiveM QB-Core based stretcher script that works even when the player is dead.

# Performance:
## Client
- 0.0 ms idle
- 0.02 in use
## Server
- 0.02 while player is transitioning between last stand and dead
- 0 ms idle

# Installation
Put the folder `prop_Id_binbag_01` wherever you put your streamed assets. Feel free to rename it, just make sure you update the model's name in the config (must be a REPLACE prop)

# Requirements
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-ambulancejob](https://github.com/qbcore-framework/qb-ambulancejob)
- [qb-menu](https://github.com/qbcore-framework/qb-menu)
