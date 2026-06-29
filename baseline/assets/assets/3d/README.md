# 3D Measure Animations

Drop `.glb` files here named to match the `MeasureAnimationKind` enum:

- `ecg.glb` — heart rate (beating heart / ECG monitor)
- `pressure_cuff.glb` — blood pressure (inflating cuff)
- `thermometer.glb` — temperature (mercury rising)
- `sugar_drop.glb` — blood sugar (droplet + test strip)
- `pulse_ox.glb` — SpO₂ (finger clip sensor)
- `scale.glb` — BMI (body scale)
- `tape.glb` — waist (measuring tape)
- `sleep.glb` — sleep (moon / night scene)

Each `.glb` should:
1. Loop cleanly (start == end pose)
2. Be 2–4 seconds long
3. Have at least one animation track named (anything — first track plays by default)
4. Stay under ~2 MB for fast load

If a file is missing, the widget falls back to the 2D `MeasureAnimation` painter.

## Where to get .glb files (free)

- https://sketchfab.com — filter: Downloadable + CC License + Animated
- https://poly.pizza — CC0, some animated
- https://www.nih.gov/3d-print-exchange — medical models (static, would need animating in Blender)
- Make your own: Spline (spline.design, free) → export `.glb`
- AI-generated: meshy.ai, lumalabs.ai/genie
