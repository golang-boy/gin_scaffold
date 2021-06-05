PROJECT=$1
find ./*   -type f   -exec bash -c  'sed -i  "s/gin_scaffold/${PROJECT}/g"  $1' - {} \;
