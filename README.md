# 5611-Project2


***Cloth simulation overview video:***
---
{% include youtube.html id="OI_T9T9jaNA" %}

---

**Cloth timestamps/list of attempted features:**
--
**Cloth simulation:** 0:00 - 0:26

I created a cloth simulation starting by defining a 50 x 50 mesh of nodes, and then connecting them with springs. In order to make it look like cloth when drawn, I drew triangles connecting between each point. The cloth is pinned along the top, and is affected by the force of gravity. It collides with the red ball object as it falls. The simulation can be started/stopped using the spacebar.

---
**3D simulation:** 0:27 - 0:52

The simulation scene is in 3D and includes a camera that can be repositioned with the 'wasd' keys. The view direction can be changed with the arrow keys.

---
**High-quality Rendering:** 0:54 - 1:09

For high-quality rendering I added lighting to the scene and also textured the cloth to look like a flag by giving each triangle vertex a corresponding texture coordinate.

---
**Cloth Difficulties:** 

A difficult part of implementing the cloth was adding the collision with the ball. Because the cloth nodes are just points, the distance when there is a collision between the ball and a point is simply the ball radius or less. However this seemed resulted in a cases where the cloth slightly phase into the ball instead of sliding off of it, or the triangles making up the cloth would become very sharp and distinct. I fixed this by adding a small constant to the collision detection and node repositioning distance, which provided enough leeway in distance to avoid these cases while still looking natural.

------
-----


***Fluid (SPH) simulation overview video:***
---
{% include youtube.html id="jDHRV6kOOW4" %}

----

**Timestamps and List of attempted features:**
---
**SPH Fluid simulation:** 0:00 - 0:31

I created the SPH Fluid simulation in 2D. There is a total 750 particles that are eventually added to the scene when the simulation is started. While the simulation is running the user is able to interact with the fluid particles using the left-click on the mouse. The simulation can be started/stopped using the spacebar.

---
**Larger Scene:** 0:06 - 0:31

I created a larger scene to look like a bathroom sink. There are visible white "sink" boundaries on the bottom half of the scene and the fluid will generate from the faucet head when started. After all the particles have been spawned, it will look as if the sink is full.

---
**User interaction:** 0:53 - 1:11

To interact with the fluid, the user can use the left-click on the mouse grab and move a chunk of particles. When the mouse-click is released the particles will also be released. 

---
**Color**: 1:12 - 1:25

The particles were colored to represent the total amount of pressure they are under. This forms a blue gradient across the particles, with dark blue being high pressure on the bottom, and light blue having low pressure on the top.

---
**Fluid Difficulties:**

I had some trouble at first with making the fluid flow realisticly. Everything was just moving too slowly and all my variables had to be very large for any movement to occur. It ended up being a scaling issue where the values were being misrepresented in the scene. To fix this I moved all the scene scaling to the draw function so that all the calculations done before that were independent from the scene scale. This made it so that the scene scale would only be applied when everything was ready to be displayed.

----
----
**Image Captures**
---

Cloth:
-

|Start screen:          | Mid simulation:          |Collision with ball:    | 
|-------------------------|-------------------------|-------------------------------------|
|<img src="./docs/assets/cloth start.JPG" width="300" height="300"> | <img src="./docs/assets/cloth mid scene.JPG" width="300" height="300"> |  <img src="./docs/assets/cloth collision.JPG" width="300" height="300">  |       

Fluid:
-

|Start screen:          | Mid simulation:          |After interaction:    | 
|-------------------------|-------------------------|-------------------------------------|
|<img src="./docs/assets/fluid start.JPG" width="300" height="300"> | <img src="./docs/assets/fluid mid.JPG" width="300" height="300"> |  <img src="./docs/assets/fluid interacting.JPG" width="300" height="300">  |          


*Source code:*

<a href= "/Cloth_code/CSCI5611_Proj2_3D_cloth.pde" download>Download cloth Code</a>

<a href= "/Fluid_code/CSCI5611_fluid_sim_2d.pde" download>Download fluid Code</a>

The cloth and fluid simulations were written by me. Included in them are the functionalities for each corresponding simulation, as well as a 2D/3D vector class if it was 2D or 3D. Both vector classes were modified based on Professor Guy's original version. I also made use of the provided camera.pde functionality that was provided from in class. The cloth simulation and SPH fluid simulation were written using Professor Guy's cloth/fluid slides and code examples as a basis. I also referenced  <a href="https://processing.org/reference/"> Processing documentation </a> to explore built-in functions and their functionalities regarding PImage, texturing, mouse/key input, etc.

The fluid simulation background texture was sourced from: <a href="https://www.vecteezy.com/photo/17154821-the-bathroom-faucet-is-turned-off-to-save-water-energy-and-protect-the-environment-water-saving-concept "> Vecteezy </a>

The cloth flag texture was sourced from: <a href="https://www.freepik.com/free-vector/illustration-usa-flag_2807790.htm#query=american%20flag&position=0&from_view=keyword&track=ais "> Freepik </a>

