include(ExternalProject)
message(STATUS "Configuring zlib...")

set(ZLIB_INSTALL_DIR ${CMAKE_BINARY_DIR}/zlib-install)
set(ZLIB_HEADERS ${ZLIB_INSTALL_DIR}/include)
set(ZLIB_LIBRARY_DIR ${ZLIB_INSTALL_DIR}/lib)
set(ZLIB_LIBRARY ${ZLIB_LIBRARY_DIR}/libz.a)

if (NOT TARGET zlib::static)
    add_library(zlib::static STATIC IMPORTED GLOBAL)
    set_target_properties(zlib::static
            PROPERTIES
            IMPORTED_LOCATION ${ZLIB_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${ZLIB_HEADERS}
            CONSUMER_CFLAGS "-I${ZLIB_HEADERS}"
            CONSUMER_LDFLAGS "-L${ZLIB_LIBRARY_DIR} -lz"
    )
endif()

register_dependency(
    zlib
    "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz"
    "9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"
    "LICENSE"
)

ExternalProject_Add(zlib
    URL ${DEP_zlib_URL}
    URL_HASH SHA256=${DEP_zlib_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_zlib_FILENAME}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${ZLIB_INSTALL_DIR} --static
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    BUILD_IN_SOURCE 1
)

add_dependencies(zlib::static zlib)
message(STATUS "zlib configuration completed")
