# Bitrix24 Dark Theme

Dark theme for desktop Bitrix24 chat and task interfaces, based on [skomaroh/bitrix24-dark-chat](https://github.com/skomaroh/bitrix24-dark-chat).

## Choose a version

- `default/user_style.css`: dark theme with project containers hidden in the main and compact recent-chat lists.
- `hide-project-chats/user_style.css`: only hide project containers, with no dark theme or color changes. Suitable for the light theme.

Install one version using the steps below. To keep an existing custom stylesheet, append the hide-only file instead of replacing existing rules.

This is visual filtering, not disabling project chats. Messages, membership, notifications and aggregate unread totals remain unchanged. The dedicated project section and individual task chats are not hidden. Requires CSS `:has()` support in the desktop application's embedded browser.

## Install

1. Back up your current `user_style.css`.
2. Download `user_style.css` from the chosen version folder.
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
