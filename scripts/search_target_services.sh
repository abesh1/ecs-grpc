#!/bin/bash

ROOT="services"
REPOSITORY_TYPE="github"
CIRCLE_API="https://circleci.com/api"

PARAMETERS='"trigger":false'

TARGET_SERVICES=$(git diff --name-only "HEAD^..HEAD" | \
    grep -E "^${ROOT}/" | \
    awk '{sub("services/", "", $0); print $0}' | \
    awk '{print substr($0, 0, index($0, "/"))}' | \
    awk  '!a[$0]++')

for SERVICE in ${TARGET_SERVICES[@]}
do
  PARAMETERS+=", \"${SERVICE}\":true"
  COUNT=$((COUNT + 1))
done

echo "Changes detected in ${COUNT} package(s)."

DATA="{ \"branch\": \"$CIRCLE_BRANCH\", \"parameters\": { $PARAMETERS } }"
echo "Triggering pipeline with data:"
echo -e "  $DATA"

URL="${CIRCLE_API}/v2/project/${REPOSITORY_TYPE}/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/pipeline"
HTTP_RESPONSE=$(curl -s -u ${CIRCLE_TOKEN}: -o response.txt -w "%{http_code}" -X POST --header "Content-Type: application/json" -d "${DATA}" "${URL}")

echo "${URL}"
echo "${CIRCLE_TOKEN}"

if [ "$HTTP_RESPONSE" -ge "200" ] && [ "$HTTP_RESPONSE" -lt "300" ]; then
    echo "API call succeeded."
    echo "Response:"
    cat response.txt
else
    echo -e "\e[93mReceived status code: ${HTTP_RESPONSE}\e[0m"
    echo "Response:"
    cat response.txt
    exit 1
fi