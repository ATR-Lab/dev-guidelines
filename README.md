# dev-guidelines
Software and hardware development guidelines

## Table of Contents

- [Software](#project-structure)
	- [Styleguides](#styleguides)
	- [Documentation](documentation)
	- [Dependency Management](#dependency-management)
	- [Version Control](#version-control)
	- [Tools](#tools)
	- [IDEs](#ides)
- [Hardware](#hardware)



## Software

One's profession should not be measured by the actions that are taken, but rather by the end-goal and the means of achieving such goal.

Anyone can program, not everyone can develop scalable, robust, and maintainable software. Let's aim for that...

You may find a list of useful books and [resources here](https://github.com/kPatch/awesome-developer-resources/blob/master/README.md#software-engineering).

### Styleguides

- [Arduino](https://www.arduino.cc/en/Reference/StyleGuide)
- [Ada]()
- [C](http://www.maultech.com/chrislott/resources/cstyle/indhill-cstyle.pdf)
- [C++](https://google.github.io/styleguide/cppguide.html)
- [Java](https://google.github.io/styleguide/javaguide.html)
- [JavaScript](https://github.com/feross/standard)
- [MATLAB](https://sites.google.com/site/matlabstyleguidelines/)
- [Python](https://google.github.io/styleguide/pyguide.html)

### Documentation

Self describing, terse code should be the norm. But, often times the complexity .... 

### Dependency Management

- [Gradle](https://gradle.org)

### Version Control

The following rules must be followed:

1. Make sure the build succeeds before committing
...Rationale: Broken code should not be committed

2. Create feature branches
...Rationale: Changes to a branch don’t affect other developers on the team. This is a good thing because a feature under development can create instability.

3. Pull down the latest changes before beginning to code
...Rationale: Keep you local version up to date. This is crucial if you’re working on feature branch, don’t let your branch diverge too far from the master branch

4. Use meaningful and succinct git messages
...Rationale: “A commit message shows whether a developer is a good collaborator”. A project’s long-term success rests (among other things) on its maintainability and being able to review others’ commits and pull requests with ease. This drives efficiency

- [A Successful Git Branching Model](http://nvie.com/posts/a-successful-git-branching-model/)
- [How to Write a Git Commit Message](http://chris.beams.io/posts/git-commit/)
- [How to Use Git with XCode](https://www.youtube.com/watch?v=9jeQQ7xNb4U )

#### Gitignore

[What is .gitignore?](http://stackoverflow.com/questions/27850222/what-is-gitignore-exactly/27850270)

- A collection of useful [.gitignore templates](https://github.com/github/gitignore)
- The [Ignoring Files chapter](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository#Ignoring-Files) of the Pro Git book.
- The [Ignoring Files article](https://help.github.com/articles/ignoring-files/) on the GitHub Help site.
- The [gitignore(5)](https://git-scm.com/docs/gitignore) manual page.

### Tools

Know your tools, from debuggers, to profilers, to IDEs.

### IDEs

#### IntelliJ

#### Eclipse

## Hardware

### Tools
