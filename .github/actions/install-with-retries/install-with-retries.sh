#!/bin/bash

# Environment variable inputs:
#   SKIP_CYPRESS_BINARY (boolean): Skips cypress binary installation if true.
#   NO_LOCKFILE (boolean): Ignores yarn.lock file if true
#   WORKING_DIRECTORY (string): Path to run yarn install at

if [ -n "$WORKING_DIRECTORY" ]; then
  echo "[LOG]: Changing directory to $WORKING_DIRECTORY"
  cd $WORKING_DIRECTORY
fi

if [ "$SKIP_CYPRESS_BINARY" = "true" ]; then
  # Skip cypress binary installation if specified
  # https://docs.cypress.io/guides/references/advanced-installation#Environment-variables
  echo "[LOG]: Setting flag to skip cypress binary installation"
  export CYPRESS_INSTALL_BINARY=0
fi

for i in {1..3}; do
  echo "===================="
  echo "Attempt $i out of 3:"
  echo "===================="

  if [ "$NO_LOCKFILE" = "true" ]; then
    echo "[LOG]: Ignoring yarn.lock file"
    yarn install --no-lockfile --network-timeout 60000
  else
    yarn install --network-timeout 60000
  fi

  # Check return value and exit early if successful
  return_value=$?
  [ $return_value -eq 0 ] && break

  # Only add delay on all but last attempt to prevent unnecessary delay if last attempt fails
  if [ "$i" -le 2 ]; then
    # when publishing to NPM, there may be a delay before the published tag appears, causing failed installs
    # add increasing delay between retries: 10s/20s
    echo "[ERROR]: yarn install failed with exit code $return_value, waiting to retry in $((15 * i)) seconds..."
    sleep $((10 * i))
  fi
done

# exit 0 if last `yarn install` was successful, non-zero otherwise
exit $return_value
