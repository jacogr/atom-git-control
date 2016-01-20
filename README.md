# Atom git-control

## What

Provides a GUI interface to manage all commonly-used git commands.

This is a first-release, while tested as part of creating this package, it has not been extensively used on much larger projects. In short: there are possibly still some issues remaining. At the same time, wanted to get the package out there and used.

![Git](https://raw.githubusercontent.com/jacogr/atom-git-control/master/screenshots/git-01.png)

## How

- Checkout or switch to any available branch with a click on the local/remote branch
- Select files to commit, either all or with an individual selection
- Compare the current working tree changes to the selected local branch
- Merge any other branch into the current active branch
- Create branches, either by remote selection of local branching
- Reset any file to its previous state with a checkout
- All git commands are logged, the commands used and output is visible
- Command available are activated based on working tree status
- Automatically fetches remote status on activation

## GitFlow

For git-flow commands to work, you need to [install git flow](https://github.com/petervanderdoes/gitflow-avh/wiki)

then, on mac, do the following:

```
  for file in `find /usr/local/bin -type f -iname git[-f]* -exec basename {} \;`; do sudo ln -s /usr/local/bin/$file /usr/bin/$file; done
```

## Where

The Atom package can be found on the Atom registry, [https://atom.io/packages/git-control](https://atom.io/packages/git-control).

Pull requests, issues, feature requests are all welcome and encouraged via [https://github.com/jacogr/atom-git-control](https://github.com/jacogr/atom-git-control).

Discussion and additional input is promoted here: [![Join the chat at https://gitter.im/jacogr/atom-git-control](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/jacogr/atom-git-control?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Maintainers

 - [MarcelMue](https://github.com/MarcelMue)
 - [Jaco Greeff](https://github.com/jacogr)
