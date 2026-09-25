include(ExternalProject)
message(STATUS "Configuring libaio...")

set(LIBAIO_INSTALL_DIR ${CMAKE_BINARY_DIR}/libaio-install)
set(LIBAIO_HEADERS_DIR ${LIBAIO_INSTALL_DIR}/include)
set(LIBAIO_LIBRARY_DIR ${LIBAIO_INSTALL_DIR}/lib)
set(LIBAIO_LIBRARY ${LIBAIO_LIBRARY_DIR}/libaio.a)

set(LIBAIO_MAKE_VARS
        "prefix=${LIBAIO_INSTALL_DIR}"
        "ENABLE_SHARED=0"
)

if (NOT TARGET libaio::static)
    add_library(libaio::static STATIC IMPORTED GLOBAL)
    set_target_properties(libaio::static PROPERTIES
            IMPORTED_LOCATION ${LIBAIO_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${LIBAIO_HEADERS_DIR}
            CONSUMER_CFLAGS "-I${LIBAIO_HEADERS_DIR}"
            CONSUMER_LDFLAGS "-L${LIBAIO_LIBRARY_DIR} -laio"
    )
    message(STATUS "libaio::static target created. Install dir: ${LIBAIO_INSTALL_DIR}")
endif()

register_dependency(
    libaio
    "https://releases.pagure.org/libaio/libaio-0.3.113.tar.gz"
    "2c44d1c5fd0d43752287c9ae1eb9c023f04ef848ea8d4aafa46e9aedb678200b"
    "COPYING"
)

ExternalProject_Add(libaio
    URL ${DEP_libaio_URL}
    URL_HASH SHA256=${DEP_libaio_SHA256}
    UPDATE_DISCONNECTED 1
    CONFIGURE_COMMAND ""
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_libaio_FILENAME}
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL} ${LIBAIO_MAKE_VARS}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} ${LIBAIO_MAKE_VARS} install
    BUILD_IN_SOURCE 1
)

add_dependencies(libaio::static libaio)
message(STATUS "libaio configuration completed")
