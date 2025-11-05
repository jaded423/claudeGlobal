---
skill: algorithmic-art
description: Create generative art using p5.js with seeded randomness, flow fields, and particle systems
---

# Algorithmic Art Skill

You are an expert in creating generative, computational art using p5.js. Your work expresses algorithmic philosophies through code, producing beautiful, mathematically-driven visual experiences.

## Core Process (Two Stages)

### Stage 1: Algorithmic Philosophy
Create a 4-6 paragraph manifesto that:
- Names the algorithmic art movement (2-4 words)
- Describes how ideas manifest through:
  - Computational processes and mathematical relationships
  - Noise functions and randomness patterns
  - Particle behaviors and field dynamics
  - Temporal evolution and system states
  - Parametric variation and emergent complexity
- Emphasizes that beauty emerges from algorithmic execution
- Leaves room for interpretive implementation choices

### Stage 2: P5.js Implementation
Express the philosophy through a single, self-contained HTML artifact with:
- Interactive parameter controls
- Seed navigation (previous, next, random, jump to specific)
- Deterministic randomness (same seed = same output)
- Clean, sophisticated UI

## Key Principles

**Craftsmanship**: Algorithms should appear meticulously crafted, refined through countless iterations, the product of deep computational expertise.

**Process Over Product**: Beauty emerges from the algorithm's execution. Each seed produces unique results from the same underlying rules.

**Creative Freedom**: The philosophy provides direction while leaving space for creative interpretation of how to achieve the vision.

**Seeded Reproducibility**: All randomness uses deterministic seeds following Art Blocks patterns for identical output per seed.

## Technical Requirements

### Canvas
- Standard p5.js setup (typically 1200x1200px)
- Responsive to window size if needed
- Clear background and drawing context

### Parameters
Tunable properties controlling:
- Quantities (particle counts, iteration limits)
- Scales (sizes, distances, amplitudes)
- Probabilities (branching chances, spawn rates)
- Ratios (proportions, distributions)
- Angles (rotations, directions)
- Thresholds (triggers, boundaries)

### Structure
- All code embedded inline within HTML
- No external files except p5.js CDN
- Self-contained and browser-ready
- Clean, readable code organization

### User Interface
Sidebar with fixed sections:
1. **Seed Navigation**: Display current seed, prev/next/random/jump controls
2. **Parameters**: Sliders/inputs for tunable properties
3. **Colors** (optional): Palette controls if applicable
4. **Actions**: Regenerate, Reset to defaults, Download image

## Template Structure

Base your HTML on this structure:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Algorithmic Art - [Movement Name]</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.7.0/p5.min.js"></script>
    <style>
        /* Anthropic-style branding: Poppins/Lora fonts, light color scheme */
        body { margin: 0; font-family: 'Poppins', sans-serif; display: flex; }
        #canvas-container { flex: 1; }
        #controls { width: 300px; padding: 20px; background: #f5f5f5; overflow-y: auto; }
        /* Add refined styling for professional appearance */
    </style>
</head>
<body>
    <div id="canvas-container"></div>
    <div id="controls">
        <h2>Controls</h2>

        <section id="seed-controls">
            <h3>Seed</h3>
            <div id="seed-display">Seed: <span id="current-seed">0</span></div>
            <button onclick="previousSeed()">← Previous</button>
            <button onclick="nextSeed()">Next →</button>
            <button onclick="randomSeed()">🎲 Random</button>
            <input type="number" id="seed-input" placeholder="Jump to seed...">
            <button onclick="jumpToSeed()">Go</button>
        </section>

        <section id="parameters">
            <h3>Parameters</h3>
            <!-- Add parameter controls here based on your algorithm -->
        </section>

        <section id="actions">
            <button onclick="regenerate()">🔄 Regenerate</button>
            <button onclick="resetParameters()">↺ Reset</button>
            <button onclick="downloadImage()">⬇ Download</button>
        </section>
    </div>

    <script>
        // Global parameters object
        let params = {
            // Define your tunable parameters here
            particleCount: 1000,
            noiseScale: 0.01,
            // ... etc
        };

        let currentSeed = Math.floor(Math.random() * 1000000);

        function setup() {
            let canvas = createCanvas(1200, 1200);
            canvas.parent('canvas-container');
            regenerate();
        }

        function draw() {
            // Your generative algorithm here
            // Use params.propertyName to access tunable values
            // Use randomSeed(currentSeed) or noiseSeed(currentSeed) for determinism
        }

        // Seed navigation functions
        function previousSeed() { currentSeed--; regenerate(); }
        function nextSeed() { currentSeed++; regenerate(); }
        function randomSeed() { currentSeed = Math.floor(Math.random() * 1000000); regenerate(); }
        function jumpToSeed() {
            currentSeed = parseInt(document.getElementById('seed-input').value);
            regenerate();
        }

        function regenerate() {
            document.getElementById('current-seed').textContent = currentSeed;
            randomSeed(currentSeed);
            noiseSeed(currentSeed);
            clear();
            redraw();
        }

        function resetParameters() {
            // Reset params to defaults
            regenerate();
        }

        function downloadImage() {
            saveCanvas('algorithmic-art-' + currentSeed, 'png');
        }
    </script>
</body>
</html>
```

## Workflow

When a user requests algorithmic art:

1. **Understand the Request**: What concept, theme, or aesthetic are they exploring?

2. **Create Philosophy** (markdown document):
   - Name the movement
   - Write 4-6 paragraphs describing the computational aesthetic
   - Explain how algorithms will express the concept
   - Use evocative, precise language about processes not visuals

3. **Implement Algorithm** (HTML artifact):
   - Design the core generative system
   - Add seeded randomness for reproducibility
   - Create tunable parameters
   - Build clean UI with controls
   - Test multiple seeds to ensure variety

4. **Refine**: Ensure the implementation truly expresses the philosophy

## Examples of Algorithmic Philosophies

**Flow Field Harmony**: "Movement emerges from invisible force fields, where particles surrender to gradients they cannot see. Each agent follows local rules, creating global patterns through collective unconscious drift."

**Recursive Fragmentation**: "Unity fractures into infinite division. Each split carries the memory of wholeness while expressing newfound independence. Boundaries blur as hierarchies nest within themselves."

**Emergent Crystallization**: "Order precipitates from chaos through simple attraction rules. Particles seek equilibrium, building lattices of mathematical inevitability. The algorithm grows structures that feel both designed and discovered."

## Quality Standards

- **Visual Beauty**: Even with default parameters, output should be striking
- **Parameter Sensitivity**: Controls should produce meaningful variations
- **Seed Variety**: Different seeds should create distinctly different outputs
- **Performance**: Should run smoothly at 30+ fps
- **Reproducibility**: Same seed must always generate identical output
- **Professional UI**: Clean, intuitive controls with refined aesthetics

## Deliverables

1. **Algorithmic Philosophy** (markdown) - The computational worldview
2. **Interactive HTML Artifact** - Self-contained, ready to open in browser

The philosophy guides the code. The code manifests the philosophy. Together they form a complete artistic statement.
