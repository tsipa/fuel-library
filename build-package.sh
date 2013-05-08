#!/bin/bash
set -e

if [ $# == 0 ]; then

  echo "Usage: $0 <tag-or-branch> [package-suffix]"
  echo "Available branches from git:"
  for line in `git branch -r`; do echo "  * $line (run \"$0 $line\")"; done
  echo 
  echo "Available tags from git:"
  for line in `git tag -l`; do echo "  * $line (run \"$0 $line\")"; done
  echo "In order to create a new release tag, use:"
  echo "  * git tag -a <release-tag> -m \"message\""
  echo "  * git push --tags"
  exit

fi

# determine release tag
tag="$1"
if [ $# == 1 ]; then
  pkgSuffix=$(echo $tag|sed -e 's/.*\///g')
else
  pkgSuffix="$2"
fi
cur_dir=$(pwd)
build_dir="fuel-$pkgSuffix"

# create directory
rm -rf $build_dir
mkdir $build_dir

# checkout fuel into it
git clone git@github.com:Mirantis/fuel.git $build_dir
cd $build_dir
git checkout -f $tag

# capture commit id
commit=`git rev-parse HEAD`

# remove git tracking
rm -rf `find . -name ".git*"`

# generate release version
echo $tag > release.version
echo $commit > release.commit

# build documentation
cd docs
make html
cd ..

# copy it to the new directory
rm -rf documentation
mkdir documentation
cp -R docs/_build/html/* documentation/

# create archive
cd $cur_dir
tar -czf ${build_dir}.tar.gz "$build_dir/deployment/" "$build_dir/documentation/" "$build_dir/release.commit" "$build_dir/release.version"

cd $build_dir
if [ -d iso ]; then
  cd iso

  make iso
  cp build/iso/*.iso $cur_dir
fi

cd $cur_dir
# remove build directory
rm -rf $build_dir

