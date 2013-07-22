
```
error:

sk: error while loading shared libraries: libtinfo.so.5: cannot open shared object file: No such file or directory

possible solution:

https://bugs.launchpad.net/ubuntu/+source/ncurses/+bug/259139

The libtinfo.so functionality is built into the libncurses.so shared library. 
For software that expects the libtinfo.so object, do the following:

sudo ln -s /usr/lib/libncurses.so.5 /usr/lib/libtinfo.so.5
sudo ln -s /usr/lib/libtinfo.so.5 /usr/lib/libtinfo.so

```
