#!/bin/bash

set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

USS_DIRECTORY="/z/$LOWERCASE_USERNAME/cobolcheck"

# Connection arguments
ZOWE_ARGS=(
    --host "$ZOWE_HOST"
    --port "$ZOWE_PORT"
    --user "$ZOWE_USERNAME"
    --pass "$ZOWE_PASSWORD"
)

echo "Checking Zowe CLI connection..."

zowe zosmf check status "${ZOWE_ARGS[@]}"

echo "Checking USS directory..."

if ! zowe zos-files list uss-files "$USS_DIRECTORY" "${ZOWE_ARGS[@]}" >/dev/null 2>&1; then

    echo "Directory does not exist. Creating it..."

    zowe zos-files create uss-directory "$USS_DIRECTORY" "${ZOWE_ARGS[@]}"

else

    echo "Directory already exists."

fi

echo "Uploading COBOL Check files..."

zowe zos-files upload dir-to-uss "./cobol-check" "$USS_DIRECTORY" \
    --recursive \
    --binary-files "cobol-check-0.2.9.jar" \
    "${ZOWE_ARGS[@]}"

echo "Verifying upload..."

zowe zos-files list uss-files "$USS_DIRECTORY" "${ZOWE_ARGS[@]}"

echo "Upload completed successfully."
