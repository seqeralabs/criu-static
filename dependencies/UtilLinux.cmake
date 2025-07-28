# util-linux is a kernel project that is the home of many libraries.
# We only provide libuuid from there but keeping the generic name
# in case we need to reference more dependencies in the future.
include(ExternalProject)
message(STATUS "Configuring util-linux...")

set(UTIL_LINUX_INSTALL_DIR ${CMAKE_BINARY_DIR}/util-linux-install)
set(UTIL_LINUX_HEADERS ${UTIL_LINUX_INSTALL_DIR}/include)
set(UTIL_LINUX_LIBRARY_DIR ${UTIL_LINUX_INSTALL_DIR}/lib)
set(UTIL_LINUX_UUID_LIBRARY ${UTIL_LINUX_LIBRARY_DIR}/libuuid.a)

if (NOT TARGET uuid::static)
    add_library(uuid::static STATIC IMPORTED GLOBAL)
    set_target_properties(uuid::static
            PROPERTIES
            IMPORTED_LOCATION ${UTIL_LINUX_UUID_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${UTIL_LINUX_HEADERS}
            CONSUMER_CFLAGS "-I${UTIL_LINUX_HEADERS}"
            CONSUMER_LDFLAGS "-L${UTIL_LINUX_LIBRARY_DIR} -luuid"
    )
endif()

register_dependency(
    util_linux
    "https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/snapshot/util-linux-2.41.1.tar.gz"
    "61a9785cbf04091286ec2bbfb78e87c35e6380f084f38115a4677b90b9ad4437"
    "COPYING"
)

ExternalProject_Add(util_linux
    URL ${DEP_util_linux_URL}
    URL_HASH SHA256=${DEP_util_linux_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_util_linux_FILENAME}
    UPDATE_COMMAND ${CMAKE_COMMAND} -E env
        sh -c "if [ ! -f <SOURCE_DIR>/configure ]; then cd <SOURCE_DIR> && chmod +x autogen.sh && ./autogen.sh || { echo 'autogen.sh failed for util-linux'; exit 1; }; fi"
    CONFIGURE_COMMAND <SOURCE_DIR>/configure
        --enable-static
        --disable-shared
        --prefix=${UTIL_LINUX_INSTALL_DIR}
        --disable-all-programs
        --enable-libuuid
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    BUILD_IN_SOURCE 1
)

add_dependencies(uuid::static util_linux)
message(STATUS "util-linux configuration completed")
