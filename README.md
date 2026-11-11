# Bitrix24 Dark Theme

Dark theme for desktop Bitrix24 chat and task interfaces, based on [skomaroh/bitrix24-dark-chat](https://github.com/skomaroh/bitrix24-dark-chat).

## Install

1. Back up your current `user_style.css`.
2. Download `default/user_style.css` from this repository.
3. Open the application's user-data folder with `Ctrl+Shift+L` (macOS: `Cmd+Shift+L`).
4. Replace `user_style.css` in that folder.
5. Reload the app window with `Ctrl+R`.

The usual Windows path is `%APPDATA%\Bitrix\Desktop\3.0`. Corporate builds may use a different folder: use the folder opened by the app.

## Changes

- Search, forwarding, unread counters and profile-menu contrast.
- Task forms, action menus, descriptions, checklists and attachment previews.
- Compact message and attachment-caption composers.
- The applications-panel button in the composer is hidden.
- Kanban cards retain their original appearance; deadline chips use native Bitrix designs.

## Compatibility

Selectors were checked against local `im 26.1300.0` and `tasks 26.900.0` sources. Compatibility with every cloud or on-premise release is not guaranteed. Some screens were checked through user feedback; a full visual regression was not performed.

## Update and rollback

Back up your current stylesheet before replacing it. To roll back, restore that backup and reload the app. Git history also contains previous revisions.

## License

Apache-2.0. See the original LICENSE and the attribution in NOTICE.
