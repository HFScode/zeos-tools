# How to write update scripts.

## chrooted file system
You should always consider that your scripts will run under a chrooted environment.
That means every path in your script should refer directories that will be present in the filesystem after the system is being installed and should not refer pathes to your current working directory

For example we assume that your working directory (ie, the directory where you extracted the ISO) is located in 
```shell
/usr/share/zpkgs/ISO/
```
In such a case, the root filesystem of the final install will be in:  
```shell
/usr/share/zpkgs/ISO/remaster-root/
```
Now assusme your script should create a file called «dummy.txt» in 
```shell
/usr/share/dummy/dummy.txt 
```
you must specify 
```shell
/usr/share/dummy/dummy.txt 
```
as the path of this file  and not 
```shell
/usr/share/zpkgs/ISO/remaster-root//usr/share/dummy/dummy.txt
```

You should always target the the rootfile system of the final installation.

Taking that into account, you can write your script the same way you write bash scripts for your local machine. You can use, all the standard bash command, deb file management commands (apt-get, gdebi and so). The only thing you can’t do is to run GUI applications. So always use the command line version of all you applications

## How to control the execution order of the scripts.
By default, the main install script will execute update scripts in alphabetical order, wich is not necessarly what you’ll want. For example you may need to be certain that a series of scripts will be executed in precise order because some of them install common dependencies for some others that should be executed after the dependencies are correctly set.

They are basically two ways to get control over the order of execution of the scripts.
### Using a package list file
The first one is to use a package list file and to pass it as an argument of the install.sh script.
You should create simple text file with the file name of the scripts to be run, on script per line in the order you want to execute them

```shell
script1.sh
script2.sh
script3.sh
```
No comment or anyting else is allowed, only the scripts file names without the path.

By doing so only the scripts that listed in the provided package list, will run and they will be run in the order they appear on the list. That can be useful to only install a series of packages for identifying side effects or for debug purpose.

### using the zexecprior.sh script
The second way to get control over execution order, is to use the zexecprior.sh script.
This script will interupt the execution of the currently installed script and run the script passed as parameter.
For example if you want script1.sh to be installed after script2.sh you just have to add the following line at the beginning of script1.sh. 

```shell
/usr/share/zpkgs/zeos-tools/zexecprior.sh script2.sh
```

By doing so the installation of script1.sh will be suspended, then script2.sh will be installed then the installation of script1.sh will be resumed.
You can of course specifiy several scripts to be installed before the current one.

If a same script is scpecified several times (in the same script of in another one) it won’t be run more than one time.

For example imagine that in script1.sh you add the following lines because script1.sh needs to be installed after script2.sh and script3.sh :


```shell
/usr/share/zpkgs/zeos-tools/zexecprior.sh script2.sh
/usr/share/zpkgs/zeos-tools/zexecprior.sh script3.sh
```

And imagine now that in script2.sh somebody else already added the following line because script2.sh needs to be installed after script3.sh :

```shell
/usr/share/zpkgs/zeos-tools/zexecprior.sh script3.sh.
```

In such case the main install script will do the following

1. Start script1
2. Interrupt script1 and start script2 (zexecprior call in script1 to script2)
3. Interrup script2 and start script3 (zexecprior call in script2 to script3)
4. Resume script2 and continue until the end.
5. Resume script1
6. Interrupt script1 and start script3 again (zexecprior call in script1 to script3)
7. Detect that script3 has already been installed previously and cancel the redundant installation
8. Resume script1 and continue until the end.

### Circular calls

By adding zexectprior.sh calls everywhere in your scripts, you can easily falls into a circular series of call.
For example 
1. script1 calls script2
2. script2 calls script3
3. script3 calls script1
4. script1 calls script2 again 
5. script2 calls script3 agin
6. and so… 

You’ll be prisoner in an infinite loop....

To avoid that the main install script checks if a call is made to an already running script.

So in our last example : 
1. script1 will call script2
2. script2 will call script3
3. script3 will call script1
4. The main install process will be stopped with a circular call loop warning.

At this moment you’ll be asked if you are sure that it is what you want and if you are certain that your script will be able to deal with such a situation. Honestly we don’t see any reason to make corcular calls but it is up to you to decide wether or not you want to take such a risk.
We higly encourage you to avoid such a situation even if your script can manage it, because it is always possible that another user run your script in a different situation (ie by providing a package list) and accidentally creates really dangerous side effects..
