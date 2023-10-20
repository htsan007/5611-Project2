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
**Screen Captures**
-
Cloth: <img src="./docs/assets/gamestart.JPG" width="200" height="300">

Fluid: <img src="./docs/assets/gamestart.JPG" width="200" height="300">

*Source code:*
<a href= "CSCI5611_Project_1.pde" Cloth code>Download Game Code</a>
<a href= "CSCI5611_Project_1.pde" Fluid code>Download Game Code</a>

Give credits here, sources, blah blah blah



