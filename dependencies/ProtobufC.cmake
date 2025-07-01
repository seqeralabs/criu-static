include(ExternalProject)
message(STATUS "Configuring protobuf-c...")

set(PROTOBUF_C_INSTALL_DIR ${CMAKE_BINARY_DIR}/protobuf-c-install)
set(PROTOBUF_C_LIBRARY_DIR ${PROTOBUF_C_INSTALL_DIR}/lib)
set(PROTOBUF_C_HEADERS_DIR ${PROTOBUF_C_INSTALL_DIR}/include)
set(PROTOBUF_C_LIBRARY_FILE ${PROTOBUF_C_LIBRARY_DIR}/libprotobuf-c.a)
set(PROTOBUF_PROTOC_C_PATH ${PROTOBUF_C_INSTALL_DIR}/bin)

if (NOT TARGET protobuf-c::static)
    add_library(protobuf-c::static STATIC IMPORTED GLOBAL)
    set_target_properties(protobuf-c::static
        PROPERTIES
        IMPORTED_LOCATION ${PROTOBUF_C_LIBRARY_FILE}
        INTERFACE_INCLUDE_DIRECTORIES ${PROTOBUF_C_HEADERS_DIR}
        INTERFACE_LINK_LIBRARIES protobuf::static
        CONSUMER_CFLAGS "-I${PROTOBUF_C_HEADERS_DIR}"
        CONSUMER_LDFLAGS "-L${PROTOBUF_C_LIBRARY_DIR} -lprotobuf-c"
        CONSUMER_PROTOC_C_PATH ${PROTOBUF_PROTOC_C_PATH}
        CONSUMER_HEADER_DIR ${PROTOBUF_C_HEADERS_DIR}
    )
endif()

install(FILES ${PROTOBUF_C_LIBRARY_FILE} DESTINATION lib)

register_dependency(
    protobuf-c
    "https://github.com/protobuf-c/protobuf-c/releases/download/v1.5.2/protobuf-c-1.5.2.tar.gz"
    "e2c86271873a79c92b58fef7ebf8de1aa0df4738347a8bd5d4e65a80a16d0d24"
    "LICENSE"
)

ExternalProject_Add(protobuf-c
    URL ${DEP_protobuf-c_URL}
    URL_HASH SHA256=${DEP_protobuf-c_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_protobuf-c_FILENAME}
    UPDATE_COMMAND sh -c "test -f <SOURCE_DIR>/configure || <SOURCE_DIR>/autogen.sh"
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env
        "protobuf_CFLAGS=$<TARGET_PROPERTY:protobuf::static,CONSUMER_CFLAGS>"
        "protobuf_LIBS=$<TARGET_PROPERTY:protobuf::static,CONSUMER_LDFLAGS>"
        "PROTOC=$<TARGET_PROPERTY:protobuf::static,CONSUMER_PROTOC_PATH>/protoc"
        <SOURCE_DIR>/configure
        --prefix=${PROTOBUF_C_INSTALL_DIR}
        --enable-static
        --disable-shared
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    DEPENDS protobuf::static
    BUILD_IN_SOURCE 1
)

add_dependencies(protobuf-c::static protobuf-c)
message(STATUS "protobuf-c configuration completed")
