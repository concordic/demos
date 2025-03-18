# Concord Demos

This is a development repository for demo applications, both with and without Concord.

## Repository Organization

Different demo applications are in different branches. For example, the `renderer` demo
would be in the `renderer` branch. Features for each demo are slash separated, e.g. 
`deffered` feature of `renderer` would be in the `renderer/deffered` branch.

Once a demo is complete, restructure the hierarchy for demo code to be in `src/<demo>/<api>`,
where `<demo>` is the demo name and `<api>` is the GPU api in use, then pull request to main.

When creating a new feature branch, branch off this branch, which contains the
original organizational template. Make sure to modify the `README.md` to list primary 
collaborators.
