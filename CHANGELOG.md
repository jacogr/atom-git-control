## 0.7.0

- Manual version push for apm publish issues

... things should just work

## 0.3.0

- Further gitflow updates
- Allow opening files from the diff
- Push to upstream button
- Fix last remailing deprecations, [#57](https://github.com/jacogr/atom-git-control/pull/57) and [#66](https://github.com/jacogr/atom-git-control/pull/66)
- Release to ensure that package doesn't break on June 1

... Atom 1.0

## 0.2.0
- Added git-flow support
- Prevented error message if git-control is opened in project that is not a repository
- Fixed deprecation warnings

... working on new features

## 0.1.9

- Fixing defineProperty.get deprecation #16
- Fixing Stylesheet Path deprecation warning #53
- Minor style changes introduced by #39
- Creating a Gitter room and some small updates in Readme and TODO #50

... fixing deprecations and getting things running again

## 0.1.8

- Actually test if a remote origin exists (getOrigin()) as opposed to remove branches
- https://github.com/jacogr/atom-git-control/issues/8

... getting things ticking on anything where a fetch or clone hasn't been done

## 0.1.7

- When a new folder is created, explicitly show all the files in it
- https://github.com/jacogr/atom-git-control/issues/9

... show untracked files

## 0.1.6

- Don't do a fetch when there are no remotes
- Don't make the push/pull/fetch items active without remotes
- https://github.com/jacogr/atom-git-control/issues/6

... working with local-only repos

## 0.1.5

- Toggle closes when open, opens when closed
- https://github.com/jacogr/atom-git-control/issues/5
- not an official release, 0.1.6 fix combines (no rapid-fire releases)

... last nigglies for issue #5

## 0.1.4

- Address 'toggle' not actually 'toggling' the control tab
- https://github.com/jacogr/atom-git-control/issues/5
- Toggle currently doesn't toggle to the 'off' state, rather only controls switching

... yeap, more usability

## 0.1.3

- Fetch also prunes branches now
- Commit dialog is also available when in merge mode
- Updated README to go through functionality

... cleanups for edgy cases

## 0.1.2

- Always do an add for modified files before doing a commit without specifying files

... helps a lot with other packages that stages (or does not)

## 0.1.1

- Updated description in package.json

... alignment with README

## 0.1.0

- Initial version
- Shows information of local vs remote branches (current active)
- Actions allowed
  - Allows reset of files to previous state
  - Fetch fetches on tab activation, menu item always available
  - Push activated when there are actual local changes available
  - Pull activated when there are remote changes detected via fetch
  - Branching and merging works

... casting it out there, not perfect but workable
