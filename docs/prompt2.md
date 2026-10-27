# PROMPT 2 — LIMITS BREAKER: VISUAL ART DIRECTION AND ASSET PRODUCTION

Act as the art director and 2D game artist for **Limits Breaker**, a dark medieval fantasy turn-based roguelike RPG in which the player solves mathematical limits to defeat enemies.

Your goal is to create a coherent, production-ready visual asset pack for an actual game, not a collection of unrelated concept art.

## 1. Shared visual identity

The game is called Limits Breaker.

Its world combines medieval fantasy, mysterious dungeons, enchanted weapons, arcane mathematics, dangerous creatures, and rare supernatural encounters.

Use this visual direction consistently:

- Dark fantasy with a hand-crafted 2D illustration or carefully controlled pixel-art aesthetic.
- Charcoal shadows, muted steel, burgundy accents, arcane violet, and warm gold.
- Dramatic but readable silhouettes.
- Restrained lighting, glowing magical symbols, and atmospheric backgrounds.
- Medieval materials: iron, leather, worn cloth, stone, wood, parchment, and enchanted crystals.
- Characters and environments are predominantly static illustrations. Motion is represented through short attack, hit, spell, healing, and death effects.
- The world must feel dangerous and mysterious, but not graphically gory.
- Avoid futuristic technology, sci-fi armor, neon cyberpunk palettes, cartoonish mobile-game styling, and overly saturated rainbow effects.

The art must be consistent with medieval instrumentation blended with light rock: atmospheric, energetic, and dramatic without becoming excessively aggressive.

## 2. Art assets required

Create a production asset pack covering the following.

### Player characters

Design a recognizable medieval adventurer suitable for repeated roguelike runs.

Provide:
- A neutral combat stance.
- An attack pose.
- A damage or stagger pose.
- A spellcasting or magical attack pose.
- A healing or item-use pose.
- A death pose.

Maintain consistent proportions, costume, equipment, and silhouette across all poses.

The character must remain recognizable when displayed at typical game-screen sizes.

### Enemies

Create a small but expressive initial roster:

- Weak enemy: a fragile dungeon creature or skeleton.
- Ordinary enemy: a standard medieval fantasy combatant.
- Strong enemy: a dangerous armored creature.
- Elite enemy: a visually distinctive and intimidating adversary.
- Miniboss: a larger, more elaborate opponent.
- Boss: a memorable major threat with a distinctive silhouette.

Give each enemy a consistent neutral pose and a small set of action or reaction poses.

Enemy strength must be communicated visually without relying exclusively on color.

### Special characters

Create two visually distinct special encounters:

**The Blacksmith**
- Medieval forge worker.
- Anvil, hammer, firelight, weapons, and enchanted metal.
- Warm orange and gold lighting.

**The Angel**
- Rare supernatural visitor.
- Ethereal robes, luminous halo, restrained golden light, and an unmistakable healing motif.
- A solemn, mysterious appearance rather than a generic cheerful cartoon angel.

The angel must contrast with the dark dungeon without looking as if it belongs to a different game.

### Environments

Create reusable environments for:
- Main menu.
- Ordinary dungeon combat.
- Boss arena.
- Blacksmith encounter.
- Angel encounter.
- Death screen.

Use layered compositions where practical, but do not force complex animation into otherwise static scenes.

### Equipment and loot

Design recognizable item icons for:
- Swords and enchanted weapons.
- Magical staves.
- Armor and shields.
- Potions and healing items.
- Relics and accessories.
- Rare equipment and special loot.

Icons must remain readable at small sizes. Use consistent silhouettes, borders, lighting, and rarity treatments.

### Combat effects

Create restrained effects for:
- Normal physical attacks.
- Arcane attacks.
- Critical or powerful attacks.
- Damage received.
- Healing.
- Enemy defeat.
- Correct mathematical answer.
- Incorrect mathematical answer.

Effects must communicate the result of an action without covering equations, answer choices, HP bars, or explanatory text.

## 3. Production requirements

Before producing assets, establish a written asset manifest containing:

- Asset identifier.
- Filename.
- Purpose.
- Dimensions or target resolution.
- Transparency requirements.
- Whether it is static or animated.
- Required pose variants.
- Intended UI placement.

Use consistent canvas sizes and alignment for related character assets. Prefer transparent backgrounds for sprites and icons, and provide full backgrounds as separate assets.

Use PNG or WebP for all artwork and UI; SVG is not part of the runtime pipeline.

If the implementation uses sprite sheets, define frame dimensions, ordering, and animation timing explicitly. Do not create arbitrary sprite sheets without documenting their layout.

Do not draw text directly into backgrounds, illustrations, or item icons unless the text is an intentional in-world detail. Game titles, buttons, HP labels, mathematical notation, and other UI text must remain editable in the game interface.

## 4. Cohesion with gameplay

The visual language should reinforce the game's mechanics:

- Correct answers: a brief, satisfying visual confirmation.
- Incorrect answers: clear feedback without humiliating or overwhelming the player.
- Advanced attacks: stronger magical effects.
- Super Difficult attacks: exceptional but restrained visual impact.
- Blacksmith: warm, industrious, metallic.
- Angel: rare, peaceful, luminous.
- Death: dramatic and readable.
- Bosses: visually powerful enough to justify their high HP.

Do not communicate mathematical difficulty only through increasingly complicated visual decoration. The equation must remain the primary object of attention when a problem is being solved.

## 5. Deliverables

Produce the actual visual files where supported, not merely descriptions of them.

Deliver:
1. A documented asset manifest.
2. The complete initial asset pack.
3. Consistent filenames and directory structure.
4. Character pose and animation specifications.
5. An asset preview sheet for review.
6. Notes on how the game should render and position each asset.
7. A list of any assets that remain placeholders.

Coordinate filenames and dimensions with the game implementation. If the codebase already defines an asset manifest, follow it. Otherwise, establish a stable naming convention and communicate it to the programming stage.

Prioritize visual consistency, readability, expressive combat, and practical integration over sheer quantity.
