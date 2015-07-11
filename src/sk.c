/*
sk.c
part of sendkeys
Copyright (C) 2013 Thomas Brand

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <ctype.h>
#include <curses.h>
#include "lo/lo.h"

//tb/130722

/*
* inspired by curin1.c, demonstrating basic ncurses single key input 
* (Copyright Paul Griffiths 1999)
* http://www.paulgriffiths.net/program/c/srcs/curin1src.html
*
* compile:
* $ gcc -o sk sk.c `pkg-config --cflags --libs liblo` \
* `pkg-config --cflags --libs ncurses` 
*
*/

void error(int num, const char *m, const char *path);
static void signal_handler(int sig);
void sendKey(int key,char *ckey);

//default port to send OSC messages from (my port)
const char* osc_my_server_port = "7777";
//default host to send OSC messages
const char* osc_send_to_host = "127.0.0.1";
//default port to send OSC messages
const char* osc_send_to_port = "7778";

//osc server
lo_server_thread st;
lo_address loa;

static double version=0.2;

int verbose = 1;
int quiet = 0;

int indicationCounter = 0;

//curses win
WINDOW * mainwin;
char * checkKey(int ch);

//data structure to hold key definitions
struct keydesc
{
	int  code;
	char name[20];
};

//define a selection of keys we will handle
static struct keydesc keys[] = {
	{ KEY_UP,        "arrow_up"	},
	{ KEY_DOWN,      "arrow_down"	},
	{ KEY_LEFT,      "arrow_left"	},
	{ KEY_RIGHT,     "arrow_right"	},
	{ KEY_HOME,      "home"		},
	{ KEY_END,       "end"		},
	{ KEY_BACKSPACE, "backspace"	},
	{ KEY_IC,        "insert"	},
	{ KEY_DC,        "delete"	},
	{ KEY_NPAGE,     "page_down"	},
	{ KEY_PPAGE,     "page_up"	},
	{ KEY_F(1),      "f1"		},
	{ KEY_F(2),      "f2"		},
	{ KEY_F(3),      "f3"		},
	{ KEY_F(4),      "f4"		},
	{ KEY_F(5),      "f5"		},
	{ KEY_F(6),      "f6"		},
	{ KEY_F(7),      "f7"		},
	{ KEY_F(8),      "f8"		},
	{ KEY_F(9),      "f9" 		},
	{ KEY_F(10),     "f10"		},
	{ KEY_F(11),     "f11"		},
	{ KEY_F(12),     "f12"		},
	{ 9,		"tabulator"	},
	{ 10,		"enter"		},
	{ 27,		"escape"	},
	{ -1,		"unsupported"	}
}; //end struct keys

int main (int argc, char *argv[])
{
	int ch;

	//handle ctrl+c etc.
	signal(SIGQUIT, signal_handler);
	signal(SIGTERM, signal_handler);
	signal(SIGHUP, signal_handler);
	signal(SIGINT, signal_handler);

	// Make STDOUT unbuffered
	setbuf(stdout, NULL);

	if (argc >= 2 && 
		( strcmp(argv[1],"-h")==0 || strcmp(argv[1],"--help")==0))
	{
		printf("syntax: sk <osc local port> <osc remote host> <osc remote port>\n\n");
		return(0);
	}
	else if (argc >= 2 && 
		( strcmp(argv[1],"-v")==0 || strcmp(argv[1],"--version")==0))
	{
		printf("%f\n",version);
		return(0);
	}
	if (argc >= 2 && 
		( strcmp(argv[1],"-i")==0 || strcmp(argv[1],"--info")==0))
	{
		printf("sk version %f, Copyright (C) 2013  Thomas Brand\n",version);
                printf("sk comes with ABSOLUTELY NO WARRANTY;\n");
                printf("This is free software, and you are welcome to redistribute it\n");
                printf("under certain conditions; see COPYING for details.\n");
		return(0);
	}

	//remote port
	if (argc >= 4)
	{
		osc_send_to_port=argv[3];
	}
	//remote host
	if (argc >= 3)
	{
		osc_send_to_host=argv[2];
	}
	//local port
	if (argc >= 2)
	{
		osc_my_server_port=argv[1];
	}

	//init osc
	st = lo_server_thread_new(osc_my_server_port, error);
	lo_server_thread_start(st);

	loa = lo_address_new(osc_send_to_host, osc_send_to_port);

	//init ncurses
	if ( (mainwin = initscr()) == NULL )
	{
		fprintf(stderr, "could not initialize ncurses\n");
		exit(1);
	}

	//no 'local' echo
	noecho();
	//hide cursosr
	curs_set(0);
	//enable non-char keys
	keypad(mainwin, TRUE);     

	int indent=3;
	int lastLine=1;

	//tell osc properties
	if(verbose==1)
	{
		mvprintw(1,indent, "___ sk (sendkeys) ___");
		mvprintw(2,indent, "sending OSC to %s:%s",osc_send_to_host,osc_send_to_port);
		mvprintw(3,indent, "sending OSC from (my) port %s",osc_my_server_port);
		lastLine=5;
	}
	if(quiet==0)
	{
		mvprintw(lastLine,indent, "(waiting for input)");
	}

	refresh();

	//abort with ctrl+c -> signal_handler cleans up
	while ( true )
	{
		ch = getch();
		if(ch==-1)
		{
			//continue;
			signal_handler(SIGQUIT);
		}

		//send osc
		sendKey(ch,checkKey(ch));

		deleteln();
		if(quiet==0 && verbose==1)
		{
			mvprintw(lastLine,indent, "0x%x", ch);
			mvprintw(lastLine,indent+8, "%s", checkKey(ch));
			if(indicationCounter>7)
			{
				indicationCounter=0;
			}

			switch(indicationCounter)
			{
				case 0:
					mvprintw(lastLine,indent+20, "(|)");
					break;
				case 1:
					mvprintw(lastLine,indent+20, "(/)");
					break;
				case 2:
					mvprintw(lastLine,indent+20, "(-)");
					break;
				case 3:
					mvprintw(lastLine,indent+20, "(\\)");
					break;
				case 4:
					mvprintw(lastLine,indent+20, "(|)");
					break;
				case 5:
					mvprintw(lastLine,indent+20, "(/)");
					break;
				case 6:
					mvprintw(lastLine,indent+20, "(-)");
					break;
				case 7:
					mvprintw(lastLine,indent+20, "(\\)");
					break;
			}

			indicationCounter++;
		}
		else if(quiet==0)
		{
			mvprintw(lastLine,indent, "%s", checkKey(ch));
		}
		refresh();
	}
} //end main

//handle printable and non-printable chars
char *checkKey(int ch)
{
	static char keych[2] = {0};

	//if printable char, return directly
	if ( isprint(ch) && !(ch & KEY_CODE_YES))
	{
		keych[0] = ch;
		return keych;
	}
	else
	{
		//non-printable, find in keys[]
		int n = 0;
		do
		{
			if ( keys[n].code == ch )
			{
				return keys[n].name;
			}
			n++;
		} while ( keys[n].code != -1 );

		return keys[n].name;
	}
}

//send osc message
void sendKey(int key,char *ckey)
{
	lo_message reply=lo_message_new();

	//lo_message_add_string(reply,osc_my_server_port);
	lo_message_add_int32(reply,key);
	lo_message_add_string(reply,ckey);

	lo_send_message (loa, "/key", reply);
	lo_message_free (reply);
}

//handle ctrl+c etc.
static void signal_handler(int sig)
{
	//clean up
	delwin(mainwin);
	endwin();
	refresh();
	//'local' echo on
	echo();
	//show cursor
	curs_set(1);
	exit(0);
}

//on osc error
void error(int num, const char *msg, const char *path)
{
	printf("liblo server error %d in path %s: %s\n", num, path, msg);
}
