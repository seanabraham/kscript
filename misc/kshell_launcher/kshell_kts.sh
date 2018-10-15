#!/usr/bin/env bash


if [ $# -ne 1 ]; then
    echo "Usage: kshell_kts.sh <kscript.kts>"
    exit 0
fi

argScript=$1

tmpfile="$(mktemp $(dirname "$argScript")/.temp.XXXXXX)"
mv "$tmpfile" "$tmpfile.kts"
tmpfile="$tmpfile.kts"

trap "rm $tmpfile" EXIT

echo '
@file:DependsOn("org.apache.hadoop:hadoop-common:2.7.0")

// should be now on maven central
@file:DependsOn("com.github.khud:kshell-repl-api:0.2.4-1.2.60")

@file:DependsOn("sparklin:jline3-shaded:0.2.5")

@file:DependsOn("sparklin:kshell:0.2.5")

' > $tmpfile

cat $argScript | grep '@file:[DependsOn MavenRepository]' >> $tmpfile

echo "Preparing interactive session by resolving script dependencies..."

## resolve dependencies without running the kscript
KSCRIPT_DIR=$(dirname $(which kscript))
kscript_nocall() { kotlin -classpath ${KSCRIPT_DIR}/kscript.jar kscript.app.KscriptKt "$@";}

kshellCP=$(kscript_nocall $tmpfile | cut -d' ' -f4)

## create new
java -classpath "${kshellCP}" com.github.khud.sparklin.kshell.KotlinShell $@
