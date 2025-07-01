include(ExternalProject)
message(STATUS "Configuring libnftnl...")

set(LIBNFTNL_INSTALL_DIR ${CMAKE_BINARY_DIR}/libnftnl-install)
set(LIBNFTNL_HEADERS ${LIBNFTNL_INSTALL_DIR}/include)
set(LIBNFTNL_LIBRARY_DIR ${LIBNFTNL_INSTALL_DIR}/lib)
set(LIBNFTNL_LIBRARY ${LIBNFTNL_LIBRARY_DIR}/libnftnl.a)

if (NOT TARGET libnftnl::static)
    add_library(libnftnl::static STATIC IMPORTED GLOBAL)
    set_target_properties(libnftnl::static
        PROPERTIES
        IMPORTED_LOCATION ${LIBNFTNL_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES ${LIBNFTNL_HEADERS}
        CONSUMER_CFLAGS "-I${LIBNFTNL_HEADERS}"
        CONSUMER_LDFLAGS "-L${LIBNFTNL_LIBRARY_DIR} -lnftnl"
    )
    message(STATUS "libnftnl::static target created. Install dir: ${LIBNFTNL_INSTALL_DIR}")
endif()

register_dependency(
    libnftnl
    "https://netfilter.org/projects/libnftnl/files/libnftnl-1.2.9.tar.xz"
    "e8c216255e129f26270639fee7775265665a31b11aa920253c3e5d5d62dfc4b8"
    "COPYING"
)

ExternalProject_Add(libnftnl
    URL ${DEP_libnftnl_URL}
    URL_HASH SHA256=${DEP_libnftnl_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_libnftnl_FILENAME}
    CONFIGURE_COMMAND autoreconf -fiv && ${CMAKE_COMMAND} -E env
        "LIBMNL_CFLAGS=$<TARGET_PROPERTY:libmnl::static,CONSUMER_CFLAGS>"
        "LIBMNL_LIBS=$<TARGET_PROPERTY:libmnl::static,CONSUMER_LDFLAGS>"
        <SOURCE_DIR>/configure 
        --prefix=${LIBNFTNL_INSTALL_DIR} 
        --enable-static=yes 
        --disable-shared
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    DEPENDS libmnl::static
    BUILD_IN_SOURCE 1
)

add_dependencies(libnftnl::static libnftnl)
message(STATUS "libnftnl configuration completed")
