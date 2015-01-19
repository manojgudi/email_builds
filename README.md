
Email Builds
====

A collection of haskell scripts which enable you to email all your builds.. 
Particularly useful for internal testing, when people dont want to build your source code and test it

Additionally you can point which build is related to which commits of that repository.


## To use:
```sh
$ ./email_build ../path/to/json/file
```

### Sample Email
Android Builds created here:

ChangeLog:

69e3a79 modifications to offline way
c1756f8 ALGO: Updates to filter | Fixes issue #64
2147643 service need not restart now | closes issue #63

CHECKSUMS
builtFile1.apk -> 77cf46469b6dd4f1a251b4dd3486a747
builtFile2.apk -> 779db0e1e5d7f9b9c97d22e2a2f20123
