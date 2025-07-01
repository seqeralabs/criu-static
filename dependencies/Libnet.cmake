include(ExternalProject)
message(STATUS "Configuring libnet...")

set(LIBNET_INSTALL_DIR ${CMAKE_BINARY_DIR}/libnet-install)
set(LIBNET_HEADERS ${LIBNET_INSTALL_DIR}/include)
set(LIBNET_LIBRARY_DIR ${LIBNET_INSTALL_DIR}/lib)
set(LIBNET_LIBRARY ${LIBNET_LIBRARY_DIR}/libnet.a)

if (NOT TARGET libnet::static)
add_library(libnet::static STATIC IMPORTED GLOBAL)
set_target_properties(libnet::static
        PROPERTIES
        IMPORTED_LOCATION ${LIBNET_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES ${LIBNET_HEADERS}
        CONSUMER_CFLAGS "-I${LIBNET_HEADERS} -D_BSD_SOURCE -D_DEFAULT_SOURCE -DHAVE_NET_ETHERNET_H"
        CONSUMER_LDFLAGS "-L${LIBNET_LIBRARY_DIR} -lnet"
)
endif()

register_dependency(
    libnet
    "https://github.com/libnet/libnet/archive/refs/tags/v1.3.tar.gz"
    "44e28a4e5a9256ce74d96fd1ad8ac2e3f300f55dc70c93bb81851183a21d7d3a"
    "LICENSE"
)

ExternalProject_Add(libnet
    URL ${DEP_libnet_URL}
    URL_HASH SHA256=${DEP_libnet_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_libnet_FILENAME}
    CONFIGURE_COMMAND autoreconf -fiv && <SOURCE_DIR>/configure --prefix=${LIBNET_INSTALL_DIR} --enable-static=yes --disable-shared
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    BUILD_IN_SOURCE 1
)
add_dependencies(libnet::static libnet)
message(STATUS "libnet configuration completed")
