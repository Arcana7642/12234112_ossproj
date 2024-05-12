#!/bin/bash

file_exists() {
    if [ ! -f "$1" ]; then
        echo "Error: $1 does not exist."
        exit 1
    fi
}


file_exists "players.csv"
file_exists "teams.csv"
file_exists "matches.csv"

echo "************OSS1 - Project1************"
echo "*      StudentID : KyungHyun Park     *"
echo "*      Name : 12234112                *"
echo "***************************************"
echo "[MENU]"
echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
echo "2. Get the team data to enter a league position in teams.csv"
echo "3. Get the Top-3 Attendance matches in mateches.csv"
echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
echo "5. Get the modified format of date_GMT in matches.csv"
echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
echo "7. Exit"

read -p "Enter your CHOICE [1-7] " reply

while [ $reply -ne 7 ]; do
    if [ $reply -eq 1 ]; then
        echo
        read -p "Do you want to get the Heung-Min son's data? (y/n): " answer
        echo
        if [ "$answer" = "y" ]; then
            player_file="players.csv"

            line=$(sed -n '225p' "$player_file")

            team=$(echo "$line" | cut -d ',' -f4)
            appearances=$(echo "$line" | cut -d ',' -f6)
            goals=$(echo "$line" | cut -d ',' -f7)
            assists=$(echo "$line" | cut -d ',' -f8)

            echo "Team: $team Appearances: $appearances Goals: $goals Assists: $assists"

        fi
    fi

    if [ $reply -eq 2 ]; then
        read -p "Enter a number between 1 and 20: " rate
        echo

        team_file="teams.csv"
        team_data=$(awk -v team_rate="$rate" -F ',' '$6 == team_rate {print}' "$team_file")

        if [ -n "$team_data" ]; then
            team_name=$(echo "$team_data" | cut -d ',' -f1)
  
            wins=$(echo "$team_data" | cut -d ',' -f2)
            draws=$(echo "$team_data" | cut -d ',' -f3)
            losses=$(echo "$team_data" | cut -d ',' -f4)
            win_rate=$(echo "scale=6; $wins / ($wins + $draws + $losses)" | bc)

            echo "Team: $team_name Win Rate: 0$win_rate"


        fi
    fi

    if [ $reply -eq 3 ]; then
        echo
        read -p "Do you want to know Top-3 attendacne data and average attendance? (y/n): " answer
        echo
        if [ "$answer" = "y" ]; then
            matches_file="matches.csv"
            top_3_matches=$(sort -t ',' -k2 -rn "$matches_file" | head -n 3)

            echo "Top-3 Attendance Matches:"
            echo "$top_3_matches" | awk -F ',' '{print $3 " vs " $4 " (" $1 ")\n" $2, $7 "\n"}'
        fi
    fi

if [ $reply -eq 4 ]; then
    echo
    read -p "Do you want to know the top scorer for each team? (y/n): " answer
    echo
    if [ "$answer" = "y" ]; then
sort -t, -k6 -n teams.csv > sorted_teams.csv


    while IFS=',' read -r team_name wins draws losses ppg league_position cards_total shots fouls; do

        top_scorer=$(awk -F, -v team="$team_name" '
            $4 == team {
                if ($7 > max_goals) {
                    max_goals = $7
                    name = $1
                    goals = $7
                }
            }
            END { print name, goals }
        ' players.csv)


        echo "$league_position $team_name"
        echo "$top_scorer"

    done < sorted_teams.csv
    fi
fi


if [ $reply -eq 5 ]; then
    read -p "Do you want to modify the format of date? (y/n)" answer
    if [ "$answer" = "y" ]; then 
        modify_date_format() {
            echo "$1" | sed -E 's/Aug/08/; s/([0-9]+) ([0-9]+) ([0-9]+) (.*)/\3\/\1\/\2 \4/g; s/-//g'
        }

        for i in $(seq 2 11); do
            str=$(awk -F, -v a=$i 'NR==a {print $1}' matches.csv)
            modified_str=$(modify_date_format "$str")
            echo "$modified_str"
        done
    fi
fi

if [ $reply -eq 6 ]; then

awk -F, 'NR > 1 {print NR-1 ") " $1}' teams.csv


echo -n "Enter your CHOICE(1~7): "
read team_number


team_name=$(awk -F, -v num="$team_number" 'NR == num+1 {print $1}' teams.csv)


awk -F, -v name="$team_name" '
$3 == name {
    diff = $5 - $6
    if (diff > max_diff) {
        max_diff = diff
        max_rows = sprintf("%s\n%s %s vs %s %s", $1, $3, $5, $6, $4)
    } else if (diff == max_diff) {
        max_rows = max_rows "\n" sprintf("%s\n%s %s vs %s %s", $1, $3, $5, $6, $4)
    }
}
END {
    if (max_rows) print max_rows
}' matches.csv

fi


    read -p "Enter your CHOICE [1-7] " reply
done
