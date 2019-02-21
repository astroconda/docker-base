#!/bin/bash
HUB=${2:-astroconda}
PROJECT=${HUB}/base
PROJECT_VERSION="${1}"
TAGS=()

if [[ -z ${PROJECT_VERSION} ]]; then
    echo "Project version required [e.g. 1.2.3... \$(git describe)]"
    exit 1
fi

read \
    PROJECT_VERSION_MAJOR \
    PROJECT_VERSION_MINOR \
    PROJECT_VERSION_PATCH <<< ${PROJECT_VERSION//\./ }

case "${HUB}" in
    *amazonaws\.com)
        if ! type -p aws; then
            echo "awscli client not installed"
            exit 1
        fi
        REGION="$(awk -F'.' '{print $(NF-2)}' <<< ${HUB})"
        $(aws ecr get-login --no-include-email --region ${REGION})
        unset REGION
        ;;
    *)
        # Assume default index
        docker login
        ;;
esac
set -x

TAGS+=( "-t ${PROJECT}:${PROJECT_VERSION}" )
is_tag_latest=$([[ -f LATEST ]] && [[ $(<LATEST) == ${PROJECT_VERSION} ]] && echo yes)
if [[ -n ${is_tag_latest} ]]; then
    TAGS+=( "-t ${PROJECT}:latest" )
    TAGS+=( "-t ${PROJECT}:${PROJECT_VERSION_MAJOR}" )
    TAGS+=( "-t ${PROJECT}:${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}" )
fi

docker build ${TAGS[@]} .
rv=$?

if (( rv > 0 )); then
    echo "Failed... Image not published"
    exit $?
fi


max_retry=4
retry=0
set +e
while (( retry != max_retry ))
do
    echo "Push attempt #$(( retry + 1 ))"
    docker push "${PROJECT}"
    rv=$?
    if [[ ${rv} == 0 ]]; then
        break
    fi
    (( retry++ ))
done

exit ${rv}
