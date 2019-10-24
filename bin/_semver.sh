#!/bin/bash

semver-cmp() {
  local left="${1}"
  local right="${2}"
  
  [[ "${left}" =~ ^([0-9x]+)\.([0-9x]+)\.([0-9x]+)$ ]] || return 1

  local left_major="${BASH_REMATCH[1]}"
  local left_minor="${BASH_REMATCH[2]}"
  local left_patch="${BASH_REMATCH[3]}"

  [[ "${right}" =~ ^([0-9x]+)\.([0-9x]+)\.([0-9x]+)$ ]] || return 1

  local right_major="${BASH_REMATCH[1]}"
  local right_minor="${BASH_REMATCH[2]}"
  local right_patch="${BASH_REMATCH[3]}"

  [ "${left_major}" = "x" ] || [ "${right_major}" = "x" ] && echo "=" && return 0
  [ "${left_major}" -lt "${right_major}" ] && echo "<" && return 0
  [ "${left_major}" -gt "${right_major}" ] && echo ">" && return 0
  [ "${left_minor}" = "x" ] || [ "${right_minor}" = "x" ] && echo "=" && return 0
  [ "${left_minor}" -lt "${right_minor}" ] && echo "<" && return 0
  [ "${left_minor}" -gt "${right_minor}" ] && echo ">" && return 0
  [ "${left_patch}" = "x" ] || [ "${right_patch}" = "x" ] && echo "=" && return 0
  [ "${left_patch}" -lt "${right_patch}" ] && echo "<" && return 0
  [ "${left_patch}" -gt "${right_patch}" ] && echo ">" && return 0
  echo "="
}

semver-eq() {
  [ "$(semver-cmp "${1}" "${2}")" = "=" ] && \
    return 0 || \
    return 1
}

semver-lt() {
  [ "$(semver-cmp "${1}" "${2}")" = "<" ] && \
    return 0 || \
    return 1
}

semver-gt() {
  [ "$(semver-cmp "${1}" "${2}")" = ">" ] && \
    return 0 || \
    return 1
}

semver-lte() {
  local cmp=$(semver-cmp "${1}" "${2}")

  if [ "${cmp}" = "<" ] || [ "${cmp}" = "=" ]; then
    return 0
  else
    return 1
  fi
}

semver-gte() {
  local cmp=$(semver-cmp "${1}" "${2}")

  if [ "${cmp}" = ">" ] || [ "${cmp}" = "=" ]; then
    return 0
  else
    return 1
  fi
}

is-semver() {
  [[ "${1}" =~ ^([0-9x]+)(\.([0-9x]+)(\.([0-9x]+))?)?$ ]] || return 1
}

is-semver-pattern() {
  [[ "${1}" =~ ^(((<=?|>=?|~|\^)?)([0-9x]+)(\.([0-9x]+)(\.([0-9x]+))?)|\ |\|\|)+$ ]] || return 1
}

semver-match() {
  local pattern="${1}"
  local version="${2}"

  # turn spaces into AND to prevent splitting on them
  pattern="${pattern// /AND}"

  # process OR groups
  local ors_match=false
  local or_patterns=(${pattern//||/ })

  for or_pattern in "${or_patterns[@]}"; do
    ands_match=true
    local and_patterns=(${or_pattern//AND/ })
    for and_pattern in ${and_patterns[@]}; do
      if [ -n "${and_pattern}" ] && \
         ! semver-match-single "${and_pattern}" "${version}"; then
        ands_match=false
        break
      fi
    done

    if [ "${ands_match}" = true ]; then
      ors_match=true
      break
    fi
  done

  [ "${ors_match}" = true ]
}

semver-match-single() {
  local pattern="${1}"
  local version="${2}"

  [[ "${pattern}" =~ ^((<=?|>=?|~|\^)?)([0-9x]+)(\.([0-9x]+)(\.([0-9x]+))?)?$ ]] || return 1

  local operator="${BASH_REMATCH[1]}"
  local pattern_major="${BASH_REMATCH[3]:-x}"
  local pattern_minor="${BASH_REMATCH[5]:-x}"
  local pattern_patch="${BASH_REMATCH[7]:-x}"

  [[ "${version}" =~ ^([0-9x]+)(\.([0-9x]+)(\.([0-9x]+))?)?$ ]] || return 1

  local version_major="${BASH_REMATCH[1]:-x}"
  local version_minor="${BASH_REMATCH[3]:-x}"
  local version_patch="${BASH_REMATCH[5]:-x}"

  # reconstitute the values with possible missing parts filled in with placeholders
  pattern="${pattern_major}.${pattern_minor}.${pattern_patch}"
  version="${version_major}.${version_minor}.${version_patch}"

  case "${operator}" in
    # caret range, matches greater than or equal up to next major version
    "^")
      local floor="${pattern}"
      local ceil="$((pattern_major + 1)).0.0"

      semver-gte "${version}" "${floor}" && semver-lt "${version}" "${ceil}"
    ;;

    # tilde range, matches greater than or equal up to next minor version
    "~")
      local floor="${pattern}"
      local ceil="${pattern_major}.$((pattern_minor + 1)).0"

      semver-gte "${version}" "${floor}" && semver-lt "${version}" "${ceil}"
    ;;

    # greater-than range
    ">")
      local floor="${pattern}"

      semver-gt "${version}" "${floor}"
    ;;

    # less-than range
    "<")
      local ceil="${pattern}"

      semver-lt "${version}" "${ceil}"
    ;;

    # greater-than-or-equal range
    ">=")
      local floor="${pattern}"

      semver-gte "${version}" "${floor}"
    ;;

    # less-than-or-equal range
    "<=")
      local ceil="${pattern}"

      semver-lte "${version}" "${ceil}"
    ;;

    # no operator, use exact match
    "")
      semver-eq "${version}" "${pattern}"
    ;;

    *)
      echo "error: unknown version operator: ${operator}" >&2
      return 1
    ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail

  passes=0
  failures=0

  reset="\033[0m"

  check() {
    local version="${1}"
    local pattern="${2}"
    local should_pass="${3}"
    local did_pass=$(semver-match "${pattern}" "${version}" && echo true || echo false)
    local operator="$([ "${should_pass}" = true ] && echo "=~" || echo "!~")"
    local passed="$([ "${should_pass}" = "${did_pass}" ] && echo true || echo false)"
    local color="$([ "${passed}" = true ] && echo "\033[32m" || echo "\033[31m")"

    if [ "${passed}" = false ]; then
      failures=$((failures + 1))
    else
      passes=$((passes + 1))
    fi

    echo -e "${color}${version} ${operator} ${pattern}${reset}"
  }

  pass() {
    check "${1}" "${2}" true
  }

  fail() {
    check "${1}" "${2}" false
  }

  echo "exact matches"
  pass "1.2.3" "1.2.3"
  fail "1.2.4" "1.2.3"
  fail "0.0.1" "0.1.1"
  echo

  echo "tilde ranges"
  pass "1.0.1" "~1.0.0"
  pass "1.0.1" "~1.0.1"
  fail "1.1.1" "~1.0.1"
  fail "0.1.1" "~1.0.1"
  echo

  echo "caret ranges"
  pass "0.1.1" "^0.0.0"
  fail "1.2.0" "^1.2.3"
  pass "1.9.9" "^1.0.0"
  pass "1.9.9" "^1.0.0"
  fail "2.0.0" "^1.9.9"
  echo

  echo "greater-than ranges"
  pass "1.0.0" ">0.0.0"
  fail "1.0.0" ">1.0.0"
  pass "1.0.1" ">1.0.0"
  pass "1.1.0" ">1.0.0"
  echo

  echo "less-than ranges"
  pass "0.9.9" "<1.0.0"
  fail "1.0.0" "<1.0.0"
  pass "1.0.0" "<1.0.1"
  pass "1.0.1" "<1.1.0"
  pass "2.2.0" "<2.3"
  fail "2.3.0" "<2.3"
  echo

  echo "greater-than-or-equal ranges"
  pass "1.0.0" ">=1.0.0"
  pass "1.9.9" ">=1.0.0"
  fail "1.0.0" ">=1.0.1"
  pass "1.0.1" ">=1.0.0"
  fail "1.0.1" ">=1.1.0"
  pass "2.0.0" ">=1.1.0"
  echo

  echo "partially-specified values"
  pass "1" "1"
  pass "1.0" "1.0.0"
  pass "1.0" "1.0.x"
  fail "2" "1.x"
  pass "3" ">2"
  echo

  echo "conjunctions"
  pass "2.2.0" "^2 <2.3"
  fail "2.3.0" "^2 <2.3"
  pass "2.2.9" "^2 <2.3 || 2.4.0"
  pass "2.4.0" "^2 <2.3 || 2.4.0"
  pass "2.4.1" "^2 <2.3 || 2.4"
  pass "1.89.0" "^1 || ^2 || ^3"
  pass "2.7.99" "^1 || ^2 || ^3"
  pass "3.0.55" "^1 || ^2 || ^3"
  pass "12.10.0" "^12.1.0 <12.11"
  echo

  color="$([ "${failures}" = 0 ] && echo "\033[32m" || echo "\033[31m")"
  echo -e "${color}${passes} passed out of $((failures + passes)) total${reset}"

  exit $failures
fi
