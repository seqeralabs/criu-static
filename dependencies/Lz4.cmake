include(ExternalProject)
message(STATUS "Configuring lz4...")

set(LZ4_INSTALL_DIR ${CMAKE_BINARY_DIR}/lz4-install)
set(LZ4_HEADERS_DIR ${LZ4_INSTALL_DIR}/include)
set(LZ4_LIBRARY_DIR ${LZ4_INSTALL_DIR}/lib)
set(LZ4_LIBRARY ${LZ4_LIBRARY_DIR}/liblz4.a)

set(LZ4_MAKE_VARS
        "PREFIX=${LZ4_INSTALL_DIR}"
        "BUILD_SHARED=no"
)

if (NOT TARGET lz4::static)
    add_library(lz4::static STATIC IMPORTED GLOBAL)
    set_target_properties(lz4::static PROPERTIES
            IMPORTED_LOCATION ${LZ4_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${LZ4_HEADERS_DIR}
            CONSUMER_CFLAGS "-I${LZ4_HEADERS_DIR}"
            CONSUMER_LDFLAGS "-L${LZ4_LIBRARY_DIR} -llz4"
    )
    message(STATUS "lz4::static target created. Install dir: ${LZ4_INSTALL_DIR}")
endif()

register_dependency(
    lz4
    "https://github.com/lz4/lz4/releases/download/v1.10.0/lz4-1.10.0.tar.gz"
    "537512904744b35e232912055ccf8ec66d768639ff3abe5788d90d792ec5f48b"
    "lib/LICENSE"
)

ExternalProject_Add(lz4
    URL ${DEP_lz4_URL}
    URL_HASH SHA256=${DEP_lz4_SHA256}
    UPDATE_DISCONNECTED 1
    CONFIGURE_COMMAND ""
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_lz4_FILENAME}
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -C lib -j${CMAKE_BUILD_PARALLEL_LEVEL} ${LZ4_MAKE_VARS} liblz4.a
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} -C lib ${LZ4_MAKE_VARS} install
    BUILD_IN_SOURCE 1
)

add_dependencies(lz4::static lz4)
message(STATUS "lz4 configuration completed")
