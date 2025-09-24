cmake_minimum_required(VERSION 3.28)

project(criu-static VERSION 4.1)
include(GNUInstallDirs)
include(macros/dependencies.cmake)

# CRIU source configuration, specify either version or commit
set(CRIU_VERSION "${PROJECT_VERSION}" CACHE STRING "CRIU version to build (e.g., 4.1)")
set(CRIU_COMMIT "" CACHE STRING "CRIU git commit/tag to build instead of version")
set(CRIU_SHASUM "9a3094f3d0aa6cfa8bd5c9b92c05f4a566ad21ee20eb9b2fbc6129a74d1f6dc7" CACHE STRING "SHA256 checksum for CRIU source")

# Force static building
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries" FORCE)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")

set(ENV{CC} ${CMAKE_C_COMPILER})
set(ENV{CXX} ${CMAKE_CXX_COMPILER})

set(SOURCE_DOWNLOADS_DIR ${CMAKE_BINARY_DIR}/downloads)

# Dependencies
include(FetchContent)
include(ExternalProject)
include(dependencies/Zlib.cmake)
include(dependencies/Libnl.cmake)
include(dependencies/Libnet.cmake)
include(dependencies/Libcap.cmake)
include(dependencies/Libaio.cmake)
include(dependencies/Protobuf.cmake)
include(dependencies/ProtobufC.cmake)
include(dependencies/Libmnl.cmake)
include(dependencies/Libnftnl.cmake)
include(dependencies/Libnftables.cmake)
include(dependencies/UtilLinux.cmake)
include(dependencies/Libintl.cmake)

# Get all dependency flags
get_target_property(PROTOBUF_C_CFLAGS protobuf-c::static CONSUMER_CFLAGS)
get_target_property(PROTOBUF_C_LDFLAGS protobuf-c::static CONSUMER_LDFLAGS)
get_target_property(PROTOBUF_C_HEADER_DIR protobuf-c::static CONSUMER_HEADER_DIR)
get_target_property(PROTOC_C_BIN_PATH protobuf-c::static CONSUMER_PROTOC_C_PATH)
get_target_property(PROTOBUF_CFLAGS protobuf::static CONSUMER_CFLAGS)
get_target_property(PROTOBUF_LDFLAGS protobuf::static CONSUMER_LDFLAGS)
get_target_property(DESCRIPTOR_PROTO_FILE protobuf::static CONSUMER_DESCRIPTOR_PROTO_FILE)
get_target_property(PROTOC_BIN_PATH protobuf::static CONSUMER_PROTOC_PATH)
get_target_property(LIBNET_CFLAGS libnet::static CONSUMER_CFLAGS)
get_target_property(LIBNET_LDFLAGS libnet::static CONSUMER_LDFLAGS)
get_target_property(LIBNL_CFLAGS libnl::static CONSUMER_CFLAGS)
get_target_property(LIBNL_LDFLAGS libnl::static CONSUMER_LDFLAGS)
get_target_property(LIBCAP_CFLAGS libcap::static CONSUMER_CFLAGS)
get_target_property(LIBCAP_LDFLAGS libcap::static CONSUMER_LDFLAGS)
get_target_property(LIBAIO_CFLAGS libaio::static CONSUMER_CFLAGS)
get_target_property(LIBAIO_LDFLAGS libaio::static CONSUMER_LDFLAGS)
get_target_property(ZLIB_CFLAGS zlib::static CONSUMER_CFLAGS)
get_target_property(ZLIB_LDFLAGS zlib::static CONSUMER_LDFLAGS)
get_target_property(LIBMNL_CFLAGS libmnl::static CONSUMER_CFLAGS)
get_target_property(LIBMNL_LDFLAGS libmnl::static CONSUMER_LDFLAGS)
get_target_property(LIBNFTNL_CFLAGS libnftnl::static CONSUMER_CFLAGS)
get_target_property(LIBNFTNL_LDFLAGS libnftnl::static CONSUMER_LDFLAGS)
get_target_property(LIBNFTABLES_CFLAGS libnftables::static CONSUMER_CFLAGS)
get_target_property(LIBNFTABLES_LDFLAGS libnftables::static CONSUMER_LDFLAGS)
get_target_property(LIBUUID_CFLAGS uuid::static CONSUMER_CFLAGS)
get_target_property(LIBUUID_LDFLAGS uuid::static CONSUMER_LDFLAGS)
get_target_property(LIBINTL_CFLAGS libintl::static CONSUMER_CFLAGS)
get_target_property(LIBINTL_LDFLAGS libintl::static CONSUMER_LDFLAGS)

# Prepare CRIU build flags
set(CRIU_FEATURE_DEFINES "-DCONFIG_HAS_NFTABLES_LIB_API_1")
set(CRIU_CFLAGS "${PROTOBUF_C_CFLAGS} ${CRIU_FEATURE_DEFINES} ${PROTOBUF_CFLAGS} ${LIBNET_CFLAGS} ${LIBNL_CFLAGS} ${LIBCAP_CFLAGS} ${LIBAIO_CFLAGS} ${ZLIB_CFLAGS} ${LIBNFTABLES_CFLAGS} ${LIBNFTNL_CFLAGS} ${LIBMNL_CFLAGS} ${LIBUUID_CFLAGS} ${LIBINTL_CFLAGS}")
set(CRIU_LDFLAGS "-static ${PROTOBUF_C_LDFLAGS} ${PROTOBUF_LDFLAGS} ${LIBNET_LDFLAGS} ${LIBNL_LDFLAGS} ${LIBCAP_LDFLAGS} ${LIBAIO_LDFLAGS} ${ZLIB_LDFLAGS} ${LIBNFTABLES_LDFLAGS} ${LIBNFTNL_LDFLAGS} ${LIBMNL_LDFLAGS} ${LIBUUID_LDFLAGS} ${LIBINTL_LDFLAGS}")
set(CRIU_MAKE_PATH_ENV "${PROTOC_BIN_PATH}:${PROTOC_C_BIN_PATH}:$ENV{PATH}")
message("-- criu CFLAGS ${CRIU_CFLAGS}")
message("-- criu LDFLAGS ${CRIU_LDFLAGS}")
message("-- criu PATH ${CRIU_MAKE_PATH_ENV}")

# CRIU build directories
set(CRIU_BUILD_DIR ${CMAKE_BINARY_DIR}/criu-build)
set(CRIU_INSTALL_DIR ${CMAKE_BINARY_DIR}/criu-install)


set(CRIU_MAKE_VARS
        "PREFIX=${CRIU_INSTALL_DIR}"
)

# Build CRIU URL based on commit or version
if(CRIU_COMMIT)
    set(CRIU_URL "https://github.com/checkpoint-restore/criu/archive/${CRIU_COMMIT}.tar.gz")
else()
    set(CRIU_URL "https://github.com/checkpoint-restore/criu/archive/refs/tags/v${CRIU_VERSION}.tar.gz")
endif()

register_dependency(
    criu
    "${CRIU_URL}"
    "${CRIU_SHASUM}"
    "COPYING"
)

ExternalProject_Add(criu
        URL ${DEP_criu_URL}
        URL_HASH SHA256=${DEP_criu_SHA256}
        UPDATE_DISCONNECTED 1
        PATCH_COMMAND patch -p1 -i ${CMAKE_SOURCE_DIR}/patch/criu-build.patch && patch -p1 -i ${CMAKE_SOURCE_DIR}/patch/criu-static-plugin.patch
        CONFIGURE_COMMAND ""
        DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
        DOWNLOAD_NAME ${DEP_criu_FILENAME}
        BUILD_COMMAND 
            ${CMAKE_MAKE_PROGRAM} -C <SOURCE_DIR> ${CRIU_MAKE_VARS} mrproper
            COMMAND ${CMAKE_COMMAND} -E rm -f "<SOURCE_DIR>/images/google/protobuf/descriptor.proto"
            COMMAND ${CMAKE_COMMAND} -E copy "${DESCRIPTOR_PROTO_FILE}" "<SOURCE_DIR>/images/google/protobuf/descriptor.proto"
            COMMAND ${CMAKE_COMMAND} -E env
                "CFLAGS=${CRIU_CFLAGS}"
                "LDFLAGS=${CRIU_LDFLAGS}"
                "CC=${CMAKE_C_COMPILER}"
                "PATH=${CRIU_MAKE_PATH_ENV}"
                "CUDA_PLUGIN_LIBCAP_CFLAGS=${LIBCAP_CFLAGS}"
                 "SKIP_PIP_INSTALL=1"
                ${CMAKE_MAKE_PROGRAM} -C <SOURCE_DIR> ${CRIU_MAKE_VARS} -j${CMAKE_BUILD_PARALLEL_LEVEL}
                CONFIG_AMDGPU=n
                STATIC_PLUGINS=y
                lib/c/built-in.o
                criu
                cuda_plugin
        INSTALL_COMMAND
            ${CMAKE_COMMAND} -E make_directory ${CRIU_INSTALL_DIR}/lib
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CRIU_INSTALL_DIR}/bin
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/lib/c/built-in.o ${CRIU_INSTALL_DIR}/lib/libcriu.o
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/lib/c/criu.h ${CRIU_INSTALL_DIR}/include/criu/criu.h
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/criu/include/version.h ${CRIU_INSTALL_DIR}/include/criu/version.h
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/images/rpc.pb-c.h ${CRIU_INSTALL_DIR}/include/criu/rpc.pb-c.h
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/criu/criu ${CRIU_INSTALL_DIR}/bin/criu
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/plugins/cuda/cuda_plugin.so ${CRIU_INSTALL_DIR}/lib/criu/cuda_plugin.so
        BINARY_DIR ${CRIU_BUILD_DIR}
        DEPENDS protobuf::static protobuf-c::static libnet::static libnl::static libcap::static libaio::static zlib::static libmnl::static libnftnl::static libnftables::static uuid::static libintl::static
)

install(FILES ${CRIU_INSTALL_DIR}/lib/libcriu.o DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(PROGRAMS ${CRIU_INSTALL_DIR}/bin/criu DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY ${CRIU_INSTALL_DIR}/include/criu DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(FILES ${CRIU_INSTALL_DIR}/lib/criu/cuda_plugin.so DESTINATION ${CMAKE_INSTALL_LIBDIR}/criu)

install(DIRECTORY ${PROTOBUF_C_HEADER_DIR}/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

message(STATUS "CRIU configuration completed")

# Install
install(FILES CMakeLists.txt CMakePresets.json DESTINATION ${CMAKE_INSTALL_DOCDIR})

install(DIRECTORY patch/ DESTINATION ${CMAKE_INSTALL_DOCDIR}/patch)
install(DIRECTORY macros/ DESTINATION ${CMAKE_INSTALL_DOCDIR}/macros)
install(DIRECTORY dependencies/ DESTINATION ${CMAKE_INSTALL_DOCDIR}/dependencies)
install(FILES CMakePresets.json package_deps_licenses.cmake.in DESTINATION ${CMAKE_INSTALL_DOCDIR})

include(check_musl.cmake)
fetch_musl_license_if_needed()

if(REGISTERED_DEPENDENCIES)
    list(REMOVE_DUPLICATES REGISTERED_DEPENDENCIES)

    set(CONSOLIDATED_LICENSE_FILE "${CMAKE_BINARY_DIR}/THIRD-PARTY-LICENSES.txt")

    configure_file(
        "${CMAKE_SOURCE_DIR}/package_deps_licenses.cmake.in"
        "${CMAKE_BINARY_DIR}/package_deps_licenses.cmake"
        @ONLY
    )

    install(SCRIPT "${CMAKE_BINARY_DIR}/package_deps_licenses.cmake")
    install(
        DIRECTORY "${SOURCE_DOWNLOADS_DIR}/"
        DESTINATION "${CMAKE_INSTALL_DOCDIR}/third_party/sources"
    )
    install(FILES "${CONSOLIDATED_LICENSE_FILE}" DESTINATION "${CMAKE_INSTALL_DOCDIR}/third_party")

    message(STATUS "Dependency download script configured for installation.")
endif()

# Detect target architecture
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
    set(TARGET_ARCH "arm64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
    set(TARGET_ARCH "amd64")
else()
    set(TARGET_ARCH "${CMAKE_SYSTEM_PROCESSOR}")
endif()

# Package
set(CPACK_PACKAGE_NAME "criu-static")
set(CPACK_PACKAGE_VERSION "${CRIU_VERSION}")
set(CPACK_PACKAGE_VENDOR "The CRIU Authors")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Static build of CRIU (Checkpoint/Restore In Userspace)")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/COPYING")
set(CPACK_SOURCE_GENERATOR "TGZ;STGZ")
set(CPACK_GENERATOR "TGZ;STGZ")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-linux-${TARGET_ARCH}")
set(CPACK_SOURCE_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-source")
include(CPack)
