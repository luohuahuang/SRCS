SRCS
====

This is a Shell script to simulate the basic core RCS function, like check out a file with a specified version, check in a file, show all log metadata of a file, diff two versions, etc.
It’s logic:
* For a totally new file, first run ‘init’ command to add a placeholder in the repository. Without ‘init’, user is not able to do other SRCS activities.
* After ‘init’, user can run ‘ci’ to check in a new version of file in the repository. The Version 0 is empty and it is for placeholder. The versions of the check in are starting with 1, 2, 3,…,10,…
* User can use ‘co’ to check out a latest version of the file from the repository or provide a ‘version’ in the command to check out a specified version.
* User can use ‘diff’ command to diff two versions existing in the repository or diff one version with the local copy.
* User can use ‘log’ command to print all of the metadata info pertaining to a file including its check in comments and version information.

Detailed info
====
* In SRCS – Check in file: http://luohuahuang.com/2014/05/17/srcs-startup/ - It implements the initial and check in a file.
* In SRCS – check out file: http://luohuahuang.com/2014/05/17/srcs-check-out-file/ - It implements check out a file with a specified version.
* In SRCS – log: http://luohuahuang.com/2014/05/20/srcs-log/ - It implements a ‘log’ command to allow user to print all the metadata for a file.
* In SRCS – diff: http://luohuahuang.com/2014/05/20/srcs-diff/ - It implements a ‘diff’ command to show diff for two versions.
* All in One - SRCS – Shell Revision Control System: http://luohuahuang.com/2014/05/21/srcs-shell-revision-control-system/

Contact
====
You can reach me at
* Email: luohua.huang@gmail.com
* Blog: http://luohuahuang.com 
