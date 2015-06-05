#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os,random,sys,time,copy,threading
from getChar import _Getch

RED='\33[1;31m' ; GREEN='\33[1;32m' ; YELLOW='\33[1;33m' ; BLUE='\33[1;34m' ; MAGENTA='\33[1;35m' ; CYAN='\33[1;36m'; NOR='\33[m'; BOLD='\33[1m'
Head=[CYAN,"D"];Body=[MAGENTA,"0"];Food=[BLUE,"I"];Road=[YELLOW,"-"];
RIGHT=0;LEFT=1;UP=2;DOWN=3;
Height=10;Width=30;Board=[];Snake=[];Direct=RIGHT
IsAlive = True;

if os.name=="nt":
    CLEAR="cls"
else:
    CLEAR="clear"

def getchar():
    inkey = _Getch()
    for i in xrange(sys.maxint):
        k=inkey()
        if k<>'':break
    return k;

def init():
    """init Board """
    global Snake
    Board.append(Body);Board.append(Body);Board.append(Head)
    Snake = [[0,2],[0,1],[0,0]]
    for i in range(Height*Width-3):
        Board.append(Road)
    randomFood()

def printBoard():
    strborad = ""
    for i in range(Height):
        str = ""
        for j in range(Width):
            temp = Board[i*Width+j]
            str += temp[0] + temp[1]
        strborad += str + "\n"
    print strborad,NOR

def printHelp():
    print "use key a s w d to move left down up right,q to exit "

def randomFood():
    temp=[]
    global Board
    global IsAlive
    for i in range(Width*Height):
        if Board[i] == Road :
            temp.append(i)
    if len(temp)==0:
        clear()
        printBoard()
        print "you win ! press q to exit!"
        IsAlive = False
    else:
        Board[temp[random.randint(0,len(temp)-1)]]=Food

def updateSnake():
    global Board
    global IsAlive
    for i in range(Height*Width):
        if Board[i] != Food:
            Board[i]=Road
    for i in range(1,len(Snake)):
        Board[Snake[i][0]*Width + Snake[i][1]]=Body
    Board[Snake[0][0]*Width + Snake[0][1]]=Head
    if  Snake[0] in Snake[1:]:
        clear()
        printBoard()
        print "you lose bite yourself! press q to exit!"
        IsAlive = False

def moveon():
    global Snake
    global IsAlive
    while True:
        SnakeHead = copy.deepcopy(Snake[0])
        SnakeTail = copy.deepcopy(Snake[-1])
        if Direct==LEFT:
            if SnakeHead[1] == 0:
                SnakeHead[1]=Width-1
            else:
                SnakeHead[1]=SnakeHead[1]-1
        elif Direct==RIGHT:
            if SnakeHead[1] == Width-1:
                SnakeHead[1]=0
            else:
                SnakeHead[1]=SnakeHead[1]+1
        elif Direct==UP:
            if SnakeHead[0] == 0:
                SnakeHead[0]=Height-1
            else:
                SnakeHead[0]=SnakeHead[0]-1
        elif Direct==DOWN:
            if SnakeHead[0] == Height-1:
                SnakeHead[0]=0
            else:
                SnakeHead[0]=SnakeHead[0]+1
        Snake = [SnakeHead]+Snake[:-1]
        if Board[SnakeHead[0]*Width+SnakeHead[1]]==Food:
            Snake.append(SnakeTail)
            updateSnake()
            randomFood()
        else:
            updateSnake()
        if not IsAlive:
            break
        clear()
        printHelp()
        printBoard()
        time.sleep(0.3)



def clear():
    """clear game board"""
    os.system(CLEAR)

def moveUp():
    global Direct
    if Direct==LEFT or Direct==RIGHT:
        Direct = UP
def moveDown():
    global Direct
    if Direct==LEFT or Direct==RIGHT:
        Direct = DOWN
def moveLeft():
    global Direct
    if Direct==UP or Direct==DOWN:
        Direct = LEFT
def moveRight():
    global Direct
    if Direct==UP or Direct==DOWN:
        Direct = RIGHT
def control():
    while True:
        c=getchar()
        if c=="w" or c=="W":
            moveUp()
        elif c=="s" or c=="S":
            moveDown()
        elif c=="a" or c=="A":
            moveLeft()
        elif c=="d" or c=="D":
            moveRight()
        elif c=="q" or c=="Q":
            exit()
def gameStart():
    init()
    t1 = threading.Thread(target=moveon)
    t1.setDaemon(True)
    t1.start()
    control()

if __name__ == '__main__': # a little test
    gameStart()
