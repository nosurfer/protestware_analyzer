#!/bin/bash

# пути сохранения
RESULTS_DIR=${RESULTS_DIR:-"/tmp/results"}
STATIC_RESULTS_DIR=${STATIC_RESULTS_DIR:-"/tmp/staticResults"}
FILE_WRITE_RESULTS_DIR=${FILE_WRITE_RESULTS_DIR:-"/tmp/writeResults"}
ANALYZED_PACKAGES_DIR=${ANALYZED_PACKAGES_DIR:-"/tmp/analyzedPackages"}
LOGS_DIR=${LOGS_DIR:-"/tmp/dockertmp"}
STRACE_LOGS_DIR=${STRACE_LOGS_DIR:-"/tmp/straceLogs"}