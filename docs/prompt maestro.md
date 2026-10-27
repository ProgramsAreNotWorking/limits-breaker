# LIMITS BREAKER — MASTER PROJECT PROMPT
## Game Design, Art Direction, Original Audio, Engineering, and Integration

You are the autonomous development team responsible for creating **Limits Breaker**, a complete, playable, polished, and maintainable mathematical roguelike RPG.

Act as a coordinated team of specialists:
- Game director and systems designer.
- Mathematics educator and exercise-engine designer.
- Gameplay programmer and software architect.
- 2D fantasy art director and asset producer.
- Music composer and sound designer.
- QA engineer and game-balancing specialist.

Your task is not to create a prototype that merely looks convincing. Your task is to deliver a coherent game in which the mathematical systems, combat mechanics, progression, art, audio, interface, and technical architecture work together.

Work autonomously, inspect the existing environment before making assumptions, and carry the project through implementation and verification. Do not stop at a plan, a mockup, a list of recommendations, or pseudocode.

---

# 1. PROJECT IDENTITY

**Official title:** Limits Breaker

**Genre:** Turn-based roguelike RPG with mathematical combat, equipment progression, random encounters, and permanent death.

**Setting:** A dark medieval fantasy world where arcane knowledge manifests as magical power.

**Core premise:** The player's ability to understand and solve mathematical problems determines their effectiveness in combat and their capacity to survive increasingly dangerous encounters.

The player is not simply completing school exercises between fights. Solving mathematical problems IS the combat system.

Every major design decision must support this premise.

## Creative direction

The game should combine:
- The strategic decisions of a turn-based RPG.
- The replayability and tension of a roguelike.
- The risk-reward decisions of selecting mathematical challenges.
- The atmosphere of a dark medieval fantasy world.
- The satisfaction of equipment upgrades, rare encounters, and powerful attacks.
- A meaningful learning progression that rewards genuine mathematical understanding.

The experience should feel like a small, carefully designed indie RPG rather than an educational website with decorative game elements.

Do not add unrelated mechanics simply because they are common in RPGs. Every feature should support combat, learning, strategy, atmosphere, or replayability.

---

# 2. REQUIRED DEVELOPMENT WORKFLOW

Work in distinct, sequential phases. Complete and verify each phase before moving to the next.

## Phase 1 — Repository inspection and technical planning

Before changing files:

1. Inspect the existing repository, available development tools, dependencies, and runtime environment.
2. Identify the current application architecture and any established conventions.
3. Determine which capabilities are actually available for generating images, audio, code, and testing.
4. Create a game design document containing the complete gameplay rules.
5. Create a technical architecture document.
6. Create an asset manifest and audio manifest with stable identifiers, formats, dimensions, and intended usage.
7. Identify unresolved decisions, make reasonable defaults, and document them.

If an existing implementation is present, preserve useful work rather than replacing it blindly.

If no technology stack is established, choose a lightweight 2D solution suitable for local execution and offline play. Prefer TypeScript and a suitable browser-based 2D rendering approach when appropriate. Keep the mathematical engine, combat simulation, game state, rendering, audio, and interface sufficiently independent to be tested separately.

Do not introduce unnecessary backend services, cloud dependencies, paid APIs, or runtime AI requirements.

## Phase 2 — Visual asset production

Create the visual assets required by the actual design.

Produce character illustrations, enemies, environments, equipment icons, interface elements, and combat effects according to the asset manifest.

Do not start by generating dozens of unrelated illustrations. Establish the art direction, produce a representative set of assets, verify their consistency, and then expand the collection.

If native image-generation capabilities are available, use them to create actual image files. If they are not available, prepare production-ready prompts, asset specifications, and integration points for a suitable image-generation tool.

Never claim that images have been generated when only descriptions or placeholders exist.

## Phase 3 — Music and sound production

Create the original soundtrack and sound effects according to the audio manifest.

Use actual audio-generation or composition capabilities when available. Otherwise, produce whatever genuine source files, MIDI, procedural audio, or detailed production specifications the environment supports.

Do not substitute external streaming links for the intended local soundtrack.

Verify loop points, filenames, formats, playback events, and volume relationships.

## Phase 4 — Core game implementation

Implement the game systems using the approved design documents and asset contracts.

Prioritize:
1. Mathematical exercise engine.
2. Turn-based combat.
3. Difficulty selection and timers.
4. Damage and enemy balancing.
5. Learning-based progression.
6. Run progression and permanent death.
7. Inventory, loot, and equipment.
8. Blacksmith and angel encounters.
9. User interface and rendering.
10. Audio integration.
11. Save data, settings, accessibility, and polish.

Use temporary assets only when necessary. Keep their locations explicit so they can be replaced without modifying gameplay logic.

## Phase 5 — Integration and verification

Integrate all final visual and audio assets.

Test a complete run, not just isolated screens. Verify that encounters transition correctly, combat resolves properly, loot and equipment work, special encounters behave as specified, and death resets the run.

Run automated tests, inspect errors, fix regressions, and document any limitations that remain.

Never mark a phase complete merely because its files exist.

---

# 3. VISUAL AND AUDIO BIBLE

All artistic output must follow this shared identity.

## Visual style

Use a coherent dark medieval fantasy aesthetic with:
- Charcoal shadows and dark stone.
- Muted steel and worn leather.
- Burgundy accents.
- Arcane violet magical effects.
- Warm gold for healing, sacred encounters, and rare rewards.
- Restrained orange firelight in forges.
- Strong silhouettes and readable character poses.
- Detailed but uncluttered 2D illustrations.

The game uses predominantly static character and environment artwork. Movement occurs through brief action animations, transitions, particles, and visual effects.

Avoid futuristic equipment, cyberpunk neon, generic sci-fi interfaces, excessively cartoonish mobile-game aesthetics, and gratuitous gore.

The visual style must remain consistent across the player, enemies, bosses, environments, loot, interface, and special encounters.

Use transparent backgrounds for character sprites and icons when appropriate. Keep mathematical text, labels, buttons, health values, and other interface content separate from background illustrations so they remain editable and legible.

## Musical style

Create an original soundtrack combining medieval instrumentation with restrained light-rock energy.

Appropriate elements include plucked strings, lute-like textures, harp, flute, fiddle, low strings, frame drums, restrained electric guitar, and bass.

The soundtrack should communicate danger, mystery, adventure, and determination.

Normal combat must remain engaging without becoming exhausting during repeated encounters. Boss music may be more intense. The blacksmith should feel warm and industrious. The angel should feel rare, ethereal, and restorative. The death theme should be somber but leave room for another attempt.

Avoid extreme metal, constant heavy distortion, EDM drops, futuristic synthesizer-driven soundscapes, and overly bombastic cinematic music.

## Shared production contracts

Before final asset production, define and maintain:
- Stable asset identifiers.
- Filenames and directory structure.
- Image dimensions and transparency.
- Sprite-sheet layout, if used.
- Audio formats and loop points.
- Music and sound-effect event identifiers.
- Intended screen or gameplay usage.

The implementation must reference these identifiers rather than scattering arbitrary file paths throughout the codebase.

If a required resource cannot be generated, document the limitation and use a clearly identified placeholder. Do not silently present placeholders as finished assets.

---

# 4. CORE COMBAT SYSTEM

Combat is turn-based.

The player fights enemies in successive encounters and selects mathematical problems as attacks.

## Turn sequence

1. Begin the player's turn and display the current enemy, health, status effects, and available challenge choices.
2. Start a limited-time problem-selection phase.
3. Present a list of problems with four difficulty categories.
4. The player chooses a problem before the selection timer expires.
5. Stop the selection timer and give the player sufficient time to solve the chosen problem.
6. If the answer is correct, execute the corresponding attack.
7. If the answer is incorrect, resolve the appropriate failure penalty.
8. Resolve enemy defeat, status effects, loot, and encounter completion.
9. Begin the next turn or transition to the next encounter.

The timer limits the time available to choose a problem, not the time available to solve it. The player must have enough time to reason through the mathematics.

If the selection timer expires, the enemy attacks and the player loses the opportunity to attack for that turn.

Make the selection duration configurable.

Do not make every calculation a reflex test. Strategic problem selection and mathematical understanding are the primary skills being tested.

## Difficulty categories

### Easy
Direct substitution and other foundational exercises.

Low risk and low damage.

### Intermediate
Problems requiring several steps, including appropriate one-sided limits, graph interpretation, tables of values, or elementary algebraic manipulation.

Moderate risk and damage.

### Advanced
More demanding limits involving factorization, simplification, or multiple mathematical steps.

High damage with a special failure penalty.

### Super Difficult
Complex, multistep challenges requiring deeper reasoning.

Very high damage with a greater failure penalty.

The four categories must be meaningfully different in both mathematical complexity and strategic value.

## Damage and failure rules

A correct answer deals the selected attack's damage.

On an incorrect answer:
- Easy: the enemy attacks the player.
- Intermediate: the enemy attacks the player.
- Advanced: the player receives 10% of the attempted attack's base damage.
- Super Difficult: the player receives 20% of the attempted attack's base damage.

Advanced and Super Difficult failures replace the ordinary enemy-attack penalty for that failed action. Do not apply both penalties unless a separately documented enemy ability explicitly requires it.

Define consistent integer rounding, minimum damage, damage ordering, and lethal outcomes. Keep these calculations deterministic and testable.

All baseline damage values must be configurable.

---

# 5. ENEMIES AND COMBAT BALANCE

Enemy strength varies independently of the mathematical difficulty progression.

Include:
- Weak enemies.
- Ordinary enemies.
- Strong enemies.
- Elite enemies.
- Minibosses.
- Bosses.

The world must not consist of enemies whose HP simply increases at a constant rate.

Required baseline balance constraints:

1. The weakest enemy must survive the strongest Intermediate attack with exactly 1 HP remaining.
2. A correct Advanced or Super Difficult attack may eliminate a weak enemy immediately.
3. A Super Difficult attack should leave a baseline medium-strength enemy nearly defeated but alive.
4. Minibosses and bosses must survive multiple Super Difficult attacks.
5. Different enemy strengths may appear within the same progression stage.

Use a data-driven balancing system and automated tests to verify these constraints.

Equipment bonuses must not accidentally invalidate the baseline rules. Explicitly distinguish baseline enemy balance from equipment-modified damage.

Enemies may have distinct abilities, resistances, or behavior patterns, but do not create so many exceptions that the player cannot understand why an attack succeeded or failed.

---

# 6. MATHEMATICAL LEARNING ENGINE

The mathematical engine is central to the game. It must be accurate, testable, and independent of the visual interface.

Do not use an external AI API to generate or grade mathematical answers at runtime.

Generate exercises from validated templates and known solution methods. Every generated problem must have a verified answer and a valid explanation.

## Required initial curriculum

### Topic A — Direct limits
- Substitution into suitable functions.
- Evaluating polynomial expressions.
- Recognizing when direct substitution is sufficient.
- Recognizing when further algebraic manipulation is required.

### Topic B — Left-hand and right-hand limits
- Approaching a point from the left.
- Approaching a point from the right.
- Distinguishing one-sided limits.
- Determining whether the two-sided limit exists.

### Topic C — Limits from Cartesian graphs
- Interpreting function behavior near a point.
- Distinguishing the limiting value from the function's value at the point.
- Recognizing different left- and right-hand behavior.

### Topic D — Approximate limits from tables
- Evaluating function values close to a target.
- Approaching from both sides.
- Identifying numerical patterns.
- Understanding that an approximate table provides evidence, not necessarily a formal proof.

### Topic E — Limits by factorization
- Recognizing indeterminate forms such as 0/0.
- Factoring polynomial expressions.
- Simplifying valid expressions.
- Evaluating the resulting limit.
- Understanding why the original function and the simplified expression may agree near the target without being defined identically at the target.

The exercise engine must support controlled variation in numerical values, algebraic expressions, and problem complexity.

Avoid arbitrary random expressions that cannot be solved by the methods the player has learned.

## Feedback and teaching

When the player answers incorrectly:
- Identify the specific error where possible.
- Explain the relevant mathematical idea.
- Show the correct solution in readable steps.
- Offer a related review problem when appropriate.

Avoid giving an unexplained correct answer.

Use deterministic grading rules for equivalent numerical or algebraic answers where supported. If symbolic equivalence is not implemented, constrain the answer format and communicate the accepted format clearly.

Mathematical expressions must be readable, accessible, and correctly rendered.

---

# 7. KNOWLEDGE-BASED PROGRESSION

The game has two independent progression systems.

## Run progression

Tracks:
- Current encounter.
- Current character stats.
- Temporary upgrades.
- Current inventory and equipment.
- Run-specific rewards.
- Current survival progress.

These values reset on death.

## Persistent learning progression

Tracks:
- Topics introduced.
- Problems attempted.
- Accuracy by topic and difficulty.
- Repeated mistakes.
- Demonstrated mastery.
- Recommended review areas.

These values persist across runs.

Problem difficulty must evolve according to demonstrated mathematical competence, not merely the number of enemies killed.

Early gameplay emphasizes foundational concepts. Later gameplay introduces more complex problems as the player demonstrates understanding.

Do not force the player to solve advanced problems before the necessary foundational knowledge has been taught.

The learning system must also avoid becoming permanently stuck because of repeated mistakes. Offer practice opportunities and gradual progression rather than hard-locking the entire game.

The goal is for the player to become better at mathematics across multiple runs, even when the character dies.

---

# 8. EQUIPMENT, LOOT, AND INVENTORY

Enemies may drop items that support the current run.

Equipment categories may include:
- Weapons.
- Magical staves.
- Armor.
- Shields.
- Consumables.
- Passive relics.
- Special loot.

Each item must have clear effects, readable statistics, and a coherent visual representation.

## Four-item inventory limit

The player can carry a maximum of four inventory items.

Clearly distinguish:
- Equipped gear.
- Carried items.
- Consumables.
- Items dropped by enemies.
- Special encounter rewards.

Define what happens when the player receives an item with a full inventory. Present an explicit choice to keep or discard an item.

Do not silently delete loot or allow the inventory to exceed its limit.

The inventory limit must be consistent throughout the game.

---

# 9. BLACKSMITH ENCOUNTER

A blacksmith appears periodically according to configurable encounter rules.

The blacksmith offers equipment upgrades using trigonometric-function exercises.

This is supplementary mathematical content, distinct from the initial limits curriculum.

Possible exercises may include evaluating familiar trigonometric functions, interpreting basic values, or simplifying appropriate expressions.

The player must demonstrate a correct answer to obtain the intended reward.

Equipment may improve attack damage, defense, healing, or other clearly defined statistics.

Ensure that rewards remain meaningful without trivializing subsequent encounters.

The blacksmith must have:
- A distinct encounter screen.
- A recognizable forge environment.
- Warm lighting and appropriate sound design.
- Clear equipment choices.
- Correctly functioning reward logic.

---

# 10. RARE ANGEL ENCOUNTER

An angel appears very rarely during a run.

The angel presents a randomly selected polynomial-factorization problem. The player cannot choose its difficulty.

Healing depends on the difficulty assigned to the generated problem.

- Correct answer: heal according to the problem's difficulty.
- Incorrect answer: heal exactly 1 HP.

Healing cannot exceed maximum HP.

The encounter must be rare enough to feel special but possible enough to be experienced during ordinary play.

Its visual and audio presentation should provide a brief contrast to the dangerous dungeon environment.

Do not make the angel a source of unlimited or repeatable healing.

---

# 11. ROGUELIKE RULES AND DEATH

Death resets the current run.

Reset:
- Current encounter.
- Current enemies.
- Temporary character progression.
- Run-specific upgrades.
- Carried loot and consumables.
- Other run-specific state.

Preserve:
- Mathematical mastery.
- Learning history.
- Settings.
- Other explicitly persistent educational data.

A run summary must report:
- Furthest encounter reached.
- Enemies defeated.
- Problems attempted and solved.
- Accuracy by topic.
- Equipment obtained.
- Topics that deserve more practice.

The game should encourage another attempt without hiding the consequences of death.

Do not introduce permanent combat bonuses that remove the challenge of future runs. Persistent unlocks should primarily support learning, cosmetics, or meaningful player choice.

---

# 12. VISUAL ASSET REQUIREMENTS

Create a consistent initial visual pack containing:

- Main-menu background and interface elements.
- Player character and action variants.
- Weak, ordinary, strong, and elite enemies.
- Miniboss and boss artwork.
- Dungeon combat backgrounds.
- Blacksmith character and forge.
- Angel character and encounter environment.
- Equipment and loot icons.
- Attack, damage, healing, and defeat effects.
- Game-over screen.
- Relevant interface icons and status indicators.

Prefer reusable assets and shared visual conventions over one-off artwork.

Characters should have recognizable silhouettes and consistent proportions across poses.

Keep UI text and equations outside the image artwork.

If image-generation tools are available, generate actual image assets. Otherwise, prepare the complete manifest and generation specifications, clearly marking what remains unproduced.

Do not fabricate asset paths or pretend missing files exist.

---

# 13. MUSIC AND SOUND REQUIREMENTS

Create an original local soundtrack and sound-effect system.

Required music:
- Main menu.
- Normal combat.
- Boss combat.
- Blacksmith.
- Angel encounter.
- Death/game over.

Required effects:
- Problem selection.
- Correct answer.
- Incorrect answer.
- Normal attack.
- Powerful arcane attack.
- Player taking damage.
- Enemy taking damage.
- Healing.
- Enemy death.
- Loot drop.
- Equipment acquisition.
- Blacksmith interaction.
- Angel appearance.
- Boss appearance.
- Player death.

Music should loop cleanly and transition according to game state.

Sound effects must not become repetitive or obscure mathematical feedback.

Provide independent music and effects volume controls.

Use locally available audio assets and avoid external streaming dependencies.

Generate actual audio where supported. If the current environment cannot produce audio, document this honestly and prepare the specifications needed for a dedicated audio-production tool.

---

# 14. USER INTERFACE AND ACCESSIBILITY

Implement:
- Main menu.
- New-run flow.
- Settings.
- Combat interface.
- Mathematical problem selection.
- Mathematical answer input.
- Solution explanations.
- Character status.
- Inventory and equipment.
- Blacksmith encounter.
- Angel encounter.
- Boss encounters.
- Death and run summary.
- Persistent learning record.

Prioritize mathematical readability.

The interface must clearly communicate:
- Whose turn it is.
- How much selection time remains.
- Which problem has been selected.
- What happens when the answer is correct or incorrect.
- Current HP and damage.
- Enemy state.
- Inventory capacity.
- Available equipment.
- Learning progression.

Support keyboard navigation, readable contrast, scalable text, and reduced-motion preferences.

Use brief animations and restrained effects. Never allow effects to obscure the exercise currently being solved.

---

# 15. TECHNICAL ARCHITECTURE AND QUALITY

Separate the following concerns:
- Mathematical exercise generation and validation.
- Combat rules and damage calculation.
- Enemy definitions and balancing.
- Learning mastery and progression.
- Run state and persistent state.
- Inventory and equipment.
- Encounter generation.
- Rendering and UI.
- Audio playback.
- Save/load operations.

Use data-driven definitions for problems, enemies, items, encounter probabilities, and balancing values.

Write automated tests for the mathematical engine, combat rules, damage penalties, enemy balance, mastery progression, inventory capacity, equipment, special encounters, and run resets.

Include deterministic test scenarios so that failures can be reproduced.

Handle corrupted or missing save data gracefully.

Avoid unnecessary dependencies, excessive abstraction, and infrastructure that does not benefit the game.

Document installation, local execution, build procedures, testing, and asset replacement.

---

# 16. ACCEPTANCE CRITERIA

The project is complete only when the following have been verified:

1. The game can be launched using documented instructions.
2. A new run can begin and progress through multiple encounters.
3. Mathematical exercises can be generated, answered, graded, and explained correctly.
4. All four difficulty categories have distinct behavior.
5. Correct attacks and failure penalties follow the documented rules.
6. Enemy balance constraints pass automated tests.
7. Mathematical mastery and run progression remain separate.
8. The four-item inventory limit is enforced.
9. Equipment and loot affect gameplay correctly.
10. The blacksmith encounter works.
11. The rare angel encounter works.
12. Death resets the current run without erasing persistent learning history.
13. Music and sound effects are connected to actual gameplay events.
14. Visual assets are integrated, with remaining placeholders clearly identified.
15. The game can complete a full gameplay cycle without critical errors.
16. The interface remains readable during combat and mathematical problem solving.
17. The documentation accurately reflects the delivered implementation.

Provide a final report listing what works, which tests were run, what assets were actually generated, and what remains incomplete.

Do not report success based solely on compilation, screenshots, or files existing on disk.

---

# 17. AUTONOMY AND DECISION-MAKING

Make sensible design decisions where requirements are unspecified.

Prioritize:
1. Mathematical correctness.
2. Strategic and satisfying turn-based combat.
3. Meaningful risk-reward decisions.
4. A coherent dark medieval fantasy identity.
5. Learning progression that survives character death.
6. Stable, maintainable code.
7. Consistent and integrated visual and audio assets.
8. Reproducible testing and honest reporting.

Do not ask the user to approve every minor choice. Document reasonable assumptions and continue working.

Do not silently discard a required mechanic because it is inconvenient to implement. If a requirement cannot be completed with the available tools, explain why and provide the best practical alternative.

The final result must be a cohesive game, not three unrelated deliverables.

**The governing principle of Limits Breaker is simple: the player's mathematical understanding determines the power of their actions, and the knowledge they acquire outlives every failed run.**
