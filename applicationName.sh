set -e

export HELM_ARGS=$1

export FILES=""

eval "array=($HELM_ARGS)";
for i in "${!array[@]}"; do
  value="${array[$i]}"
  if [ $value == '-f' ]
  then
    export FILES="$FILES ${array[$i+1]}"
  elif [[ $value == applicationName=* ]]
  then
    export APPLICATION_NAME=$(echo $value | sed 's/applicationName=//g')
    echo $APPLICATION_NAME
    exit 0
  elif [[ $value == application.name=* ]]
  then
    export APPLICATION_NAME=$(echo $value | sed 's/application.name=//g')
    echo $APPLICATION_NAME
    exit 0
  fi
done

eval "fileArray=($FILES)";

if [ ${#fileArray[@]} = 0 ]
then
  echo "NO APPLICATION_NAME :("
  exit 1
fi

if [ ${#fileArray[@]} = 1 ] && [ ! -z $(cat $FILES | yq r - applicationName) ]
then
  APPLICATION_NAME=$(cat $FILES | yq r - applicationName)
elif [ ${#fileArray[@]} = 1 ] && [ ! -z $(cat $FILES | yq r - appplcation.name) ]
then
  APPLICATION_NAME=$(cat $FILES | yq r - application.name)
else
  REVERSED_FILES=$(echo $FILES | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }')
  APPLICATION_NAME=$(yq m $REVERSED_FILES | yq r - applicationName)
  APPLICATION_NAME=$(yq m $REVERSED_FILES | yq r - application.name)
fi

if [ ! -z "$APPLICATION_NAME"]
then
  echo "NO APPLICATION_NAME :("
  exit 1
fi

echo $APPLICATION_NAME