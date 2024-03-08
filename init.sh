#!/bin/bash

# Exit script immediately if any command returns a non-zero exit status.
set -e

# Prompt for project name (default to local folder name)
DEFAULT_ARTIFACT_ID=`pwd | sed -e 's|^.*/||'`
read -p "Artifact ID [$DEFAULT_ARTIFACT_ID]: " ARTIFACT_ID
ARTIFACT_ID=${ARTIFACT_ID:-$DEFAULT_ARTIFACT_ID}
# echo Artifact ID is $ARTIFACT_ID

# Prompt for Group ID
DEFAULT_GROUP_ID=com.example
read -p "Group ID [$DEFAULT_GROUP_ID]: " GROUP_ID
GROUP_ID=${GROUP_ID:-$DEFAULT_GROUP_ID}
# echo Group ID is $GROUP_ID

# Prompt for Java version
DEFAULT_JAVA_VERSION=17
read -p "Java version [$DEFAULT_JAVA_VERSION]: " JAVA_VERSION
JAVA_VERSION=${JAVA_VERSION:-$DEFAULT_JAVA_VERSION}
# echo Java version is $JAVA_VERSION


# Prompt to keep quickstart in new project git history (default to yes)
while true; do
    read -p "Keep quickstart-java-project in $ARTIFACT_ID git history? ([Y]/n): " yn
    case $yn in
        ""    ) KEEP_HISTORY=true;  break;;
        [Yy]* ) KEEP_HISTORY=true;  break;;
        [Nn]* ) KEEP_HISTORY=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
# echo $KEEP_HISTORY

# Artifact Name is the artifact id, replacing - and _ with spaces and capitalizing the first letter of each word
ARTIFACT_NAME=`echo "$ARTIFACT_ID" | sed -re 's/(^|[ _-]+)([a-zA-Z])/ \u\2/g' -e 's/^ +//'`
# Class Name is Artifact Name removing the spaces
CLASS_NAME=`echo "${ARTIFACT_NAME}Application" | sed -re 's/\s+//g'`
# Package Structure is the group ID, removing separators and in all lower case
PACKAGE_STRUCTURE=`echo "${GROUP_ID}.${ARTIFACT_ID}" | sed -re 's/[ _-]+//g' | awk '{print tolower($0)}'`
PACKAGE_DIRS=`echo "$PACKAGE_STRUCTURE" | sed -re 's/\./\//g'`
echo "Class Name=$CLASS_NAME"
echo "Package Structure=$PACKAGE_STRUCTURE"
echo "Package Dirs=$PACKAGE_DIRS"

# Delete quickstart-java-project specific files and settings
rm README.md LICENSE init.sh
# Delete the url tag
sed -e '/github.com\/baincd/d' -i pom.xml
git commit -a -m "Delete quickstart-java-project specific files and settings"

# In `POM.xml` update groupId, artifactId, name, Java version
sed -e "s/<groupId>com\.example/<groupId>$GROUP_ID/" -i pom.xml
sed -e "s/<artifactId>quickstart-java-project/<artifactId>$ARTIFACT_ID/" -i pom.xml
sed -e "s/<name>quickstart-java-project/<name>$ARTIFACT_ID/" -i pom.xml
sed -E "s/(<maven\.compiler\.\w+>)[0-9]+/\1$JAVA_VERSION/" -i pom.xml
if [[ -n "$(git status --porcelain)" ]]; then
    git commit -a -m "Initialize $ARTIFACT_ID POM";
else
    echo "pom.xml is unchanged";
fi


# Update the Java files class name and package hierarchy
function updateJavaFiles () {
    local DIR=$1
    local SUFFIX=$2

    cd $DIR
    sed -E "s/^package .*$/package ${PACKAGE_STRUCTURE};/" -i com/example/quickstartjavaproject/QuickstartJavaProjectApplication${SUFFIX}.java
    sed -E "s/(class +)\w+/\1${CLASS_NAME}${SUFFIX}/"      -i com/example/quickstartjavaproject/QuickstartJavaProjectApplication${SUFFIX}.java
    [ -d $PACKAGE_DIRS ] || mkdir -p $PACKAGE_DIRS
    [ -f $PACKAGE_DIRS/${CLASS_NAME}${SUFFIX}.java ] || mv com/example/quickstartjavaproject/QuickstartJavaProjectApplication${SUFFIX}.java $PACKAGE_DIRS/${CLASS_NAME}${SUFFIX}.java
    find . -type d -empty -delete
    cd ../../..
}
updateJavaFiles "src/main/java"
updateJavaFiles "src/test/java" "Test"
if [[ -n "$(git status --porcelain)" ]]; then
    git add -A . && git commit -m "Initialize $ARTIFACT_ID Java classes";
else
    echo "Java files are unchanged";
fi


# Create new git history (if that option was selected)
if [ "$KEEP_HISTORY" = false ]; then
    git branch -m quickstart-${ARTIFACT_ID}_archive
    git checkout --orphan main
    git reset
    git commit --allow-empty -m "Git Repo Initialized"
    git add -A .
    git commit -a -m "$ARTIFACT_ID Initial Commit"
fi

echo ""
echo "Application $ARTIFACT_ID Initialized!"
