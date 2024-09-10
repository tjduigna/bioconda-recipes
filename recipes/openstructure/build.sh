#!/bin/bash

export PLATFORM_EXT=so
if [[ "${OSTYPE}" == "darwin"* ]]; then
    export PLATFORM_EXT=dylib
fi

sed -i.tmp 's/lib64/lib/g' cmake_support/OST.cmake
sed -i.tmp 's/"@Python_EXECUTABLE@"/`which python`/' scripts/ost_config.in

cmake -Bbuild -G "${CMAKE_GENERATOR}" \
    -DOPTIMIZE=ON \
    -DPREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DENABLE_MM=OFF \
    -DCOMPILE_TMTOOLS=1 \
    -DENABLE_GFX=OFF \
    -DENABLE_GUI=OFF \
    -DENABLE_INFO=OFF \
    -DENABLE_STATIC=ON \
    -DCMAKE_CXX_COMPILER_VERSION="11.4.0" \
    -DPython_EXECUTABLE="${BUILD_PREFIX}/bin/python" \
    -DBOOST_NO_BOOST_CMAKE=TRUE \
    -DBOOST_ROOT:PATHNAME="${BUILD_PREFIX}/lib" \
    -DBoost_LIBRARY_DIRS:FILEPATH="${BUILD_PREFIX}/lib" \
    -DPYTHON_ROOT="${BUILD_PREFIX}/lib" \
    -DPYTHON_LIBRARIES="${BUILD_PREFIX}/lib/libpython${PY_VER}.${PLATFORM_EXT}" \
    -DSYS_ROOT="${BUILD_PREFIX}"
cmake --build build --target install -j 8
wget ftp://ftp.wwpdb.org/pub/pdb/data/monomers/components.cif.gz
${SRC_DIR}/build/stage/bin/chemdict_tool create ${SRC_DIR}/components.cif.gz compounds.chemlib pdb
${SRC_DIR}/build/stage/bin/chemdict_tool update ${SRC_DIR}/modules/conop/data/charmm.cif compounds.chemlib charmm
cmake -Bbuild -G "${CMAKE_GENERATOR}" -DCOMPOUND_LIB=${SRC_DIR}/compounds.chemlib
cmake --build build --target install -j 8
