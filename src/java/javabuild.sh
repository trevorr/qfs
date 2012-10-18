#!/bin/bash

if [ $# -eq 1 -a x"$1" = x'-h' ]; then
    echo "Usage:"
    echo "basename $0 [<hadoop-version> | clean]"
    echo "Script to build QFA Java access library and optionally the Apache Hadoop QFS plugin."
    echo "Supported hadoop versions: 1.0.*, 1.1.*, 0.23.*, 2.*.*"
    exit 0
fi

if which mvn > /dev/null; then
    echo "Using Apache Maven to build QFS jars.."
else
    echo "Skipping Java build of QFS. Install Apache Maven and try again." 
    exit 0
fi

hadoop_qfs_profile="none"

if [ $# -eq 1 ]; then
    if [ x"$1" = x'clean' ]; then
        mvn clean
        exit 0
    elif [[ "$1" == 1.0.* || "$1" == 1.1.* ]]; then
        hadoop_qfs_profile="hadoop_branch1_profile"
    elif [[ "$1" == 0.23.* || "$1" == 2.* ]]; then
        hadoop_qfs_profile="hadoop_trunk_profile"
    else
        echo "Unsupported Hadoop release version."
        exit 1
    fi
fi

cwd=$(dirname "$0")
qfs_release_version=$(sh $cwd/../cc/common/buildversgit.sh -v | head -1)
qfs_source_revision=$(sh $cwd/../cc/common/buildversgit.sh -v | tail -1)
if [ -z "$qfs_source_revision" ]; then
    qfs_source_revision="00000000"
fi

echo "qfs_release_version = $qfs_release_version"
echo "qfs_source_revision = $qfs_source_revision"
echo "hadoop_qfs_profile  = $hadoop_qfs_profile"

if [ x"$hadoop_qfs_profile" = x'none' ]; then
    echo "Running: mvn -Dqfs.release.version=$qfs_release_version -Dqfs.source.revision=$qfs_source_revision --projects qfs-access package"
    mvn -Dqfs.release.version=$qfs_release_version -Dqfs.source.revision=$qfs_source_revision --projects qfs-access package
else
    echo "Running: mvn -P $hadoop_qfs_profile -Dqfs.release.version=$qfs_release_version -Dqfs.source.revision=$qfs_source_revision -Dhadoop.release.version=$1 package"
    mvn -P $hadoop_qfs_profile -Dqfs.release.version=$qfs_release_version -Dqfs.source.revision=$qfs_source_revision -Dhadoop.release.version=$1 package
fi 
