#!/bin/sh
#
# Uses sed and cpp to get nng.h into a form cffi can swallow.
# removes #includes,
echo "// THIS FILE WAS AUTOMATICALLY GENERATED BY $0" > nng_api.h
process_header() {
    # remove includes; otherwise cpp chokes
    sed '/^#include/d' "$1" | \
    # cpp, since cffi can't do includes
    cpp | \
    # Strip all preprocessor directives
    sed 's/^#.*$//g' | \
    # remove blank lines
    sed '/^$/d' | \
    # remove NNG_DECL since we don't need it
    sed 's/^NNG_DECL *//g'
}

process_header nng/include/nng/nng.h | awk '1;/extern int nng_msg_getopt/{exit}'| head -n -1 >> nng_api.h
process_header nng/include/nng/protocol/bus0/bus.h >> nng_api.h
process_header nng/include/nng/protocol/pair0/pair.h >> nng_api.h
process_header nng/include/nng/protocol/pair1/pair.h >> nng_api.h
process_header nng/include/nng/protocol/pipeline0/push.h >> nng_api.h
process_header nng/include/nng/protocol/pipeline0/pull.h >> nng_api.h
process_header nng/include/nng/protocol/pubsub0/pub.h >> nng_api.h
process_header nng/include/nng/protocol/pubsub0/sub.h >> nng_api.h
process_header nng/include/nng/protocol/reqrep0/req.h >> nng_api.h
process_header nng/include/nng/protocol/reqrep0/rep.h >> nng_api.h
process_header nng/include/nng/protocol/survey0/survey.h >> nng_api.h
process_header nng/include/nng/protocol/survey0/respond.h >> nng_api.h
# nng_tls_config_{pass,key} have only stub implementations, and are
# undefined when building with mbedtls. so we explicitly exclude them
process_header nng/include/nng/supplemental/tls/tls.h | egrep -v "nng_tls_config_(pass|key)" >> nng_api.h
process_header nng/include/nng/transport/tls/tls.h >> nng_api.h

grep '^#define NNG_FLAG' nng/include/nng/nng.h >> nng_api.h
grep '^#define NNG_.*_VERSION' nng/include/nng/nng.h >> nng_api.h
