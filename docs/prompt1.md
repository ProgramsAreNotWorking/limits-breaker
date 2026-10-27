# PROMPT 1 — LIMITS BREAKER: GAME DESIGN, ARCHITECTURE AND IMPLEMENTATION

Act as a senior game developer, gameplay programmer, and software architect. Build a complete, playable game called **Limits Breaker**, a turn-based mathematical roguelike RPG set in a dark medieval fantasy world.

Do not build a generic educational website with game elements attached. The game itself must be the learning experience.

## 1. Development workflow

Before implementing anything:

1. Inspect the existing repository, if one exists. Understand its structure, dependencies, conventions, and current state.
2. Create a concise technical plan and a game design specification.
3. Establish clear contracts for the visual assets and music: filenames, formats, dimensions, audio loops, event names, and when each asset should be used.
4. Implement the game incrementally, testing each major system.
5. Run the available tests and verify the actual game in a browser or supported runtime.
6. Finish with documentation explaining how to install, run, test, and build the game.

Do not stop after producing a plan or mockup. Complete the implementation. Do not claim a feature works unless you have tested it.

Prefer a lightweight, maintainable 2D implementation. If the repository has no established technology stack, evaluate a browser-based implementation using TypeScript and a suitable 2D rendering library. Keep the mathematical engine independent of rendering and UI code. Avoid unnecessary frameworks, online services, runtime AI dependencies, and complicated infrastructure.

## 2. Game identity

- Title: Limits Breaker.
- Genre: turn-based roguelike RPG with mathematical combat.
- Setting: dark medieval fantasy with arcane magic.
- Visual presentation: static illustrated characters and environments, with brief animations during attacks, damage, healing, spellcasting, and deaths.
- Audio identity: medieval instrumentation blended with restrained, energetic rock.
- Core experience: strategic problem selection, mathematical mastery, risk versus reward, loot, and permanent death.

All menus, gameplay screens, enemies, equipment, visual effects, and music must belong to this same fictional world.

## 3. Core gameplay loop

The player enters a run, fights successive groups of enemies, earns loot, improves equipment, encounters special events, and eventually dies or reaches a milestone.

Combat is turn-based.

During the player's turn:

1. Present a limited-time selection phase with a list of mathematical problems.
2. Each problem has a difficulty category: Easy, Intermediate, Advanced, or Super Difficult.
3. The player chooses a problem before the selection timer expires.
4. Once chosen, the player receives sufficient time to solve it without a real-time enemy attack interrupting the calculation.
5. A correct answer executes the corresponding attack.
6. An incorrect answer normally allows the enemy to attack. Advanced and Super Difficult problems instead apply their special self-damage rules.
7. Resolve status effects, enemy deaths, rewards, and the next turn.

The time limit applies to selecting a problem, not to solving it. Provide configurable timings and accessible feedback.

If the selection timer expires, resolve a missed turn according to a clearly documented rule. Use an enemy attack by default.

## 4. Mathematical combat system

Implement four difficulty categories with distinct damage, complexity, and risk.

- **Easy:** direct substitution and foundational exercises.
- **Intermediate:** multistep limits, basic one-sided limits, graph interpretation, or tables.
- **Advanced:** more demanding algebraic manipulation and factorization.
- **Super Difficult:** complex, multistep problems requiring deeper mathematical reasoning.

Correct answers inflict the selected attack's damage.

For incorrect answers:
- Easy and Intermediate: the player receives the enemy's attack.
- Advanced: the player receives 10% of the attempted attack's base damage.
- Super Difficult: the player receives 20% of the attempted attack's base damage.

Define deterministic rounding, minimum damage, damage ordering, and lethal outcomes. Do not accidentally apply both enemy damage and self-damage for the same failed Advanced or Super Difficult attempt.

The damage values and enemy statistics must be configurable data, not scattered hardcoded constants.

### Mathematical correctness

Build a reliable mathematical exercise engine.

Include:
- Direct limits using substitution.
- Left-hand and right-hand limits.
- Limits interpreted from Cartesian graphs.
- Approximate limits using tables of values.
- Limits solved through polynomial factorization and simplification.

Exercises must have mathematically correct answers, valid explanations, and appropriate difficulty labels. Generate problems from controlled templates and validate their solutions rather than randomly generating arbitrary expressions with potentially incorrect answer keys.

When a player answers incorrectly, explain the underlying concept and show the relevant solution steps. Include a retry or review mechanism that does not unnecessarily stall the entire game.

Do not use an LLM or an external API to calculate answers. The game must work offline.

## 5. Enemy design and balance

Enemy power must vary. Not every encounter should become uniformly harder or consist of enemies with ever-increasing health.

Required balancing constraints:

- The weakest enemy must survive the strongest Intermediate attack with exactly 1 HP remaining, under the baseline damage configuration.
- A sufficiently strong attack may instantly kill a weak enemy.
- A Super Difficult attack should leave a baseline medium-strength enemy nearly dead, while still allowing that enemy to survive.
- Minibosses and bosses must withstand multiple Super Difficult attacks.
- Weak, ordinary, strong, and elite enemies may appear in the same progression stage, with appropriate probabilities.

Create a configurable balance system and automated tests for these relationships. If equipment modifies damage, explicitly distinguish baseline balancing values from equipment-enhanced damage.

## 6. Knowledge-based progression

The difficulty of mathematical problems must evolve as the player demonstrates mathematical competence.

Track mastery independently for each subject and problem category.

Use performance, repeated mistakes, and successful problem solving to determine which problem templates become available and how frequently they appear.

Do not unlock advanced material exclusively through enemy kills or elapsed run time. A player must demonstrate sufficient understanding before advanced problems become common.

However, maintain a separate run progression system for enemy encounters, rewards, and difficulty scaling.

A death resets the current run, including its temporary character progression and collected loot. Preserve the player's long-term mathematical mastery and learning history, so the game does not erase actual learning.

Make the distinction between run progression and learning progression explicit in the design.

## 7. Equipment and special encounters

### Blacksmith

A blacksmith encounter appears periodically after a configurable number of encounters.

The player can attempt equipment upgrades using trigonometric-function exercises. Trigonometry is supplementary content, distinct from the core limits curriculum.

Equipment may include weapons, armor, magical staves, and passive relics. Each item must have understandable stats and a clear gameplay effect.

Rewards should depend on the challenge and successful completion. Make the encounter meaningful without allowing unlimited equipment stacking or trivializing combat.

### Angel encounter

A very rare angel appears during a run and offers a healing challenge.

The angel randomly determines the difficulty of a polynomial-factorization problem. The player cannot select the difficulty.

- Correct solution: restore an amount of HP determined by the problem's difficulty.
- Incorrect solution: restore exactly 1 HP.

The event must be rare, visually distinct, and capable of creating memorable recovery moments. All healing must respect the player's maximum HP.

### Loot and inventory

Enemies can drop usable items and equipment.

The player may carry a maximum of four inventory items. Clearly distinguish carried items from currently equipped gear. The inventory limit must be enforced consistently, with an understandable choice when new loot arrives and no free inventory slots remain.

## 8. Roguelike structure

Death ends the current run and returns the player to the beginning.

Reset the run's location, enemies, temporary upgrades, consumables, and collected loot. Preserve the persistent learning record and mathematical mastery.

Avoid adding permanent combat power that makes repeated runs mathematically trivial. If persistent unlocks exist, keep them primarily focused on learning content, cosmetic rewards, or player choice.

Implement a run summary showing the furthest encounter reached, enemies defeated, problems solved, accuracy, and subjects that need practice.

## 9. User interface and presentation

Build a cohesive game interface with:

- Main menu, settings, and a clear new-run flow.
- Combat screen with player and enemy illustrations, HP, turn state, problem selection, timers, and readable mathematical notation.
- Mathematical feedback with explanations and solution steps.
- Equipment, loot, and inventory management.
- Blacksmith and angel encounter screens.
- Run-death screen and run statistics.
- A persistent learning record and mastery overview.
- Pause or safe interruption where appropriate.

Use static 2D illustrations as the foundation. Animate only when a character or object performs an action. Avoid unnecessary continuous animation, visual clutter, and distracting effects over equations.

All equations must render legibly on desktop and mobile screens. Support keyboard navigation, readable contrast, scalable text, and reduced-motion preferences.

## 10. Audio integration

Integrate music and sound effects through a centralized audio manager.

Define explicit events for:
- Main menu.
- Normal combat.
- Boss combat.
- Player attack.
- Enemy attack.
- Correct answer.
- Incorrect answer.
- Healing.
- Loot acquisition.
- Blacksmith.
- Angel encounter.
- Death and game over.

Music should be loopable and should not restart on every turn. Sound effects must not overlap excessively or obscure mathematical feedback.

Use local assets and allow the player to adjust music and sound-effect volumes independently. Respect browser audio-autoplay restrictions.

Use placeholder assets only where necessary during development. Document the exact filenames expected from the separate art and music production stages, and replace placeholders when final assets are available.

## 11. Testing and completion criteria

Create tests for:
- Mathematical answer correctness.
- Problem generation and difficulty classification.
- Correct and incorrect combat outcomes.
- The 10% and 20% self-damage rules.
- Enemy health balance constraints.
- Mastery progression.
- Death and run resets.
- Four-item inventory limits.
- Blacksmith rewards.
- Angel encounter probability and healing.
- Equipment effects and damage calculations.

Test a complete run through multiple encounters, including at least one special event and death.

The finished product must be playable, coherent, and maintainable, not just a visual mockup.

Deliver:
1. Working game.
2. Source code.
3. Setup and run instructions.
4. Technical architecture documentation.
5. Mathematical exercise documentation.
6. Asset manifest shared with the art and music stages.
7. Automated tests and a clear report of what was actually verified.

Make sensible decisions for unspecified details, document them, and avoid asking for approval on every minor decision. Prioritize mathematical correctness, a fun risk-reward loop, and a cohesive RPG experience.
