# How to make new .gitignore entries affect all files 

1. `Make changes to .gitignore`
2. `git commit -a -m "Pre .gitignore changes"`
3. `git rm -r --cached .` 
4. `git add .`
5. `git commit -a -m "Pose .gitignore changes"`
6. `git status`

The prompt should say "nothing to commit (working directory clean)"

Source: Nat Darke, '14 on stackoverflow