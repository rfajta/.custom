for d in $(find . -maxdepth 1 -type d)
do
    du -ms "$d" 2>/dev/null
done
# du -ms -maxdepth 0 .
