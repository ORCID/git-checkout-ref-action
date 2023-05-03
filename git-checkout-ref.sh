#!/bin/bash
#set -x

#
# defaults
#

set -o errexit -o errtrace -o nounset -o functrace -o pipefail
shopt -s inherit_errexit 2>/dev/null || true

trap 'echo "exit_code $? line $LINENO linecallfunc $BASH_COMMAND"' ERR

ref=${GHA_REF:-'default'}
default_branch=${GHA_DEFAULT_BRANCH:-'main'}
USER=$(whoami)

#
# functions
#

NAME=git-checkout-ref.sh

usage(){
I_USAGE="

  Usage:  ${NAME} [OPTIONS]

  Description:

    This is a function to handle the fact that github actions doesn't allow dynamic inputs

  Requirements:


  Options:
      -r  | --ref            ) default | default_branch | sha or git branch
      -db | --default_branch ) provide which default branch to use

"
  echo "$I_USAGE"
  exit
}


#
# args
#

while :
do
  case ${1-default} in
      --*help|-h          ) usage ; exit 0 ;;
      --man               ) usage ; exit 0 ;;
      -v | --verbose      ) VERBOSE=$(($VERBOSE+1)) ; shift ;;
      --debug             ) DEBUG=1; [ "$VERBOSE" == "0" ] && VERBOSE=1 ; shift;;
      --dry-run           ) dry_run=1 ; shift ;;
      -r | --ref          ) ref=$2 ;shift 2 ;;
      -db | --default_branch ) default_branch=$2 ;shift 2 ;;
      --) shift ; break ;;
      -*) echo "WARN: Unknown option (ignored): $1" >&2 ; shift ;;
      *)  break ;;
    esac
done

# handle running locally
GITHUB_OUTPUT=${GITHUB_OUTPUT:-/tmp/$NAME.$USER}

#
# main
#
#set -x

echo "input ref: $ref"

if [[ "$ref" = 'default' ]];then
  # empty ref will cause github actions to perform it's default action:-

  # When checking out the repository that
  # triggered a workflow, this defaults to the reference or SHA for that event.
  # Otherwise, uses the default branch.
  echo "output ref: "

  echo "ref=" >> "$GITHUB_OUTPUT" 2>/dev/null
elif [[ "$ref" = 'default_branch' ]];then
  # NOTE: this will cause checkouts to contain any commits that a github
  #       action pipeline has committed. So if a build relies on some previous formatting actions
  #       an extra git fetch will not be required.
  echo "ref=$default_branch" >> "$GITHUB_OUTPUT" 2>/dev/null
  echo "output ref: $default_branch"
else
  echo "ref=$ref" >> "$GITHUB_OUTPUT" 2>/dev/null
  echo "output ref: $ref"
fi



