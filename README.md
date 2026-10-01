# CookbookCentral

Citations

1. Connecting to sql database code.
   Based on code from activity 1.
   https://canvas.oregonstate.edu/courses/1967354/assignments/9690197?module_item_id=24460780



Setting up for local testing:
1. Clone repository
2. Run 'pip install --user virtualenv' to install virtualenv package.
3. Run 'python -m venv .' to create virtual env.
4. Run 'source ./Scripts/activate' to start virtual env.
5. Run 'pip install -r requirements.txt' to download required packages.
6. Run 'flask run' to start up development server. Also server must be restarted when code is updated.

ALL development must be completed in a different branch than main so before altering code checkout different branch.
1. Run 'git pull' to get most up to date code
2. Run 'git checkout -b new_branch_name'

If you have an existing local branch and need to merge new code from the main branch into your local branch:
1. Run 'git checkout -b main'
2. Run 'git pull'
3. Run 'git checkout -b local_branch-name'
4. Run 'git merge main'
This will allow you to have new code in your exisiting local branch.


Michael will do all work in a branch named 'dev' so any other name is fine to use for a branch
