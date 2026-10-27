# PROMPT 3 — LIMITS BREAKER: ORIGINAL MUSIC AND SOUND DESIGN

Act as the composer, sound designer, and audio integrator for **Limits Breaker**, a dark medieval fantasy turn-based roguelike RPG built around mathematical combat.

Produce a cohesive original audio identity that fits the game's world, pacing, visual style, and gameplay systems.

Do not deliver only a playlist of existing music. Create original music and sound assets where your available tools support audio generation or composition. If audio generation is unavailable, provide production-ready musical specifications, MIDI or project files where possible, and clear implementation instructions. Never claim to have rendered audio that you have not actually created.

## 1. Musical identity

Limits Breaker combines:

- Medieval fantasy instrumentation.
- Restrained, light rock energy.
- Mysterious dungeon ambience.
- Arcane magical atmosphere.
- Tension during difficult decisions.
- A sense of danger, discovery, and perseverance.

Use a coherent palette built around instruments such as lute, plucked strings, harp, flute, fiddle, frame drums, low strings, acoustic percussion, and restrained electric guitar or bass.

The rock influence should provide rhythm and momentum, not turn the soundtrack into metal. Avoid extreme distortion, relentless double-kick drums, EDM drops, futuristic synths, and generic orchestral trailer clichés.

The soundtrack should feel like different parts of the same medieval fantasy world.

## 2. Required music tracks

### Main menu theme

A memorable, atmospheric introduction to the world.

Use a restrained medieval motif with subtle rock instrumentation that hints at adventure and danger. It should work during menu navigation without becoming distracting.

### Normal combat loop

Energetic and rhythmic, with enough space for turn-based combat and mathematical reasoning.

The track should sustain tension without becoming exhausting after repeated loops. It must not contain abrupt transitions that make a long encounter irritating.

### Boss combat loop

A more intense variation of the same musical identity.

Use stronger percussion, heavier low strings, and more pronounced rock elements. Maintain melodic or harmonic continuity with the normal combat theme so both clearly belong to the same game.

### Blacksmith theme

Warm, rhythmic, and slightly industrial in texture.

Use hammer-like percussion, metallic accents, plucked strings, and restrained fire or forge ambience. It should feel like a brief opportunity to prepare and improve equipment.

### Angel encounter theme

Rare, ethereal, and emotionally relieving.

Use delicate high-register melodies, soft strings, chimes, and restrained golden or sacred tonal associations. Avoid overly sentimental or excessively grand religious music.

### Death and game-over theme

Short, somber, and memorable.

Reflect the loss of a run while suggesting that another attempt remains possible. Do not make it melodramatic.

## 3. Sound effects

Create a consistent sound-effect pack for:

- Selecting a problem.
- Confirming a selection.
- Correct mathematical answer.
- Incorrect mathematical answer.
- Normal attack.
- Powerful arcane attack.
- Enemy attack.
- Player taking damage.
- Healing.
- Enemy defeat.
- Loot drop.
- Equipment acquisition.
- Blacksmith interaction.
- Angel appearance.
- Boss appearance.
- Player death.

Audio feedback for mathematical answers should be clear and brief. Correct and incorrect answers must be distinguishable without being irritating.

Do not use loud error buzzers, comic sounds, or exaggerated arcade effects that conflict with the medieval fantasy setting.

## 4. Audio implementation specifications

Provide a documented audio manifest with stable filenames, for example:

- `music_menu`
- `music_combat`
- `music_boss`
- `music_blacksmith`
- `music_angel`
- `music_game_over`
- `sfx_answer_correct`
- `sfx_answer_incorrect`
- `sfx_attack`
- `sfx_attack_arcane`
- `sfx_player_hit`
- `sfx_enemy_hit`
- `sfx_heal`
- `sfx_enemy_death`
- `sfx_loot`
- `sfx_equipment`
- `sfx_angel_appearance`

Treat these names as logical identifiers. Use the final filenames and formats agreed with the game implementation.

Music must loop cleanly, without audible gaps, sudden volume changes, or clicks. Prefer seamless loop points and consistent loudness within each musical category.

Provide suitable local audio formats such as OGG or WAV, depending on browser/runtime compatibility and file-size requirements. Include loop-point metadata or instructions where relevant.

Define the intended playback event for each sound and avoid repeatedly restarting music on every combat turn.

Implement or document:
- Separate music and effects volume controls.
- Safe audio initialization when user interaction is required.
- Appropriate transitions between menu, combat, boss, blacksmith, angel, and death states.
- No overlapping sound-effect spam.
- No external streaming dependency.
- Graceful handling of missing audio assets.

## 5. Consistency with the visual art

The sound should match the visual direction:

- Charcoal, steel, burgundy, violet arcane magic, and warm gold.
- Dark medieval dungeons.
- Expressive but mostly static 2D illustrations.
- Short attack and spell animations.
- A dangerous roguelike atmosphere with occasional moments of relief.

Normal combat should feel tactical rather than frantic. Powerful mathematical attacks should feel satisfying without making every correct answer sound like a final boss defeat.

The angel encounter should feel genuinely rare, and its audio entrance should communicate relief and opportunity immediately.

## 6. Deliverables

Produce:
1. Original audio files where supported.
2. The complete music and sound-effect manifest.
3. Loop and transition specifications.
4. Recommended volume levels and mix notes.
5. A mapping between game events and audio identifiers.
6. A list of generated assets, source projects, and remaining placeholders.
7. Integration instructions for the game programmer.

Prioritize a coherent musical identity, clean looping, restrained effects, and audio that supports concentration while still making combat feel rewarding.
