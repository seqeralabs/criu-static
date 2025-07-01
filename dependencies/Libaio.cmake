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
    "https://pagure.io/libaio/archive/libaio-0.3.113/libaio-libaio-0.3.113.tar.gz"
    "716c7059703247344eb066b54ecbc3ca2134f0103307192e6c2b7dab5f9528ab"
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
