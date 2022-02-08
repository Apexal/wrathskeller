# Contributing Guide


## Choosing What to Work On
1. Browse the Issue tracker for an item to work on
2. If you are a team member, assign yourself to the item
3. If you are an outside contributor, leave a comment saying you would like to claim it

## Starting to Work
1. Make sure you are on the `master` branch with `git checkout master`
2. Pull in any updates from GitHub with `git pull origin master`
3. Create a new branch off of master named after the issue with `git checkout -b issue-12` where 12 is replaced with the issue
    - If you are not working on a particular issue, name the branch something short and explanatory like `add-menu-subtitle`

## Working on the Item
1. Try to keep your changes limited to what the branch is for
    - For example, if you come across a bug while working on a feature, open an Issue for later instead of trying to also fix it along with adding the feature
1. Regularly commit your changes instead of waiting till the very end
2. Regularly push your commits to GitHub so you can link to your commits in Status Updates (for RCOS team members)
3. Make sure nothing is broken before pushing your commits!

## Merging Your Changes
1. Open a new Pull request for the branch you created
2. Give a good description of the changes and why you did what you did
