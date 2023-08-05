
set -

if test -d "/opt/homebrew/bin/"; then
  PATH="/opt/homebrew/bin/:${PATH}"
fi
export PATH

if which swiftlint > /dev/null; then
  cd "${PROJECT_DIR}"
  swiftlint
  cd "${PROJECT_DIR}/../../Sources"
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi