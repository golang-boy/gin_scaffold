PROJECT=${1:-gin_scaffold}
echo "project name: $PROJECT"
rm -rf .git
find ./*  -path "./init.sh" -prune -o -type f -print   -exec bash -c  'sed -i "s/gin_scaffold/$2/g"  $1' - {} $PROJECT \;
