#!/usr/bin/env bash

head="D";body="0";food="I";road="-"
height=10;width=30;board=();snake=();iseat=false;
RED='\e[1;31m' ; GREEN='\e[1;32m' ; YELLOW='\e[1;33m' ; BLUE='\e[1;34m' ; MAGENTA='\e[1;35m' ; CYAN='\e[1;36m'; NOR='\e[m'; BOLD='\e[1m'

function cprint {
    case "$1" in
        $head) printf "${CYAN}$head$NOR"
            ;;
        $body) printf "${MAGENTA}$body$NOR"
            ;;
        $food) printf "${BLUE}$food$NOR"
            ;;
        $road) printf "${YELLOW}$road$NOR"
            ;;
        *)  printf "${RED}%-4s$NOR" "$1"
            ;;
    esac
}

#init snake and board
function init() {
    board[0]=$body;board[1]=$body;board[2]=$head;
    snake[0]="0 2";snake[1]="0 1";snake[2]="0 0";
    echo right > .direct
    for (( i = 3; i < height*width; i++ )); do
        board[$i]=$road;
    done
}


function randomFood(){
    k=0
    temp=()
    for (( i = 0; i < height*width; i++ )); do
        if [[ ${board[$i]} = $road ]]; then
            temp[$k]=$i
            (( k++ ))    
        fi
    done
    if [[ $k = 0 ]]; then
        echo gameover 
        exit 0
    fi
    ran=$[ RANDOM % k ]
    board[${temp[$ran]}]=$food;
}

function updateSnake(){
    for (( i = 0;i < height*width;i++));do
        board[$i]=$road;
    done
    length=$((${#snake[*]}-1))
    for (( k = length; k > 0; k--)); do
        temp=(${snake[k]})
        board[$((${temp[0]}*width+${temp[1]}))]=$body
    done
    temp=(${snake[0]})
    board[$((${temp[0]}*width+${temp[1]}))]=$head
}


function printfHelp() {
    printf "use a d to move left and right ,q to exit \n"
}

function printfGameBload() {
    for (( i = 0; i < height; i++ )); do
        for (( j = 0; j < width; j++ )); do
            cprint ${board[i*width+j]} 
        done
        printf "\n" 
    done
}

function turnLeft(){
    case `cat .direct` in
        up)
            echo left > .direct
            ;;
        down)
            echo left > .direct
            ;;
    esac
}

function turnRight(){
    case `cat .direct` in
        up)
            echo right > .direct
            ;;
        down)
            echo right> .direct
            ;;
    esac
}

function turnUp(){
    case `cat .direct` in
        left)
            echo up> .direct
            ;;
        right)
            echo up> .direct
            ;;
    esac
}

function turnDown(){
    case `cat .direct` in
        left)
            echo down> .direct
            ;;
        right)
            echo down> .direct
            ;;
    esac
}

function moveon() {
    while true
    do
        length=$((${#snake[*]}-1))
        last=${snake[length]}
        for (( k = length; k > 0; k--)); do
            snake[$k]=${snake[k-1]}
        done
        temp=(${snake[0]})
        case `cat .direct` in
            up)
                case ${temp[0]} in
                    0)
                        snake[0]="$((height-1)) ${temp[1]}"
                        ;;
                    *)
                        snake[0]="$((${temp[0]}-1)) ${temp[1]}"
                        ;;
                esac
                ;;
            down)
                case ${temp[0]} in
                    $(($height-1)))
                        snake[0]="0 ${temp[1]}"
                        ;;
                    *)
                        snake[0]="$((${temp[0]}+1)) ${temp[1]}"
                        ;;
                esac
                ;;
            left)
                case ${temp[1]} in
                    0)
                        snake[0]="${temp[0]} $((width-1))"
                        ;;
                    *)
                        snake[0]="${temp[0]} $((${temp[1]}-1))"
                        ;;
                esac
                ;;
            right)
                case ${temp[1]} in
                    $(($width-1)))
                        snake[0]="${temp[0]} 0"
                        ;;
                    *)
                        snake[0]="${temp[0]} $((${temp[1]}+1))"
                        ;;
                esac
                ;;
        esac
        clear
        updateSnake
        randomFood
        printfHelp
        printfGameBload
        cat .direct
        sleep 1
    done
}

function control(){
    while true 
    do
        read -s -n 1 key
        case "$key" in
            a) turnLeft
                ;;
            d) turnRight
                ;;
            w) turnUp
                ;;
            s) turnDown
                ;;
            q) ps axu | grep snake.sh | grep bash | awk '{print $2}' | xargs kill
                ;;
         esac
    done
}

init
moveon &
control 
