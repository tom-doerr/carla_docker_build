# What is it?
This project aims at making it easier to create the Carla Python eggs.

# Installation
Clone the Unreal Engine repository.
The `UnrealEngine` repository/folder needs to be inside of this repository, i.e. `[...]/carla_docker_build/UnrealEngine/`.
After this you can run `./build.sh` and it should create the Python eggs.

# Limitations
Currenlty only the eggs for Carla versions 0.9.3 - 0.9.9 are build.
It is not possible to create Python3.8 eggs, since Carla is not compatible with Python3.8.
