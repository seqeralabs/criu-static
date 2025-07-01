include(ExternalProject)
message(STATUS "Configuring libintl...")

set(LIBINTL_INSTALL_DIR ${CMAKE_BINARY_DIR}/libintl-install)
set(LIBINTL_HEADERS ${LIBINTL_INSTALL_DIR}/include)
set(LIBINTL_LIBRARY_DIR ${LIBINTL_INSTALL_DIR}/lib)
set(LIBINTL_LIBRARY ${LIBINTL_LIBRARY_DIR}/libintl.a)

if (NOT TARGET libintl::static)
    add_library(libintl::static STATIC IMPORTED GLOBAL)
    set_target_properties(libintl::static
        PROPERTIES
        IMPORTED_LOCATION ${LIBINTL_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES ${LIBINTL_HEADERS}
        CONSUMER_CFLAGS "-I${LIBINTL_HEADERS}"
        CONSUMER_LDFLAGS "-L${LIBINTL_LIBRARY_DIR} -lintl"
    )
    message(STATUS "libintl::static target created. Install dir: ${LIBINTL_INSTALL_DIR}")
endif()

register_dependency(
    gettext
    "https://ftp.gnu.org/gnu/gettext/gettext-0.24.1.tar.xz"
    "6164ec7aa61653ac9cdfb41d5c2344563b21f707da1562712e48715f1d2052a6"
    "gettext-runtime/COPYING"
)

ExternalProject_Add(gettext
    URL ${DEP_gettext_URL}
    URL_HASH SHA256=${DEP_gettext_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_gettext_FILENAME}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure 
        --prefix=${LIBINTL_INSTALL_DIR} 
        --disable-shared 
        --enable-static 
        --disable-java
        --disable-csharp
        --disable-c++
        --disable-tools
        --without-emacs
        --without-git
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -C gettext-runtime/intl -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} -C gettext-runtime/intl install
    BUILD_IN_SOURCE 1
)

add_dependencies(libintl::static gettext)
message(STATUS "libintl configuration completed")
