#!/bin/bash

TASKFILE="$HOME/tasks.txt"
DONEFILE="$HOME/tasks_done.txt"

TODAY=$(date +%F)
TOMORROW=$(date -d "+1 day" +%F)
FUTURE=$(date -d "+5 days" +%F)

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

sort_tasks () {

awk '
{
	p=3
	if ($2=="H") p=1
	if ($2=="M") p=2
	if ($2=="L") p=3
	print $1,p,$0
}
' "$TASKFILE" | sort | cut -d' ' -f3-
}

show_tasks () {

echo -e "$CYAN"
echo "==============================="
echo "       TASK DASHBOARD"
echo "==============================="
echo -e "${RESET}"

total=$(wc -l < "$TASKFILE")
donecount=0
[ -f "$DONEFILE" ] && donecount=$(wc -l < "$DONEFILE")

echo "Progress: $donecount / $total completed"
echo

sorted=$(sort_tasks)

echo -e "${RED}Overdue:${RESET}"
echo "$sorted" | awk -v today="$TODAY" '$1 < today {print NR". "$0}'

echo
echo -e "${GREEN}Today:${RESET}"
echo "$sorted" | awk -v today="$TODAY" '$1 == today {print NR" . "$0}'

echo
echo -e "${YELLOW}Tomorrow:${RESET}"
echo "$sorted" | awk -v t="$TOMORROW" '$1 == t {print NR" . "$0}'

echo
echo -e "${CYAN}Next 5 Days:${RESET}"
echo "$sorted" | awk -v today="$TODAY" -v future="$FUTURE" ' $1 > today && $1 <= future {print NR" . "$0}'
}

today_tasks () {

echo -e "${GREEN}Today's Tasks:${RESET}"
sort_tasks | awk -v today="$TODAY" '$1 == today {print NR". "$0}'
}

add_task () {

date_input="$1"
priority="$2"
shift 2
task="$*"

year=$(date +%Y)

# convert MM-DD -> YYYY-MM_DD
date="$year-$date_input"

echo "$date $priority $task" >> "$TASKFILE"

echo "Task added for $date."
}

quick_add () {

priority="$1"
shift
task="$*"

today=$(date +%F)

echo "$today $priority $task" >> "$TASKFILE"

echo "Task added for today."
}
complete_task () {

num="$1"

sorted=$(sort_tasks)

line=$(echo "$sorted" | sed "${num}q;d")

grep -vF "$line" "$TASKFILE" > "$TASKFILE.tmp"
mv "$TASKFILE.tmp" "$TASKFILE"

echo "$line" >> "$DONEFILE"

echo "Task completed."
}

case "$1" in

add)
add_task "$2" "$3" "${@:4}"
;;

done)
complete_task "$2"
;;

today)
today_tasks
;;

+++)
shift
quick_add H "$@"
;;

++)
shift
quick_add M "$@"
;;

+)
shift
quick_add L "$@"
;;

*)
show_tasks
;;

esac

