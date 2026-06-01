# Start with human Render Pipeline inspection

The first implementation will rely on human inspection through Render Pass toggles and captures rather than automated visual regression tests. The Render Pipeline should still be shaped so screenshot and pixel checks can be added later, but early automation is deferred because the art direction, Shader Passes, and polish details are expected to move while the Odin Game catches up to the Reference Prototype.

## Considered Options

- Add automated visual regression tests from the first Render Pipeline.
- Start with human inspection and keep capture points automation-ready.

## Consequences

- Visual quality depends on disciplined manual inspection at first.
- Render Pass capture names and outputs should remain stable.
- Automated screenshot checks can be added later without reshaping the Render Pipeline.
