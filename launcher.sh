#!/bin/bash

SEED=

SCRIPT_FILE_PATH=$(readlink -f $0)
SCRIPT_DIR_PATH=`dirname $SCRIPT_FILE_PATH`

# ============================================================================

function print_help_message {
  echo "Launches \"aluminium-cricket-t\" program or helps to  build it"
  echo "Options:"
  echo "-h or --help  :   print this message and exit"
  echo "-u            :   unpack thirdpaty libs from archives"
  echo "-s or --seed  :   will be used later for debugging purposes (not available for now)"
}

function unpack_thirdparty {
  THIRDPARTY_ARCHIVED_DIR="${SCRIPT_DIR_PATH}/thirdparty_archived"
  THIRDPARTY_DIR="${SCRIPT_DIR_PATH}/thirdparty"
  echo "Preparing to unpack thirdparty archives:"
  echo "from: ${THIRDPARTY_ARCHIVED_DIR}"
  echo "to  : ${THIRDPARTY_DIR}"
  if [ ! -d ${THIRDPARTY_ARCHIVED_DIR} ]; then
    echo "ERROR: folder ${THIRDPARTY_ARCHIVED_DIR} not found"
    return 1
  fi

  # if "./thirdparty" folder exists, it will be saved as "./thirdparty_bac"
  # if "./thirdparty_bac" folder exists, it will removed"
  if [ -d ${THIRDPARTY_DIR} ]; then
    THIRDPARTY_DIR_BAC="${SCRIPT_DIR_PATH}/thirdparty_bac"
    if [ -d ${THIRDPARTY_DIR_BAC} ]; then
      echo "removing folder ${THIRDPARTY_DIR_BAC}"
      rm -rf ${THIRDPARTY_DIR_BAC}
    fi
    
    echo "saving existing ${THIRDPARTY_DIR} to bac"
    mv ${THIRDPARTY_DIR} ${THIRDPARTY_DIR_BAC}
 
    mkdir ${THIRDPARTY_DIR}
  else
    mkdir ${THIRDPARTY_DIR}  
  fi

  find ${THIRDPARTY_ARCHIVED_DIR} -name '*.tar.gz' -type f | while read fname; do
    echo "Extracting ${fname}"
    tar -xzf ${fname} -C ${THIRDPARTY_DIR}
  done
}

# ============================================================================

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -s|--seed)
    SEED="$2"
    shift 
    shift 
    ;;
    -h|--help)
    print_help_message
    exit 0
    ;;
    -u)
    unpack_thirdparty
    exit 0
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done

if [[ !  -z  ${POSITIONAL}  ]] ; then
  echo "ERROR: unprocessed(unknown) options: " ${POSITIONAL}
  exit 1
fi

#set -- "${POSITIONAL[@]}" # restore positional parameters, not needed  in this script

# ============================================================================
# ============================================================================

love ${SCRIPT_DIR_PATH}
