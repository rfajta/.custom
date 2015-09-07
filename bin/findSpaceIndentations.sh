
find . -name "$1" -exec grep -l "^   *[^ ]*$" {} \;
