include(ExternalProject)
message(STATUS "Configuring libnl...")

set(LIBNL_INSTALL_DIR ${CMAKE_BINARY_DIR}/libnl-install)
set(LIBNL_HEADERS ${LIBNL_INSTALL_DIR}/include)
set(LIBNL_LIBRARY_DIR ${LIBNL_INSTALL_DIR}/lib)
set(LIBNL_LIBRARY ${LIBNL_LIBRARY_DIR}/libnl-3.a)

if (NOT TARGET libnl::static)
    add_library(libnl::static STATIC IMPORTED GLOBAL)
    set_target_properties(libnl::static
        PROPERTIES
        IMPORTED_LOCATION ${LIBNL_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES ${LIBNL_HEADERS}
        CONSUMER_CFLAGS "-I${LIBNL_HEADERS} -I${LIBNL_HEADERS}/libnl3"
        CONSUMER_LDFLAGS "-L${LIBNL_LIBRARY_DIR} -lnl-3"
    )
    message(STATUS "libnl::static target created. Install dir: ${LIBNL_INSTALL_DIR}")
endif()

register_dependency(
    libnl
    "https://github.com/thom311/libnl/releases/download/libnl3_9_0/libnl-3.9.0.tar.gz"
    "aed507004d728a5cf11eab48ca4bf9e6e1874444e33939b9d3dfed25018ee9bb"
    "COPYING"
)

ExternalProject_Add(libnl
    URL ${DEP_libnl_URL}
    URL_HASH SHA256=${DEP_libnl_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_libnl_FILENAME}
    UPDATE_COMMAND sh -c "test -f <SOURCE_DIR>/configure || <SOURCE_DIR>/autogen.sh"
    CONFIGURE_COMMAND <SOURCE_DIR>/configure 
        --prefix=${LIBNL_INSTALL_DIR} 
        --enable-static=yes 
        --disable-shared
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    BUILD_IN_SOURCE 1
)

add_dependencies(libnl::static libnl)
message(STATUS "libnl configuration completed")
