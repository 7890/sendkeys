sk - sendkeys
=============

Install on Linux
----------------

```
  git clone git://github.com/7890/sendkeys.git
  cd sendkeys
  make
  ./sk
  #ctrl+c
  #sudo make install
  #will install to /usr/local/bin, /usr/local/share/man/man1
```

man page
--------

```
SK(1)                                                                                     SK(1)



NAME
       sk - send every keystroke as OSC message

SYNOPSIS
       sk [-h | --help | -v | --version | -i | --info] 

       sk [local OSC port [remote OSC host [remote OSC port]]]

DESCRIPTION
       sk sends interpreted cooked keycodes as OSC messages.

       The following characters and keys are understood:

       a-z, A-Z, 0-9, +-_"'%&/\()=?.:,;[]{}<>^~$@#|*

       F1-F12

       space, backspace, delete, enter, arrow keys, page keys, home, end, insert, tabulator,
       escape

       sk version is 0.1

OPTIONS
       -h, --help
           Show help (if given as only argument)

       -v, --version
           Show version (if given as only argument)

       -i, --info
           Show info (if given as only argument)

       local OSC port
           Messages will have a source port equal to local OSC port. Default: 7777

       remote OSC host
           Messages are sent to specified host. Default: localhost

       remote OSC port
           Messages are sent to specified port, Deault: 7770

EXIT STATUS
       0
           Success

       1
           Error

EXAMPLES
       Start with standard values
           $ sk

       Start with all OSC properties set
           $ sk 1234 10.10.10.22 4444

BUGS
       See the BUGS file in the source distribution.

AUTHOR
       sk was written by Thomas Brand <tom@trellis.ch>

RESOURCES
       Github: https://github.com/7890/sendkeys

SEE ALSO
       oscdump(1)

COPYING
       Copyright (C) 2013 Thomas Brand. Free use of this software is granted under the terms of
       the GNU General Public License (GPL).



                                           07/23/2013                                     SK(1)

```
