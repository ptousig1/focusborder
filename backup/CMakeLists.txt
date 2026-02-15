#######################################
# Effect

set(focusborder_SOURCES
    focusborder.cpp
    plugin.cpp
)

kwin_add_builtin_effect(focusborder ${focusborder_SOURCES})

target_link_libraries(focusborder PRIVATE
    kwin
)
