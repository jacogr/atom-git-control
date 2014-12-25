## 0.1.3

- Fetch also prunes branches now
- Commit dialog is also available when in merge mode

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
