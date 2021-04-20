#!/bin/sh

VERSION=$( grep VERSION tmstatus.sh | sed 's/.*=//' )

echo "Version ${VERSION}"
echo 'Did you update the RELEASE_NOTES.md? '
read -r ANSWER
if [ "x${ANSWER}" = "xy" ] ; then    

    make &&
    gh release create "v${VERSION}" --title "tmstatus.sh-${VERSION}" --notes-file RELEASE_NOTES.md "tmstatus.sh-${VERSION}.tar.gz" "tmstatus.sh-${VERSION}.tar.bz2"

fi
