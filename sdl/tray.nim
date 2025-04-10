import std/options, bitgen, common
from properties import PropertiesId
from surface    import Surface

type TrayEntryFlag* = distinct uint32
TrayEntryFlag.gen_bit_ops(
    TrayButton, TrayCheckbox, TraySubmenu, _,
    _, _, _, _,
    _, _, _, _,
    _, _, _, _,
    _, _, _, _,
    _, _, _, _,
    _, _, _, _,
    _, _, TrayChecked, TrayDisabled,
)

type
    Tray*      = distinct pointer
    TrayMenu*  = distinct pointer
    TrayEntry* = distinct pointer

    TrayCallback* = proc(user_data: pointer; entry: TrayEntry) {.cdecl.}

    TrayEntryView* = object
        entries*: ptr UncheckedArray[TrayEntry]
        len*    : int32

proc SDL_DestroyTray*(tray: Tray) {.importc, cdecl, dynlib: SdlLib.}
proc `=destroy`*(tray: Tray) =
    SDL_DestroyTray tray

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_CreateTray*(icon: Surface; tooltip: cstring): Tray
proc SDL_SetTrayIcon*(tray: Tray; icon: Surface)
proc SDL_SetTrayTooltip*(tray: Tray; tooltip: cstring)
proc SDL_CreateTrayMenu*(tray: Tray): TrayMenu
proc SDL_CreateTraySubmenu*(entry: TrayEntry): TrayMenu
proc SDL_GetTrayMenu*(tray: Tray): TrayMenu
proc SDL_GetTraySubmenu*(entry: TrayEntry): TrayMenu
proc SDL_GetTrayEntries*(menu: TrayMenu; cnt: ptr cint): ptr UncheckedArray[TrayEntry]
proc SDL_RemoveTrayEntry*(entry: TrayEntry)
proc SDL_InsertTrayEntryAt*(menu: TrayMenu; pos: cint; label: cstring; flags: TrayEntryFlag): TrayEntry
proc SDL_SetTrayEntryLabel*(entry: TrayEntry; label: cstring)
proc SDL_GetTrayEntryLabel*(entry: TrayEntry): cstring
proc SDL_SetTrayEntryChecked*(entry: TrayEntry; checked: bool)
proc SDL_GetTrayEntryChecked*(entry: TrayEntry): bool
proc SDL_SetTrayEntryEnabled*(entry: TrayEntry; enabled: bool)
proc SDL_GetTrayEntryEnabled*(entry: TrayEntry): bool
proc SDL_SetTrayEntryCallback*(entry: TrayEntry; cb: TrayCallback; user_data: pointer)
proc SDL_ClickTrayEntry*(entry: TrayEntry)
proc SDL_GetTrayEntryParent*(entry: TrayEntry): TrayMenu
proc SDL_GetTrayMenuParentEntry*(menu: TrayMenu): TrayEntry
proc SDL_GetTrayMenuParentTray*(menu: TrayMenu): Tray
proc SDL_UpdateTrays*()
{.pop.}

{.push inline.}

proc create_tray*(icon: Option[Surface]; tooltip: string): Tray =
    let icon    = if icon.is_some: get icon else: Surface nil
    let tooltip = if tooltip.len > 0: cstring tooltip else: cstring nil
    SDL_CreateTray icon, tooltip

proc set_icon*(tray: Tray; icon: Option[Surface]) =
    let icon = if icon.is_some: get icon else: Surface nil
    SDL_SetTrayIcon tray, icon
proc `icon=`*(tray: Tray; icon: Option[Surface]) = set_icon tray, icon

proc set_tooltip*(tray: Tray; tooltip: string) =
    let tooltip = if tooltip.len > 0: cstring tooltip else: cstring nil
    SDL_SetTrayTooltip tray, tooltip
proc `tooltip=`*(tray: Tray; tooltip: string) = set_tooltip tray, tooltip

proc create_menu*(tray: Tray): TrayMenu          = SDL_CreateTrayMenu tray
proc create_submenu*(entry: TrayEntry): TrayMenu = SDL_CreateTraySubmenu entry

proc menu*(tray: Tray): TrayMenu          = SDL_GetTrayMenu tray
proc submenu*(entry: TrayEntry): TrayMenu = SDL_GetTraySubmenu entry

proc entries*(menu: TrayMenu): TrayEntryView =
    result.entries = SDL_GetTrayEntries(menu, result.len.addr)

proc remove*(entry: TrayEntry) =
    SDL_RemoveTrayEntry entry

proc insert*(menu: TrayMenu; label: string; pos: SomeInteger = -1; flags: TrayEntryFlag = TrayButton): TrayEntry =
    let label = if label.len > 0: cstring label else: cstring nil
    result = SDL_InsertTrayEntryAt(menu, cint pos, label, flags)
    sdl_assert result, &"Failed to insert item '{label}' into tray menu at position {pos} (flags: {flags})"

proc set_label*(entry: TrayEntry; label: string) =
    let label = if label.len > 0: cstring label else: cstring nil
    SDL_SetTrayEntryLabel entry, label
proc `label=`*(entry: TrayEntry; label: string) = set_label entry, label

proc set_checked*(entry: TrayEntry; checked: bool) =
    SDL_SetTrayEntryChecked entry, checked
proc `checked=`*(entry: TrayEntry; checked: bool) = set_checked entry, checked

proc set_enabled*(entry: TrayEntry; enabled: bool) =
    SDL_SetTrayEntryEnabled entry, enabled
proc `enabled=`*(entry: TrayEntry; enabled: bool) = set_enabled entry, enabled

proc set_callback*(entry: TrayEntry; cb: TrayCallback; user_data: pointer = nil) =
    SDL_SetTrayEntryCallback entry, cb, user_data
proc `callback=`*(entry: TrayEntry; cb: TrayCallback) = set_callback entry, cb

proc label*(entry: TrayEntry): string    = $SDL_GetTrayEntryLabel(entry)
proc is_checked*(entry: TrayEntry): bool = SDL_GetTrayEntryChecked entry
proc is_enabled*(entry: TrayEntry): bool = SDL_GetTrayEntryEnabled entry

proc click*(entry: TrayEntry) =
    SDL_ClickTrayEntry entry

proc update_trays*() =
    SDL_UpdateTrays()

proc parent*(entry: TrayEntry): TrayMenu      = SDL_GetTrayEntryParent entry
proc parent_entry*(menu: TrayMenu): TrayEntry = SDL_GetTrayMenuParentEntry menu
proc parent_tray*(menu: TrayMenu): Tray       = SDL_GetTrayMenuParentTray menu

{.pop.}
