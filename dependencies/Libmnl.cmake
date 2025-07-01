include(ExternalProject)
message(STATUS "Configuring libmnl...")

set(LIBMNL_INSTALL_DIR ${CMAKE_BINARY_DIR}/libmnl-install)
set(LIBMNL_HEADERS ${LIBMNL_INSTALL_DIR}/include)
set(LIBMNL_LIBRARY_DIR ${LIBMNL_INSTALL_DIR}/lib)
set(LIBMNL_LIBRARY ${LIBMNL_LIBRARY_DIR}/libmnl.a)

if (NOT TARGET libmnl::static)
    add_library(libmnl::static STATIC IMPORTED GLOBAL)
    set_target_properties(libmnl::static
            PROPERTIES
            IMPORTED_LOCATION ${LIBMNL_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${LIBMNL_HEADERS}
            CONSUMER_CFLAGS "-I${LIBMNL_HEADERS}"
            CONSUMER_LDFLAGS "-L${LIBMNL_LIBRARY_DIR} -lmnl"
    )
    message(STATUS "libmnl::static target created. Install dir: ${LIBMNL_INSTALL_DIR}")
endif()

register_dependency(
    libmnl
    "https://netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2"
    "274b9b919ef3152bfb3da3a13c950dd60d6e2bcd54230ffeca298d03b40d0525"
    "COPYING"
)

ExternalProject_Add(libmnl
    URL ${DEP_libmnl_URL}
    URL_HASH SHA256=${DEP_libmnl_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_libmnl_FILENAME}
    CONFIGURE_COMMAND autoreconf -fiv && ./configure --prefix=${LIBMNL_INSTALL_DIR} --enable-static=yes --disable-shared
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    BUILD_IN_SOURCE 1
)

add_dependencies(libmnl::static libmnl)
message(STATUS "libmnl configuration completed")
