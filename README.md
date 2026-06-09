# NSPanel Dashboard

A modern, touch-friendly dashboard for Home Assistant designed for NSPanel displays (480x480).

## Features

- 🎨 Beautiful gradient design with Inter font
- 📱 Swipeable pages (4 entities per page)
- 🌡️ Temperature controls for climate entities
- 🎵 Media player controls with Google Assistant voice commands
- 🔄 Real-time state updates
- 🌙 Screensaver mode with clock and temperature
- ⚙️ **Centralized configuration** - Configure once, access anywhere
- 🎯 Material Symbols icons for all entity types

## Storage

**All configuration is stored server-side** in Docker volumes:

- `global_config.json` - Home Assistant URL and token
- `room_configs.json` - All room configurations
- `active_room.txt` - Currently selected room per device

**Benefits:**
- ✅ Configure once on any device
- ✅ Access from any browser/device
- ✅ Survives browser cache clears
- ✅ Persistent across container restarts
- ✅ Easy to backup (just backup the Docker volume)

**Backup your config:**
```bash
docker cp nspanel-dashboard:/data ./backup
```

**Restore config:**
```bash
docker cp ./backup/. nspanel-dashboard:/data
```

## Quick Start

1. **First time setup** - Build and start the container:
   ```bash
   docker-compose up -d --build
   ```

   > **Important:** The container proxies requests to Home Assistant and needs the
   > `HA_URL` environment variable set in `docker-compose.yml`. It **must** include
   > the scheme (`http://` or `https://`), for example:
   > ```yaml
   > environment:
   >   - HA_URL=http://homeassistant.local:8123
   > ```
   > If `HA_URL` is missing or has no scheme, nginx fails to start with
   > `invalid URL prefix in /etc/nginx/nginx.conf`.

2. **Access the dashboard**:
   - HTTP: `http://your-server-ip:8080`
   - HTTPS: `https://your-server-ip:8443` (for voice messages)

3. **Configure**:
   - Tap the room name to open settings
   - Enter your Home Assistant URL and long-lived access token
   - Add your entities
   - Save settings

## Fully Kiosk Browser Setup

For NSPanel devices running Fully Kiosk Browser:

### Basic Setup
1. Set URL to `https://your-server-ip:8443`
2. Enable kiosk mode

### SSL Certificate (Required for Voice Messages)
Since the dashboard uses a self-signed certificate, you need to configure Fully Kiosk to accept it:

1. **Open Fully Kiosk Settings** (3-finger tap or web interface at `http://panel-ip:2323`)
2. Go to **Settings** → **Web Content Settings** → **Advanced Web Settings**
3. Enable these options:
   - ✅ **Ignore SSL Errors**
   - ✅ **Allow Mixed Content**
4. **Restart Fully Kiosk**

### Voice Message Support (Optional)
To enable microphone access for voice messages:

1. In **Settings** → **Web Content Settings** → **Advanced Web Settings**
2. Enable:
   - ✅ **Allow Microphone Access**
   - ✅ **Enable getUserMedia**
   - ✅ **Allow Camera Access** (sometimes required)
3. **Restart Fully Kiosk**

**Note:** Some NSPanel hardware may not have an accessible microphone. In this case, you can still receive voice messages from other devices, but cannot record them on the panel.

## Development

The project is now split into separate files for easy editing:

- `index.html` - HTML structure
- `styles.css` - All styling
- `app.js` - All JavaScript logic

### Making Changes

Thanks to volume mounts in docker-compose.yml, you can edit these files and **just refresh your browser** - no rebuild needed!

1. Edit `styles.css`, `app.js`, or `index.html`
2. Save the file
3. Refresh your browser (Ctrl+F5 for hard refresh)

### When to Rebuild

You only need to rebuild the container if you change:
- `Dockerfile`
- `nginx.conf.template`
- `docker-entrypoint.sh`
- `docker-compose.yml`

Rebuild command:
```bash
docker-compose up -d --build
```

## File Structure

```
.
├── index.html              # Main HTML file
├── styles.css              # All CSS styles
├── app.js                  # All JavaScript
├── docker-compose.yml      # Docker Compose configuration
├── Dockerfile              # Docker image definition
├── nginx.conf.template     # Nginx configuration template
├── docker-entrypoint.sh    # Container startup script
└── nspanel-dashboard.html  # Legacy single-file version (can be deleted)
```

## Configuration

### Initial Setup

On first launch, you'll be guided through:

1. **Global Settings** - Configure once for all rooms:
   - Home Assistant URL
   - Long-lived access token

2. **Room Configuration** - Create room profiles:
   - Room name
   - Temperature entity (optional)
   - Entities to display

### Multi-Room Deployment

The dashboard now supports multiple room configurations:

1. **Configure all rooms once** - Create room profiles for each location
2. **Select room per panel** - Each NSPanel picks its room from the list
3. **Shared credentials** - All rooms use the same HA URL and token

**Workflow:**
```
1. First panel: Configure global settings + create all room profiles
2. Additional panels: Just select the room from the dropdown
```

**Storage:**
- Global settings (HA URL, token): Shared across all rooms
- Room configs: Stored as a list you can select from
- Active room: Each browser/panel remembers its selected room

### Managing Rooms

Access settings by tapping the room name, then:

- **Select Room** - Switch to a different room configuration
- **New Room** - Create a new room profile
- **Edit Current** - Modify the active room's settings
- **Delete** - Remove a room profile
- **Global Settings** - Update HA URL or token

### Default Entities

Edit `app.js` and modify the `DEFAULT_ROOM_CONFIG` object:

```javascript
const DEFAULT_ROOM_CONFIG = {
    roomName: 'Living Room',
    headerTempEntity: '',
    entities: [
        { id: 'light.living_room', label: 'Living Room' },
        // Add more entities here
    ]
};
```

### Supported Entity Types

- `light.*` - Lights with toggle
- `switch.*` - Switches with toggle
- `scene.*` - Scenes (turn on only)
- `script.*` - Scripts (turn on only)
- `climate.*` - Thermostats with temperature controls
- `sensor.*` - Read-only sensors with unit display
- `media_player.*` - Media players with play/pause/skip controls
  - Tap to play/pause
  - Use prev/play/next buttons
  - **Long press (800ms)** to send voice commands to Google Assistant
- `fan.*`, `cover.*`, `lock.*` - With appropriate icons

### Media Player Voice Commands

Long press on a media player tile to send commands to Google Assistant:

**Examples:**
- "Play jazz music"
- "Play Spotify playlist chill vibes"
- "Set volume to 50%"
- "Stop"
- "Next song"

**Requirements:**
- Home Assistant with [Google Assistant SDK](https://www.home-assistant.io/integrations/google_assistant_sdk/) integration configured
- Or falls back to TTS if SDK not available

**How it works:**
1. Long press (hold for 800ms) on a media player tile
2. Enter your command in the dialog
3. Command is sent via `notify.google_assistant_sdk` service
4. Google Assistant executes the command on the speaker

### Screensaver

- Activates after 60 seconds of inactivity
- Shows time, date, room name, and temperature
- Tap anywhere to exit

## Customization

### Change Colors

Edit `styles.css` and modify the gradient colors:

```css
body {
    background: linear-gradient(135deg, #0f0f0f 0%, #1a1a1a 100%);
}
```

### Change Screensaver Timeout

Edit `app.js`:

```javascript
const SCREENSAVER_TIMEOUT = 60000; // milliseconds
```

### Entities Per Page

Edit `app.js`:

```javascript
const ENTITIES_PER_PAGE = 4; // Change to 6 or 8 for more tiles
```

## Troubleshooting

### Dashboard not loading
- Check that the container is running: `docker ps`
- Check logs: `docker logs nspanel-dashboard`

### Can't connect to Home Assistant
- Verify your HA URL is correct (include http:// or https://)
- Check that your long-lived access token is valid
- Ensure nginx can reach your HA instance

### Changes not appearing
- Hard refresh your browser (Ctrl+F5)
- Check file permissions on mounted volumes
- Verify files are saved correctly

### Lost room configuration
- Room configs are stored server-side in `/data` directory
- Backup with: `docker cp nspanel-dashboard:/data ./backup`
- Restore with: `docker cp ./backup/. nspanel-dashboard:/data`
- Configs persist across browser sessions and devices

### Room not showing in dropdown
- Make sure you saved the room after creating it
- Check browser console for errors
- Try refreshing the page

## License

MIT
