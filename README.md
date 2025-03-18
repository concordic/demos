# Concord Demos

This is a development repository for demo applications, both with and without Concord.

## Repository Organization

Different demo applications are in different branches. For example, the `renderer` demo
built on Vulkan would be in the `renderer.vulkan` branch. Features for each demo are 
dot (`.`) separated, e.g. `deferred` feature of `renderer.vulkan` would be in the
`renderer.vulkan.deferred` branch.

Once a demo is complete, restructure the hierarchy for demo code to be in `src/<demo>/<api>`,
where `<demo>` is the demo name and `<api>` is the GPU API in use, then pull request to main.

When creating a new feature branch, branch off the `template` branch, which contains the
original organizational template. Make sure to modify the `README.md` to list primary 
collaborators.
