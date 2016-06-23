getdim
======
Lua script to get image dimensions. 
Coded by Ilya Kolbin (iskolbin@gmail.com), original code:
http://www.java-gaming.org/index.php?topic=21438.0

Usage
-----

Assume we have 10x10 png named img.png:

```sh
lua getdim.lua img.png [format]
```

prints in console width and height of image, separated by tabulation:

```sh
10	10
```

Format
------

For example:

```sh
lua getdim.lua img.png '$p$tab$w$tab$h$newline'
```

prints in console:

```sh
img.png	10	10
```

Available format options:
	* **$w** -- width
	* **$h** -- height
	* **$t** -- type
	* **$T** -- uppercased type
	* **$p** -- path
	* **$P** -- uppercased type
	* **$$** -- dollar sign
	* **$tab** -- tabulation
	* **$newline** -- newline
