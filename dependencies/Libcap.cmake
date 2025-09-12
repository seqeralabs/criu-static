include(ExternalProject)
message(STATUS "Configuring libcap...")

set(LIBCAP_INSTALL_DIR ${CMAKE_BINARY_DIR}/libcap-install)
set(LIBCAP_HEADERS ${LIBCAP_INSTALL_DIR}/include)
set(LIBCAP_LIBRARY_DIR ${LIBCAP_INSTALL_DIR}/lib)
set(LIBCAP_LIBRARY ${LIBCAP_LIBRARY_DIR}/libcap.a)
set(LIBCAP_PKGCONFIG_DIR ${LIBCAP_INSTALL_DIR}/lib/pkgconfig)

set(LIBCAP_MAKE_VARS
        "lib=lib"
        "prefix=${LIBCAP_INSTALL_DIR}"
        "CC=${CMAKE_C_COMPILER}"
        "SHARED=no"
)

if (NOT TARGET libcap::static)
    add_library(libcap::static STATIC IMPORTED GLOBAL)
    set_target_properties(libcap::static
            PROPERTIES
            IMPORTED_LOCATION ${LIBCAP_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${LIBCAP_HEADERS}
            CONSUMER_CFLAGS "-I${LIBCAP_HEADERS}"
            CONSUMER_LDFLAGS "-L${LIBCAP_LIBRARY_DIR} -lcap"
    )
endif()

register_dependency(
    libcap
    "https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.70.tar.gz"
    "d3b777ed413c9fafface03b917e171854709b5e4be38dbfb9219aaf7dfd4eea6"
    "License"
)

ExternalProject_Add(libcap
    URL ${DEP_libcap_URL}
    URL_HASH SHA256=${DEP_libcap_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_libcap_FILENAME}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND sh -c "${CMAKE_MAKE_PROGRAM} -C <SOURCE_DIR>/libcap -j${CMAKE_BUILD_PARALLEL_LEVEL} ${LIBCAP_MAKE_VARS} || ${CMAKE_MAKE_PROGRAM} -C <SOURCE_DIR>/libcap ${LIBCAP_MAKE_VARS}"
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} -C <SOURCE_DIR>/libcap ${LIBCAP_MAKE_VARS} install
    BUILD_IN_SOURCE 1
)

add_dependencies(libcap::static libcap)
message(STATUS "libcap configuration completed")
