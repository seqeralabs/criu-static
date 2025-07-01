include(ExternalProject)
message(STATUS "Configuring libnftables...")

set(LIBNFTABLES_INSTALL_DIR ${CMAKE_BINARY_DIR}/libnftables-install)
set(LIBNFTABLES_HEADERS ${LIBNFTABLES_INSTALL_DIR}/include)
set(LIBNFTABLES_LIBRARY_DIR ${LIBNFTABLES_INSTALL_DIR}/lib)
set(LIBNFTABLES_LIBRARY ${LIBNFTABLES_LIBRARY_DIR}/libnftables.a)

if (NOT TARGET libnftables::static)
    add_library(libnftables::static STATIC IMPORTED GLOBAL)
    set_target_properties(libnftables::static
            PROPERTIES
            IMPORTED_LOCATION ${LIBNFTABLES_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${LIBNFTABLES_HEADERS}
            CONSUMER_CFLAGS "-I${LIBNFTABLES_HEADERS}"
            CONSUMER_LDFLAGS "-L${LIBNFTABLES_LIBRARY_DIR} -lnftables"
    )
    message(STATUS "libnftables::static target created. Install dir: ${LIBNFTABLES_INSTALL_DIR}")
endif()

register_dependency(
    libnftables
    "https://netfilter.org/projects/nftables/files/nftables-1.1.3.tar.xz"
    "9c8a64b59c90b0825e540a9b8fcb9d2d942c636f81ba50199f068fde44f34ed8"
    "COPYING"
)

ExternalProject_Add(libnftables
    URL ${DEP_libnftables_URL}
    URL_HASH SHA256=${DEP_libnftables_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_libnftables_FILENAME}
    CONFIGURE_COMMAND autoreconf -fiv && ${CMAKE_COMMAND} -E env
                      "LIBMNL_CFLAGS=$<TARGET_PROPERTY:libmnl::static,CONSUMER_CFLAGS>"
                      "LIBMNL_LIBS=$<TARGET_PROPERTY:libmnl::static,CONSUMER_LDFLAGS>"
                      "LIBNFTNL_CFLAGS=$<TARGET_PROPERTY:libnftnl::static,CONSUMER_CFLAGS>"
                      "LIBNFTNL_LIBS=$<TARGET_PROPERTY:libnftnl::static,CONSUMER_LDFLAGS>"
                      <SOURCE_DIR>/configure --prefix=${LIBNFTABLES_INSTALL_DIR} --enable-static=yes --disable-shared --disable-man-doc --with-mini-gmp --without-cli
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    DEPENDS libmnl::static libnftnl::static
    BUILD_IN_SOURCE 1
)

add_dependencies(libnftables::static libnftables)
message(STATUS "libnftables configuration completed")
